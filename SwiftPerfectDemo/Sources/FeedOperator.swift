//
//  FeedOperator.swift
//  SwiftPerfectDemo
//
//  Created by macjs on 17/5/26.
//
//

import Foundation

class FeedBaseOperator: BaseOperator {
    //MARK: 内部接口
    
    private let feedTableName = "Feed"
    
    //MARK: 外部接口
    
    /// 反馈
    ///
    /// - Parameters:
    ///   - userObjectId: 反馈人id
    ///   - feedContent: 反馈内容
    /// - Returns: 返回JSON数据
    func addFeedOperator(userObjectId: String, feedContent: String) -> String? {
        let dateString = UtilsBase().getCurrentDate()
        
        let values = "('\(userObjectId)', ('\(feedContent)'), ('\(dateString!)'), ('\(dateString!)'))"
        let insertStatement = "insert into \(feedTableName) (userFeed, content, createdAt, updateAt) values \(values)"
        
        if !mysql.query(statement: insertStatement) {
            print("/****\n\(mysql.errorMessage())\n****/")
            responseJson = UtilsBase().createFailureJsonLog(message: "操作失败")
        } else {
            responseJson = UtilsBase().createSuccessJsonLog(jsonObject: "反馈成功")
        }
        
        return responseJson
    }
}
