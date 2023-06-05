//
//  FinishRoundController.swift
//  EzgWatch WatchKit Extension
//
//  Created by iMac on 06/03/23.
//

import WatchKit
import Foundation
import WatchConnectivity
import Alamofire

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    var stroke = 0
    var put = 0
    var total = 0
    var hole = 1
    var finishRoundValue = false
    let session = WCSession.default
    var baseUrl = "https://api.ezgolftech.com/api/v1/"
    var temp = false
    var swipe = true
    var holeModel: [HoleData] = []
    var userInteraction: Bool = false
    var modelUpdate: Bool = true
    var deactivate: Bool = false
    
    @IBOutlet weak var totalLabel: WKInterfaceLabel!
    @IBOutlet weak var strokeLabel: WKInterfaceLabel!
    @IBOutlet weak var putLabel: WKInterfaceLabel!
    
    
    override func awake(withContext context: Any?) {
        updateLabel()
        NotificationCenter.default.addObserver(self, selector: #selector(deactivateRound(_:)), name: NSNotification.Name("deactivateRound"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateHoleInfo(_:)), name: NSNotification.Name("updateHoleData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateHoleModel(_:)), name: NSNotification.Name("holeModel"), object: nil)
    }
    
    func updateLabel() {
        setTitle("Hole \(hole)")
        setPut(val: put)
        setStroke(val: stroke)
        setTotal(val: total)
    }
    
    @objc func updateHoleModel(_ notification: Notification) {
        if let data = notification.userInfo as? [String: Any] {
            if modelUpdate {
                holeModel = data["holeModel"] as! [HoleData]
                swipe = true
            } else {
                modelUpdate = true
                holeModel.removeAll()
            }
        }
    }
    
    @objc func updateHoleInfo(_ notification: Notification) {
        if let data = notification.userInfo as? [String: Any] {
            modelUpdate = true
            deactivate = false
            let holeNumber = data["holeNumber"] as! Int
            let currentRoundId = data["currentRoundId"] as! String
            DispatchQueue.main.async { [self] in
                if holeNumber == 19 {
                    UserDefaults.standard.set("\(currentRoundId)", forKey: "roundID")
                    if holeModel.count > 0 {
                        let index = holeNumber - 2
                        hole = holeNumber - 1
                        total = holeModel[index].score ?? 0
                        put = holeModel[index].putts ?? 0
                        stroke = total - put
                        swipe = true
                        DispatchQueue.main.async { [self] in
                            updateLabel()
                        }
                        print("Hole:\(hole)|Put:\(put)|Stroke:\(stroke)|total:\(total)")
                    }
                } else {
                    UserDefaults.standard.set("\(currentRoundId)", forKey: "roundID")
                    hole = holeNumber
                    stroke = 0
                    put = 0
                    total = 0
                    swipe = true
                    DispatchQueue.main.async { [self] in
                        updateLabel()
                    }
                    print("Hole:\(hole)|Put:\(put)|Stroke:\(stroke)|total:\(total)")
                }
            }
        }
    }
    
    @objc func deactivateRound(_ notification: Notification) {
        if let data = notification.userInfo as? [String: Bool] {
            let deactivateRound = data["deactivateRound"]
            if deactivateRound == true {
                holeModel.removeAll()
                swipe = true
                deactivate = true
                hole = 1
                stroke = 0
                put = 0
                total = 0
                DispatchQueue.main.async { [self] in
                    updateLabel()
                }
            }
        }
    }
    
    func createHoleAPI(val: Bool) {
        isValidateToken { [self] isValid in
            if isValid {
                createHole(val: val)
            } else {
                refreshToken { [self] success in
                    if success {
                        createHole(val: val)
                    } else {
                        print("Error in createHoleAPI")
                    }
                }
            }
        }
    }
    
    func createHole(val: Bool) {
        let parameters: Parameters = [
            "round": "\(UserDefaults.standard.string(forKey: "roundID") ?? "")",
            "number": hole,
            "par":1 ,
            "score": total,
            "putts": put
        ]
        let token = "\(UserDefaults.standard.string(forKey: "token") ?? "")"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        let url = "\(baseUrl)hole/"
        Alamofire.request(url, method: .post, parameters: parameters, headers: headers).responseJSON { response in
            switch response.result {
            case .success(_):
                DispatchQueue.main.async { [self] in
                    if val {
                        if hole < 18 {
                            hole += 1
                            put = 0
                            stroke = 0
                            total = 0
                        }
                        swipe = true
                        DispatchQueue.main.async { [self] in
                            updateLabel()
                        }
                        if session.isReachable {
                            session.sendMessage(["roundAPI": true, "holeAPI": true], replyHandler: nil)
                        } else if WCSession.isSupported() {
                            session.transferUserInfo(["roundAPI": true, "holeAPI": true])
                        }
                    } else if !val {
                        print("HoleModelCount on createHole:-",holeModel.count,"hole:-",hole)
                        if holeModel.count >= hole - 1 {
                            print("createHole Val = False")
                            if session.isReachable {
                                session.sendMessage(["roundAPI": true, "holeAPI": true], replyHandler: nil)
                            } else if WCSession.isSupported() {
                                session.transferUserInfo(["roundAPI": true, "holeAPI": true])
                            }
                            put = holeModel[hole-2].putts ?? 0
                            total = holeModel[hole-2].score ?? 0
                            stroke = total - put
                            hole = holeModel[hole-2].number ?? 0
                            swipe = true
                            DispatchQueue.main.async { [self] in
                                updateLabel()
                            }
                        }
                    }
                    userInteraction = false
                }
            case .failure(let error):
                print("API error: \(error)")
            }
        }
    }
    
    func updateHoleAPI(val: Bool) {
        isValidateToken { [self] isValid in
            if isValid {
                updateHole(val: val)
            } else {
                refreshToken { [self] success in
                    if success {
                        updateHole(val: val)
                    } else {
                        print("Error in updateHoleAPI")
                    }
                }
            }
        }
    }
    
    func updateHole(val: Bool) {
        let parameters: Parameters = [
            "round": "\(UserDefaults.standard.string(forKey: "roundID") ?? "")",
            "number": hole,
            "par":1 ,
            "score": total,
            "putts": put
        ]
        let headers: HTTPHeaders = ["Authorization": "Bearer \(UserDefaults.standard.string(forKey: "token") ?? "")"]
        let holeId = holeModel[hole - 1].Id ?? "0"
        let url = "\(baseUrl)hole/\(holeId)"
        Alamofire.request(url, method: .put, parameters: parameters, headers: headers).responseJSON { [self] response in
            switch response.result {
            case .success:
                if session.isReachable {
                    session.sendMessage(["roundAPI": true, "holeAPI": true], replyHandler: nil)
                }
                if val == true {
                    if holeModel.count > hole {
                        put = holeModel[hole].putts ?? 0
                        total = holeModel[hole].score ?? 0
                        stroke = total - put
                        hole = holeModel[hole].number ?? 0
                        DispatchQueue.main.async { [self] in
                            updateLabel()
                        }
                    } else if deactivate == false && hole < 18{
                        put = 0
                        total = 0
                        stroke = 0
                        hole = hole + 1
                        DispatchQueue.main.async { [self] in
                            updateLabel()
                        }
                    }
                } else if val == false {
                    if holeModel[hole-2].number == hole-1 {
                        put = holeModel[hole-2].putts ?? 0
                        total = holeModel[hole-2].score ?? 0
                        stroke = total - put
                        hole = holeModel[hole-2].number ?? 0
                        DispatchQueue.main.async { [self] in
                            updateLabel()
                        }
                    }
                }
                userInteraction = false
            case .failure:
                print("API Error")
            }
        }
    }
    
    func isValidateToken(completion: @escaping (Bool) -> Void) {
        let tokenExpireAt = Int64(UserDefaults.standard.string(forKey: "tokenExpireAt") ?? "0")
        let currentTimestamp = Int64(Date().timeIntervalSince1970 * 1000)
        
        if currentTimestamp < tokenExpireAt ?? 0 {
            completion(true)
        } else {
            completion(false)
        }
    }
    
    func refreshToken(completion: @escaping (Bool) -> Void) {
        let parameters: Parameters = ["refresh_token": "\(UserDefaults.standard.string(forKey: "refreshToken") ?? "")"]
        let url = "\(baseUrl)user/access_token"
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
                    completion(true)
                }
            case .failure(let error):
                print("API Error: \(error)")
                completion(false)
            }
        }
    }
    
    @IBAction func swipedNext(_ sender: Any) {
        if swipe {
            swipe = false
            if holeModel.count >= hole {
                if userInteraction && holeModel[hole-1].number == hole {
                    if hole == 18 {
                        updateHoleAPI(val: true)
                        self.presentController(withName: "FinishRoundController", context: nil)
                    } else {
                        updateHoleAPI(val: true)
                    }
                } else if !userInteraction {
                    if holeModel.count > hole {
                        put = holeModel[hole].putts ?? 0
                        total = holeModel[hole].score ?? 0
                        stroke = total - put
                        hole = holeModel[hole].number ?? 0
                        DispatchQueue.main.async { [self] in
                            updateLabel()
                        }
                    } else if hole == 18 {
                        self.presentController(withName: "FinishRoundController", context: nil)
                    } else {
                        hole = hole + 1
                        put = 0
                        stroke = 0
                        total = 0
                        DispatchQueue.main.async { [self] in
                            updateLabel()
                        }
                    }
                    swipe = true
                }
            } else {
                if hole == 18 {
                    createHoleAPI(val: true)
                    self.presentController(withName: "FinishRoundController", context: nil)
                } else {
                    createHoleAPI(val: true)
                }
            }
        }
    }
    
    @IBAction func swipedPrevious(_ sender: Any) {
        if hole > 1 && swipe == true {
            swipe = false
            if holeModel.count >= hole {
                if userInteraction {
                    updateHoleAPI(val: false)
                } else if !userInteraction && holeModel.count >= hole - 1 {
                    put = holeModel[hole-2].putts ?? 0
                    total = holeModel[hole-2].score ?? 0
                    stroke = total - put
                    hole = holeModel[hole-2].number ?? 0
                    DispatchQueue.main.async { [self] in
                        updateLabel()
                    }
                    swipe = true
                }
            } else if hole <= 18 {
                createHoleAPI(val: false)
            }
        }
    }
    
    @IBAction func puttLongPush(_ sender: Any) {
        let v = sender as! WKLongPressGestureRecognizer
        if v.state == .began {
            if(put > 0){
                put = put - 1
            }
            setPut(val: put)
            total = put + stroke
            setTotal(val: total)
            userInteraction = true
        }
    }
    
    @IBAction func storeLongPush(_ sender: Any) {
        let v = sender as! WKLongPressGestureRecognizer
        if v.state == .began {
            if(stroke > 0){
                stroke = stroke - 1
            }
            setStroke(val: stroke)
            total = put + stroke
            setTotal(val: total)
            userInteraction = true
        }
    }
  
    @IBAction func puttClicked() {
        put = put + 1
        setPut(val: put)
        total = put + stroke
        setTotal(val: total)
        userInteraction = true
    }
    
    @IBAction func strokeClicked() {
        stroke = stroke + 1
        setStroke(val: stroke)
        total = put + stroke
        setTotal(val: total)
        userInteraction = true
    }
    
    func setPut(val :Int){
        if(val<=0){
            putLabel.setText("-")
        }else{
            putLabel.setText("\(val)")
        }
    }
    
    func setStroke(val :Int){
        if(val<=0){
            strokeLabel.setText("-")
        }else{
            strokeLabel.setText("\(val)")
        }
    }
    
    func setTotal(val :Int){
        if(val<=0){
            totalLabel.setText("-")
        }else{
            totalLabel.setText("\(val)")
        }
    }
    
    override func willActivate() {
        temp = true
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name("response"), object: nil)
    }
    
    @objc func handleNotification(_ notification: Notification) {
        if temp {
            temp = false
            if let data = notification.userInfo as? [String: Bool] {
                if data["call"] == true {
                    DispatchQueue.main.async { [self] in
                        if session.isReachable {
                            session.sendMessage(["popToMain": true], replyHandler: nil)
                        } else if WCSession.isSupported() {
                            session.transferUserInfo(["popToMain": true])
                        }
                        let nextControllerName = "OpenRoundMsgController"
                        self.pushController(withName: nextControllerName, context: nil)
                        WKInterfaceController.reloadRootPageControllers(withNames: [nextControllerName], contexts: nil, orientation: .vertical, pageIndex: 0)
                    }
                    
                }
            }
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("error :- \(error.localizedDescription)")
        }
        print("ACTIVATION COMPLETE in WatchOS")
    }
}
