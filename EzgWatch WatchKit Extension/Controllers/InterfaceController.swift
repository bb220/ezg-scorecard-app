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
                }
            }
            else {
                UserDefaults.standard.set("\(currentRoundId)", forKey: "roundID")
                hole = holeNumber
                stroke = 0
                put = 0
                total = 0
                swipe = true
                DispatchQueue.main.async { [self] in
                    updateLabel()
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
    
    func createRoundAPI() {
        let roundIndex = UserDefaults.standard.integer(forKey: "roundIndex") + 1
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayDate = dateFormatter.string(from: Date())
        let parameters: Parameters = [
            "name": "Round \(roundIndex)",
            "played_date": "\(todayDate)"
        ]
        UserDefaults.standard.set(roundIndex, forKey: "roundIndex")
        let token = "\(UserDefaults.standard.string(forKey: "token") ?? "")"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        let url = "\(baseUrl)round/"
        Alamofire.request(url, method: .post, parameters: parameters, headers: headers).responseJSON { response in
            switch response.result {
            case .success(_):
                let model = try? JSONDecoder().decode(GetRoundId.self, from: response.data!)                
                DispatchQueue.main.async {
                    UserDefaults.standard.set("\(model?.data?.Id ?? "")", forKey: "roundID")
                    self.createHoleAPI(val: true)
                }
            case .failure(let error):
                print("API error: \(error)")
            }
        }
    }
    
    func createHoleAPI(val: Bool) {
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
                        hole += 1
                        if hole == 19 {
                            hole = 1
                            holeModel.removeAll()
                        }
                        put = 0
                        stroke = 0
                        total = 0
                        swipe = true
                        DispatchQueue.main.async { [self] in
                            updateLabel()
                        }
                        if session.isReachable {
                            if hole == 2 {
                                session.sendMessage(["roundAPI": true, "scorecardVC": true], replyHandler: nil)
                            } else {
                                session.sendMessage(["roundAPI": true, "holeAPI": true], replyHandler: nil)
                            }
                        } else if WCSession.isSupported() {
                            session.transferUserInfo(["roundAPI": true, "holeAPI": true])
                        }
                    } else if !val {
                        if holeModel.count >= hole - 1 {
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
                    if hole == 18 {
                        holeModel.removeAll()
                        put = 0
                        stroke = 0
                        total = 0
                        hole = 1
                        DispatchQueue.main.async { [self] in
                            updateLabel()
                        }
                    } else if holeModel.count > hole {
                        put = holeModel[hole].putts ?? 0
                        total = holeModel[hole].score ?? 0
                        stroke = total - put
                        hole = holeModel[hole].number ?? 0
                        DispatchQueue.main.async { [self] in
                            updateLabel()
                        }
                    } else if deactivate == false {
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
    
    @IBAction func swipedNext(_ sender: Any) {
        if swipe {
            swipe = false
            if holeModel.count >= hole {
                if userInteraction && holeModel[hole-1].number == hole {
                    if hole == 18 {
                        let created: Bool = true
                        let context = [put, stroke, total, created] as [Any]
                        self.presentController(withName: "FinishRoundController", context: context)
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
                        let created: Bool = true
                        let context = [put, stroke, total,created] as [Any]
                        self.presentController(withName: "FinishRoundController", context: context)
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
            }
            else {
                if hole == 18 {
                    let created: Bool = false
                    let context = [put, stroke, total,created] as [Any]
                    self.presentController(withName: "FinishRoundController", context: context)
                } else {
                    if hole == 1 {
                        createRoundAPI()
                    } else {
                        createHoleAPI(val: true)
                    }
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
                if data["call"] == true && data["created"] == false {
                    modelUpdate = false
                    createHoleAPI(val: true)
                    DispatchQueue.main.async { [self] in
                        if session.isReachable {
                            session.sendMessage(["popToMain": true], replyHandler: nil)
                        } else if WCSession.isSupported() {
                            session.transferUserInfo(["popToMain": true])
                        }
                    }
                } else if data["call"] == true && data["created"] == true && holeModel.count >= hole {
                    modelUpdate = false
                    updateHoleAPI(val: true)
                    DispatchQueue.main.async { [self] in
                        if session.isReachable {
                            session.sendMessage(["popToMain": true], replyHandler: nil)
                        } else if WCSession.isSupported() {
                            session.transferUserInfo(["popToMain": true])
                        }
                    }
                } else {
                    swipe = true
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
