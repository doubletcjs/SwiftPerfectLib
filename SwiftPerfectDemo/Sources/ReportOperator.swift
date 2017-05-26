//
//  ReportOperator.swift
//  SwiftPerfectDemo
//
//  Created by macjs on 17/5/26.
//
//

import Foundation

class ReportBaseOperator: BaseOperator {
    //MARK: 内部接口
    
    private let reportTableName = "Report"
    
    /// 删除举报记录
    ///
    /// - Parameters:
    ///   - targetObjectId: 目标id
    ///   - userObjectId: 举报人id
    ///   - reportType: 举报类型 0 分类 1 心情 2 心情评论 3 用户
    /// - Returns: Bool
    func deleteReportOperator(targetObjectId: String, userObjectId: String, reportType: Int) -> Bool {
        let statement = "delete from \(reportTableName) where targetPointer = '\(targetObjectId)' and userReport = '\(userObjectId)' and type = '\(reportType)'"
        
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
    
    //MARK: 外部接口
    
    /// 举报
    ///
    /// - Parameters:
    ///   - targetObjectId: 目标id
    ///   - userObjectId: 举报人id
    ///   - reportType: 举报类型 0 分类 1 心情 2 心情评论 3 用户
    /// - Returns: 返回JSON数据
    func addReportOperator(targetObjectId: String, userObjectId: String, reportType: Int) -> String? {
        let dateString = UtilsBase().getCurrentDate()
        
        let values = "('\(targetObjectId)', ('\(userObjectId)'), ('\(reportType)', ('\(dateString!)'), ('\(dateString!)'))"
        let insertStatement = "insert into \(reportTableName) (targetPointer, userReport, type, createdAt, updateAt) values \(values)"
        
        if !mysql.query(statement: insertStatement) {
            print("/****\n\(mysql.errorMessage())\n****/")
            responseJson = UtilsBase().createFailureJsonLog(message: "操作失败")
        } else {
            responseJson = UtilsBase().createSuccessJsonLog(jsonObject: "举报成功")
        }
        
        return responseJson
    }
}
