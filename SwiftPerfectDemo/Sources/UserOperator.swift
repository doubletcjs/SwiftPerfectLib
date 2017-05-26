//
//  UserOperator.swift
//  SwiftPerfectDemo
//
//  Created by macjs on 17/5/26.
//
//

import Foundation

class UserBaseOperator: BaseOperator {
    //MARK: 内部接口
    
    private let userTableName = "User"
    private let AES_ENCRYPT_KEY = "~!@#$%^&*()_+com.xyz.appname_1234567890-="
    
    /// 用户名是否存在
    ///
    /// - Parameters:
    ///   - username: 用户名
    ///   - mobile: 手机号
    /// - Returns: Int 0 不存在 1 存在用户名 2 存在手机号 3 查询失败
    private func checkAccount(username: String, mobile: String) -> Int! {
        let statement = "select objectId, username, mobilePhoneNumber from \(userTableName) where username = '\(username)' or mobilePhoneNumber = '\(mobile)'"
        
        if !mysql.query(statement: statement) {
            print("/****\n\(mysql.errorMessage())\n****/")
            return 3
        } else {
            var isExist = 0
            let results = mysql.storeResults()!
            
            if results.numRows() == 0 {
                isExist = 0
            } else {
                results.forEachRow { row in
                    if row[1] == username {
                        isExist = 1
                    } else if row[2] == mobile {
                        isExist = 2
                    } else {
                        isExist = 0
                    }
                }
            }
            
            return isExist
        }
    }
    
    /// 用户是否存在
    ///
    /// - Parameter objectId: 用户id
    /// - Returns: Bool
    private func isAccountExist(objectId: String) -> Bool! {
        let statement = "select objectId from \(userTableName) where objectId = '\(objectId)'"
        
        if !mysql.query(statement: statement) {
            print("/****\n\(mysql.errorMessage())\n****/")
            return false
        } else {
            var isExist = false
            let results = mysql.storeResults()!
            
            if results.numRows() == 0 {
                isExist = false
            } else {
                results.forEachRow { row in
                    if row[0] == objectId {
                        isExist = true
                    } else {
                        isExist = false
                    }
                }
            }
            
            return isExist
        }
    }
    //MARK: 外部接口
    
    /// 根据用户名或用户id获取用户信息
    ///
    /// - Parameters:
    ///   - username: 用户名
    ///   - objectId: 用户id
    /// - Returns: 返回JSON数据
    func getUserInfo(username: String, objectId: String) -> String? {
        var statement = ""
        var aviableQuery = false
        
        if username.characters.count > 0 {
            aviableQuery = true
            statement = "select objectId, username, mobilePhoneNumber, signature, portrait, homeBG, gender, createdAt, updateAt from \(userTableName) where username = '\(username)'"
        } else if objectId.characters.count > 0 {
            aviableQuery = true
            statement = "select objectId, username, mobilePhoneNumber, signature, portrait, homeBG, gender, createdAt, updateAt from \(userTableName) where objectId = '\(objectId)'"
        } else {
            aviableQuery = false
        }
        
        if aviableQuery == true {
            if !mysql.query(statement: statement) {
                print("/****\n\(mysql.errorMessage())\n****/")
                responseJson = UtilsBase().createFailureJsonLog(message: "获取用户信息失败")
            } else {
                let results = mysql.storeResults()!
                var dict = [String: AnyObject]()
                
                if results.numRows() == 0 {
                    responseJson = UtilsBase().createFailureJsonLog(message: "用户不存在!")
                } else {
                    results.forEachRow { row in
                        dict["objectId"] = objectId as AnyObject
                        dict["username"] = row[1] as AnyObject
                        dict["mobile"] = row[2] as AnyObject
                        dict["signature"] = row[3] as AnyObject
                        dict["portrait"] = row[4] as AnyObject
                        dict["homeBG"] = row[5] as AnyObject
                        dict["gender"] = Int(row[6]!) as AnyObject
                        dict["createdAt"] = row[7] as AnyObject
                        dict["updateAt"] = row[8] as AnyObject
                    }
                    
                    responseJson = UtilsBase().createSuccessJsonLog(jsonObject: dict)
                }
            }
        } else {
            responseJson = UtilsBase().createFailureJsonLog(message: "获取用户信息失败")
        }
        
        return responseJson
    }
    
    /// 注册用户名
    ///
    /// - Parameters:
    ///   - username: 用户名
    ///   - password: 密码
    ///   - mobile: 手机号码
    /// - Returns: 返回JSON数据
    func registerAccount(username: String, password: String, mobile: String) -> String? {
        let accountStatus = checkAccount(username: username, mobile: mobile)
        if accountStatus == 0 {
            let dateString = UtilsBase().getCurrentDate()
            let signature = ""
            let portrait = ""
            let homeBG = ""
            let gender = 0
            let createCollection = false
            let email = ""
            
            let values = "('\(username)', AES_ENCRYPT('\(password)', '\(AES_ENCRYPT_KEY)'), ('\(mobile)'), ('\(signature)'), ('\(portrait)'), ('\(homeBG)'), ('\(gender)'), (\(createCollection)), ('\(email)'), ('\(dateString!)'), ('\(dateString!)'))"
            let statement = "insert into \(userTableName) (username, password, mobilePhoneNumber, signature, portrait, homeBG, gender, createCollection, email, createdAt, updateAt) values \(values)"
            
            if !mysql.query(statement: statement) {
                print("/****\n\(mysql.errorMessage())\n****/")
                responseJson = UtilsBase().createFailureJsonLog(message: "用户注册失败")
            } else {
                responseJson = getUserInfo(username: username, objectId: "")
            }
        } else if accountStatus == 1 {
            responseJson = UtilsBase().createFailureJsonLog(message: "\(username)已被注册")
        } else if accountStatus == 2 {
            responseJson = UtilsBase().createFailureJsonLog(message: "该手机号码已被注册")
        } else {
            responseJson = UtilsBase().createFailureJsonLog(message: "用户注册失败")
        }
        
        return responseJson
    }
    
    /// 检验用户名 用户名、手机号码二选一
    ///
    /// - Parameters:
    ///   - username: 用户名
    ///   - mobile: 手机号码
    ///   - password: 密码
    /// - Returns: 返回JSON数据
    func verifyAccount(username: String, mobile: String, password: String) -> String? {
        let accountStatus = checkAccount(username: username, mobile: mobile)
        if accountStatus == 0 {
            responseJson = UtilsBase().createFailureJsonLog(message: "用户不存在")
        } else if accountStatus == 3 {
            responseJson = UtilsBase().createFailureJsonLog(message: "登录失败")
        } else {
            var statement = ""
            if username.characters.count > 0 {
                statement = "select objectId, username, mobilePhoneNumber, signature, portrait, homeBG, gender, createdAt, updateAt from \(userTableName) where username = '\(username)' and password = AES_ENCRYPT('\(password)', '\(AES_ENCRYPT_KEY)')"
            } else if mobile.characters.count > 0 {
                statement = "select objectId, username, mobilePhoneNumber, signature, portrait, homeBG, gender, createdAt, updateAt from \(userTableName) where mobilePhoneNumber = '\(mobile)' and password = AES_ENCRYPT('\(password)', '\(AES_ENCRYPT_KEY)')"
            }
            
            if !mysql.query(statement: statement) {
                print("/****\n\(mysql.errorMessage())\n****/")
                responseJson = UtilsBase().createFailureJsonLog(message: "登录失败")
            } else {
                let results = mysql.storeResults()!
                var dict = [String: AnyObject]()
                
                if results.numRows() == 0 {
                    responseJson = UtilsBase().createFailureJsonLog(message: "密码错误")
                } else {
                    results.forEachRow { row in
                        dict["objectId"] = row[0] as AnyObject
                        dict["username"] = row[1] as AnyObject
                        dict["mobile"] = row[2] as AnyObject
                        dict["signature"] = row[3] as AnyObject
                        dict["portrait"] = row[4] as AnyObject
                        dict["homeBG"] = row[5] as AnyObject
                        dict["gender"] = Int(row[6]!) as AnyObject
                        dict["createdAt"] = row[7] as AnyObject
                        dict["updateAt"] = row[8] as AnyObject
                    }
                    
                    responseJson = UtilsBase().createSuccessJsonLog(jsonObject: dict)
                }
            }
        }
        
        return responseJson
    }
    
    /// 修改密码
    ///
    /// - Parameters:
    ///   - objectId: 用户id
    ///   - oldpassword: 原密码
    ///   - password: 新密码
    /// - Returns: 返回JSON数据
    func changePassword(objectId: String, oldpassword: String, password: String) -> String? {
        if self.isAccountExist(objectId: objectId) == false {
            responseJson = UtilsBase().createFailureJsonLog(message: "用户不存在")
        } else {
            let verifyOldStatement = "select objectId, username from \(userTableName) where objectId = '\(objectId)' and password = AES_ENCRYPT('\(oldpassword)', '\(AES_ENCRYPT_KEY)')"
            if !mysql.query(statement: verifyOldStatement) {
                print("/****\n\(mysql.errorMessage())\n****/")
                responseJson = UtilsBase().createFailureJsonLog(message: "修改密码失败")
            } else {
                let results = mysql.storeResults()!
                
                if results.numRows() == 0 {
                    responseJson = UtilsBase().createFailureJsonLog(message: "原密码错误")
                } else {
                    results.forEachRow { row in
                        let dateString = UtilsBase().getCurrentDate()
                        let updateStatement = "update \(userTableName) set password = AES_ENCRYPT('\(password)', '\(AES_ENCRYPT_KEY)'), updateAt = '\(dateString!)' where objectId = '\(objectId)'"
                        
                        if !mysql.query(statement: updateStatement) {print("/****\n\(mysql.errorMessage())\n****/")
                            responseJson = UtilsBase().createFailureJsonLog(message: "修改用户密码失败")
                        } else {
                            responseJson = UtilsBase().createSuccessJsonLog(jsonObject: "用户密码成功")
                        }
                    }
                }
            }
            
            /*
             let statement = "select AES_DECRYPT(password, '\(AES_ENCRYPT_KEY)') as password from \(userTableName) where objectId = '\(objectId)'"
             if !mysql.query(statement: statement) {
             responseJson = UtilsBase().createFailureJsonLog(message: "找回密码失败")
             } else {
             let results = mysql.storeResults()!
             
             if results.numRows() == 0 {
             responseJson = UtilsBase().createFailureJsonLog(message: "找回密码失败")
             } else {
             results.forEachRow { row in
             guard row.first! != nil else {
             return
             }
             
             responseJson = UtilsBase().createSuccessJsonLog(jsonObject: {"msg": "找回密码成功", "pwd": "\(row.frist!)"})
             }
             }
             }
             */
        }
        
        return responseJson
    }
    
    /// 更新用户信息
    ///
    /// - Parameters:
    ///   - objectId: 用户id
    ///   - username: 用户名
    ///   - signature: 签名
    ///   - portrait: 头像
    ///   - homeBG: 主页背景
    ///   - gender: 性别
    /// - Returns: 返回JSON数据
    func updateUserInfo(objectId: String, username: String?, signature: String?, portrait: String?, homeBG: String?, gender: Int) -> String? {
        let statement = "select objectId, username, mobilePhoneNumber, signature, portrait, homeBG, gender, createdAt, updateAt from \(userTableName) where objectId = '\(objectId)'"
        if !mysql.query(statement: statement) {
            print("/****\n\(mysql.errorMessage())\n****/")
            responseJson = UtilsBase().createFailureJsonLog(message: "更新用户信息失败")
        } else {
            let results = mysql.storeResults()!
            var dict = [String: AnyObject]()
            
            if results.numRows() == 0 {
                responseJson = UtilsBase().createFailureJsonLog(message: "用户不存在")
            } else {
                results.forEachRow { row in
                    dict["objectId"] = objectId as AnyObject
                    dict["username"] = row[1] as AnyObject
                    dict["mobile"] = row[2] as AnyObject
                    dict["signature"] = row[3] as AnyObject
                    dict["portrait"] = row[4] as AnyObject
                    dict["homeBG"] = row[5] as AnyObject
                    dict["gender"] = Int(row[6]!) as AnyObject
                    dict["createdAt"] = row[7] as AnyObject
                    dict["updateAt"] = row[8] as AnyObject
                }
                
                var updateSQL = ""
                var updateSQLs = [String]()
                
                if username != nil && dict["username"] as? String != username {
                    updateSQLs.append("username = '\(username!)'")
                    
                    dict["username"] = username as AnyObject
                }
                
                if signature != nil && dict["signature"] as? String != signature {
                    updateSQLs.append("signature = '\(signature!)'")
                    
                    dict["signature"] = signature as AnyObject
                }
                
                if portrait != nil && dict["portrait"] as? String != portrait {
                    updateSQLs.append("portrait = '\(portrait!)'")
                    
                    dict["signature"] = signature as AnyObject
                }
                
                if homeBG != nil && dict["homeBG"] as? String != homeBG {
                    updateSQLs.append("homeBG = '\(homeBG!)'")
                    
                    dict["homeBG"] = homeBG as AnyObject
                }
                
                if gender >= 0 && dict["gender"] as! Int != gender {
                    updateSQLs.append("gender = '\(gender)'")
                    
                    dict["gender"] = Int(gender) as AnyObject
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
                    let updateStatement = "update \(userTableName) set \(updateSQL), updateAt = '\(dateString!)' where objectId = '\(objectId)'"
                    
                    if !mysql.query(statement: updateStatement) {
                        print("/****\n\(mysql.errorMessage())\n****/")
                        responseJson = UtilsBase().createFailureJsonLog(message: "更新用户信息失败")
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
}
