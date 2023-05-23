//
//  LoginController.swift
//  EzgIOS
//
//  Created by Ahmed Abdeen on 22/01/2023.
//

import UIKit
import RxSwift
import WatchConnectivity

class LoginController: UIViewController {
    
    // MARK: - View Model
    
    var viewModel = LoginViewModel()
    let disposeBag = DisposeBag()
    let session = WCSession.default
    
    // MARK: - Properties
    
    @IBOutlet weak var textFieldEmail: UITextField!
    
    @IBOutlet weak var textFieldPassword: UITextField!
    
    @IBOutlet weak var btnSignIn: UIButton!
    
    // MARK: - Variables
    
    // MARK: - View Methods
    

    override func viewDidLoad() {
        super.viewDidLoad()

        initViews()
    }
    
    private func initViews(){
        btnSignIn.layer.cornerRadius = 10
    }
    
    // MARK: - Validate
    
    private func validateForm() -> Bool {
        
        if(textFieldEmail.text!.isEmpty || textFieldPassword.text!.isEmpty){
            Utility.showAlertNew(message: "Please fill all the required fields", context: self)
            return false
        }
        
        return true
        
    }
    
    // MARK: - Action
    
    @IBAction func didTapSignInBtn(_ sender: Any) {
        
        if validateForm() {
            login()
        }
        
    }
    
    // MARK: - Network
    
    private func login(){
        
        Utility.showProgressDialog(view: self.view)
        
        let params: [String: Any] =
            ["email": (textFieldEmail.text ?? ""),
             "password": (textFieldPassword.text ?? "")
        ]
        
        viewModel.login(params: params)
            .subscribe(onSuccess: { [self] message in
                if session.isReachable {
                    let data = ["userId": "\(UserDefaults.standard.string(forKey: "userId") ?? "")",
                                  "token": "\(UserDefaults.standard.string(forKey: "token") ?? "")",
                                "refreshToken":"\(UserDefaults.standard.string(forKey: "refreshToken") ?? "")",
                                "tokenExpireAt": UserDefaults.standard.integer(forKey: "tokenExpireAt")] as [String : Any]
                    session.sendMessage(data, replyHandler: nil, errorHandler: nil)
                } else if WCSession.isSupported() {
                    let data = ["userId": "\(UserDefaults.standard.string(forKey: "userId") ?? "")",
                                  "token": "\(UserDefaults.standard.string(forKey: "token") ?? "")",
                                "refreshToken":"\(UserDefaults.standard.string(forKey: "refreshToken") ?? "")",
                                "tokenExpireAt": UserDefaults.standard.integer(forKey: "tokenExpireAt")] as [String : Any]
                    session.transferUserInfo(data)
                }
                
                Utility.hideProgressDialog(view: self.view)
                
                Utility.openMainPageController()
                
            }, onError: { (error) in
                Utility.hideProgressDialog(view: self.view)
                Utility.showAlertNew(message: "We can't find that username and password. Please try again or create a new account.", context: self)
            })
        .disposed(by: disposeBag)
    }

}
