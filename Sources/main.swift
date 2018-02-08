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


public typealias RequestHandle = (HTTPRequest, HTTPResponse) -> ()

let call1_Handle:RequestHandle = { (request, response) in
    var string = request.remoteAddress.host + ":\(request.remoteAddress.port)" + "\n"
    string += request.serverName + "\n" + request.serverAddress.host + ":\(request.serverAddress.port)" + "\n"
    string += request.uri + "\n"
    
    let query = request.queryParams
    for item in query {
        string += "\(item.0): \(item.1) \n"
    }
    response.appendBody(string: string)
    response.completed()
}

let call2_Handle:RequestHandle = { (request, response) in
    response.appendBody(string: "this is call2 api")
    response.completed()
}

var api = Routes()
api.add(method: .get, uri: "/call1", handler: call1_Handle)
api.add(method: .get, uri: "/call2", handler: call2_Handle)

//API 版本 1
var api1Routs = Routes.init(baseUri: "/v1")
//API 版本 2
var api2Routs = Routes.init(baseUri: "/v2")
// 为API版本v1增加主调函数
api1Routs.add(api)
// 为API版本v2增加主调函数
api2Routs.add(api)

//更新API版本v2主调函数
api2Routs.add(method: .get, uri: "/call2") { (request, response) in
    response.appendBody(string: "this is call2 v2 api")
    response.completed()
}


struct Filter404: HTTPResponseFilter {
    func filterBody(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
        callback(.continue)
    }
    
    func filterHeaders(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
        if case .notFound = response.status {
            response.setBody(string: "文件\(response.request.path) 不存在。")
            response.setHeader(.contentLength, value: "\(response.bodyBytes.count)")
            callback(.done)
        }
        else {
            callback(.continue)
        }
    }
}


//创建服务器
let server = HTTPServer()
//设置端口号
server.serverPort = 8282
//服务器名称
server.serverName = "MyServer"
//创建路由表
var routs = Routes.init()

//将两个版本的路由都注册到服务器主路由表上
routs.add(api1Routs)
routs.add(api2Routs)

//注册路由表
server.addRoutes(routs)

let filter404 = Filter404()
server.setResponseFilters([(filter404, .high)])

do {
    //启动服务器
    try server.start()
}
catch PerfectError.networkError(let err, let msg) {
    print("网络错误：\(err) \(msg)")
}

