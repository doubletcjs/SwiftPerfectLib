//
//  ReadRecordOperator.swift
//  SwiftPerfectDemo
//
//  Created by macjs on 17/5/26.
//
//

import Foundation

class ReadRecordBaseOperator: BaseOperator {
    //MARK: 内部接口
    
    private let readRecordTableName = "ReadRecord"
    
    //MARK: 外部接口
    
    /// 获取阅读人数
    ///
    /// - Parameters:
    ///   - targetObjectId: 目标id
    ///   - type: 类型 0 分类
    /// - Returns: Int
    func getReadCount(targetObjectId: String, type: Int) -> Int {
        var count: Int = 0
        let statement = "select count(objectId) from \(readRecordTableName) where targetPointer = '\(targetObjectId)' and type = '\(type)'"
        if !mysql.query(statement: statement) {
            print("/****\n\(mysql.errorMessage())\n****/")
        } else {
            let results = mysql.storeResults()!
            
            results.forEachRow { row in
                count = Int(row[0]!)!
            }
        }
        
        return count
    }
    
    /// 添加阅读记录
    ///
    /// - Parameters:
    ///   - targetObjectId: 目标id
    ///   - userObjectId: 用户id
    ///   - type: 类型 0 分类
    /// - Returns: Int
    func addReadRecord(targetObjectId: String, userObjectId: String, type: Int) -> String? {
        let statement = "select objectId from \(readRecordTableName) where targetPointer = '\(targetObjectId)' and userReadRecord = '\(userObjectId)'  and type = '\(type)'"
        if !mysql.query(statement: statement) {
            print("/****\n\(mysql.errorMessage())\n****/")
            responseJson = UtilsBase().createFailureJsonLog(message: "操作失败")
        } else {
            let results = mysql.storeResults()!
            if results.numRows() == 0 {
                let dateString = UtilsBase().getCurrentDate()
                
                let values = "('\(targetObjectId)', ('\(userObjectId)'), '\(type)', ('\(dateString!)'), ('\(dateString!)'))"
                let insertStatement = "insert into \(readRecordTableName) (targetPointer, userReadRecord, type, createdAt, updateAt) values \(values)"
                
                if !mysql.query(statement: insertStatement) {
                    print("/****\n\(mysql.errorMessage())\n****/")
                    responseJson = UtilsBase().createFailureJsonLog(message: "操作失败")
                } else {
                    var dict = [String: AnyObject]()
                    dict["readCount"] = Int(self.getReadCount(targetObjectId: targetObjectId, type: type)) as AnyObject
                    responseJson = UtilsBase().createSuccessJsonLog(jsonObject: dict)
                }
            } else {
                responseJson = UtilsBase().createSuccessJsonLog(jsonObject: "已记录")
            }
        }
        
        return responseJson
    }
}
