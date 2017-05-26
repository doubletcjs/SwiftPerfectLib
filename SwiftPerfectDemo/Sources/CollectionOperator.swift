//
//  CollectionOperator.swift
//  SwiftPerfectDemo
//
//  Created by macjs on 17/5/26.
//
//

import Foundation

class CollectionBaseOperator: BaseOperator {
    //MARK: 内部接口
    
    private let collectionTableName = "Collection"
    private let userTableName = "User"
    
    /// 查看分类
    ///
    /// - Parameters:
    ///   - collectionObjectId: 分类id
    /// - Returns: 返回JSON数据
    func readSingleCollectionOperator(collectionObjectId: String) -> String? {
        let baseStatement = "select collection.objectId, collection.title, collection.bgUrl, collection.introduction, collection.tags, collection.status, collection.lastStatus, collection.createStatus, collection.authorCollection, collection.createdAt, collection.updateAt, user.objectId, user.portrait, user.homeBG, user.mobilePhoneNumber, user.gender, user.username, user.signature, user.email, user.createdAt, user.updateAt from \(collectionTableName) collection, \(userTableName) user where (user.objectId = collection.authorCollection)"
        let statement = "\(baseStatement) and collection.objectId = '\(collectionObjectId)'"
        
        if !mysql.query(statement: statement) {
            print("/****\n\(mysql.errorMessage())\n****/")
            responseJson = UtilsBase().createFailureJsonLog(message: "分类获取失败")
        } else {
            let results = mysql.storeResults()!
            
            if results.numRows() == 0 {
                responseJson = UtilsBase().createFailureJsonLog(message: "该分类不存在")
            } else {
                var dict = [String: AnyObject]()
                
                results.forEachRow { row in
                    dict["objectId"] = row[0] as AnyObject
                    dict["title"] = row[1] as AnyObject
                    dict["bgUrl"] = row[2] as AnyObject
                    dict["introduction"] = row[3] as AnyObject
                    dict["tags"] = row[4] as AnyObject
                    dict["status"] = Int(row[5]!) as AnyObject
                    dict["lastStatus"] = Int(row[6]!) as AnyObject
                    dict["createStatus"] = Int(row[7]!) as AnyObject
                    dict["authorCollection"] = row[8] as AnyObject
                    dict["createdAt"] = row[9] as AnyObject
                    dict["updateAt"] = row[10] as AnyObject
                    
                    //用户信息
                    var authorInfo = [String: AnyObject]()
                    authorInfo["objectId"] = row[11] as AnyObject
                    authorInfo["portrait"] = row[12] as AnyObject
                    authorInfo["homeBG"] = row[13] as AnyObject
                    authorInfo["mobile"] = row[14] as AnyObject
                    authorInfo["gender"] = Int(row[15]!) as AnyObject
                    authorInfo["username"] = row[16] as AnyObject
                    authorInfo["signature"] = row[17] as AnyObject
                    authorInfo["createdAt"] = row[18] as AnyObject
                    authorInfo["updateAt"] = row[19] as AnyObject
                    
                    dict["author"] = authorInfo as AnyObject
                    
                    dict["stalkerCount"] = Int(ReadRecordBaseOperator().getReadCount(targetObjectId: row[0]!, type: 0)) as AnyObject
                }
                
                responseJson = UtilsBase().createSuccessJsonLog(jsonObject: dict)
            }
        }
        
        return responseJson
    }
    
    //MARK: 外部接口
    
    /// 添加分类
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - bgUrl: 背景图片
    ///   - authorObjectId: 作者id
    ///   - introduction: 简介
    ///   - tags: 标签集合 JSON
    ///   - createStatus: // 0 用户创建 1 系统创建每日心情 2 系统创建我的秘密
    ///   - status: //状态 0 所有人可看 1 私密 2 回收站 3 待清理 <0~1>
    /// - Returns: 返回JSON数据
    func createCollectionOperator(title: String, bgUrl: String, authorObjectId: String, introduction: String, tags: String, createStatus: Int, status: Int) -> String? {
        let dateString = UtilsBase().getCurrentDate()
        
        let values = "('\(title)', ('\(bgUrl)'), ('\(authorObjectId)'), ('\(introduction)'), ('\(tags)'), ('\(createStatus)'), ('\(status)'), ('\(status)'), ('\(dateString!)'), ('\(dateString!)'))"
        let insertStatement = "insert into \(collectionTableName) (title, bgUrl, authorCollection, introduction, tags, createStatus, status, lastStatus, createdAt, updateAt) values \(values)"
        
        if !mysql.query(statement: insertStatement) {
            print("/****\n\(mysql.errorMessage())\n****/")
            responseJson = UtilsBase().createFailureJsonLog(message: "操作失败")
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
                        dict["title"] = title as AnyObject
                        dict["bgUrl"] = bgUrl as AnyObject
                        dict["authorCollection"] = authorObjectId as AnyObject
                        dict["introduction"] = introduction as AnyObject
                        dict["tags"] = tags as AnyObject
                        dict["status"] = Int(status) as AnyObject
                        dict["lastStatus"] = Int(status) as AnyObject
                        dict["createStatus"] = Int(createStatus) as AnyObject
                        dict["createdAt"] = dateString as AnyObject
                        dict["updateAt"] = dateString as AnyObject
                        
                        let authorInfo = UtilsBase().jsonToDictionary(text: UserBaseOperator().getUserInfo(username: "", objectId: authorObjectId)!)!
                        dict["author"] = authorInfo[ResultObjectKey] as AnyObject
                        
                        dict["stalkerCount"] = 0 as AnyObject
                        
                        responseJson = UtilsBase().createSuccessJsonLog(jsonObject: dict)
                    }
                }
            }
        }
        
        return responseJson
    }
    
    /// 更新分类信息
    ///
    /// - Parameters:
    ///   - collectionObjectId: 分类id
    ///   - title: 标题
    ///   - bgUrl: 背景图片
    ///   - introduction: 简介
    ///   - tags: 标签集合 JSON
    ///   - status: //状态 0 所有人可看 1 私密 2 回收站 3 待清理 <0~1>
    /// - Returns: 返回JSON数据
    func editCollectionOperator(collectionObjectId: String, title: String?, bgUrl: String?, introduction: String?, tags: String?, status: Int) -> String? {
        let statement = "select objectId, title, bgUrl, authorCollection, introduction, tags, status, lastStatus, createStatus, createdAt, updateAt from \(collectionTableName) where objectId = '\(collectionObjectId)'"
        if !mysql.query(statement: statement) {
            print("/****\n\(mysql.errorMessage())\n****/")
            responseJson = UtilsBase().createFailureJsonLog(message: "更新分类败")
        } else {
            let results = mysql.storeResults()!
            var dict = [String: AnyObject]()
            
            if results.numRows() == 0 {
                responseJson = UtilsBase().createFailureJsonLog(message: "分类不存在")
            } else {
                results.forEachRow { row in
                    dict["objectId"] = row[0] as AnyObject
                    dict["title"] = row[1] as AnyObject
                    dict["bgUrl"] = row[2] as AnyObject
                    dict["authorCollection"] = row[3] as AnyObject
                    dict["introduction"] = row[4] as AnyObject
                    dict["tags"] = row[5] as AnyObject
                    dict["status"] = Int(row[6]!) as AnyObject
                    dict["lastStatus"] = Int(row[7]!) as AnyObject
                    dict["createStatus"] = Int(row[8]!) as AnyObject
                    dict["createdAt"] = row[9] as AnyObject
                    dict["updateAt"] = row[10] as AnyObject
                }
                
                dict["stalkerCount"] = Int(ReadRecordBaseOperator().getReadCount(targetObjectId: dict["objectId"] as! String, type: 0)) as AnyObject
                
                var updateSQL = ""
                var updateSQLs = [String]()
                
                if title != nil && dict["title"] as? String != title {
                    updateSQLs.append("title = '\(title!)'")
                    
                    dict["title"] = title as AnyObject
                }
                
                if bgUrl != nil && dict["bgUrl"] as? String != bgUrl {
                    updateSQLs.append("bgUrl = '\(bgUrl!)'")
                    
                    dict["bgUrl"] = bgUrl as AnyObject
                }
                
                if introduction != nil && dict["introduction"] as? String != introduction {
                    updateSQLs.append("introduction = '\(introduction!)'")
                    
                    dict["introduction"] = introduction as AnyObject
                }
                
                if tags != nil && dict["tags"] as? String != tags {
                    updateSQLs.append("tags = '\(tags!)'")
                    
                    dict["tags"] = tags as AnyObject
                }
                
                if status >= 0 && dict["status"] as! Int != status {
                    updateSQLs.append("status = '\(status)'")
                    
                    dict["lastStatus"] = dict["status"] as AnyObject
                    dict["status"] = Int(status) as AnyObject
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
                    let updateStatement = "update \(userTableName) set \(updateSQL), updateAt = '\(dateString!)' where objectId = '\(collectionObjectId)'"
                    
                    if !mysql.query(statement: updateStatement) {
                        print("/****\n\(mysql.errorMessage())\n****/")
                        responseJson = UtilsBase().createFailureJsonLog(message: "分类更新失败")
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
    
    /// 查看用户创建分类
    ///
    /// - Parameters:
    ///   - userObjectId: 用户id
    ///   - loginObjectId: 当前登录用户id
    /// - Returns: 返回JSON数据
    func readCollectionOperator(loginObjectId: String, userObjectId: String, currentPage: Int, pageSize: Int) -> String? {
        var statement = ""
        
        let baseStatement = "select collection.objectId, collection.title, collection.bgUrl, collection.introduction, collection.tags, collection.status, collection.lastStatus, collection.createStatus, collection.authorCollection, collection.createdAt, collection.updateAt, user.objectId, user.portrait, user.homeBG, user.mobilePhoneNumber, user.gender, user.username, user.signature, user.email, user.createdAt, user.updateAt from \(collectionTableName) collection, \(userTableName) user where (user.objectId = collection.authorCollection)"
        
        if loginObjectId.characters.count == 0 {
            statement = "\(baseStatement) and authorCollection = '\(userObjectId)' and status = '\(0)' limit \(currentPage*pageSize), \(pageSize)"
        } else if loginObjectId == userObjectId {
            //当前登录用户查看本人的分类
            statement = "\(baseStatement) and authorCollection = '\(userObjectId)' and (status = '\(0)' or status = '\(1)') limit \(currentPage*pageSize), \(pageSize)"
        } else {
            statement = "\(baseStatement) and authorCollection = '\(userObjectId)' and status = '\(0)' limit \(currentPage*pageSize), \(pageSize)"
        }
        
        if !mysql.query(statement: statement) {
            print("/****\n\(mysql.errorMessage())\n****/")
            responseJson = UtilsBase().createFailureJsonLog(message: "分类获取失败")
        } else {
            let results = mysql.storeResults()!
            
            if results.numRows() == 0 {
                responseJson = UtilsBase().createFailureJsonLog(message: "该分类不存在")
            } else {
                var collectionList = [[String: AnyObject]]()
                
                results.forEachRow { row in
                    var dict = [String: AnyObject]()
                    dict["objectId"] = row[0] as AnyObject
                    dict["title"] = row[1] as AnyObject
                    dict["bgUrl"] = row[2] as AnyObject
                    dict["introduction"] = row[3] as AnyObject
                    dict["tags"] = row[4] as AnyObject
                    dict["status"] = Int(row[5]!) as AnyObject
                    dict["lastStatus"] = Int(row[6]!) as AnyObject
                    dict["createStatus"] = Int(row[7]!) as AnyObject
                    dict["authorCollection"] = row[8] as AnyObject
                    dict["createdAt"] = row[9] as AnyObject
                    dict["updateAt"] = row[10] as AnyObject
                    
                    //用户信息
                    var authorInfo = [String: AnyObject]()
                    authorInfo["objectId"] = row[11] as AnyObject
                    authorInfo["portrait"] = row[12] as AnyObject
                    authorInfo["homeBG"] = row[13] as AnyObject
                    authorInfo["mobile"] = row[14] as AnyObject
                    authorInfo["gender"] = Int(row[15]!) as AnyObject
                    authorInfo["username"] = row[16] as AnyObject
                    authorInfo["signature"] = row[17] as AnyObject
                    authorInfo["createdAt"] = row[18] as AnyObject
                    authorInfo["updateAt"] = row[19] as AnyObject
                    
                    dict["author"] = authorInfo as AnyObject
                    
                    dict["stalkerCount"] = Int(ReadRecordBaseOperator().getReadCount(targetObjectId: row[0]!, type: 0)) as AnyObject
                    
                    collectionList.append(dict)
                }
                
                responseJson = UtilsBase().createSuccessJsonLog(jsonObject: collectionList)
            }
        }
        
        return responseJson
    }
}
