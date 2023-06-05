//
//  LoginContrroller.swift
//  EzgWatch WatchKit Extension
//
//  Created by iMac on 06/03/23.
//

import WatchKit
import Foundation
import WatchConnectivity

class LoginContrroller: WKInterfaceController, WCSessionDelegate {
    
    let session = WCSession.default
    var holeModel: [HoleData] = []
    var holeNumber: Int = 0
    var currentRoundId: String = ""
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
            checkLogin()
        }
    }
    
    func checkLogin() {
        if UserDefaults.standard.string(forKey: "userId") != nil && UserDefaults.standard.string(forKey: "userId") != "" {
            DispatchQueue.main.async { [self] in
                if holeNumber == 0 && currentRoundId == "" {
                    holeModel.removeAll()
                    let nextControllerName = "OpenRoundMsgController"
                    self.pushController(withName: nextControllerName, context: nil)
                    WKInterfaceController.reloadRootPageControllers(withNames: [nextControllerName], contexts: nil, orientation: .vertical, pageIndex: 0)
                } else {
                    holeModel.removeAll()
                    let nextControllerName = "InterfaceController"
                    if let visibleController = WKExtension.shared().visibleInterfaceController {
                        if !(visibleController is InterfaceController) {
                            self.pushController(withName: nextControllerName, context: nil)
                            WKInterfaceController.reloadRootPageControllers(withNames: [nextControllerName], contexts: nil, orientation: .vertical, pageIndex: 0)
                        }
                    }
                }
            }
        }
    }
    
    func checkRoundOpen() {
        if UserDefaults.standard.string(forKey: "userId") != nil && UserDefaults.standard.string(forKey: "userId") != "" {
            DispatchQueue.main.async { [self] in
                if holeNumber == 0 && currentRoundId == "" {
                    holeModel.removeAll()
                    let nextControllerName = "OpenRoundMsgController"
                    self.pushController(withName: nextControllerName, context: nil)
                    WKInterfaceController.reloadRootPageControllers(withNames: [nextControllerName], contexts: nil, orientation: .vertical, pageIndex: 0)
                } else {
                    let nextControllerName = "InterfaceController"
                    if let visibleController = WKExtension.shared().visibleInterfaceController {
                        if !(visibleController is InterfaceController) {
                            self.pushController(withName: nextControllerName, context: nil)
                            WKInterfaceController.reloadRootPageControllers(withNames: [nextControllerName], contexts: nil, orientation: .vertical, pageIndex: 0)
                        }
                    }
                    let data = ["holeNumber": holeNumber, "currentRoundId": currentRoundId] as [String : Any]
                    NotificationCenter.default.post(name: NSNotification.Name("updateHoleData"), object: nil, userInfo: data)
                    let data1 = ["holeModel":holeModel]
                    NotificationCenter.default.post(name: NSNotification.Name("holeModel"), object: nil, userInfo: data1)
                }
            }
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            print("Session activated in WatchOS.")
        } else {
            print("Session not activated in WatchOS.")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let holeNumber = message["holeNumber"] as? Int, let currentRoundId = message["currentRoundId"] as? String {
            self.currentRoundId = currentRoundId
            self.holeNumber = holeNumber
            print("didReceiveMessage currentRoundId :-",currentRoundId,"holeNumber :-",holeNumber)
            DispatchQueue.main.async {
                self.checkRoundOpen()
            }
        }
        if let deactivateRound = message["deactivateRound"] as? Bool {
            let data = ["deactivateRound": deactivateRound]
            NotificationCenter.default.post(name: NSNotification.Name("deactivateRound"), object: nil, userInfo: data)
        }
        if let token = message["token"] as? String {
            UserDefaults.standard.set("\(token)", forKey: "token")
            print("didReceiveMessage token:\(UserDefaults.standard.string(forKey: "token") ?? "")")
        }
        if let refreshToken = message["refreshToken"] as? String {
            UserDefaults.standard.set("\(refreshToken)", forKey: "refreshToken")
            print("didReceiveMessage refreshToken:\(UserDefaults.standard.string(forKey: "refreshToken") ?? "")")
        }
        if let tokenExpireAt = message["tokenExpireAt"] as? Int64 {
            UserDefaults.standard.set(tokenExpireAt, forKey: "tokenExpireAt")
            print("didReceiveMessage tokenExpireAt:\(UserDefaults.standard.integer(forKey: "tokenExpireAt"))")
        }
        if let userId = message["userId"] as? String {
            UserDefaults.standard.set("\(userId)", forKey: "userId")
            print("didReceiveMessage userId:\(UserDefaults.standard.string(forKey: "userId") ?? "")")
            checkLogin()
            if UserDefaults.standard.string(forKey: "userId") == "" {
                UserDefaults.standard.set("", forKey: "token")
                UserDefaults.standard.set("", forKey: "refreshToken")
                UserDefaults.standard.set(0, forKey: "tokenExpireAt")
                DispatchQueue.main.async {
                    let nextControllerName = "LoginController"
                    self.pushController(withName: nextControllerName, context: nil)
                    WKInterfaceController.reloadRootPageControllers(withNames: [nextControllerName], contexts: nil, orientation: .vertical, pageIndex: 0)
                }
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        if let holeNumber = userInfo["holeNumber"] as? Int, let currentRoundId = userInfo["currentRoundId"] as? String {
            self.currentRoundId = currentRoundId
            self.holeNumber = holeNumber
            print("didReceiveUserInfo currentRoundId :-",currentRoundId,"holeNumber :-",holeNumber)
            DispatchQueue.main.async {
                self.checkRoundOpen()
            }
        }
        if let deactivateRound = userInfo["deactivateRound"] as? Bool {
            let data = ["deactivateRound": deactivateRound]
            NotificationCenter.default.post(name: NSNotification.Name("deactivateRound"), object: nil, userInfo: data)
        }
        if let token = userInfo["token"] as? String {
            UserDefaults.standard.set("\(token)", forKey: "token")
            print("didReceiveUserInfo token:\(UserDefaults.standard.string(forKey: "token") ?? "")")
        }
        if let refreshToken = userInfo["refreshToken"] as? String {
            UserDefaults.standard.set("\(refreshToken)", forKey: "refreshToken")
            print("didReceiveUserInfo refreshToken:\(UserDefaults.standard.string(forKey: "refreshToken") ?? "")")
        }
        if let tokenExpireAt = userInfo["tokenExpireAt"] as? Int64 {
            UserDefaults.standard.set(tokenExpireAt, forKey: "tokenExpireAt")
            print("didReceiveUserInfo tokenExpireAt:\(UserDefaults.standard.string(forKey: "tokenExpireAt") ?? "")")
        }
        if let userId = userInfo["userId"] as? String {
            UserDefaults.standard.set("\(userId)", forKey: "userId")
            print("didReceiveUserInfo userId:\(UserDefaults.standard.string(forKey: "userId") ?? "")")
            checkLogin()
            if UserDefaults.standard.string(forKey: "userId") == "" {
                UserDefaults.standard.set("", forKey: "token")
                UserDefaults.standard.set("", forKey: "refreshToken")
                UserDefaults.standard.set(0, forKey: "tokenExpireAt")
                DispatchQueue.main.async {
                    let nextControllerName = "LoginController"
                    self.pushController(withName: nextControllerName, context: nil)
                    WKInterfaceController.reloadRootPageControllers(withNames: [nextControllerName], contexts: nil, orientation: .vertical, pageIndex: 0)
                }
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        do {
            let decoder = JSONDecoder()
            let decodedObject = try decoder.decode(GetHoleList.self, from: messageData)
            self.holeModel = decodedObject.data ?? []
            DispatchQueue.main.async { [self] in
                holeModel = holeModel.reversed()
                print("didReceiveMessageData HoleModel Count:-",holeModel.count)
                let data = ["holeModel":holeModel]
                NotificationCenter.default.post(name: NSNotification.Name("holeModel"), object: nil, userInfo: data)
            }
        } catch {
            print("Error decoding JSON data: \(error.localizedDescription)")
        }
    }

}
