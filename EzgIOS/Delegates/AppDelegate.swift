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
        
        /// Set tabbar text
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20.0)], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20.0)], for: .selected)
        
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
