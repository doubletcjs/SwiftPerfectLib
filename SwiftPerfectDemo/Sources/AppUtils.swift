//
//  AppUtils.swift
//  SwiftPerfectDemo
//
//  Created by macjs on 17/5/26.
//
//

import Foundation
import PerfectCrypto

let RequestResultSuccess: String = "000"
let RequestResultFailure: String = "001"
let ResultObjectKey = "resultObject"
let ResultCodeKey = "resultCode"
let ErrorMessageKey = "errorMessage"
var BaseResponseJson: [String : Any] = [ResultObjectKey:[], ResultCodeKey:RequestResultSuccess, ErrorMessageKey:""]

class UtilsBase {
    func createFailureJsonLog(message: String) -> String? {
        BaseResponseJson[ResultCodeKey] = RequestResultFailure
        BaseResponseJson[ResultObjectKey] = [String: String]()
        BaseResponseJson[ErrorMessageKey] = message
        
        guard let json = try? BaseResponseJson.jsonEncodedString() else {
            return nil
        }
        
        return json
    }
    
    func createSuccessJsonLog(jsonObject: Any) -> String? {
        BaseResponseJson[ResultCodeKey] = RequestResultSuccess
        BaseResponseJson[ResultObjectKey] = jsonObject
        BaseResponseJson[ErrorMessageKey] = ""
        
        guard let json = try? BaseResponseJson.jsonEncodedString() else {
            return nil
        }
        
        return json
    }
    
    /// 获取当前时间 转 字符串
    ///
    /// - Returns: String
    func getCurrentDate() -> String? {
        let now = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let nowString = dateFormatter.string(from: now as Date)
        
        return nowString
    }
    
    func jsonToDictionary(text: String) -> AnyObject? {
        let data = text.data(using: String.Encoding.utf8)! as Data
        let dictionary = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
        
        return dictionary as AnyObject?
    }
    
    func objectToJson(object: AnyObject) -> String? {
        var result: String = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
            
            if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                result = JSONString
            }
            
        } catch {
            result = ""
        }
        
        return result
    }
    
    deinit {
        
    }
}
