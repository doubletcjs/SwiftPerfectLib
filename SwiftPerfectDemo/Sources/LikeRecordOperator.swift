//
//  LikeRecordOperator.swift
//  SwiftPerfectDemo
//
//  Created by macjs on 17/5/26.
//
//

import Foundation

class LikeRecordBaseOperator: BaseOperator {
    //MARK: 内部接口
    private let likeTableName = "LikeRecord"
    
    //MARK: 外部接口
    
    /// 点赞
    ///
    /// - Parameters:
    ///   - targetObjectId: 点赞对象id
    ///   - userObjectId: 点赞人id
    ///   - likeType: 类型 0 分类
    /// - Returns: 返回JSON数据
    func likeOperator(targetObjectId: String, userObjectId: String, likeType: Int) -> String? {
        let statement = "select objectId from \(likeTableName) where targetPointer = '\(targetObjectId)' and userPointer = '\(userObjectId)' and type = '\(likeType)'"
        
        if !mysql.query(statement: statement) {
            print("/****\n\(mysql.errorMessage())\n****/")
            responseJson = UtilsBase().createFailureJsonLog(message: "操作失败")
        } else {
            let dateString = UtilsBase().getCurrentDate()
            let results = mysql.storeResults()!
            var dict = [String: AnyObject]()
            
            if results.numRows() == 0 {
                //点赞
                let values = "('\(targetObjectId)', ('\(userObjectId)'), ('\(likeType)', ('\(dateString!)'), ('\(dateString!)'))"
                let insertStatement = "insert into \(likeTableName) (targetPointer, userPointer, type, createdAt, updateAt) values \(values)"
                
                if !mysql.query(statement: insertStatement) {
                    print("/****\n\(mysql.errorMessage())\n****/")
                    responseJson = UtilsBase().createFailureJsonLog(message: "操作失败")
                } else {
                    dict["isLiked"] = true as AnyObject
                    dict["msg"] = "点赞成功" as AnyObject
                    responseJson = UtilsBase().createSuccessJsonLog(jsonObject: dict)
                }
            } else {
                //取消点赞
                results.forEachRow { row in
                    let objectId = row[0]!
                    let deleteStatement = "delete from \(likeTableName) where objectId = '\(objectId)'"
                    
                    if !mysql.query(statement: deleteStatement) {
                        print("/****\n\(mysql.errorMessage())\n****/")
                        responseJson = UtilsBase().createFailureJsonLog(message: "操作失败")
                    } else {
                        dict["isLiked"] = false as AnyObject
                        dict["msg"] = "已取消点赞" as AnyObject
                        responseJson = UtilsBase().createSuccessJsonLog(jsonObject: dict)
                    }
                }
            }
        }
        
        return responseJson
    }
    
    //MARK: 外部接口
    
    /// 是否点赞
    ///
    /// - Parameters:
    ///   - targetObjectId: 点赞对象id
    ///   - userObjectId: 点赞人id
    ///   - likeType: 类型
    /// - Returns: Bool
    func isLikeOperator(targetObjectId: String, userObjectId: String, likeType: Int) -> Bool {
        let statement = "select objectId from \(likeTableName) where targetPointer = '\(targetObjectId)' and userLike = '\(userObjectId)' and type = '\(likeType)'"
        
        if !mysql.query(statement: statement) {
            print("/****\n\(mysql.errorMessage())\n****/")
            return false
        } else {
            let results = mysql.storeResults()!
            
            if results.numRows() == 0 {
                return false
            } else {
                return true
            }
        }
    }
    
    /// 点赞数量
    ///
    /// - Parameters:
    ///   - targetObjectId: 点赞对象id
    ///   - likeType: 类型
    /// - Returns: Bool
    func likeCountOperator(targetObjectId: String, likeType: Int) -> Int {
        var likeCount: Int = 0
        
        let statement = "select count(objectId) from \(likeTableName) where targetPointer = '\(targetObjectId)' and type = '\(likeType)'"
        
        if !mysql.query(statement: statement) {
            print("/****\n\(mysql.errorMessage())\n****/")
            likeCount = 0
        } else {
            let results = mysql.storeResults()!
            
            if results.numRows() == 0 {
                likeCount = 0
            } else {
                results.forEachRow { row in
                    likeCount = Int(row[0]!)!
                }
            }
        }
        
        return likeCount
    }
}
