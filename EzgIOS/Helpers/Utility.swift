import Foundation
import UIKit
import SVProgressHUD
import Reachability
import Alamofire
import SwiftKeychainWrapper

class Utility {
    
    static var isAcCreated: Bool = false
    
    static func showAlert(message: String) -> UIAlertController {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        
        return alert
    }
    
    static func showAlertNew(message: String, context: UIViewController) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .cancel, handler: nil))
        context.present(alert, animated: true, completion: nil)
    }
    
    static func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    static func getDefaultColor() -> UIColor{
        return UIColor(red: 40/255.0, green: 163/255.0, blue: 230/255.0, alpha: 1.0)
    }
    
    static func showProgressDialog(view: UIView){
       view.isUserInteractionEnabled = false
        SVProgressHUD.setBackgroundColor(UIColor(named: "Primary")!)
       SVProgressHUD.setForegroundColor(UIColor.white)
       SVProgressHUD.show()
    }
    
    static func hideProgressDialog(view: UIView){
        view.isUserInteractionEnabled = true
        SVProgressHUD.dismiss()
    }
    
    static func openLogin(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let vc = UIStoryboard(name: "Authentication", bundle: nil).instantiateInitialViewController()

        if #available(iOS 13.0, *){
            if let scene = UIApplication.shared.connectedScenes.first{
                guard let windowScene = (scene as? UIWindowScene) else { return }
                print(">>> windowScene: \(windowScene)")
                let window: UIWindow = UIWindow(frame: windowScene.coordinateSpace.bounds)
                window.windowScene = windowScene
                window.rootViewController = vc
                window.makeKeyAndVisible()
                appDelegate.window = window
            }
        } else {
            appDelegate.window?.rootViewController = vc
            appDelegate.window?.makeKeyAndVisible()
        }
    }
    
    static func openMainPageController(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        
        if #available(iOS 13.0, *){
            if let scene = UIApplication.shared.connectedScenes.first{
                guard let windowScene = (scene as? UIWindowScene) else { return }
                print(">>> windowScene: \(windowScene)")
                let window: UIWindow = UIWindow(frame: windowScene.coordinateSpace.bounds)
                window.windowScene = windowScene //Make sure to do this
                window.rootViewController = vc
                window.makeKeyAndVisible()
                appDelegate.window = window
            }
        } else {
            appDelegate.window?.rootViewController = vc
            appDelegate.window?.makeKeyAndVisible()
        }
    }
    
    static func isValidateToken(completion: @escaping (Bool) -> Void) {
        let tokenExpireAt = UserDefaults.standard.integer(forKey: "tokenExpireAt")
        let currentTimestamp = Int(Date().timeIntervalSince1970 * 1000)
        if currentTimestamp < tokenExpireAt {
            completion(true)
        } else {
            completion(false)
        }
    }
    
    static func refreshToken(completion: @escaping (Bool) -> Void) {
        let parameters: Parameters = ["refresh_token": "\(UserDefaults.standard.string(forKey: "refreshToken") ?? "")"]
        let url = "\(Global.sharedInstance.baseUrl)user/access_token"
        Alamofire.request(url, method: .post, parameters: parameters).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any], let data = json["data"] as? [String: Any] {
                    let access_token = data["access_token"] as? String
                    let refresh_token = data["refresh_token"] as? String
                    let token_expire_at = data["token_expire_at"] as? Int64
                    UserDefaults.standard.set(access_token, forKey: "token")
                    UserDefaults.standard.set(refresh_token, forKey: "refreshToken")
                    UserDefaults.standard.set(token_expire_at, forKey: "tokenExpireAt")
                    KeychainWrapper.standard.set(access_token ?? "", forKey: "accessToken")
                    KeychainWrapper.standard.set(refresh_token ?? "", forKey: "refreshToken")
                    completion(true)
                }
            case .failure(let error):
                print("API Error: \(error)")
                completion(false)
            }
        }
    }
    
    /*static func isLoggedIn(context: UIViewController) -> Bool {
        if Global.sharedInstance.userData == nil {
            loginRedirectAlert(context: context)
            return false
        }
        
        return true
    }*/

    
}
