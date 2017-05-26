//
//  MoodCommentOperator.swift
//  SwiftPerfectDemo
//
//  Created by macjs on 17/5/26.
//
//

import Foundation

class MoodCommentBaseOperator: BaseOperator {
    //MARK: 内部接口
    
    private let moodCommentTableName = "MoodComment"
    private let userTableName = "User"
    
    /// 评论回复数量
    ///
    /// - Parameters:
    ///   - superObjectId: 评论id
    ///   - type: 类型 0 心情评论 1 心情评论回复
    /// - Returns: Bool
    private func commentReplyCountOperator(superObjectId: String) -> Int {
        var commentCount: Int = 0
        
        let statement = "select count(objectId) from \(moodCommentTableName) where superTargetPointer = '\(superObjectId)' and type = '\(1)' and status = '\(0)'"
        
        if !mysql.query(statement: statement) {
            print("/****\n\(mysql.errorMessage())\n****/")
            commentCount = 0
        } else {
            let results = mysql.storeResults()!
            
            if results.numRows() == 0 {
                commentCount = 0
            } else {
                results.forEachRow { row in
                    commentCount = Int(row[0]!)!
                }
            }
        }
        
        return commentCount
    }
    
    //MARK: 外部接口
    
    /// 评论数量
    ///
    /// - Parameters:
    ///   - targetObjectId: 目标id
    ///   - type: 类型 0 心情评论 1 心情评论回复
    /// - Returns: Bool
    func commentCountOperator(targetObjectId: String) -> Int {
        var commentCount: Int = 0
        
        let statement = "select count(objectId) from \(moodCommentTableName) where targetPointer = '\(targetObjectId)' and status = '\(0)'"
        
        if !mysql.query(statement: statement) {
            print("/****\n\(mysql.errorMessage())\n****/")
            commentCount = 0
        } else {
            let results = mysql.storeResults()!
            
            if results.numRows() == 0 {
                commentCount = 0
            } else {
                results.forEachRow { row in
                    commentCount = Int(row[0]!)!
                }
            }
        }
        
        return commentCount
    }
    
    /// 添加评论、回复
    ///
    /// - Parameters:
    ///   - targetObjectId: 目标id
    ///   - superObjectId: 回复评论id
    ///   - userObjectId: 用户id
    ///   - content: 评论、回复内容
    ///   - type: 类型 0 心情评论 1 心情评论回复
    /// - Returns: 返回JSON数据
    func createCommentReplyOperator(targetObjectId: String, superObjectId: String, userObjectId: String, content: String, type: Int) -> String? {
        let dateString = UtilsBase().getCurrentDate()
        
        let values = "('\(targetObjectId)', '\(superObjectId)', '\(userObjectId)', '\(content)', '\(type)', '\(0)', ('\(dateString!)'), ('\(dateString!)'))"
        let insertStatement = "insert into \(moodCommentTableName) (targetPointer, superTargetPointer, authorComment, content, type, status, createdAt, updateAt) values \(values)"
        
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
                    
                    dict["targetPointer"] = targetObjectId as AnyObject
                    dict["superTargetPointer"] = superObjectId as AnyObject
                    dict["authorComment"] = userObjectId as AnyObject
                    dict["content"] = content as AnyObject
                    dict["type"] = Int(type) as AnyObject
                    dict["status"] = 0 as AnyObject
                    dict["createdAt"] = dateString as AnyObject
                    dict["updateAt"] = dateString as AnyObject
                    
                    if type == 0 {
                        dict["replyCount"] = 0 as AnyObject
                    }
                    let authorInfo = UtilsBase().jsonToDictionary(text: UserBaseOperator().getUserInfo(username: "", objectId: userObjectId)!)!
                    dict["author"] = authorInfo[ResultObjectKey] as AnyObject
                    
                    responseJson = UtilsBase().createSuccessJsonLog(jsonObject: dict)
                }
            }
        }
        
        return responseJson
    }
    
    /// 删除评论、回复
    ///
    /// - Parameters:
    ///   - objectId: id
    ///   - status: 0 正常 1 删除待清理
    /// - Returns: 返回JSON数据
    func deleteCommentOrReplyOperator(objectId: String, status: Int) -> String? {
        let dateString = UtilsBase().getCurrentDate()
        let updateStatement = "update \(moodCommentTableName) set status = '\(status)', updateAt = '\(dateString!)' where objectId = '\(objectId)'"
        
        if !mysql.query(statement: updateStatement) {
            print("/****\n\(mysql.errorMessage())\n****/")
            responseJson = UtilsBase().createFailureJsonLog(message: "删除失败")
        } else {
            responseJson = UtilsBase().createSuccessJsonLog(jsonObject: "删除成功")
        }
        
        return responseJson
    }
    
    /// 评论列表
    ///
    /// - Parameters:
    ///   - targetObjectId: 目标id
    ///   - type: 类型 0 心情评论 1 心情评论回复
    /// - Returns: 返回JSON数据
    func readCommentOperator(targetObjectId: String, type: Int, currentPage: Int, pageSize: Int) -> String? {
        let baseStatement = "select comment.objectId, comment.targetPointer, comment.superTargetPointer, comment.authorComment, comment.content, comment.type, comment.status, comment.createdAt, comment.updateAt, user.objectId, user.portrait, user.homeBG, user.mobilePhoneNumber, user.gender, user.username, user.signature, user.email, user.createdAt, user.updateAt from \(moodCommentTableName) comment, \(userTableName) user where (user.objectId = comment.authorComment)"
        
        let statement = "\(baseStatement) and targetPointer = '\(targetObjectId)' and status = '\(0)' and type = '\(type)' limit \(currentPage*pageSize), \(pageSize)"
        if !mysql.query(statement: statement) {
            print("/****\n\(mysql.errorMessage())\n****/")
            responseJson = UtilsBase().createFailureJsonLog(message: "评论列表获取失败")
        } else {
            let results = mysql.storeResults()!
            
            if results.numRows() == 0 {
                responseJson = UtilsBase().createFailureJsonLog(message: "评论列表为空")
            } else {
                var commentList = [[String: AnyObject]]()
                results.forEachRow { row in
                    var dict = [String: AnyObject]()
                    dict["objectId"] = row[0] as AnyObject
                    dict["targetPointer"] = row[1] as AnyObject
                    dict["superTargetPointer"] = row[2] as AnyObject
                    dict["authorComment"] = row[3] as AnyObject
                    dict["content"] = row[4] as AnyObject
                    dict["type"] = Int(row[5]!) as AnyObject
                    dict["status"] = Int(row[6]!) as AnyObject
                    dict["createdAt"] = row[7] as AnyObject
                    dict["updateAt"] = row[8] as AnyObject
                    
                    //用户信息
                    var authorInfo = [String: AnyObject]()
                    authorInfo["objectId"] = row[9] as AnyObject
                    authorInfo["portrait"] = row[10] as AnyObject
                    authorInfo["homeBG"] = row[11] as AnyObject
                    authorInfo["mobile"] = row[12] as AnyObject
                    authorInfo["gender"] = Int(row[13]!) as AnyObject
                    authorInfo["username"] = row[14] as AnyObject
                    authorInfo["signature"] = row[15] as AnyObject
                    authorInfo["email"] = row[16] as AnyObject
                    authorInfo["createdAt"] = row[17] as AnyObject
                    authorInfo["updateAt"] = row[18] as AnyObject
                    
                    dict["author"] = authorInfo as AnyObject
                    
                    //每条评论回复数
                    dict["replyCount"] = Int(self.commentReplyCountOperator(superObjectId: dict["objectId"] as! String)) as AnyObject
                    
                    commentList.append(dict)
                }
                
                responseJson = UtilsBase().createSuccessJsonLog(jsonObject: commentList)
            }
        }
        
        return responseJson
    }
    
    /// 评论回复列表
    ///
    /// - Parameters:
    ///   - superObjectId: 回复评论id
    ///   - type: 类型 0 心情评论 1 心情评论回复
    /// - Returns: 返回JSON数据
    func readCommentReplyOperator(superObjectId: String, type: Int, currentPage: Int, pageSize: Int) -> String? {
        let baseStatement = "select comment.objectId, comment.targetPointer, comment.superTargetPointer, comment.authorComment, comment.content, comment.type, comment.status, comment.createdAt, comment.updateAt, user.objectId, user.portrait, user.homeBG, user.mobilePhoneNumber, user.gender, user.username, user.signature, user.email, user.createdAt, user.updateAt from \(moodCommentTableName) comment, \(userTableName) user where (user.objectId = comment.authorComment)"
        
        let statement = "\(baseStatement) and superTargetPointer = '\(superObjectId)' and status = '\(0)' and type = '\(type)' limit \(currentPage*pageSize), \(pageSize)"
        if !mysql.query(statement: statement) {
            print("/****\n\(mysql.errorMessage())\n****/")
            responseJson = UtilsBase().createFailureJsonLog(message: "回复列表获取失败")
        } else {
            let results = mysql.storeResults()!
            
            if results.numRows() == 0 {
                responseJson = UtilsBase().createFailureJsonLog(message: "回复列表为空")
            } else {
                var replyList = [[String: AnyObject]]()
                results.forEachRow { row in
                    var dict = [String: AnyObject]()
                    dict["objectId"] = row[0] as AnyObject
                    dict["targetPointer"] = row[1] as AnyObject
                    dict["superTargetPointer"] = row[2] as AnyObject
                    dict["authorComment"] = row[3] as AnyObject
                    dict["content"] = row[4] as AnyObject
                    dict["type"] = Int(row[5]!) as AnyObject
                    dict["status"] = Int(row[6]!) as AnyObject
                    dict["createdAt"] = row[7] as AnyObject
                    dict["updateAt"] = row[8] as AnyObject
                    
                    //用户信息
                    var authorInfo = [String: AnyObject]()
                    authorInfo["objectId"] = row[9] as AnyObject
                    authorInfo["portrait"] = row[10] as AnyObject
                    authorInfo["homeBG"] = row[11] as AnyObject
                    authorInfo["mobile"] = row[12] as AnyObject
                    authorInfo["gender"] = Int(row[13]!) as AnyObject
                    authorInfo["username"] = row[14] as AnyObject
                    authorInfo["signature"] = row[15] as AnyObject
                    authorInfo["email"] = row[16] as AnyObject
                    authorInfo["createdAt"] = row[17] as AnyObject
                    authorInfo["updateAt"] = row[18] as AnyObject
                    
                    dict["author"] = authorInfo as AnyObject
                    
                    replyList.append(dict)
                }
                
                responseJson = UtilsBase().createSuccessJsonLog(jsonObject: replyList)
            }
        }
        
        return responseJson
    }
}
