//
//  ScorecardViewController.swift
//  EzgIOS
//
//  Created by iMac on 10/03/23.
//

import UIKit
import Alamofire
import Foundation
import WatchConnectivity

class ScorecardViewController: UIViewController {
    
    @IBOutlet var headerView: UIView!
    @IBOutlet var frontScore: UILabel!
    @IBOutlet var backScore: UILabel!
    @IBOutlet var totalScore: UILabel!
    @IBOutlet var holesTableView: UITableView!
    @IBOutlet var scoreBoardView: UIView!
    @IBOutlet var shareButton: UIButton!
    
    let session = WCSession.default
    var holeModelData: [HoleData] = []
    var scoreArray: [String] = []
    var roundId: String = ""
    var roundName: String = ""
    var roundDate: String = ""
    var editToggle: Bool = true
    var total = 0
    var front = 0
    var back = 0
    var updatedRoundName: String = ""
    var isRoundNameEdit: Bool = false
    var updatedGolfScore: [[String: Int]] = []
    var didChangeVariableValue: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        holeListAPI(call: false)
    }
    
    func initView() {
        Utility.showProgressDialog(view: self.view)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = dateFormatter.date(from: roundDate) {
            dateFormatter.dateFormat = "MM/dd/yyyy"
            roundDate = "\(dateFormatter.string(from: date))"
        }
        title = roundName
        NotificationCenter.default.addObserver(self, selector: #selector(reloadScorecardVC(_:)), name: NSNotification.Name("updateScorecardVC"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(popToMainVC(_:)), name: NSNotification.Name("popToMain"), object: nil)
        holesTableView.separatorColor = UIColor.clear
        headerView.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        headerView.dropShadow(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.06), opacity: 1, offSet: CGSize(width: 0, height: 0), radius: 16, scale: true)
        scoreBoardView.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        scoreBoardView.dropShadow(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.1), opacity: 1, offSet: CGSize(width: 0, height: 8), radius: 16, scale: true)
        
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped(_:)))
        navigationItem.rightBarButtonItem = editButton
    }
    
    @objc final private func textEditing(textField: UITextField) {
        isRoundNameEdit = true
        updatedRoundName = textField.text ?? "Round"
    }
    
    @objc func editButtonTapped(_ sender: UIBarButtonItem) {
        if editToggle {
            updatedGolfScore.removeAll()
            editToggle = false
            shareButton.isEnabled = false
            let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonTapped(_:)))
            saveButton.tintColor = .link
            navigationItem.rightBarButtonItem = saveButton
            
            let width = UIScreen.main.bounds.width - 150 / 2
            let textField = UITextField(frame: CGRect(x: width, y: 0, width: 150, height: 40))
            textField.backgroundColor = UIColor.systemGray5
            textField.textAlignment = .center
            textField.layer.cornerRadius = 10
            textField.text = navigationItem.title
            textField.font = UIFont(name: "Rubik-Medium", size: 20)!
            textField.textColor = UIColor(red: 0, green: 0, blue: 0)
            textField.addTarget(self, action: #selector(textEditing(textField:)), for: .editingChanged)
            updatedRoundName = navigationItem.title ?? "Round"
            navigationItem.titleView = textField
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
            let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped(_:)))
            navigationItem.leftBarButtonItem = cancelButton
            
            DispatchQueue.main.async { [self] in
                editToggle = false
                holesTableView.reloadData()
            }
            
        } else {
            editToggle = true
            shareButton.isEnabled = true
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped(_:)))
        }
    }
    
    @objc func saveButtonTapped(_ sender: UIBarButtonItem) {
        if isRoundNameEdit == true {
            updateRoundNameAPI()
        }
        if updatedGolfScore.count > 0 {
            updateScoreAPI()
        }
        let navigationTitleLabel = UILabel()
        navigationTitleLabel.text = updatedRoundName
        navigationTitleLabel.sizeToFit()
        navigationTitleLabel.font = UIFont(name: "Rubik-Medium", size: 20)!
        navigationTitleLabel.textColor = UIColor(red: 0, green: 0, blue: 0)
        navigationItem.titleView = navigationTitleLabel
        navigationItem.title = updatedRoundName
        
        DispatchQueue.main.async { [self] in
            editToggle = true
            holesTableView.reloadData()
        }
        editButtonTapped(sender)
    }
    
    @objc func cancelButtonTapped(_ sender: UIBarButtonItem) {
        updatedGolfScore.removeAll()
        editButtonTapped(sender)
        navigationItem.leftBarButtonItem = nil
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Rounds", style: .plain, target: nil, action: nil)
        let navigationTitleLabel = UILabel()
        navigationTitleLabel.text = roundName
        navigationTitleLabel.sizeToFit()
        navigationTitleLabel.font = UIFont(name: "Rubik-Medium", size: 20)!
        navigationTitleLabel.textColor = UIColor(named: "black")
        navigationItem.titleView = navigationTitleLabel
        navigationItem.title = roundName
        
        totalScore.text = "\(total)"
        frontScore.text = "\(front)"
        backScore.text = "\(back)"
        
        DispatchQueue.main.async { [self] in
            editToggle = true
            holesTableView.reloadData()
        }
    }
    
    @objc func reloadScorecardVC(_ notification: Notification) {
        if let data = notification.userInfo as? [String: Bool] {
            if data["holeAPI"] == true {
                UserDefaults.standard.set(false, forKey: "holeAPI")
                holeListAPI(call: true)
            }
        }
    }
    
    @objc func popToMainVC(_ notification: Notification) {
        if let data = notification.userInfo as? [String: Bool] {
            if data["pop"] == true {
                didChangeVariableValue?(true)
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    func holeListAPI(call: Bool) {
        Utility.isValidateToken { [self] isValid in
            if isValid {
                holeList(call: call)
            } else {
                Utility.refreshToken { [self] success in
                    if success {
                        holeList(call: call)
                    } else {
                        print("Error in holeListAPI")
                    }
                }
            }
        }
    }
    
    func holeList(call: Bool) {
        let url = "\(Global.sharedInstance.baseUrl)hole?page=1&limit=18&round=\(roundId)"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(UserDefaults.standard.string(forKey: "token") ?? "")",
        ]
        Alamofire.request(url, method: .get, headers: headers).responseJSON { response in
            switch response.result {
            case .success(_):
                if let model = try? JSONDecoder().decode(GetHoleList.self, from: response.data!) {
                    self.holeModelData = model.data ?? []
                    self.holeModelData = self.holeModelData.reversed()
                    DispatchQueue.main.async { [self] in
                        if holeModelData.count > 0 {
                            if session.isReachable && call == true {
                                do {
                                    let jsonData = try JSONEncoder().encode(model)
                                    session.sendMessageData(jsonData, replyHandler: nil, errorHandler: nil)
                                } catch {
                                    print("Error encoding holeDataArray: \(error)")
                                }
                            } else if !call {
                                let holeNumber = holeModelData.count + 1
                                if session.isReachable {
                                    do {
                                        let jsonData = try JSONEncoder().encode(model)
                                        session.sendMessageData(jsonData, replyHandler: nil, errorHandler: nil)
                                    } catch {
                                        print("Error encoding holeDataArray: \(error)")
                                    }
                                    let data = ["holeNumber": holeNumber, "currentRoundId": "\(roundId)"] as [String : Any]
                                    session.sendMessage(data, replyHandler: nil, errorHandler: nil)
                                } else if WCSession.isSupported() {
                                    let data = ["holeNumber": holeNumber, "currentRoundId": "\(roundId)"] as [String : Any]
                                    session.transferUserInfo(data)
                                }
                            }
                            total = 0
                            front = 0
                            back = 0
                            for i in 0...holeModelData.count - 1 {
                                total += holeModelData[i].score!
                                totalScore.text = "\(total)"
                                if i < 9 {
                                    front += holeModelData[i].score!
                                    frontScore.text = "\(front)"
                                }
                                if i > 8 {
                                    back += holeModelData[i].score!
                                    backScore.text = "\(back)"
                                }
                            }
                        }
                        DispatchQueue.main.async { [self] in
                            scoreArray.removeAll()
                            for i in 0...17 {
                                if i <= holeModelData.count - 1 {
                                    scoreArray.append("\(holeModelData[i].score ?? 0)")
                                } else {
                                    scoreArray.append("-")
                                }
                            }
                            holesTableView.reloadData()
                            Utility.hideProgressDialog(view: view)
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func updateRoundNameAPI() {
        Utility.isValidateToken { [self] isValid in
            if isValid {
                udateRoundName()
            } else {
                Utility.refreshToken { [self] success in
                    if success {
                        udateRoundName()
                    } else {
                        print("Error in udateRoundNameAPI")
                    }
                }
            }
        }
    }
    
    func udateRoundName() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDate = Date()
        let dateString = dateFormatter.string(from: currentDate)
        
        let parameters: Parameters = [
            "name": "\(updatedRoundName)",
            "played_date": "\(dateString)",
        ]
        let headers: HTTPHeaders = ["Authorization": "Bearer \(UserDefaults.standard.string(forKey: "token") ?? "")"]
        let url = "\(Global.sharedInstance.baseUrl)round/\(roundId)"
        Alamofire.request(url, method: .put, parameters: parameters, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any],
                   let data = json["data"] as? [String: Any],
                   let name = data["name"] as? String {
                    self.roundName = name
                    let data = ["roundAPI": true]
                    NotificationCenter.default.post(name: NSNotification.Name("updateMainVC"), object: nil, userInfo: data)
                }
                
            case .failure(let error):
                print("API Error: \(error)")
            }
        }
    }
    
    func updateScoreAPI() {
        Utility.isValidateToken { [self] isValid in
            if isValid {
                updateScore()
            } else {
                Utility.refreshToken { [self] success in
                    if success {
                        updateScore()
                    } else {
                        print("Error in updateScoreAPI")
                    }
                }
            }
        }
    }
    
    func updateScore() {
        let parameters: Parameters = [
            "round": roundId,
            "holes": updatedGolfScore
        ]
        let headers: HTTPHeaders = ["Authorization": "Bearer \(UserDefaults.standard.string(forKey: "token") ?? "")"]
        let url = "\(Global.sharedInstance.baseUrl)hole/bulk"
        Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { [self] response in
            switch response.result {
            case .success:
                Utility.showProgressDialog(view: self.view)
                holeListAPI(call: true)
                let data = ["roundAPI": true]
                NotificationCenter.default.post(name: NSNotification.Name("updateMainVC"), object: nil, userInfo: data)
            case .failure:
                print("API Error")
            }
        }
    }
    
    @IBAction func shareScoreTap(_ sender: Any) {
        
        let text = """
        Check out my scorecard
        \(roundName)
        \(roundDate)
        
        Total: \(totalScore.text ?? "-")
        Front 9: \(frontScore.text ?? "-")
        Back 9: \(backScore.text ?? "-")
        1: \(scoreArray[0])
        2: \(scoreArray[1])
        3: \(scoreArray[2])
        4: \(scoreArray[3])
        5: \(scoreArray[4])
        6: \(scoreArray[5])
        7: \(scoreArray[6])
        8: \(scoreArray[7])
        9: \(scoreArray[8])
        - - - - -
        10: \(scoreArray[9])
        11: \(scoreArray[10])
        12: \(scoreArray[11])
        13: \(scoreArray[12])
        14: \(scoreArray[13])
        15: \(scoreArray[14])
        16: \(scoreArray[15])
        17: \(scoreArray[16])
        18: \(scoreArray[17])
        
        Focus on your game with the
        EZG Golf Scorecard app
        https://apps.apple.com/app/apple-store/id6449625414?pt=124483576&ct=share&mt=8
        """
        let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.barButtonItem = sender as? UIBarButtonItem
        }
        present(activityViewController, animated: true, completion: nil)
    }
    
}

extension ScorecardViewController: ScorecardViewControllerDelegate {
    func incrementScore(value: Int) {
        if let current = Int(totalScore.text ?? "0") {
            let incrementedInt = current + 1
            totalScore.text = "\(incrementedInt)"
        }
        if value < 9 {
            if let current = Int(frontScore.text ?? "0") {
                let incrementedInt = current + 1
                frontScore.text = "\(incrementedInt)"
            }
        } else {
            if let current = Int(backScore.text ?? "0") {
                let incrementedInt = current + 1
                backScore.text = "\(incrementedInt)"
            }
        }
    }
    
    func decrementScore(value: Int) {
        if let current = Int(totalScore.text ?? "0") {
            let incrementedInt = current - 1
            totalScore.text = "\(incrementedInt)"
        }
        if value < 9 {
            if let current = Int(frontScore.text ?? "0") {
                let incrementedInt = current - 1
                frontScore.text = "\(incrementedInt)"
            }
        } else {
            if let current = Int(backScore.text ?? "0") {
                let incrementedInt = current - 1
                backScore.text = "\(incrementedInt)"
            }
        }
    }
}

extension ScorecardViewController: UITableViewDelegate, UITableViewDataSource, ChangeScoreValueDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 18
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = holesTableView.dequeueReusableCell(withIdentifier: "HoleTVCell", for: indexPath) as? HoleTVCell
        cell?.scoreDelegate = self
        cell?.delegate = self
        cell?.setValueOnCell(index: indexPath.row, holeModelData: holeModelData, isEditable: editToggle)
        return cell!
    }
    
    func scoreUpdate(number: Int, par: Int, score: Int, putts: Int) {
        var update: Bool = false
        if updatedGolfScore.count > 0 {
            for i in 0...updatedGolfScore.count - 1 {
                if updatedGolfScore[i]["number"] == number {
                    updatedGolfScore[i]["number"] = number
                    updatedGolfScore[i]["par"] = 1
                    updatedGolfScore[i]["score"] = score
                    updatedGolfScore[i]["putts"] = putts
                    update = true
                    break
                }
            }
            DispatchQueue.main.async { [self] in
                if !update {
                    let data = ["number": number, "par": par, "score": score, "putts": putts]
                    updatedGolfScore.append(data)
                }
            }
        } else {
            let data = ["number": number, "par": par, "score": score, "putts": putts]
            updatedGolfScore.append(data)
        }
    }
}
