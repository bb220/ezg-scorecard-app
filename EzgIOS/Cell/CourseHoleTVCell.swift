//
//  CourseHoleTVCell.swift
//  EzgIOS
//
//  Created by iMac on 01/09/23.
//

import Foundation
import UIKit

protocol EditCourseViewControllerDelegate: AnyObject {
    func incrementScore(value: Int, parValue: Int)
    func decrementScore(value: Int, parValue: Int)
    func reloadTableView()
    func updateTmpData(updatedPars: [[String: Int?]])
}
protocol ParValueChangeDelegate: AnyObject {
    func parUpdate(number:Int, par:Int)
}

class CourseHoleTVCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet var holeBackView: UIView!
    @IBOutlet var holeName: UILabel!
    @IBOutlet var parView: UIView!
    @IBOutlet var parButton: UIButton!
    @IBOutlet weak var parTxtField: UITextField!
    
    var updatedPars: [[String: Int?]] = []
    var isNewCourse: Bool?
    var currentTextFieldValue = 0
    weak var delegate: EditCourseViewControllerDelegate?
    weak var parDelegate: ParValueChangeDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        holeBackView.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        holeBackView.dropShadow(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.06), opacity: 1, offSet: CGSize(width: 0, height: 0), radius: 16, scale: true)
        parTxtField.delegate = self
    }
    
    @objc final private func textEditing(textField: UITextField) {
        
        let title = textField.text
        if textField.text == "" {
            return
        }
        if let parValue = Int(textField.text ?? "0") {
            let number = Int(holeName.text ?? "0")
            
            var par = parValue
            if currentTextFieldValue < parValue {
                par = parValue - currentTextFieldValue
                delegate?.incrementScore(value: Int(holeName.text ?? "0") ?? 0, parValue: par)
            } else if currentTextFieldValue > parValue  {
                par = par - currentTextFieldValue
                delegate?.decrementScore(value: Int(holeName.text ?? "0") ?? 0, parValue: par)
            } else { }
            
            textField.text = title
            parDelegate?.parUpdate(number: number ?? 0, par: parValue)
//            updateTmp(number: number ?? 0, par: parValue)
        }
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        currentTextFieldValue = Int(textField.text ?? "0") ?? 0
        print("textField.text ---- ", textField.text!, currentTextFieldValue)
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // maximum character length
        let maxLength = 2
        let allowedCharacterSet = CharacterSet(charactersIn: "0123456789")
        let stringCharacterSet = CharacterSet(charactersIn: string)
        
        if string.isEmpty { return true }
        // Check the new string is numeric and doesn't exceed the maximum length
        if stringCharacterSet.isSubset(of: allowedCharacterSet) && textField.text?.count ?? 0 + string.count <= maxLength {
            return true
        } else { return false }
    }
    
    
//    func updateTmp(number: Int, par: Int) {
//        var update: Bool = false
//        if updatedPars.count > 0 {
//            for val in 0...updatedPars.count - 1 {
//                if updatedPars[val]["number"] == number {
//                    updatedPars[val]["par"] = par
//                    update = true
//                    break
//                }
//            }
//        } else { updatedPars.append(["number": number, "par": par]) }
//
//        DispatchQueue.main.async { [self] in
//            if update {
//                delegate?.updateTmpData(updatedPars: updatedPars)
//            }
//        }
//    }
    
    func setValueOnCell(index: Int, isEditable: Bool, isNewCourseCreate: Bool, updateParArr: [[String:Int?]] ) {
        isNewCourse = isNewCourseCreate
        updatedPars = updateParArr
        holeName.text = "\(index + 1)"
        parTxtField.text = ""
        parTxtField.addTarget(self, action: #selector(textEditing(textField:)), for: .editingDidEnd)
        parTxtField.delegate = self
        
        if index < updatedPars.count {
            if updatedPars[index]["par"] != nil {
                parTxtField.isEnabled = isEditable ? true : false
                parView.backgroundColor = (isEditable ? UIColor.systemGray5 : UIColor.clear)
                parButton.setTitle("", for: .normal)
                parTxtField.text = "\(updatedPars[index]["par"]!!)"
            }
        } else if index == updatedPars.count && isEditable {
            parTxtField.isEnabled = true
            parButton.setTitle("", for: .normal)
            parTxtField.text = ""
            parView.backgroundColor = UIColor.systemGray5
        } else {
            parTxtField.isEnabled = isEditable ? true : false
            parView.backgroundColor = (isEditable ? UIColor.systemGray5 : UIColor.clear)
            parButton.setTitle("", for: .normal)
            parTxtField.text = ""
        }
    }
}

