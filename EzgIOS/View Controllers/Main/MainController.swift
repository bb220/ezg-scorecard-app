//
//  ViewController.swift
//  EzgIOS
//
//  Created by Ahmed Abdeen on 22/01/2023.
//

import UIKit
import SwiftKeychainWrapper
import WatchConnectivity
import Alamofire
import Foundation
import SystemConfiguration

class MainController: UIViewController {
    
    let limit = 10
    var currentPage = 1
    var totalPage = 0
    let activityIndicatorView = UIActivityIndicatorView(style: .large)
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var roundsTableView: UITableView!
    @IBOutlet weak var addRoundBtn: UIBarButtonItem!
    
    let session = WCSession.default
    let textAttributes = [
        NSAttributedString.Key.foregroundColor:UIColor(red: 0, green: 0, blue: 0),
        NSAttributedString.Key.font: UIFont(name: "Rubik-Medium", size: 20)!
    ]
    var modelData: [RoundData] = []
    var holeModelData: [HoleData] = []
    var temp = true
    var deActivate: Bool = false
    var totalRound: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        roundListAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if deActivate == false {
            if session.isReachable {
                session.sendMessage(["deactivateRound": true], replyHandler: nil, errorHandler: nil)
            } else if WCSession.isSupported() {
                session.transferUserInfo(["deactivateRound": true])
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
                if session.isReachable {
                    session.sendMessage(["deactivateRound": true], replyHandler: nil, errorHandler: nil)
                } else if WCSession.isSupported() {
                    session.transferUserInfo(["deactivateRound": true])
                }
            }
        }
    }
    
    func initViews() {
        addRoundBtn.isEnabled = false
        if Utility.isAcCreated {
            accountCreatedAlert()
        }
        Utility.showProgressDialog(view: self.view)
        UserDefaults.standard.set(KeychainWrapper.standard.string(forKey: "accessToken"), forKey: "token")
        UserDefaults.standard.set(KeychainWrapper.standard.string(forKey: "id"), forKey: "userId")
        
        let data = ["userId": "\(UserDefaults.standard.string(forKey: "userId") ?? "")",
                      "token": "\(UserDefaults.standard.string(forKey: "token") ?? "")",
                    "refreshToken":"\(UserDefaults.standard.string(forKey: "refreshToken") ?? "")",
                    "tokenExpireAt": UserDefaults.standard.integer(forKey: "tokenExpireAt")] as [String : Any]
        if session.isReachable {
            session.sendMessage(data, replyHandler: nil, errorHandler: nil)
        } else if WCSession.isSupported() {
            session.transferUserInfo(data)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(reloadMainVC(_:)), name: NSNotification.Name("updateMainVC"), object: nil)
        refreshControl.addTarget(self, action: #selector(refreshTable(_:)), for: .valueChanged)
        roundsTableView.addSubview(refreshControl)
        roundsTableView.separatorColor = UIColor.clear
        view.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    func accountCreatedAlert() {
        let alert = UIAlertController(title: "", message: "Account created.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default) { UIAlertAction in
            self.dismiss(animated: true)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true)
        Utility.isAcCreated = false
    }

    @objc func reloadMainVC(_ notification: Notification) {
        if let data = notification.userInfo as? [String: Bool] {
            if data["roundAPI"] == true {
                UserDefaults.standard.set(false, forKey: "roundAPI")
                roundListAPI()
                holeListAPI()
            }
        }
    }
    
    @objc func refreshTable(_ sender: Any) {
        currentPage = 1
        temp = true
        roundListAPI()
    }
    
    func roundListAPI() {
        Utility.isValidateToken { [self] isValid in
            if isValid {
                roundList()
            } else {
                Utility.refreshToken { [self] success in
                    if success {
                        roundList()
                    } else {
                        print("Error in holeListAPI")
                    }
                }
            }
        }
    }
    
    func roundList() {
        let url = "\(Global.sharedInstance.baseUrl)round?page=\(currentPage)&limit=\(limit)"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(UserDefaults.standard.string(forKey: "token") ?? "")",
        ]
        Alamofire.request(url, method: .get, headers: headers).responseJSON {[self] response in
            switch response.result {
            case .success(_):
                if let model = try? JSONDecoder().decode(GetRoundList.self, from: response.data!) {
                    totalPage = model.totalPages ?? 0
                    if currentPage == 1 {
                        modelData = model.data ?? []
                        if modelData.count > 0 && temp {
                            holeListAPI()
                            roundsTableView.reloadData()
                            temp = false
                        } else {
                            totalRound = 0
                        }
                    } else {
                        modelData += model.data ?? []
                        DispatchQueue.main.async { [self] in
                            roundsTableView.reloadData()
                            roundsTableView.tableFooterView = hidefooterview()
                            Utility.hideProgressDialog(view: self.view)
                        }
                    }
                    DispatchQueue.main.async { [self] in
                        if modelData.count > 0 {
                            roundsTableView.setMessage(message: "")
                            totalRound = model.total_rounds ?? 0
                        } else {
                            totalRound = 0
                            roundsTableView.reloadData()
                            Utility.hideProgressDialog(view: self.view)
                            refreshControl.endRefreshing()
                            roundsTableView.setMessage(message: "Tap + to create a round")
                        }
                        addRoundBtn.isEnabled = true
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func holeListAPI() {
        Utility.isValidateToken { [self] isValid in
            if isValid {
                holeList()
            } else {
                Utility.refreshToken { [self] success in
                    if success {
                        holeList()
                    } else {
                        print("Error in holeListAPI")
                    }
                }
            }
        }
    }
    
    func holeList() {
        let url = "\(Global.sharedInstance.baseUrl)hole?page=1&limit=10000"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(UserDefaults.standard.string(forKey: "token") ?? "")",
        ]
        Alamofire.request(url, method: .get, headers: headers).responseJSON { [self] response in
            switch response.result {
            case .success(_):
                if let model = try? JSONDecoder().decode(GetHoleList.self, from: response.data!) {
                    holeModelData = model.data ?? []
                    DispatchQueue.main.async { [self] in
                        roundsTableView.reloadData()
                        refreshControl.endRefreshing()
                        roundsTableView.tableFooterView = hidefooterview()
                        Utility.hideProgressDialog(view: self.view)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func deleteRoundAPI(roundId: String, index: Int) {
        Utility.isValidateToken { [self] isValid in
            if isValid {
                deleteRound(roundId: roundId, index: index)
            } else {
                Utility.refreshToken { [self] success in
                    if success {
                        deleteRound(roundId: roundId, index: index)
                    } else {
                        print("Error in deleteRoundAPI")
                    }
                }
            }
        }
    }
    
    func deleteRound(roundId: String, index: Int) {
        let url = "\(Global.sharedInstance.baseUrl)round/\(roundId)"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(UserDefaults.standard.string(forKey: "token") ?? "")",
        ]
        Alamofire.request(url, method: .delete, headers: headers).responseJSON {[self] response in
            switch response.result {
            case .success(_):
                if session.isReachable {
                    session.sendMessage(["deactivateRound": true], replyHandler: nil, errorHandler: nil)
                } else if WCSession.isSupported() {
                    session.transferUserInfo(["deactivateRound": true])
                }
                currentPage = 1
                temp = true
                roundListAPI()
            case .failure(let error):
                print("Error on delete RoundId :-",error)
            }
        }
    }
    
    func createRoundAPI() {
        Utility.showProgressDialog(view: self.view)
        Utility.isValidateToken { [self] isValid in
            if isValid {
                createRound()
            } else {
                Utility.refreshToken { [self] success in
                    if success {
                        createRound()
                    } else {
                        Utility.hideProgressDialog(view: self.view)
                        print("Error in createRoundAPI")
                    }
                }
            }
        }
    }
    
    func createRound() {
        let roundIndex = totalRound + 1
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayDate = dateFormatter.string(from: Date())
        let parameters: Parameters = [
            "name": "Round \(roundIndex)",
            "played_date": "\(todayDate)"
        ]
        let token = "\(UserDefaults.standard.string(forKey: "token") ?? "")"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        let url = "\(Global.sharedInstance.baseUrl)round/"
        Alamofire.request(url, method: .post, parameters: parameters, headers: headers).responseJSON { [self] response in
            switch response.result {
            case .success(_):
                Utility.hideProgressDialog(view: self.view)
                let model = try? JSONDecoder().decode(GetRoundId.self, from: response.data!)
                temp = true
                roundListAPI()
                DispatchQueue.main.async { [self] in
                    UserDefaults.standard.set("\(model?.data?.Id ?? "")", forKey: "roundID")
                    let vc = storyboard?.instantiateViewController(withIdentifier: "ScorecardViewController") as? ScorecardViewController
                    vc?.roundId = model?.data?.Id ?? ""
                    vc?.roundName = model?.data?.name ?? ""
                    self.navigationController?.pushViewController(vc!, animated: true)
                }
            case .failure(let error):
                print("API error: \(error)")
            }
        }
    }
    
    private func clearUserData() {
        let removeSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: "accessToken")
        Global.sharedInstance.user = nil
        Utility.isAcCreated = false
        UserDefaults.standard.set("", forKey: "userId")
        UserDefaults.standard.set("", forKey: "token")
        UserDefaults.standard.set("", forKey: "refreshToken")
        UserDefaults.standard.set(0, forKey: "tokenExpireAt")
        let data = ["userId": ""]
        if session.isReachable {
            session.sendMessage(data, replyHandler: nil, errorHandler: nil)
        } else if WCSession.isSupported() {
            session.transferUserInfo(data)
        }
        if removeSuccessful {
            Utility.openLogin()
        }
    }
    
    @IBAction func didTapAddRoundBtn(_ sender: Any) {
        createRoundAPI()
    }
    
    @IBAction func didTapLogoutBtn(_ sender: Any) {
        if WCSession.isSupported() {
            clearUserData()
        }
    }
}

extension MainController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == modelData.count - 1 && indexPath.row > 8 {
            if currentPage <= totalPage {
                self.currentPage += 1
                roundsTableView.tableFooterView = footerview()
                self.roundListAPI()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = roundsTableView.dequeueReusableCell(withIdentifier: "RoundsTVCell", for: indexPath) as? RoundsTVCell
        cell?.setValueOnCell(holeModelData: holeModelData, modelData: modelData, index: indexPath.row)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ScorecardViewController") as? ScorecardViewController
        vc?.roundId = modelData[indexPath.row].Id ?? ""
        vc?.roundName = modelData[indexPath.row].name ?? ""
        vc?.roundDate = modelData[indexPath.row].createdAt ?? ""
        vc?.didChangeVariableValue = { value in
            self.deActivate = value
        }
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [self] (_, _, completionHandler) in
            completionHandler(true)
            Utility.showProgressDialog(view: self.view)
            deleteRoundAPI(roundId: modelData[indexPath.row].Id ?? "", index: indexPath.row)
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }

    func footerview() -> UIView {
        activityIndicatorView.startAnimating()
        roundsTableView.tableFooterView?.isHidden = false
        let view = UIView(frame: CGRect(x: roundsTableView.frame.width/2-25, y: 0, width: 50, height: 50))
        view.addSubview(activityIndicatorView)
        return view
    }
    
    func hidefooterview() -> UIView {
        activityIndicatorView.stopAnimating()
        roundsTableView.tableFooterView?.isHidden = true
        let view = UIView(frame: CGRect(x: 0, y: 0, width: roundsTableView.frame.width, height: 0))
        return view
    }
    
}

extension UITableView {
    func setMessage(message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor(red: 0.608, green: 0.608, blue: 0.647, alpha: 1)
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "Rubik-Regular", size: 24)
        messageLabel.sizeToFit()
        self.backgroundView = messageLabel
    }
}
