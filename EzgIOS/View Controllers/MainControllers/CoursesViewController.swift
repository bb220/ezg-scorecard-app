//
//  CoursesViewController.swift
//  EzgIOS
//
//  Created by iMac on 01/09/23.
//

import Foundation
import UIKit
import SwiftKeychainWrapper
import WatchConnectivity
import Alamofire
import RxSwift

class CoursesViewController: UIViewController {
    
    @IBOutlet weak var coursesTableView: UITableView!
    
    let limit = 10
    var currentPage = 1
    var totalPage = 0
    let activityIndicatorView = UIActivityIndicatorView(style: .large)
    let refreshControl = UIRefreshControl()
    var isCreatRoundCall = false
    var isSelecteCourseCall = false
    var roundId: String = ""
    var roundName: String = ""
    var roundDate: String = ""
    
    var coursesListData: [CourseData] = []
    var courseHoleModelData: [CourseHoleData] = []
    var callBackValue: ((_ courseId: String, _ courseName: String, _ isNeedviewWillCall: Bool)-> Void)?
    var totalCourses: Int = 0
    var temp = true
    
    let session = WCSession.default
    let textAttributes = [
        NSAttributedString.Key.foregroundColor:UIColor(red: 0, green: 0, blue: 0),
        NSAttributedString.Key.font: UIFont(name: "Rubik-Medium", size: 20)!
    ]
    
    override func viewDidLoad() {
        initViews()
        coursesListAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if tabBarController!.selectedIndex == 1 {
            self.tabBarController?.tabBar.isHidden = false
        }
        currentPage = 1
        temp = true
        coursesListAPI()
    }
    
    func initViews() {
        refreshControl.addTarget(self, action: #selector(refreshTable(_:)), for: .valueChanged)
        coursesTableView.addSubview(refreshControl)
        coursesTableView.separatorColor = UIColor.clear
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        if isCreatRoundCall {
            if isSelecteCourseCall == false {
                let bottomSkipBtn = UIButton(frame: CGRect(x: 0, y: 0, width: coursesTableView.frame.width, height: 44))
                bottomSkipBtn.setTitle("Skip", for: .normal)
                bottomSkipBtn.setTitleColor(.gray, for: .normal)
                bottomSkipBtn.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
                coursesTableView.tableFooterView = bottomSkipBtn
            }
        }
        if isCreatRoundCall == false {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(didTapLogoutBtn))
        }
    }
    
    @objc func refreshTable(_ sender: Any) {
        currentPage = 1
        temp = true
        coursesListAPI()
    }
    
    func coursesListAPI() {
        Utility.isValidateToken { [self] isValid in
            if isValid {
                coursesList()
            } else {
                Utility.refreshToken { [self] success in
                    if success {
                        coursesList()
                    } else { print("Error in coursesListAPI") }
                }
            }
        }
    }
    
    func coursesList() {
        let url = "\(Global.sharedInstance.baseUrl)course?page=\(currentPage)&limit=\(limit)"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(UserDefaults.standard.string(forKey: "token") ?? "")",
        ]
        Alamofire.request(url, method: .get, headers: headers).responseJSON {[self] response in
            switch response.result {
            case .success(_):
                
                if let model = try? JSONDecoder().decode(GetCoursesList.self, from: response.data!) {
                    totalPage = model.total_pages ?? 0
                    if currentPage == 1 {
                        coursesListData = model.data ?? []
                        if coursesListData.count > 0 && temp {
                            courseHoleListAPI()
                            coursesTableView.reloadData()
                            temp = false
                        } else { totalCourses = 0 }
                    } else {
                        coursesListData += model.data ?? []
                        DispatchQueue.main.async { [self] in
                            coursesTableView.reloadData()
                            Utility.hideProgressDialog(view: self.view)
                        }
                    }
                    DispatchQueue.main.async { [self] in
                        if coursesListData.count > 0 {
                            coursesTableView.setMessage(message: "")
                            totalCourses = model.total_courses ?? 0
                        } else {
                            totalCourses = 0
                            coursesTableView.reloadData()
                            Utility.hideProgressDialog(view: self.view)
                            refreshControl.endRefreshing()
                            coursesTableView.setMessage(message: isSelecteCourseCall ? "Course has not created yet." : "Tap + to create a course")
                        }
                    }
                }
            case .failure(let error):
                print(error)
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
                    } else { print("Error in holeListAPI") }
                }
            }
        }
    }
    
    func courseHoleList() {
        let url = "\(Global.sharedInstance.baseUrl)course_hole?page=1&limit=1000"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(UserDefaults.standard.string(forKey: "token") ?? "")",
        ]
        Alamofire.request(url, method: .get, headers: headers).responseJSON { [self] response in
            switch response.result {
            case .success(_):
                
                if let model = try? JSONDecoder().decode(GetCourseHoleList.self, from: response.data!) {
                    courseHoleModelData = model.data ?? []
                    DispatchQueue.main.async { [self] in
                        coursesTableView.reloadData()
                        refreshControl.endRefreshing()
                        Utility.hideProgressDialog(view: self.view)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func deleteCourseAPI(courseId: String) {
        Utility.isValidateToken { [self] isValid in
            if isValid {
                deleteCourse(courseId: courseId)
            } else {
                Utility.refreshToken { [self] success in
                    if success {
                        deleteCourse(courseId: courseId)
                    } else { print("Error in deleteCourseAPI") }
                }
            }
        }
    }
    
    func deleteCourse(courseId: String) {
        let url = "\(Global.sharedInstance.baseUrl)course/\(courseId)"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(UserDefaults.standard.string(forKey: "token") ?? "")",
        ]
        Alamofire.request(url, method: .delete, headers: headers).responseJSON {[self] response in
            switch response.result {
            case .success(_):
                
                currentPage = 1
                temp = true
                coursesListAPI()
            case .failure(let error):
                print("Error on delete Course :-",error)
            }
        }
    }
    
    @IBAction func didTapAddCourseBtn(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "EditCourseViewController") as? EditCourseViewController
        vc?.totalCourses = totalCourses
        vc?.isNewCourseCreate = true
        vc?.isCreatRoundCall = isCreatRoundCall
        vc?.roundId = roundId
        vc?.roundName = roundName
        vc?.roundDate = roundDate
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @objc func didTapLogoutBtn() {
        if WCSession.isSupported() {
            clearUserData()
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
    
    func footerview() -> UIView {
        activityIndicatorView.startAnimating()
        //        coursesTableView.tableFooterView?.isHidden = false
        let view = UIView(frame: CGRect(x: coursesTableView.frame.width/2-25, y: 0, width: 50, height: 50))
        return view
    }
    
    /// Handle the "Skip" button tap event
    @objc func skipButtonTapped() {
        print("Skip button tapped")
        let vc = storyboard?.instantiateViewController(withIdentifier: "ScorecardViewController") as? ScorecardViewController
        vc?.roundId = roundId
        vc?.roundName = roundName
        vc?.roundDate = roundDate
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func hidefooterview() -> UIView {
        activityIndicatorView.stopAnimating()
        coursesTableView.tableFooterView?.isHidden = true
        let view = UIView(frame: CGRect(x: 0, y: 0, width: coursesTableView.frame.width, height: 0))
        return view
    }
    
}

extension CoursesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == coursesListData.count - 1 && indexPath.row > 8 {
            if currentPage <= totalPage {
                self.currentPage += 1
                self.coursesListAPI()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coursesListData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = coursesTableView.dequeueReusableCell(withIdentifier: "CoursesTVCell", for: indexPath) as? CoursesTVCell
        cell?.setValueOnCell(holeModelData: courseHoleModelData, modelData: coursesListData, index: indexPath.row)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isCreatRoundCall {
            if isSelecteCourseCall {
                callBackValue?(coursesListData[indexPath.row]._id ?? "", coursesListData[indexPath.row].name ?? "Select a course", true)
                self.navigationController?.popViewController(animated: true)
            } else {
                let vc = storyboard?.instantiateViewController(withIdentifier: "ScorecardViewController") as? ScorecardViewController
                vc!.roundId = roundId
                vc!.roundName = roundName
                vc!.roundDate = roundDate
                vc!.courseId = coursesListData[indexPath.row]._id ?? ""
                vc!.isCreatRoundCall = isCreatRoundCall
                vc!.isNeedviewWillCall = true
                vc?.selectedCourseName = coursesListData[indexPath.row].name ?? "Select a course"
                self.navigationController?.pushViewController(vc!, animated: true)
            }
        } else {
            let vc = storyboard?.instantiateViewController(withIdentifier: "EditCourseViewController") as? EditCourseViewController
            vc?.courseName = coursesListData[indexPath.row].name ?? ""
            vc?.courseId = coursesListData[indexPath.row]._id ?? ""
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [self] (_, _, completionHandler) in
            completionHandler(true)
            Utility.showProgressDialog(view: self.view)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                Utility.hideProgressDialog(view: self.view)
            }
            deleteCourseAPI(courseId: coursesListData[indexPath.row]._id ?? "")
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
}



