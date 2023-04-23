//
//  NetworkAdapter.swift
//  Kelkou TV
//
//  Created by Mac on 8/1/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import RxSwift
import Moya

class NetworkManager: NSObject {
        
    let provider = MoyaProvider<NetworkService>(plugins: [NetworkLoggerPlugin(verbose: true)])
    
    // MARK: - User
    
    func login(params: [String: Any]) -> Single<Any> {
        return provider.rx
            .request(.login(params: params))
            .filter(statusCode: 200)
            .mapJSON()
    }
    
    func register(params: [String: Any]) -> Completable {
        return provider.rx
            .request(.register(params: params))
            .filter(statusCode: 200)
            .asObservable()
            .ignoreElements()
    }
    
}
