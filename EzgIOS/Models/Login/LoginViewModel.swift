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

class LoginViewModel {
    
    let provider = NetworkManager()
 
    func login(params: [String: Any]) -> Single<Any> {
        
        return .create (subscribe: { observer in
            
            self.provider.login(params: params)
                .subscribe(onSuccess: { response in
                    
                    do {
                        let json = JSON(response)
                        
                        let accessToken = json["data"]["token"].string
                        
                        let email = json["data"]["email"].string
                        
                        let id = json["data"]["_id"].string
                                            
                        //Save access token to KeyChain Wrapper
                        let _: Bool = KeychainWrapper.standard.set(accessToken!, forKey: "accessToken")
                        
                        let _: Bool = KeychainWrapper.standard.set(email!, forKey: "email")
                        
                        let _: Bool = KeychainWrapper.standard.set(id!, forKey: "id")
                        
                        Global.sharedInstance.token = accessToken!
                        UserDefaults.standard.set("\(id ?? "")", forKey: "userId")
                        UserDefaults.standard.set("\(accessToken ?? "")", forKey: "token")
                        
                        observer(.success("Login Success..."))
                        
                    }
                    
                    
                }, onError: { error in
                    observer(.error(error))
                })
        })
        
    }
    
}
