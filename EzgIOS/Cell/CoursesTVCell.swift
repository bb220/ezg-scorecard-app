//
//  CoursesTVCell.swift
//  EzgIOS
//
//  Created by iMac on 01/09/23.
//

import UIKit

class CoursesTVCell: UITableViewCell {
    
    
    @IBOutlet var backView: UIView!
    @IBOutlet var courseName: UILabel!
    @IBOutlet var courseDate: UILabel!
    @IBOutlet var courseScore: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backView.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        backView.dropShadow(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.06), opacity: 1, offSet: CGSize(width: 0, height: 0), radius: 16, scale: true)
        courseName.textColor = UIColor(named: "black")
    }
    
    func setValueOnCell(holeModelData: [CourseHoleData]?, modelData: [CourseData]?, index: Int) {
        // For Total Score calculation
        var total = 0
        let HoleData = holeModelData?.filter {
            ($0.course == modelData?[index]._id)
        }
        if HoleData!.count > 0 {
            for i in 0...HoleData!.count - 1 {
                total = total + (HoleData?[i].par)!
            }
            courseScore.text = "\(total)"
        } else {
            courseScore.text = "-"
        }
        // For Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = dateFormatter.date(from: modelData?[index].createdAt ?? "") {
            dateFormatter.dateFormat = "MM/dd/yyyy"
            courseDate.text = "\(dateFormatter.string(from: date))"
        }
        //For Course Name
        courseName.text = "\(modelData?[index].name ?? "")".capitalized
    }
}
