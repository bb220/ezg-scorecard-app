//
//  EditCourseViewController.swift
//  EzgIOS
//
//  Created by iMac on 01/09/23.
//

import Foundation
import UIKit
import Alamofire
import WatchConnectivity

class EditCourseViewController: UIViewController {
    
    @IBOutlet var headerView: UIView!
    @IBOutlet var frontScore: UILabel!
    @IBOutlet var backScore: UILabel!
    @IBOutlet var totalScore: UILabel!
    @IBOutlet var courseHolesTableView: UITableView!
    @IBOutlet var scoreBoardView: UIView!
    
    var courseHoleModelData: [CourseHoleData] = []
    var updatedPars: [[String: Int?]] = []
    var roundId: String = ""
    var roundName: String = ""
    var roundDate: String = ""
    var courseId: String = ""
    var courseName: String = ""
    var updatedCourseName: String = ""
    
    var isNewCourseCreate = false
    var isCourseNameEdit: Bool = false
    var isCreatRoundCall = false
    var editBtnTapped = false
    var total = 0
    var front = 0
    var back = 0
    var totalCourses: Int = 0
    let token = "\(UserDefaults.standard.string(forKey: "token") ?? "")"
    
    override func viewDidLoad() {
        initView()
    }
    
    func initView() {
        if isNewCourseCreate {
            title = "Course \(totalCourses + 1)"
            courseName = "Course \(totalCourses + 1)"
            let editButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonTapped(_:)))
            navigationItem.rightBarButtonItem = editButton
            editButtonTapped()
        } else {
            title = courseName
            let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped))
            navigationItem.rightBarButtonItem = editButton
            courseHoleListAPI()
        }
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        courseHolesTableView.separatorColor = UIColor.clear
        headerView.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        headerView.dropShadow(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.06), opacity: 1, offSet: CGSize(width: 0, height: 0), radius: 16, scale: true)
        scoreBoardView.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        scoreBoardView.dropShadow(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.1), opacity: 1, offSet: CGSize(width: 0, height: 8), radius: 16, scale: true)
    }
    
    @objc func editButtonTapped() {
        editBtnTapped = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonTapped(_:)))
        
        let width = UIScreen.main.bounds.width - 150 / 2
        let textField = UITextField(frame: CGRect(x: width, y: 0, width: 150, height: 40))
        textField.backgroundColor = UIColor.systemGray5
        textField.textAlignment = .center
        textField.layer.cornerRadius = 10
        textField.text = navigationItem.title
        textField.font = UIFont(name: "Rubik-Medium", size: 20)!
        textField.textColor = UIColor(red: 0, green: 0, blue: 0)
        textField.addTarget(self, action: #selector(textEditing(textField:)), for: .editingChanged)
        updatedCourseName = courseName
        navigationItem.titleView = textField
        
        DispatchQueue.main.async { [self] in
            courseHolesTableView.reloadData()
        }
    }
    
    @objc final private func textEditing(textField: UITextField) {
        isCourseNameEdit = true
        updatedCourseName = textField.text ?? "Course"
    }
    
    @objc func saveButtonTapped(_ sender: UIBarButtonItem) {
        editBtnTapped = false
        if isNewCourseCreate == true {
            createCourseAPI()
        } else {
            if updatedPars.count > 0 {
                bulkParUpdateAPI()
            }
        }
        if isCourseNameEdit == true {
            updateCourseNameAPI()
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped))
        courseHolesTableView.reloadData()
        DispatchQueue.main.async { [self] in
            let navigationTitleLabel = UILabel()
            navigationTitleLabel.text = updatedCourseName
            navigationTitleLabel.sizeToFit()
            navigationTitleLabel.font = UIFont(name: "Rubik-Medium", size: 20)!
            navigationTitleLabel.textColor = UIColor(red: 0, green: 0, blue: 0)
            navigationItem.titleView = navigationTitleLabel
        }
    }
    
    func calculateTotalPars(courseHoleModelData: [CourseHoleData]) {
        if courseHoleModelData.count > 0 {
            total = 0
            front = 0
            back = 0
            for i in 0...courseHoleModelData.count - 1 {
                total += courseHoleModelData[i].par!
                totalScore.text = "\(total)"
                if i < 9 {
                    front += courseHoleModelData[i].par!
                    frontScore.text = "\(front)"
                }
                if i > 8 {
                    back += courseHoleModelData[i].par!
                    backScore.text = "\(back)"
                }
            }
        }
    }
    
    func createCourseAPI() {
        Utility.showProgressDialog(view: self.view)
        Utility.isValidateToken { [self] isValid in
            if isValid {
                createCourse()
            } else {
                Utility.refreshToken { [self] success in
                    if success {
                        createCourse()
                    } else {
                        Utility.hideProgressDialog(view: self.view)
                        print("Error in createCourseAPI")
                    }
                }
            }
        }
    }
    
    func createCourse() {
        let url = "\(Global.sharedInstance.baseUrl)course/"
        let parameters: Parameters = [
            "name": isCourseNameEdit ? updatedCourseName : courseName
        ]
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        Alamofire.request(url, method: .post, parameters: parameters, headers: headers).responseJSON { [self] response in
            switch response.result {
            case .success(_):
                Utility.hideProgressDialog(view: self.view)
                let model = try? JSONDecoder().decode(GetCourseId.self, from: response.data!)
                //                print("creatCourse model--->",model)
                courseId =  model?.data?.Id ?? ""
                courseName = model?.data?.name ?? ""
                
                DispatchQueue.main.async {
                    if isNewCourseCreate {
                        bulkParUpdateAPI()
                        isNewCourseCreate = false
                    }
                }
            case .failure(let error):
                print("API error: \(error)")
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
        let url = "\(Global.sharedInstance.baseUrl)course_hole?page=1&limit=18&course=\(courseId)"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(UserDefaults.standard.string(forKey: "token") ?? "")",
        ]
        Alamofire.request(url, method: .get, headers: headers).responseJSON { response in
            switch response.result {
            case .success(_):
                if let model = try? JSONDecoder().decode(GetCourseHoleList.self, from: response.data!) {
                    self.courseHoleModelData = model.data ?? []
                    self.courseHoleModelData = self.courseHoleModelData.reversed()
                    DispatchQueue.main.async { [self] in
                        updatedPars.removeAll()
                        if courseHoleModelData.count > 0 {
                            for value in 0...courseHoleModelData.count - 1 {
                                let data = ["number": courseHoleModelData[value].number, "par": courseHoleModelData[value].par]
                                updatedPars.append(data)
                            }
                        }
                        calculateTotalPars(courseHoleModelData: courseHoleModelData)
                        DispatchQueue.main.async { [self] in
                            courseHolesTableView.reloadData()
                            Utility.hideProgressDialog(view: view)
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func bulkParUpdateAPI() {
        Utility.isValidateToken { [self] isValid in
            if isValid {
                bulkParUpdate()
            } else {
                Utility.refreshToken { [self] success in
                    if success {
                        bulkParUpdate()
                    } else { print("Error in updateScoreAPI") }
                }
            }
        }
    }
    
    func bulkParUpdate() {
        let url = "\(Global.sharedInstance.baseUrl)course_hole/bulk"
//        print("updatedPars====>>",updatedPars)
        let parameters: Parameters = [
            "course": courseId,
            "holes": updatedPars
        ]
        let headers: HTTPHeaders = ["Authorization": "Bearer \(UserDefaults.standard.string(forKey: "token") ?? "")"]
        Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            switch response.result {
            case .success:
//                print(response.map({ i in
//                    print("bulk--",i, "response", response.data)
//                }))
                Utility.showProgressDialog(view: self.view)
                self.courseHoleListAPI()
                
                DispatchQueue.main.async { [self] in
                    if isCreatRoundCall == true {
                        let vc = storyboard?.instantiateViewController(withIdentifier: "ScorecardViewController") as? ScorecardViewController
                        vc?.courseId = courseId
                        vc?.roundId = roundId
                        vc?.roundName = roundName
                        vc?.roundDate = roundDate
                        vc?.isCreatRoundCall = isCreatRoundCall
                        vc?.selectedCourseName = courseName
                        vc?.isNeedviewWillCall = true
                        self.navigationController?.pushViewController(vc!, animated: true)
                    }
                }
            case .failure:
                print("bulk UpdateScore API Error")
            }
        }
    }
    
    func updateCourseNameAPI() {
        Utility.isValidateToken { [self] isValid in
            if isValid {
                updateCourseName()
            } else {
                Utility.refreshToken { [self] success in
                    if success {
                        updateCourseName()
                    } else { print("Error in updateCourseNameAPI") }
                }
            }
        }
    }
    
    func updateCourseName() {
        let url = "\(Global.sharedInstance.baseUrl)course/\(courseId)"
        let parameters: Parameters = [
            "name": "\(updatedCourseName)"
        ]
        
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        Alamofire.request(url, method: .put, parameters: parameters, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any],
                   let data = json["data"] as? [String: Any],
                   let name = data["name"] as? String {
                    self.courseName = name
                }
            case .failure(let error):
                print("update CourseNameAPI Error: \(error)")
            }
        }
    }
    
}

extension EditCourseViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 18
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = courseHolesTableView.dequeueReusableCell(withIdentifier: "CourseHoleTVCell", for: indexPath) as? CourseHoleTVCell
        cell?.delegate = self
        cell?.parDelegate = self
        cell?.setValueOnCell(index: indexPath.row, isEditable: editBtnTapped, isNewCourseCreate: isNewCourseCreate, updateParArr: updatedPars)
        return cell!
    }
}

extension EditCourseViewController: EditCourseViewControllerDelegate, ParValueChangeDelegate {
    func incrementScore(value: Int, parValue: Int) {
        if let current = Int(totalScore.text ?? "0") {
            let incrementedInt = current + parValue
            totalScore.text = "\(incrementedInt)"
        }
        if value < 10 {
            if let current = Int(frontScore.text ?? "0") {
                let incrementedInt = current + parValue
                frontScore.text = "\(incrementedInt)"
            }
        } else {
            if let current = Int(backScore.text ?? "0") {
                let incrementedInt = current + parValue
                backScore.text = "\(incrementedInt)"
            }
        }
    }
    
    func decrementScore(value: Int, parValue: Int) {
        if let current = Int(totalScore.text ?? "0") {
            let decrementedInt = current - abs(parValue)
            totalScore.text = "\(decrementedInt)"
        }
        if value < 10 {
            if let current = Int(frontScore.text ?? "0") {
                let decrementedInt = current - abs(parValue)
                frontScore.text = "\(decrementedInt)"
            }
        } else {
            if let current = Int(backScore.text ?? "0") {
                let decrementedInt = current - abs(parValue)
                backScore.text = "\(decrementedInt)"
            }
        }
    }
    
    func reloadTableView() {
        courseHolesTableView.reloadData()
    }
    
    func updateTmpData(updatedPars: [[String: Int?]]) {
        self.updatedPars.removeAll()
        self.updatedPars = updatedPars
    }
    
    func parUpdate(number: Int, par: Int) {
        if updatedPars.count > 0 {
            for i in 0...updatedPars.count - 1 {
                if updatedPars[i]["number"] == number {
                    updatedPars[i]["number"] = number
                    updatedPars[i]["par"] = par
                    break
                }
            }
            DispatchQueue.main.async { [self] in
                let data = ["number": number, "par": par]
                updatedPars.append(data)
//                courseHolesTableView.reloadData()
            }
        } else {
            let data = ["number": number, "par": par]
            updatedPars.append(data)
//            courseHolesTableView.reloadData()
        }
    }
}


