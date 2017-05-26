//
//  BaseOperator.swift
//  SwiftPerfectDemo
//
//  Created by macjs on 17/5/26.
//
//

import Foundation
import MySQL
import PerfectLogger

//MARK: 连接MySql数据库的类
class MySQLConnect {
    var host: String {          //数据库IP
        get {
            return "127.0.0.1"
        }
    }
    
    var port: String {
        get {
            return "3306"       //数据库端口
        }
    }
    
    var user: String {          //数据库用户名
        get {
            return "root"
        }
    }
    
    var password: String {      //数据库密码
        get {
            return ""
        }
    }
    
    private var connect: MySQL!             //用于操作MySql的句柄
    
    //MySQL句柄单例
    private static var instance: MySQL!
    public static func shareInstance(dataBaseName: String) -> MySQL {
        if instance == nil {
            instance = MySQLConnect(dataBaseName: dataBaseName).connect
        }
        
        return instance
    }
    
    private init(dataBaseName: String) {
        self.connectDataBase()
        self.selectDataBase(name: dataBaseName)
    }
    
    /// 连接数据库
    private func connectDataBase() {
        if connect == nil {
            connect = MySQL()
        }
        
        let connected = connect.connect(host: "\(host)", user: user, password: password)
        guard connected else {// 验证一下连接是否成功
            //LogFile.error(connect.errorMessage())
            print(connect.errorMessage())
            return
        }
        
        print("数据库连接成功")
        LogFile.info("数据库连接成功")
    }
    
    /// 选择数据库Scheme
    ///
    /// - Parameter name: Scheme名
    func selectDataBase(name: String) {
        // 选择具体的数据Schema
        guard connect.selectDatabase(named: name) else {
            print("数据库选择失败。错误代码：\(connect.errorCode()) 错误解释：\(connect.errorMessage())")
            LogFile.error("数据库选择失败。错误代码：\(connect.errorCode()) 错误解释：\(connect.errorMessage())")
            return
        }
        
        print("连接Schema：\(name)成功")
        LogFile.info("连接Schema：\(name)成功")
    }
    
    deinit {
        
    }
}

//MARK: 操作数据库的基类
class BaseOperator {
    private let dataBaseName = ""
    var mysql: MySQL {
        get {
            return MySQLConnect.shareInstance(dataBaseName: dataBaseName)
        }
    }
    
    var responseJson: String!
}
