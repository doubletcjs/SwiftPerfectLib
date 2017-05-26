//
//  MoodOperator.swift
//  SwiftPerfectDemo
//
//  Created by macjs on 17/5/26.
//
//

import Foundation

class MoodBaseOperator: BaseOperator {
    //MARK: 内部接口
    
    private let moodTableName = "Mood"
    private let userTableName = "User"
    private let collectionTableName = "Collection"
    
    //MARK: 外部接口
    
    /// 添加心情
    ///
    /// - Parameters:
    ///   - videoItem: 视频信息 JSON
    ///   - status: 状态 0 正常 1 回收站 2 待清理
    ///   - imageItems: 图片数组信息 JSON
    ///   - content: 内容
    ///   - collectionObjectId: 所属分类id
    ///   - authorObjectId: 作者id
    /// - Returns: 返回JSON数据
    func createMoodOperator(videoItem: String, status: Int, imageItems: String, content: String, collectionObjectId: String, authorObjectId: String) -> String? {
        let dateString = UtilsBase().getCurrentDate()
        
        let values = "('\(videoItem)', ('\(status)'), ('\(imageItems)'), ('\(content)'), ('\(collectionObjectId)'), ('\(authorObjectId)'), ('\(dateString!)'), ('\(dateString!)'))"
        let insertStatement = "insert into \(moodTableName) (videoItem, status, imageItems, content, collectionMood, authorMood, createdAt, updateAt) values \(values)"
        
        if !mysql.query(statement: insertStatement) {
            print("/****\n\(mysql.errorMessage())\n****/")
            responseJson = UtilsBase().createFailureJsonLog(message: "添加失败")
        } else {
            responseJson = UtilsBase().createSuccessJsonLog(jsonObject: "添加成功")
            
            if !mysql.query(statement: "select @@IDENTITY") {
                print("/****\n\(mysql.errorMessage())\n****/")
            } else {
                let results = mysql.storeResults()!
                
                if results.numRows() == 0 {
                    
                } else {
                    var dict = [String: AnyObject]()
                    results.forEachRow { row in
                        dict["objectId"] = row[0] as AnyObject
                    }
                    
                    dict["videoItem"] = videoItem as AnyObject
                    dict["status"] = Int(status) as AnyObject
                    dict["imageItems"] = imageItems as AnyObject
                    dict["content"] = content as AnyObject
                    dict["collectionMood"] = collectionObjectId as AnyObject
                    dict["authorMood"] = authorObjectId as AnyObject
                    dict["createdAt"] = dateString as AnyObject
                    dict["updateAt"] = dateString as AnyObject
                    
                    let authorInfo = UtilsBase().jsonToDictionary(text: UserBaseOperator().getUserInfo(username: "", objectId: authorObjectId)!)!
                    dict["author"] = authorInfo[ResultObjectKey] as AnyObject
                    
                    let collectionInfo = UtilsBase().jsonToDictionary(text: CollectionBaseOperator().readSingleCollectionOperator(collectionObjectId: collectionObjectId)!)!
                    dict["collection"] = collectionInfo[ResultObjectKey] as AnyObject
                    
                    dict["likeCount"] = 0 as AnyObject
                    dict["commentCount"] = 0 as AnyObject
                    dict["isLiked"] = false as AnyObject
                    
                    responseJson = UtilsBase().createSuccessJsonLog(jsonObject: dict)
                }
            }
        }
        
        return responseJson
    }
    
    /// 编辑心情
    ///
    /// - Parameters:
    ///   - moodObjectId: 分类id
    ///   - videoItem: 视频信息 JSON
    ///   - imageItems: 图片数组信息 JSON
    ///   - content: 内容
    ///   - status: 状态 0 正常 1 回收站 2 待清理
    /// - Returns: 返回JSON数据
    func editMoodOperator(moodObjectId: String, videoItem: String?, imageItems: String?, content: String?, status: Int) -> String? {
        let statement = "select objectId, videoItem, imageItems, content, status, collectionMood, authorMood, createdAt, updateAt from \(moodTableName) where objectId = '\(moodObjectId)'"
        if !mysql.query(statement: statement) {
            print("/****\n\(mysql.errorMessage())\n****/")
            responseJson = UtilsBase().createFailureJsonLog(message: "更新心情失败")
        } else {
            let results = mysql.storeResults()!
            var dict = [String: AnyObject]()
            
            if results.numRows() == 0 {
                responseJson = UtilsBase().createFailureJsonLog(message: "心情不存在")
            } else {
                results.forEachRow { row in
                    dict["objectId"] = row[0] as AnyObject
                    dict["videoItem"] = row[1] as AnyObject
                    dict["imageItems"] = row[2] as AnyObject
                    dict["content"] = row[3] as AnyObject
                    dict["status"] = Int(row[4]!) as AnyObject
                    dict["collectionMood"] = row[5] as AnyObject
                    dict["authorMood"] = row[6] as AnyObject
                    dict["createdAt"] = row[7] as AnyObject
                    dict["updateAt"] = row[8] as AnyObject
                }
                
                let authorInfo = UtilsBase().jsonToDictionary(text: UserBaseOperator().getUserInfo(username: "", objectId: dict["authorMood"] as! String)!)!
                dict["author"] = authorInfo[ResultObjectKey] as AnyObject
                
                let collectionInfo = UtilsBase().jsonToDictionary(text: CollectionBaseOperator().readSingleCollectionOperator(collectionObjectId: dict["collectionMood"] as! String)!)!
                dict["collection"] = collectionInfo[ResultObjectKey] as AnyObject
                
                dict["commentCount"] = Int(MoodCommentBaseOperator().commentCountOperator(targetObjectId: dict["objectId"] as! String)) as AnyObject
                dict["isLiked"] = false as AnyObject
                dict["likeCount"] = Int(LikeRecordBaseOperator().likeCountOperator(targetObjectId: dict["objectId"] as! String, likeType: 0)) as AnyObject
                
                var updateSQL = ""
                var updateSQLs = [String]()
                
                if videoItem != nil && dict["videoItem"] as? String != videoItem {
                    updateSQLs.append("videoItem = '\(videoItem!)'")
                    
                    dict["videoItem"] = videoItem as AnyObject
                }
                
                if imageItems != nil && dict["imageItems"] as? String != imageItems {
                    updateSQLs.append("bgUrl = '\(imageItems!)'")
                    
                    dict["imageItems"] = imageItems as AnyObject
                }
                
                if content != nil && dict["content"] as? String != content {
                    updateSQLs.append("content = '\(content)'")
                    
                    dict["content"] = content as AnyObject
                }
                
                if status >= 0 && dict["status"] as? Int != status {
                    updateSQLs.append("status = '\(status)'")
                    
                    dict["status"] = status as AnyObject
                }
                
                for sql in updateSQLs {
                    if updateSQL.characters.count == 0 {
                        updateSQL = sql
                    } else {
                        updateSQL = "\(updateSQL), \(sql)"
                    }
                }
                
                if updateSQL.characters.count > 0 {
                    let dateString = UtilsBase().getCurrentDate()
                    let updateStatement = "update \(userTableName) set \(updateSQL), updateAt = '\(dateString!)' where objectId = '\(moodObjectId)'"
                    
                    if !mysql.query(statement: updateStatement) {
                        print("/****\n\(mysql.errorMessage())\n****/")
                        responseJson = UtilsBase().createFailureJsonLog(message: "心情更新失败")
                    } else {
                        dict["updateAt"] = dateString as AnyObject
                        responseJson = UtilsBase().createSuccessJsonLog(jsonObject: dict)
                    }
                } else {
                    responseJson = UtilsBase().createSuccessJsonLog(jsonObject: "没有需要更新的内容")
                }
            }
        }
        
        return responseJson
    }
    
    /// 分类心情列表
    ///
    /// - Parameters:
    ///   - loginObjectId: 当前登录用户id
    ///   - collectionObjectId: 分类id
    /// - Returns: 返回JSON数据
    func readCollectionMoodOperator(loginObjectId: String, collectionObjectId: String, currentPage: Int, pageSize: Int) -> String? {
        let baseStatement = "select collection.objectId, collection.title, collection.bgUrl, collection.introduction, collection.tags, collection.status, collection.lastStatus, collection.createStatus, collection.authorCollection, collection.createdAt, collection.updateAt, user.objectId, user.portrait, user.homeBG, user.mobilePhoneNumber, user.gender, user.username, user.signature, user.email, user.createdAt, user.updateAt, mood.objectId, mood.videoItem, mood.imageItems, mood.content, mood.status, mood.collectionMood, mood.authorMood, mood.createdAt, mood.updateAt from \(moodTableName) mood, \(collectionTableName) collection, \(userTableName) user where (collection.objectId = mood.collectionMood) and (user.objectId = mood.authorMood)"
        
        let statement = "\(baseStatement) and collectionMood = '\(collectionObjectId)' and mood.status = '\(0)' limit \(currentPage*pageSize), \(pageSize)"
        
        if !mysql.query(statement: statement) {
            print("/****\n\(mysql.errorMessage())\n****/")
            responseJson = UtilsBase().createFailureJsonLog(message: "分类心情列表获取失败")
        } else {
            let results = mysql.storeResults()!
            
            if results.numRows() == 0 {
                responseJson = UtilsBase().createFailureJsonLog(message: "分类心情列表为空")
            } else {
                var collectionList = [[String: AnyObject]]()
                
                results.forEachRow { row in
                    var dict = [String: AnyObject]()
                    
                    //分类信息
                    var collectionInfo = [String: AnyObject]()
                    collectionInfo["objectId"] = row[0] as AnyObject
                    collectionInfo["title"] = row[1] as AnyObject
                    collectionInfo["bgUrl"] = row[2] as AnyObject
                    collectionInfo["introduction"] = row[3] as AnyObject
                    collectionInfo["tags"] = row[4] as AnyObject
                    collectionInfo["status"] = Int(row[5]!) as AnyObject
                    collectionInfo["lastStatus"] = Int(row[6]!) as AnyObject
                    collectionInfo["createStatus"] = Int(row[7]!) as AnyObject
                    collectionInfo["authorCollection"] = row[8] as AnyObject
                    collectionInfo["createdAt"] = row[9] as AnyObject
                    collectionInfo["updateAt"] = row[10] as AnyObject
                    
                    //用户信息
                    var authorInfo = [String: AnyObject]()
                    authorInfo["objectId"] = row[11] as AnyObject
                    authorInfo["portrait"] = row[12] as AnyObject
                    authorInfo["homeBG"] = row[13] as AnyObject
                    authorInfo["mobile"] = row[14] as AnyObject
                    authorInfo["gender"] = Int(row[15]!) as AnyObject
                    authorInfo["username"] = row[16] as AnyObject
                    authorInfo["signature"] = row[17] as AnyObject
                    authorInfo["email"] = row[18] as AnyObject
                    authorInfo["createdAt"] = row[19] as AnyObject
                    authorInfo["updateAt"] = row[20] as AnyObject
                    
                    dict["objectId"] = row[21] as AnyObject
                    dict["videoItem"] = row[22] as AnyObject
                    dict["imageItems"] = row[23] as AnyObject
                    dict["content"] = row[24] as AnyObject
                    dict["status"] = Int(row[25]!) as AnyObject
                    dict["collectionMood"] = row[26] as AnyObject
                    dict["authorMood"] = row[27] as AnyObject
                    dict["createdAt"] = row[28] as AnyObject
                    dict["updateAt"] = row[29] as AnyObject
                    
                    dict["author"] = authorInfo as AnyObject
                    dict["collection"] = collectionInfo as AnyObject
                    
                    dict["likeCount"] = Int(LikeRecordBaseOperator().likeCountOperator(targetObjectId: dict["objectId"] as! String, likeType: 0)) as AnyObject
                    dict["commentCount"] = Int(MoodCommentBaseOperator().commentCountOperator(targetObjectId: dict["objectId"] as! String)) as AnyObject
                    
                    if loginObjectId.characters.count == 0 || loginObjectId == authorInfo["objectId"] as! String {
                        dict["isLiked"] = false as AnyObject
                    } else {
                        dict["isLiked"] = Bool(LikeRecordBaseOperator().isLikeOperator(targetObjectId: dict["objectId"] as! String, userObjectId: loginObjectId, likeType: 0)) as AnyObject
                    }
                    
                    collectionList.append(dict)
                }
                
                responseJson = UtilsBase().createSuccessJsonLog(jsonObject: collectionList)
            }
        }
        
        return responseJson
    }
    
    /// 心情详情
}
