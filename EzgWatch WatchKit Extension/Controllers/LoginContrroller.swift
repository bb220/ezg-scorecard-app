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
        UserDefaults.standard.integer(forKey: "roundIndex")
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
            checkLogin()
        }
    }
    
    func checkLogin() {
        if UserDefaults.standard.string(forKey: "userId") != nil && UserDefaults.standard.string(forKey: "userId") != "" {
            DispatchQueue.main.async {
                let nextControllerName = "InterfaceController"
                self.pushController(withName: nextControllerName, context: nil)
                WKInterfaceController.reloadRootPageControllers(withNames: [nextControllerName], contexts: nil, orientation: .vertical, pageIndex: 0)
            }
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            if let token = session.receivedApplicationContext["token"] as? String {
                UserDefaults.standard.set("\(token)", forKey: "token")
            }
            if let userId = session.receivedApplicationContext["userId"] as? String {
                UserDefaults.standard.set("\(userId)", forKey: "userId")
            }
        } else {
            print("Session not activated in WatchOS.")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let holeNumber = message["holeNumber"] as? Int, let currentRoundId = message["currentRoundId"] as? String {
            self.currentRoundId = currentRoundId
            self.holeNumber = holeNumber
            let data = ["holeNumber": holeNumber, "currentRoundId": currentRoundId] as [String : Any]
            NotificationCenter.default.post(name: NSNotification.Name("updateHoleData"), object: nil, userInfo: data)
        }
        if let deactivateRound = message["deactivateRound"] as? Bool {
            let data = ["deactivateRound": deactivateRound]
            NotificationCenter.default.post(name: NSNotification.Name("deactivateRound"), object: nil, userInfo: data)
        }
        if let roundIndex = message["roundIndex"] as? Int {
            UserDefaults.standard.set(roundIndex, forKey: "roundIndex")
        }
        if let token = message["token"] as? String {
            UserDefaults.standard.set("\(token)", forKey: "token")
        }
        if let userId = message["userId"] as? String {
            UserDefaults.standard.set("\(userId)", forKey: "userId")
            checkLogin()
            if UserDefaults.standard.string(forKey: "userId") == "" {
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
            let data = ["holeNumber": holeNumber, "currentRoundId": currentRoundId] as [String : Any]
            NotificationCenter.default.post(name: NSNotification.Name("updateHoleData"), object: nil, userInfo: data)
        }
        if let deactivateRound = userInfo["deactivateRound"] as? Bool {
            let data = ["deactivateRound": deactivateRound]
            NotificationCenter.default.post(name: NSNotification.Name("deactivateRound"), object: nil, userInfo: data)
        }
        if let roundIndex = userInfo["roundIndex"] as? Int {
            UserDefaults.standard.set(roundIndex, forKey: "roundIndex")
        }
        if let token = userInfo["token"] as? String {
            UserDefaults.standard.set("\(token)", forKey: "token")
        }
        if let userId = userInfo["userId"] as? String {
            UserDefaults.standard.set("\(userId)", forKey: "userId")
            checkLogin()
            if UserDefaults.standard.string(forKey: "userId") == "" {
                DispatchQueue.main.async {
                    let nextControllerName = "LoginController"
                    self.pushController(withName: nextControllerName, context: nil)
                    WKInterfaceController.reloadRootPageControllers(withNames: [nextControllerName], contexts: nil, orientation: .vertical, pageIndex: 0)
                }
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        let data = messageData
        do {
            let decoder = JSONDecoder()
            let decodedObject = try decoder.decode(GetHoleList.self, from: data)
            self.holeModel = decodedObject.data ?? []
            DispatchQueue.main.async { [self] in
                holeModel = holeModel.reversed()
                let data = ["holeModel":holeModel]
                NotificationCenter.default.post(name: NSNotification.Name("holeModel"), object: nil, userInfo: data)
            }
        } catch {
            print("Error decoding JSON data: \(error.localizedDescription)")
        }
    }

}
