//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectMustache
import MySQL
import PerfectLogger
//import PerfectRequestLogger

let server = HTTPServer()
var routes = Routes()

//MARK: 注册用户
routes.add(method: .post, uri: "/register") { (request, response) in
    let username: String = request.param(name: "username")!;
    let mobile: String = request.param(name: "mobile")!
    let password: String = request.param(name: "password")!
    
    guard let json = UserBaseOperator().registerAccount(username: username, password: password, mobile: mobile) else {
        print("json为空")
        
        response.setBody(string: UtilsBase().createFailureJsonLog(message: "请求参数错误")!)
        response.completed()
        return
    }
    
    response.setBody(string: json)
    response.completed()
}

//MARK: 登录用户 用户名、手机号码二选一
routes.add(method: .post, uri: "/login") { (request, response) in
    var username: String = ""
    var mobile: String = ""
    var allNotAvailable: Bool = true
    
    if request.param(name: "username") != nil {
        username = request.param(name: "username")!
        allNotAvailable = false
    }
    
    if request.param(name: "mobile") != nil {
        mobile = request.param(name: "mobile")!
        allNotAvailable = false
    }
    
    if allNotAvailable == true {
        response.setBody(string: UtilsBase().createFailureJsonLog(message: "请输入用户名或手机号码")!)
        response.completed()
        return
    }
    
    let password: String = request.param(name: "password")!
    
    guard let json = UserBaseOperator().verifyAccount(username: username, mobile: mobile, password: password) else {
        print("json为空")
        
        response.setBody(string: UtilsBase().createFailureJsonLog(message: "请求参数错误")!)
        response.completed()
        return
    }
    
    response.setBody(string: json)
    response.completed()
}

//MARK: - 获取用户信息
routes.add(method: .post, uri: "/userInfo") { (request, response) in
    var username: String = ""
    var objectId: String = ""
    var allNotAvailable: Bool = true
    
    if request.param(name: "username") != nil {
        username = request.param(name: "username")!
        allNotAvailable = false
    }
    
    if request.param(name: "objectId") != nil {
        objectId = request.param(name: "objectId")!
        allNotAvailable = false
    }
    
    if allNotAvailable == true {
        response.setBody(string: UtilsBase().createFailureJsonLog(message: "请输入用户名或用户id")!)
        response.completed()
        return
    }
    
    guard let json = UserBaseOperator().getUserInfo(username: username, objectId: objectId) else {
        print("json为空")
        
        response.setBody(string: UtilsBase().createFailureJsonLog(message: "请求参数错误")!)
        response.completed()
        return
    }
    
    response.setBody(string: json)
    response.completed()
}

//MARK: - 修改用户密码
routes.add(method: .post, uri: "/resetPassword") { (request, response) in
    let objectId: String = request.param(name: "objectId")!;
    let oldpassword: String = request.param(name: "oldpassword")!;
    let password: String = request.param(name: "password")!;
    
    guard let json = UserBaseOperator().changePassword(objectId: objectId, oldpassword: oldpassword, password: password) else {
        print("json为空")
        
        response.setBody(string: UtilsBase().createFailureJsonLog(message: "请求参数错误")!)
        response.completed()
        return
    }
    
    response.setBody(string: json)
    response.completed()
}

//MARK: - 修改用户信息
routes.add(method: .post, uri: "/changeUserInfo") { (request, response) in
    let objectId: String = request.param(name: "objectId")!;
    
    var username: String? = nil
    var signature: String? = nil
    var portrait: String? = nil
    var homeBG: String? = nil
    var gender: Int = -1
    var allNotAvailable: Bool = true
    
    if request.param(name: "username") != nil {
        username = request.param(name: "username")!
        allNotAvailable = false
    }
    
    if request.param(name: "signature") != nil {
        signature = request.param(name: "signature")!
        allNotAvailable = false
    }
    
    if request.param(name: "portrait") != nil {
        portrait = request.param(name: "portrait")!
        allNotAvailable = false
    }
    
    if request.param(name: "homeBG") != nil {
        homeBG = request.param(name: "homeBG")!
        allNotAvailable = false
    }
    
    if request.param(name: "gender") != nil {
        gender = Int(request.param(name: "gender")!)!
        
        allNotAvailable = false
    }
    
    if allNotAvailable == true {
        response.setBody(string: UtilsBase().createFailureJsonLog(message: "无需更新")!)
        response.completed()
        return
    }
    
    guard let json = UserBaseOperator().updateUserInfo(objectId: objectId, username: username, signature: signature, portrait: portrait, homeBG: homeBG, gender: gender) else {
        print("json为空")
        
        response.setBody(string: UtilsBase().createFailureJsonLog(message: "请求参数错误")!)
        response.completed()
        return
    }
    
    response.setBody(string: json)
    response.completed()
}

//MARK: - 用户反馈
routes.add(method: .post, uri: "/addFeed") { (request, response) in
    var userObjectId: String = ""
    if request.param(name: "userObjectId") != nil {
        userObjectId = request.param(name: "userObjectId")!;
    }
    
    let content: String = request.param(name: "content")!;
    
    guard let json = FeedBaseOperator().addFeedOperator(userObjectId: userObjectId, feedContent: content) else {
        print("json为空")
        
        response.setBody(string: UtilsBase().createFailureJsonLog(message: "请求参数错误")!)
        response.completed()
        return
    }
    
    response.setBody(string: json)
    response.completed()
}

//MARK: - 添加阅读记录
routes.add(method: .post, uri: "/addReadRecord") { (request, response) in
    let targetObjectId: String = request.param(name: "targetObjectId")!;
    let type: Int = Int(request.param(name: "type")!)!;
    let userObjectId: String = request.param(name: "userObjectId")!;
    
    guard let json = ReadRecordBaseOperator().addReadRecord(targetObjectId: targetObjectId, userObjectId: userObjectId, type: type) else {
        print("json为空")
        
        response.setBody(string: UtilsBase().createFailureJsonLog(message: "请求参数错误")!)
        response.completed()
        return
    }
    
    response.setBody(string: json)
    response.completed()
}

//MARK: - 点赞操作
routes.add(method: .post, uri: "/likeOperator") { (request, response) in
    let targetObjectId: String = request.param(name: "targetObjectId")!;
    let type: Int = Int(request.param(name: "type")!)!;
    let userObjectId: String = request.param(name: "userObjectId")!;
    
    guard let json = LikeRecordBaseOperator().likeOperator(targetObjectId: targetObjectId, userObjectId: userObjectId, likeType: type) else {
        print("json为空")
        
        response.setBody(string: UtilsBase().createFailureJsonLog(message: "请求参数错误")!)
        response.completed()
        return
    }
    
    response.setBody(string: json)
    response.completed()
}

//MARK: - 举报操作
routes.add(method: .post, uri: "/reportOperator") { (request, response) in
    let targetObjectId: String = request.param(name: "targetObjectId")!;
    let type: Int = Int(request.param(name: "type")!)!;
    let userObjectId: String = request.param(name: "userObjectId")!;
    
    guard let json = ReportBaseOperator().addReportOperator(targetObjectId: targetObjectId, userObjectId: userObjectId, reportType: type) else {
        print("json为空")
        
        response.setBody(string: UtilsBase().createFailureJsonLog(message: "请求参数错误")!)
        response.completed()
        return
    }
    
    response.setBody(string: json)
    response.completed()
}

//MARK: - 获取用户分类
routes.add(method: .post, uri: "/userCollectionList") { (request, response) in
    let userObjectId: String = request.param(name: "userObjectId")!;
    var currentPage: Int = 0;
    var pageSize: Int = 1000;
    var loginObjectId: String = ""
    
    if request.param(name: "loginObjectId") != nil {
        loginObjectId = request.param(name: "loginObjectId")!;
    }
    
    if request.param(name: "currentPage") != nil {
        currentPage = Int(request.param(name: "currentPage")!)!;
    }
    
    if request.param(name: "pageSize") != nil {
        pageSize = Int(request.param(name: "pageSize")!)!;
    }
    
    guard let json = CollectionBaseOperator().readCollectionOperator(loginObjectId: loginObjectId, userObjectId: userObjectId, currentPage: currentPage, pageSize: pageSize) else {
        print("json为空")
        
        response.setBody(string: UtilsBase().createFailureJsonLog(message: "请求参数错误")!)
        response.completed()
        return
    }
    
    response.setBody(string: json)
    response.completed()
}

//MARK: - 创建分类
routes.add(method: .post, uri: "/createCollection") { (request, response) in
    let title: String = request.param(name: "title")!;
    let bgUrl: String = request.param(name: "bgUrl")!;
    let authorObjectId: String = request.param(name: "authorObjectId")!;
    let introduction: String = request.param(name: "introduction")!;
    let tags: String = request.param(name: "tags")!;
    let createStatus: Int = Int(request.param(name: "createStatus")!)!;
    let status: Int = Int(request.param(name: "status")!)!;
    
    guard let json = CollectionBaseOperator().createCollectionOperator(title: title, bgUrl: bgUrl, authorObjectId: authorObjectId, introduction: introduction, tags: tags, createStatus: createStatus, status: status) else {
        print("json为空")
        
        response.setBody(string: UtilsBase().createFailureJsonLog(message: "请求参数错误")!)
        response.completed()
        return
    }
    
    response.setBody(string: json)
    response.completed()
}

//MARK: - 编辑分类
routes.add(method: .post, uri: "/editCollection") { (request, response) in
    let collectionObjectId: String = request.param(name: "collectionObjectId")!;
    var title: String = ""
    var bgUrl: String = ""
    var introduction: String = ""
    var tags: String = ""
    var status: Int = -1;
    
    if request.param(name: "title") != nil {
        title = request.param(name: "title")!;
    }
    
    if request.param(name: "bgUrl") != nil {
        bgUrl = request.param(name: "bgUrl")!;
    }
    
    if request.param(name: "introduction") != nil {
        introduction = request.param(name: "introduction")!;
    }
    
    if request.param(name: "tags") != nil {
        tags = request.param(name: "tags")!;
    }
    
    if request.param(name: "status") != nil {
        status = Int(request.param(name: "status")!)!;
    }
    
    guard let json = CollectionBaseOperator().editCollectionOperator(collectionObjectId: collectionObjectId, title: title, bgUrl: bgUrl, introduction: introduction, tags: tags, status: status) else {
        print("json为空")
        
        response.setBody(string: UtilsBase().createFailureJsonLog(message: "请求参数错误")!)
        response.completed()
        return
    }
    
    response.setBody(string: json)
    response.completed()
}

//MARK: - 创建心情
routes.add(method: .post, uri: "/createMood") { (request, response) in
    let videoItem: String = request.param(name: "videoItem")!;
    let imageItems: String = request.param(name: "imageItems")!;
    let content: String = request.param(name: "content")!;
    let collectionObjectId: String = request.param(name: "collectionObjectId")!;
    let authorObjectId: String = request.param(name: "authorObjectId")!;
    let status: Int = Int(request.param(name: "status")!)!;
    
    guard let json = MoodBaseOperator().createMoodOperator(videoItem: videoItem, status: status, imageItems: imageItems, content: content, collectionObjectId: collectionObjectId, authorObjectId: authorObjectId) else {
        print("json为空")
        
        response.setBody(string: UtilsBase().createFailureJsonLog(message: "请求参数错误")!)
        response.completed()
        return
    }
    
    response.setBody(string: json)
    response.completed()
}

//MARK: - 获取分类心情
routes.add(method: .post, uri: "/collectionMoodList") { (request, response) in
    let collectionObjectId: String = request.param(name: "collectionObjectId")!;
    var currentPage: Int = 0;
    var pageSize: Int = 1000;
    var loginObjectId: String = ""
    
    if request.param(name: "currentPage") != nil {
        currentPage = Int(request.param(name: "currentPage")!)!;
    }
    
    if request.param(name: "pageSize") != nil {
        pageSize = Int(request.param(name: "pageSize")!)!;
    }
    
    if request.param(name: "loginObjectId") != nil {
        loginObjectId = request.param(name: "loginObjectId")!;
    }
    
    guard let json = MoodBaseOperator().readCollectionMoodOperator(loginObjectId: loginObjectId, collectionObjectId: collectionObjectId, currentPage: currentPage, pageSize: pageSize) else {
        print("json为空")
        
        response.setBody(string: UtilsBase().createFailureJsonLog(message: "请求参数错误")!)
        response.completed()
        return
    }
    
    response.setBody(string: json)
    response.completed()
}

//MARK: - 添加评论、回复
routes.add(method: .post, uri: "/addCommentReply") { (request, response) in
    let targetObjectId: String = request.param(name: "targetObjectId")!;
    var superObjectId: String = ""
    let userObjectId: String = request.param(name: "userObjectId")!;
    let content: String = request.param(name: "content")!;
    let type: Int = Int(request.param(name: "type")!)!;
    
    if type == 1 {
        superObjectId = request.param(name: "superObjectId")!;
    }
    
    guard let json = MoodCommentBaseOperator().createCommentReplyOperator(targetObjectId: targetObjectId, superObjectId: superObjectId, userObjectId: userObjectId, content: content, type: type) else {
        print("json为空")
        
        response.setBody(string: UtilsBase().createFailureJsonLog(message: "请求参数错误")!)
        response.completed()
        return
    }
    
    response.setBody(string: json)
    response.completed()
}

//MARK: - 删除评论、回复
routes.add(method: .post, uri: "/deleteComment") { (request, response) in
    let objectId: String = request.param(name: "objectId")!;
    
    guard let json = MoodCommentBaseOperator().deleteCommentOrReplyOperator(objectId: objectId, status: 1) else {
        print("json为空")
        
        response.setBody(string: UtilsBase().createFailureJsonLog(message: "请求参数错误")!)
        response.completed()
        return
    }
    
    response.setBody(string: json)
    response.completed()
}

//MARK: - 心情评论列表
routes.add(method: .post, uri: "/moodCommentList") { (request, response) in
    let targetObjectId: String = request.param(name: "targetObjectId")!;
    let type: Int = 0;
    var currentPage: Int = 0;
    var pageSize: Int = 1000;
    
    if request.param(name: "currentPage") != nil {
        currentPage = Int(request.param(name: "currentPage")!)!;
    }
    
    if request.param(name: "pageSize") != nil {
        pageSize = Int(request.param(name: "pageSize")!)!;
    }
    
    guard let json = MoodCommentBaseOperator().readCommentOperator(targetObjectId: targetObjectId, type: type, currentPage: currentPage, pageSize: pageSize) else {
        print("json为空")
        
        response.setBody(string: UtilsBase().createFailureJsonLog(message: "请求参数错误")!)
        response.completed()
        return
    }
    
    response.setBody(string: json)
    response.completed()
}

//MARK: - 心情评论回复列表
routes.add(method: .post, uri: "/moodCommentReplyList") { (request, response) in
    let superObjectId: String = request.param(name: "superObjectId")!;
    let type: Int = 1;
    var currentPage: Int = 0;
    var pageSize: Int = 1000;
    
    if request.param(name: "currentPage") != nil {
        currentPage = Int(request.param(name: "currentPage")!)!;
    }
    
    if request.param(name: "pageSize") != nil {
        pageSize = Int(request.param(name: "pageSize")!)!;
    }
    
    guard let json = MoodCommentBaseOperator().readCommentReplyOperator(superObjectId: superObjectId, type: type, currentPage: currentPage, pageSize: pageSize) else {
        print("json为空")
        
        response.setBody(string: UtilsBase().createFailureJsonLog(message: "请求参数错误")!)
        response.completed()
        return
    }
    
    response.setBody(string: json)
    response.completed()
}

routes.add(method: .post, uri: "/test") { (request, response) in
    print("\(LikeRecordBaseOperator().isLikeOperator(targetObjectId: "10004", userObjectId: "10016", likeType: 0))")
    
    response.setBody(string: UtilsBase().createFailureJsonLog(message: "操作成功")!)
    response.completed()
    
    //    let dateString = UtilsBase().getCurrentDate()
    //
    //    let values = "('测试', 'http://', '10016', '测试简介', '', '0', '0', '0', ('\(dateString!)'), ('\(dateString!)'))"
    //    let insertStatement = "insert into Collection (title, bgUrl, authorCollection, introduction, tags, createStatus, status, lastStatus, createdAt, updateAt) values \(values)"
    //
    //    if !BaseOperator().mysql.query(statement: insertStatement) {
    //        print("\(BaseOperator().mysql.errorMessage())")
    //        response.setBody(string: UtilsBase().createFailureJsonLog(message: "操作失败")!)
    //        response.completed()
    //        return
    //    } else {
    //        if !BaseOperator().mysql.query(statement: "select @@IDENTITY") {
    //
    //        } else {
    //            BaseOperator().mysql.storeResults()?.forEachRow { row in
    //                print("\(row[0]!)")
    //            }
    //        }
    //
    //        response.setBody(string: UtilsBase().createFailureJsonLog(message: "操作成功")!)
    //        response.completed()
    //        return
    //    }
    
    //    var count: Int = 0
    //    let statement = "select count(objectId) from Collection where authorCollection = '\(10016)' and status = '\(0)'"
    //    if !BaseOperator().mysql.query(statement: statement) {
    //        print("获取分类阅读人数失败\(BaseOperator().mysql.errorMessage())")
    //    } else {
    //        let results = BaseOperator().mysql.storeResults()!
    //
    //        results.forEachRow { row in
    //            count = Int(row[0]!)!
    //        }
    //    }
    //
    //    print("\(count)")
    //    response.setBody(string: UtilsBase().createFailureJsonLog(message: "操作成功")!)
    //    response.completed()
}

//MARK: 图片路径
let imagePath = "\(server.documentRoot)/images"
let imageDir = Dir(imagePath)
if !imageDir.exists {
    try Dir(imagePath).create()
}

//MARK: - 文件上传
routes.add(method: .post, uri: "/upload") { (request, response) in
    // 通过操作fileUploads数组来掌握文件上传的情况
    // 如果这个POST请求不是分段multi-part类型，则该数组内容为空
    
    if let uploads = request.postFileUploads, uploads.count > 0 {
        // 创建一个字典数组用于检查已经上载的内容
        var dict: Dictionary = [String: AnyObject]()
        
        var ImgWidth: Float = 0.0
        var ImgHeight: Float = 0.0
        var ImgPath: String = ""
        
        for upload in uploads {
            if upload.fieldName == "ImgWidth" {
                ImgWidth = Float(upload.fieldValue)!
            }
            
            if upload.fieldName == "ImgHeight" {
                ImgHeight = Float(upload.fieldValue)!
            }
            
            dict["ImgWidth"] = "\(ImgWidth)" as AnyObject
            dict["ImgHeight"] = "\(ImgHeight)" as AnyObject
            
            if upload.fieldName != "ImgHeight" && upload.fieldName != "ImgWidth" {
                dict["fieldName"] = "\(upload.fieldName)" as AnyObject
                dict["contentType"] = "\(upload.contentType)" as AnyObject
                dict["fileName"] = "\(upload.fileName)" as AnyObject
                dict["fileSize"] = "\((upload.fileSize))" as AnyObject
                dict["tmpFileName"] = "\(upload.tmpFileName)" as AnyObject
                
                // 将文件转移走，如果目标位置已经有同名文件则进行覆盖操作。
                let thisFile = File(upload.tmpFileName)
                do {
                    ImgPath = "\(imagePath)/\(upload.fileName)"
                    let _ = try thisFile.moveTo(path: "\(imagePath)/\(upload.fileName)", overWrite: true)
                } catch {
                    print(error)
                    
                    response.setBody(string: UtilsBase().createFailureJsonLog(message: "请求参数错误")!)
                    response.completed()
                }
            }
        }
        
        print("\(UtilsBase().createSuccessJsonLog(jsonObject: dict)!)")
        print("\(ImgPath)")
        
        response.setBody(string: UtilsBase().createSuccessJsonLog(jsonObject: "图片上传成功")!)
        response.completed()
    } else {
        print("\(request)")
        print("\(response)")
        
        response.setBody(string: UtilsBase().createFailureJsonLog(message: "请求参数错误")!)
        response.completed()
    }
}

//MARK: 日志
let logPath = "./files/log"
let logDir = Dir(logPath)
if !logDir.exists {
    try Dir(logPath).create()
}

LogFile.location = "\(logPath)/DiaryMood.log"
// 日志过滤器，将日志写入对应的文件
//server.setRequestFilters([(RequestLogger(), .high)]) // 首先增加高优先级的过滤器
//server.setResponseFilters([(RequestLogger(), .low)]) // 首先增加高优先级的过滤器

//LogFile.debug("调试消息")
//LogFile.info("消息")
//LogFile.warning("警告消息")
//LogFile.error("错误消息")
//LogFile.critical("严重消息")
//LogFile.terminal("服务器终止消息")

//MARK: 服务器配置
server.addRoutes(routes)
server.serverPort = 8181
server.documentRoot = "./webroot"

//MARK: 服务器启动
do { 
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    LogFile.error("网络出现错误：\(err) \(msg)")
    print("网络出现错误：\(err) \(msg)")
}

