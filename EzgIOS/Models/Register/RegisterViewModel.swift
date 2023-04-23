//
//  RegisterViewModel.swift
//  TalibayatiIOS
//
//  Created by A.Abdeen on 1/2/21.
//

import Foundation

import RxSwift
import Moya
import SwiftyJSON
import SwiftKeychainWrapper

class RegisterViewModel {
    
    let provider = NetworkManager()
 
    func register(params: [String: Any]) -> Completable {
        
        return .create (subscribe: { observer in
            
            self.provider.register(params: params)
                .subscribe(onCompleted: {
                    
                    observer(.completed)
                    
                }, onError: { error in
                    observer(.error(error))
                })
        })
        
    }
    
}
