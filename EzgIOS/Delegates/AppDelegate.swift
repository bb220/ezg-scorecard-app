//
//  AppDelegate.swift
//  EzgIOS
//
//  Created by Ahmed Abdeen on 22/01/2023.
//

import UIKit
import WatchConnectivity

@main
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {
    
    var window: UIWindow?
    var session: WCSession?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        
        return true
    }
    
    // WCSessionDelegate methods
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            print("Session activated in iOS.")
            if WCSession.isSupported() {
                let data = ["userId": "\(UserDefaults.standard.string(forKey: "userId") ?? "")",
                            "token": "\(UserDefaults.standard.string(forKey: "token") ?? "")"]
                session.transferUserInfo(data)
            }
        } else {
            print("Session not activated in iOS.")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive in iOS")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate in iOS")
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        if let roundAPI = userInfo["roundAPI"] as? Bool {
            let data = ["roundAPI": roundAPI]
            NotificationCenter.default.post(name: NSNotification.Name("updateMainVC"), object: nil, userInfo: data)
        }
        if let holeAPI = userInfo["holeAPI"] as? Bool {
            let data = ["holeAPI": holeAPI]
            NotificationCenter.default.post(name: NSNotification.Name("updateScorecardVC"), object: nil, userInfo: data)
        }
        if let shouldShowScorecard = userInfo["popToMain"] as? Bool, shouldShowScorecard {
            let data = ["pop": shouldShowScorecard]
            NotificationCenter.default.post(name: NSNotification.Name("popToMain"), object: nil, userInfo: data)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let roundAPI = message["roundAPI"] as? Bool {
            let data = ["roundAPI": roundAPI]
            NotificationCenter.default.post(name: NSNotification.Name("updateMainVC"), object: nil, userInfo: data)
        }
        if let holeAPI = message["holeAPI"] as? Bool {
            let data = ["holeAPI": holeAPI]
            NotificationCenter.default.post(name: NSNotification.Name("updateScorecardVC"), object: nil, userInfo: data)
        }
        if let shouldShowScorecard = message["popToMain"] as? Bool, shouldShowScorecard {
            let data = ["pop": shouldShowScorecard]
            NotificationCenter.default.post(name: NSNotification.Name("popToMain"), object: nil, userInfo: data)
        }
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

@IBDesignable extension UIView
{
    
    @IBInspectable
    public var cornerRadius: CGFloat
    {
        set (radius) {
            self.layer.cornerRadius = radius
            self.layer.masksToBounds = radius > 0
        }
        
        get {
            return self.layer.cornerRadius
        }
    }
    
    @IBInspectable
    public var borderWidth: CGFloat
    {
        set (borderWidth) {
            self.layer.borderWidth = borderWidth
        }
        
        get {
            return self.layer.borderWidth
        }
    }
    
    @IBInspectable
    public var borderColor:UIColor?
    {
        set (color) {
            self.layer.borderColor = color?.cgColor
        }
        
        get {
            if let color = self.layer.borderColor
            {
                return UIColor(cgColor: color)
            } else {
                return nil
            }
        }
    }
    @IBInspectable
    public var shadowColor: UIColor? {
        set (color) {
            self.layer.shadowColor = color?.cgColor
        }
        
        get {
            if let color = self.layer.shadowColor
            {
                return UIColor(cgColor: color)
            } else {
                return nil
            }
        }
        
        
    }
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return self.layer.shadowOpacity
        }
        set {
            self.layer.shadowOpacity = newValue
        }
    }
}
class PaddingLabel: UILabel {
    
    var inset = UIEdgeInsets.zero
    
    func padding(_ top: CGFloat, _ bottom: CGFloat, _ left: CGFloat, _ right: CGFloat) {
        self.frame = CGRect(x: 0, y: 0, width: self.frame.width + left + right, height: self.frame.height + top + bottom)
        inset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: inset))
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.height += inset.top + inset.bottom
            contentSize.width += inset.left + inset.right
            return contentSize
        }
    }
}

extension UIView {
    
    // OUTPUT 1
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.06).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: -5, height: 5)
        layer.shadowRadius = 5
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}
