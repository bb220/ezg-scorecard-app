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
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var holesTableView: UITableView!
    @IBOutlet weak var scoreBoardView: UIView!
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var frontScore: UILabel!
    @IBOutlet weak var backScore: UILabel!
    @IBOutlet weak var totalScore: UILabel!
    @IBOutlet weak var totalDifference: UILabel!
    @IBOutlet weak var frontDifference: UILabel!
    @IBOutlet weak var backDifference: UILabel!
    
    let session = WCSession.default
    var holeModelData: [HoleData] = []
    var tmpData: [data] = []
    var scoreArray: [String] = []
    var courseHoleModelData: [CourseHoleData] = []
    var courseId: String = ""
    var roundId: String = ""
    var roundName: String = ""
    var roundDate: String = ""
    var editToggle: Bool = true
    var total = 0
    var front = 0
    var back = 0
    var totalDifferenceRC = 0
    var frontDifferenceRC = 0
    var backDifferenceRC = 0
    var updatedRoundName: String = ""
    var isRoundNameEdit: Bool = false
    var isCreatRoundCall = false
    var isNeedviewWillCall = false
    var selectedCourseName = "Select a course"
    var updatedGolfScore: [[String: Int]] = []
    var didChangeVariableValue: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("roundId :- \(roundId)")
        print("roundName :- \(roundName)")
        initView()
        holeListAPI(call: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let data = ["holeNumber": 0, "currentRoundId": ""] as [String : Any]
        if session.isReachable {
            session.sendMessage(data, replyHandler: nil, errorHandler: nil)
        } else if WCSession.isSupported() {
            session.transferUserInfo(data)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        if isNeedviewWillCall == true {
            courseHoleListAPI()
            configureCustomNavBar(roundName: roundName, courseName: selectedCourseName)
            updateRoundNameAPI()
            if holeModelData.count > 0 {
                let holeNumber = holeModelData.count + 1
                let data = ["holeNumber": holeNumber, "currentRoundId": "\(roundId)"] as [String : Any]
                if session.isReachable {
                    session.sendMessage(data, replyHandler: nil, errorHandler: nil)
                }
            } else if holeModelData.count == 0 {
                let data = ["holeNumber": 1, "currentRoundId": "\(roundId)"] as [String : Any]
                if session.isReachable {
                    session.sendMessage(data, replyHandler: nil, errorHandler: nil)
                } else if WCSession.isSupported() {
                    session.transferUserInfo(data)
                }
            }
        }
    }
    
    func initView() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        Utility.showProgressDialog(view: self.view)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = dateFormatter.date(from: roundDate) {
            dateFormatter.dateFormat = "MM/dd/yyyy"
            roundDate = "\(dateFormatter.string(from: date))"
        }
        totalDifference.isHidden = true
        frontDifference.isHidden = true
        backDifference.isHidden = true
        title = roundName
        configureCustomNavBar(roundName: roundName, courseName: selectedCourseName)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .plain, target: self, action: #selector(self.backToInitial))
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
    
    //MARK: - Button Actions
    @objc func editButtonTapped(_ sender: UIBarButtonItem) {
        if editToggle {
            updatedGolfScore.removeAll()
            editToggle = false
            shareButton.isEnabled = false
            updatedRoundName = roundName
            
            let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonTapped(_:)))
            saveButton.tintColor = .link
            navigationItem.rightBarButtonItem = saveButton
            
            let textField = UITextField(frame: CGRect(x: UIScreen.main.bounds.width - 150 / 2, y: 0, width: 150, height: 40))
            textField.backgroundColor = UIColor.systemGray5
            textField.textAlignment = .center
            textField.layer.cornerRadius = 10
            textField.text = navigationItem.title
            textField.font = UIFont(name: "Rubik-Medium", size: 20)!
            textField.textColor = UIColor(red: 0, green: 0, blue: 0)
            textField.addTarget(self, action: #selector(textEditing(textField:)), for: .editingChanged)
            
            navigationItem.titleView = textField
            let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped(_:)))
            navigationItem.leftBarButtonItem = cancelButton
            
            DispatchQueue.main.async { [self] in
                editToggle = false
                holesTableView.reloadData()
            }
        } else {
            editToggle = true
            shareButton.isEnabled = true
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped(_:)))
        }
    }
    
    @objc func backToInitial(sender: AnyObject) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func saveButtonTapped(_ sender: UIBarButtonItem) {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .plain, target: self, action: #selector(self.backToInitial))
        
        if isRoundNameEdit == true || isCreatRoundCall == true {
            updateRoundNameAPI()
        }
        updateScoreAPI()
        roundName = updatedRoundName
        configureCustomNavBar(roundName: updatedRoundName, courseName: selectedCourseName)
        
        holesTableView.reloadData()
        DispatchQueue.main.async { [self] in
            editToggle = true
        }
        editButtonTapped(sender)
    }
    
    @objc func cancelButtonTapped(_ sender: UIBarButtonItem) {
        updatedGolfScore.removeAll()
        editButtonTapped(sender)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .plain, target: self, action: #selector(self.backToInitial))
        
        configureCustomNavBar(roundName: roundName, courseName: selectedCourseName)
        showRoundTotalLbl()
        holeListAPI(call: true)
        editToggle = true
    }
    
    @objc func selectCourseBtn() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "CoursesViewController") as? CoursesViewController
        vc?.isCreatRoundCall = true
        vc?.isSelecteCourseCall = true
        vc?.roundId = roundId
        vc?.roundName = roundName
        vc?.roundDate = roundDate
        vc?.callBackValue = {
            (courseId: String, courseName: String, isNeedviewWillCall : Bool) in
            //            print("DataFrom popView ::::::",courseId,courseName)
            self.courseId = courseId
            self.selectedCourseName = courseName
            self.isNeedviewWillCall = isNeedviewWillCall
        }
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    // MARK: Custom navigation title & button
    func configureCustomNavBar(roundName: String, courseName: String) {
        let customNavTitleView = UIView()
        customNavTitleView.frame = CGRect(x: 0, y: 0, width: 200, height: 48)
        
        /// Round Name Lbl
        let roundTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        roundTitleLabel.text = roundName
        roundTitleLabel.textColor = UIColor.black
        roundTitleLabel.textAlignment = .center
        roundTitleLabel.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
        roundTitleLabel.adjustsFontSizeToFitWidth = true
        customNavTitleView.addSubview(roundTitleLabel)
        
        /// Select course Btn ||  Selected Course Lbl
        if selectedCourseName == "Select a course" {
            let selecteCourseBtn = UIButton(type: .custom)
            selecteCourseBtn.setTitle(courseName, for: .normal)
            selecteCourseBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            selecteCourseBtn.setTitleColor(.gray, for: .normal)
            selecteCourseBtn.frame = CGRect(x: 30, y: 30, width: 140, height: 15)
            selecteCourseBtn.addTarget(self,action: #selector(selectCourseBtn), for: .touchUpInside)
            customNavTitleView.addSubview(selecteCourseBtn)
        } else {
            let selectedCourselabel = UILabel(frame: CGRect(x: 30, y: 30, width: 140, height: 15))
            selectedCourselabel.text = selectedCourseName
            selectedCourselabel.textColor = UIColor.gray
            selectedCourselabel.textAlignment = .center
            selectedCourselabel.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
            selectedCourselabel.adjustsFontSizeToFitWidth = true
            customNavTitleView.addSubview(selectedCourselabel)
        }
        navigationItem.titleView = customNavTitleView
    }
    
    @objc func reloadScorecardVC(_ notification: Notification) {
        if let data = notification.userInfo as? [String: Bool] {
            if data["holeAPI"] == true {
                UserDefaults.standard.set(false, forKey: "holeAPI")
                holeListAPI(call: false)
            }
        }
    }
    
    @objc func popToMainVC(_ notification: Notification) {
        if let data = notification.userInfo as? [String: Bool] {
            if data["pop"] == true {
                didChangeVariableValue?(true)
                DispatchQueue.main.async { [self] in
                    let data = ["holeNumber": 0, "currentRoundId": ""] as [String : Any]
                    if session.isReachable {
                        session.sendMessage(data, replyHandler: nil, errorHandler: nil)
                    } else if WCSession.isSupported() {
                        session.transferUserInfo(data)
                    }
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    @IBAction func shareScoreTap(_ sender: Any) {
        var dfRCArray: [String] = []
        shareScoreCalculation(&dfRCArray)
        var shareCourseName = ""
        if selectedCourseName != "Select a course" {
            shareCourseName = selectedCourseName
        }
        let text = """
        Check out my scorecard
        \(roundDate)
        \(roundName)
        \(shareCourseName)
        
        Total: \(totalScore.text ?? "-") \(totalDifference.text ?? "-")
        Front 9: \(frontScore.text ?? "-") \(frontDifference.text ?? "-")
        Back 9: \(backScore.text ?? "-") \(backDifference.text ?? "-")
        1: \(scoreArray[0]) \(dfRCArray[0])
        2: \(scoreArray[1]) \(dfRCArray[1])
        3: \(scoreArray[2]) \(dfRCArray[2])
        4: \(scoreArray[3]) \(dfRCArray[3])
        5: \(scoreArray[4]) \(dfRCArray[4])
        6: \(scoreArray[5]) \(dfRCArray[5])
        7: \(scoreArray[6]) \(dfRCArray[6])
        8: \(scoreArray[7]) \(dfRCArray[7])
        9: \(scoreArray[8]) \(dfRCArray[8])
        - - - - -
        10: \(scoreArray[9]) \(dfRCArray[9])
        11: \(scoreArray[10]) \(dfRCArray[10])
        12: \(scoreArray[11]) \(dfRCArray[11])
        13: \(scoreArray[12]) \(dfRCArray[12])
        14: \(scoreArray[13]) \(dfRCArray[13])
        15: \(scoreArray[14]) \(dfRCArray[14])
        16: \(scoreArray[15]) \(dfRCArray[15])
        17: \(scoreArray[16]) \(dfRCArray[16])
        18: \(scoreArray[17]) \(dfRCArray[17])
        
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
    
    func shareScoreCalculation(_ dfRCArray: inout [String]) {
        for i in 0...17 {
            if selectedCourseName != "Select a course" && holeModelData.count != 0 {
                if i <= holeModelData.count - 1 {
                    if i <= courseHoleModelData.count - 1 {
                        let roundScore = holeModelData[i].score ?? 0
                        let par = courseHoleModelData[i].par ?? 0
                        let df = roundScore - par
                        
                        if String(df).contains("-") { dfRCArray.append("\(df)") }
                        else if df == 0 { dfRCArray.append("") }
                        else { dfRCArray.append("+\(df)") }
                    } else { dfRCArray.append("") }
                } else { dfRCArray.append("") }
            } else { dfRCArray.append("") }
        }
    }
    
    
    //MARK: API Calling
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
        Alamofire.request(url, method: .get, headers: headers).responseJSON { [self] response in
            switch response.result {
            case .success(_):
                courseHoleListAPI()
                if let model = try? JSONDecoder().decode(GetHoleList.self, from: response.data!) {
                    self.holeModelData = model.data ?? []
                    self.holeModelData = self.holeModelData.reversed()
                    DispatchQueue.main.async { [self] in
                        tmpData.removeAll()
                        if holeModelData.count > 0 {
                            for value in 0...holeModelData.count - 1 {
                                tmpData.append(data.init(number: holeModelData[value].number,
                                                         putt: holeModelData[value].putts,
                                                         score: holeModelData[value].score))
                            }
                        }
                        let data = ["roundAPI": true]
                        NotificationCenter.default.post(name: NSNotification.Name("updateMainVC"), object: nil, userInfo: data)
                        if holeModelData.count > 0 {
                            let holeNumber = holeModelData.count + 1
                            let data = ["holeNumber": holeNumber, "currentRoundId": "\(roundId)"] as [String : Any]
                            if session.isReachable && call {
                                do {
                                    let jsonData = try JSONEncoder().encode(model)
                                    session.sendMessageData(jsonData, replyHandler: nil, errorHandler: nil)
                                } catch { print("Error encoding holeDataArray: \(error)") }
                                session.sendMessage(data, replyHandler: nil, errorHandler: nil)
                            } else if WCSession.isSupported() && call {
                                session.transferUserInfo(data)
                            } else if session.isReachable && !call {
                                do {
                                    let jsonData = try JSONEncoder().encode(model)
                                    session.sendMessageData(jsonData, replyHandler: nil, errorHandler: nil)
                                } catch { print("Error encoding holeDataArray: \(error)") }
                            }
                            calculateRoundScore()
                        } else if holeModelData.count == 0 {
                            let data = ["holeNumber": 1, "currentRoundId": "\(roundId)"] as [String : Any]
                            if session.isReachable {
                                session.sendMessage(data, replyHandler: nil, errorHandler: nil)
                            } else if WCSession.isSupported() {
                                session.transferUserInfo(data)
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
                    } else { print("Error in udateRoundNameAPI") }
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
            "name": isNeedviewWillCall ? roundName : updatedRoundName ,
            "played_date": "\(dateString)",
            "course": "\(courseId)",
        ]
        let headers: HTTPHeaders = ["Authorization": "Bearer \(UserDefaults.standard.string(forKey: "token") ?? "")"]
        let url = "\(Global.sharedInstance.baseUrl)round/\(roundId)"
        Alamofire.request(url, method: .put, parameters: parameters, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
//                print(response.result.map({ i in
//                    print("i is ---",i)
//                }))
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
                    } else { print("Error in updateScoreAPI") }
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
                updatedGolfScore.removeAll()
                Utility.showProgressDialog(view: self.view)
                holeListAPI(call: false)
                let data = ["roundAPI": true]
                NotificationCenter.default.post(name: NSNotification.Name("updateMainVC"), object: nil, userInfo: data)
            case .failure:
                print("API Error")
            }
        }
    }
    
    func courseHoleListAPI() {
        Utility.isValidateToken { [self] isValid in
            if isValid {
                courseHoleList()
            } else {
                Utility.refreshToken { [self] success in
                    if success {
                        courseHoleList()
                    } else { print("Error in courseHoleListAPI") }
                }
            }
        }
    }
    
    func courseHoleList() {
        Utility.showProgressDialog(view: view)
        if courseId == "" {
            return
        }
        let url = "\(Global.sharedInstance.baseUrl)course_hole?page=1&limit=18&course=\(courseId)"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(UserDefaults.standard.string(forKey: "token") ?? "")",
        ]
        Alamofire.request(url, method: .get, headers: headers).responseJSON { [self] response in
            Utility.hideProgressDialog(view: self.view)
            switch response.result {
            case .success(_):
                Utility.hideProgressDialog(view: view)
                if let model = try? JSONDecoder().decode(GetCourseHoleList.self, from: response.data!) {
                    self.courseHoleModelData.removeAll()
                    //print("model is ------>>>",model)
                    self.courseHoleModelData = model.data ?? []
                    courseHoleModelData = courseHoleModelData.reversed()
                    if courseHoleModelData.isEmpty == true {
                        showRoundTotalLbl()
                        holesTableView.reloadData()
                    }
                    calculateCourseDifference()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: Calculation func
    func showRoundTotalLbl() {
        totalScore.text = "\(total)"
        frontScore.text = "\(front)"
        backScore.text = "\(back)"
    }
    
    func calculateRoundScore() {
        total = 0
        front = 0
        back = 0
        for i in 0...holeModelData.count - 1 {
            total += holeModelData[i].score!
            if i < 9 {
                front += holeModelData[i].score!
            } else if i > 8 {
                back += holeModelData[i].score!
            }
        }
        if courseId == "" || selectedCourseName == "Select a course" {
            showRoundTotalLbl()
            holesTableView.reloadData()
        }
    }
    
    func calculateCourseDifference() {
        self.totalDifferenceRC = 0
        self.frontDifferenceRC = 0
        self.backDifferenceRC = 0
        if selectedCourseName == "Select a course" {
            return
        }
        
        if courseHoleModelData.count > 0 {
            for i in 0...courseHoleModelData.count - 1 {
                if i < holeModelData.count {
                    self.totalDifferenceRC += courseHoleModelData[i].par!
                    totalDifference.isHidden = false
                    if i < 9 {
                        self.frontDifferenceRC += courseHoleModelData[i].par!
                        frontDifference.isHidden = false
                    } else if i > 8 {
                        self.backDifferenceRC += courseHoleModelData[i].par!
                        backDifference.isHidden = false
                    }
                }
                
                if i == courseHoleModelData.count - 1 {
                    let totalRC = total - totalDifferenceRC
                    let frontRC = front - frontDifferenceRC
                    let backRC = back - backDifferenceRC
                    
                    showRoundTotalLbl()
                    
                    if totalRC == 0 {
                        totalDifference.text = "E"
                    } else {
                        if String(totalRC).contains("-") { totalDifference.text = "\(totalRC)"
                        } else { totalDifference.text = "+\(totalRC)" }
                    }
                    
                    if frontRC == 0 {
                        frontDifference.text = "E"
                    } else {
                        if String(frontRC).contains("-") {  frontDifference.text = "\(frontRC)"
                        } else { frontDifference.text = "+\(frontRC)" }
                    }
                    
                    if backRC == 0 {
                        backDifference.text = "E"
                    } else {
                        if String(backRC).contains("-") { backDifference.text = "\(backRC)"
                        } else { backDifference.text = "+\(backRC)" }
                    }
                }
            }
            holesTableView.reloadData()
        }
    }
}

extension ScorecardViewController: ScorecardViewControllerDelegate {
    
    func incrementScore(value: Int) {
        //
    }
    
    func decrementScore(value: Int) {
        //
    }
    
    func reloadTableView() {
        holesTableView.reloadData()
    }
    
    func updateTmpData(tmpData: [data]) {
        self.tmpData = tmpData
        holesTableView.reloadData()
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
        cell?.roundId = roundId
        
        if indexPath.row < courseHoleModelData.count {
            cell!.courseParLbl.text = "\(courseHoleModelData[indexPath.row].par ?? 0)"
            cell!.courseHoleObj = courseHoleModelData[indexPath.row]
        } else {
            cell!.courseHoleObj = nil
            cell!.courseParLbl.text = ""
            cell!.visualView.isHidden = true
        }
        cell?.setValueOnCell(index: indexPath, modelData: tmpData, isEditable: editToggle, courseDataCount: courseHoleModelData.count)
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
