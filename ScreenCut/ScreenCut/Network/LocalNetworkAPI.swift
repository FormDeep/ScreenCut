//
//  LocalNetworkAPI.swift
//  ScreenCut
//
//  Created by helinyu on 2024/11/7.
//

import Moya
import Combine
import Foundation

enum LocalNetworkAPI {
    case translate(text: String)
}

extension LocalNetworkAPI: TargetType {
    var method: Moya.Method {
        return .post
    }
    
    var task: Moya.Task {
        switch self {
           case .translate(let text):
               let parameters = ["text": text]
               return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
           }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
    var baseURL: URL {
        return URL(string: "http://127.0.0.1:5000")!
    }
    
    var path: String {
        switch self {
        case .translate:
            return "/translate"
        }
    }
}


//let provider = MoyaProvider<MyAPI>()
//var cancellables = Set<AnyCancellable>()  // 用于存储订阅

// 定义一个用户模型
struct Translate: Codable {
    let text: String
}


