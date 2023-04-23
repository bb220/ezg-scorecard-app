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
    let session = WCSession.default
    let textAttributes = [
        NSAttributedString.Key.foregroundColor:UIColor(red: 0, green: 0, blue: 0),
        NSAttributedString.Key.font: UIFont(name: "Rubik-Medium", size: 20)!
    ]
    var modelData: [RoundData] = []
    var holeModelData: [HoleData] = []
    var temp = true
    var navigate = false
    var deActivate: Bool = false
    
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
        Utility.showProgressDialog(view: self.view)
        UserDefaults.standard.set(KeychainWrapper.standard.string(forKey: "accessToken"), forKey: "token")
        UserDefaults.standard.set(KeychainWrapper.standard.string(forKey: "id"), forKey: "userId")
        if session.isReachable {
            let data = ["userId": "\(UserDefaults.standard.string(forKey: "userId") ?? "")",
                          "token": "\(UserDefaults.standard.string(forKey: "token") ?? "")"]
            session.sendMessage(data, replyHandler: nil, errorHandler: nil)
        } else if WCSession.isSupported() {
            let data = ["userId": "\(UserDefaults.standard.string(forKey: "userId") ?? "")",
                          "token": "\(UserDefaults.standard.string(forKey: "token") ?? "")"]
            session.transferUserInfo(data)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(reloadMainVC(_:)), name: NSNotification.Name("updateMainVC"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(navigateVC(_:)), name: NSNotification.Name("navigateVC"), object: nil)
        refreshControl.addTarget(self, action: #selector(refreshTable(_:)), for: .valueChanged)
        roundsTableView.addSubview(refreshControl)
        roundsTableView.separatorColor = UIColor.clear
        view.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        navigationController?.navigationBar.titleTextAttributes = textAttributes
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
    
    @objc func navigateVC(_ notification: Notification) {
        if let data = notification.userInfo as? [String: Bool] {
            navigate = data["scorecardVC"] ?? false
        }
    }
    
    @objc func refreshTable(_ sender: Any) {
        currentPage = 1
        temp = true
        roundListAPI()
    }
    
    func roundListAPI() {
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
                        } else {
                            roundsTableView.reloadData()
                            Utility.hideProgressDialog(view: self.view)
                            refreshControl.endRefreshing()
                            roundsTableView.setMessage(message: "Use the WatchOS app to start a round")
                        }
                        if session.isReachable {
                            session.sendMessage(["roundIndex": model.total_rounds ?? 0], replyHandler: nil, errorHandler: nil)
                        } else if WCSession.isSupported() {
                            session.transferUserInfo(["roundIndex": model.total_rounds ?? 0])
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func holeListAPI() {
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
                        if navigate == true {
                            let vc = storyboard?.instantiateViewController(withIdentifier: "ScorecardViewController") as? ScorecardViewController
                            vc?.roundId = modelData[0].Id ?? ""
                            vc?.roundName = modelData[0].name ?? ""
                            navigate = false
                            self.navigationController?.pushViewController(vc!, animated: true)
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func deleteRoundAPI(roundId: String, index: Int) {
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
    
    private func clearUserData(){
        let removeSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: "accessToken")
        Global.sharedInstance.user = nil
        UserDefaults.standard.set("", forKey: "userId")
        UserDefaults.standard.set("", forKey: "token")
        UserDefaults.standard.set("", forKey: "roundIndex")
        let data = ["userId": "", "token": "", "roundIndex":""]
        session.transferUserInfo(data)
        if removeSuccessful {
            Utility.openLogin()
        }
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
