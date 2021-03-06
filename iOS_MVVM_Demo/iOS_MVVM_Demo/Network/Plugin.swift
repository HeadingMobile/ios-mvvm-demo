//
//  Plugin.swift
//  RxSwift_Part1
//
//  Created by shengling on 2018/6/14.
//  Copyright © 2018 ShengLing. All rights reserved.
//

import Foundation
import Alamofire

protocol Plugin {
    
    func willSendRequest(_ request: URLRequestConvertible)
    
    func didReceiverResponse(_ response: DataResponse<Any>?)
}

struct TokenPlugin: Plugin {
    func willSendRequest(_ request: URLRequestConvertible) {
        if let token = Token.current {
            Alamofire.SessionManager.default.session.configuration.httpCookieStorage?.setCookie(token)
        }
    }
    func didReceiverResponse(_ response: DataResponse<Any>?) {
        guard let condition = response?.request?.url?.absoluteString else { return }
        if condition != "https://api.github.com/user" { return }
        if let headerFields = response?.response?.allHeaderFields as? [String: String],
            let url = response?.request?.url {
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url)
            if let cookie = cookies.first {
                Token.setToken(token: cookie)
            }
        }
        if let header = response?.request?.allHTTPHeaderFields, let value = header[Token.headerKey] {
            Token.setHeader(header: [Token.headerKey: value])
        }
    }
}

struct PrintPlugin: Plugin {
    func willSendRequest(_ request: URLRequestConvertible) {
//        #if dubug
        do {
            debugPrint(try request.asURLRequest().debugDescription)
        } catch {
            print(error)
        }
//        #endif
    }
    func didReceiverResponse(_ response: DataResponse<Any>?) {
//        #if debug
        debugPrint(response?.description ?? "")
//        #endif
    }
}
