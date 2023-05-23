//
//  LoginController.swift
//  EzgIOS
//
//  Created by Ahmed Abdeen on 22/01/2023.
//

import UIKit
import RxSwift
import BEMCheckBox
import WatchConnectivity

class RegisterController: UIViewController {
    
    // MARK: - View Model
    
    var viewModel = RegisterViewModel()
    let disposeBag = DisposeBag()
    
    // MARK: - Properties
    
    @IBOutlet weak var textFieldEmail: UITextField!
    
    @IBOutlet weak var textFieldPassword: UITextField!
    
    @IBOutlet weak var btnRegister: UIButton!
    
    @IBOutlet weak var cbAgree: BEMCheckBox!
    
    
    // MARK: - Variables
    let session = WCSession.default
    
    // MARK: - View Methods
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
    }
    
    private func initViews(){
        btnRegister.layer.cornerRadius = 10
        cbAgree.boxType = .square
    }
    
    // MARK: - Validate
    
    private func validateForm() -> Bool {
        
        if(textFieldEmail.text!.isEmpty || textFieldPassword.text!.isEmpty){
            Utility.showAlertNew(message: "Please fill all the required fields", context: self)
            return false
        }
        
        if(!cbAgree.on){
            Utility.showAlertNew(message: "Please agree our terms first", context: self)
            return false
        }
        
        return true
        
    }
    
    // MARK: - Action
    
    @IBAction func didTapSignInBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapRegisterBtn(_ sender: Any) {
        
        if validateForm() {
            register()
        }
        
    }
    
    // MARK: - Network
    
    private func register(){
        
        Utility.showProgressDialog(view: self.view)
        
        let params: [String: Any] = [
            "email": (textFieldEmail.text ?? ""),
            "password": (textFieldPassword.text ?? "")
        ]
        
        viewModel.register(params: params)
            .subscribe(onCompleted: { [self] in
                login()
            }, onError: { (error) in
                Utility.hideProgressDialog(view: self.view)
                Utility.showAlertNew(message: "An account with this email already exists", context: self)
            })
            .disposed(by: disposeBag)
    }
    
    private func login() {
        let viewModel = LoginViewModel()
        let params: [String: Any] = [
            "email": (textFieldEmail.text ?? ""),
            "password": (textFieldPassword.text ?? "")
        ]
        
        viewModel.login(params: params)
            .subscribe(onSuccess: { [self] message in
                if session.isReachable {
                    print("Session.isReachable inside")
                    let data = ["userId": "\(UserDefaults.standard.string(forKey: "userId") ?? "")",
                                "token": "\(UserDefaults.standard.string(forKey: "token") ?? "")"]
                    session.sendMessage(data, replyHandler: nil, errorHandler: nil)
                } else if WCSession.isSupported() {
                    print("WCSession.isSupported inside")
                    let data = ["userId": "\(UserDefaults.standard.string(forKey: "userId") ?? "")",
                                "token": "\(UserDefaults.standard.string(forKey: "token") ?? "")"]
                    session.transferUserInfo(data)
                }
                Utility.hideProgressDialog(view: self.view)
                Utility.isAcCreated = true
                Utility.openMainPageController()
                
            }, onError: { (error) in
                Utility.hideProgressDialog(view: self.view)
                Utility.showAlertNew(message: "We can't find that username and password. Please try again or create a new account.", context: self)
            })
            .disposed(by: disposeBag)
    }
    
}
