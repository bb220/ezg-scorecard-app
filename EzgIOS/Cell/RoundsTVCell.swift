//
//  RoundsTVCell.swift
//  EzgIOS
//
//  Created by iMac on 10/03/23.
//

import UIKit
import SwiftyJSON

class RoundsTVCell: UITableViewCell {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var roundName: UILabel!
    @IBOutlet weak var roundDate: UILabel!
    @IBOutlet weak var roundScore: UILabel!
    @IBOutlet weak var courseNameLbl: UILabel!
    @IBOutlet weak var roundCourseDfLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backView.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        backView.dropShadow(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.06), opacity: 1, offSet: CGSize(width: 0, height: 0), radius: 16, scale: true)
        roundName.textColor = UIColor(named: "black")
    }
    
    func setValueOnCell(holeModelData: [HoleData]?, modelData: [RoundData]?, courseHolesData: [CourseHoleData]?, index: Int) {
        // For Total Score calculation
        var total = 0
        var courseTotal = 0
        roundCourseDfLbl.text = "-"
        courseNameLbl.text = ""
        
        //MARK: Round Total Score
        var roundHolesData = holeModelData?.filter {
            ($0.round?.Id == modelData?[index].Id)
        }
        if roundHolesData!.count > 0 {
            
            for i in 0...roundHolesData!.count - 1 {
                total = total + (roundHolesData?[i].score)!
            }
            roundScore.text = "\(total)"
        } else { roundScore.text = "-" }
        roundHolesData = roundHolesData?.reversed()
        
        //MARK: Course and Round difference & Course name
        if let courseObj = modelData![index].course {
            courseNameLbl.text = courseObj.name
            var courseHoleData = courseHolesData?.filter {
                ($0.course == courseObj.Id)
            }
            courseHoleData = courseHoleData?.reversed()
            if courseHoleData!.count > 0 {
                for i in 0...courseHoleData!.count - 1 {
                    if i < roundHolesData!.count  {
                        courseTotal = courseTotal + (courseHoleData?[i].par)!
                    } else {
                        courseTotal = courseTotal + 0
                    }
                }
                let differenceRC = total - courseTotal
                
                if differenceRC == 0 {
                    roundCourseDfLbl.text = "E"
                } else {
                    if String(differenceRC).contains("-") { roundCourseDfLbl .text = "\(differenceRC)"
                    } else { roundCourseDfLbl.text = "+\(differenceRC)" }
                }
            }
        }
        
        // For Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = dateFormatter.date(from: modelData?[index].createdAt ?? "") {
            dateFormatter.dateFormat = "MM/dd/yyyy"
            roundDate.text = "\(dateFormatter.string(from: date))"
        }
        //For Round name
        roundName.text = "\(modelData?[index].name ?? "")"
    }

}
