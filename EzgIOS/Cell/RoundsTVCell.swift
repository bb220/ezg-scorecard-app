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
    @IBOutlet weak var courseName: UILabel!
    @IBOutlet weak var courseScore: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backView.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        backView.dropShadow(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.06), opacity: 1, offSet: CGSize(width: 0, height: 0), radius: 16, scale: true)
        roundName.textColor = UIColor(named: "black")
    }
    
    func setValueOnCell(holeModelData: [HoleData]?, modelData: [RoundData]?, index: Int) {
        // For Total Score calculation
        var total = 0
        courseScore.text = "+0"
        courseName.text = ""

        /// Round Total Score
        let HoleData = holeModelData?.filter {
            ($0.round?.Id == modelData?[index].Id)
        }
        if HoleData!.count > 0 {
            for i in 0...HoleData!.count - 1 {
                total = total + (HoleData?[i].score)!
            }
            roundScore.text = "\(total)"
        } else { roundScore.text = "-" }
        
        /// Course Total Score & Course name
        if let courseObj = modelData![index].course {
            courseName.text = courseObj.name
            
            let differenceRC = total - courseObj.total!
            if String(differenceRC).contains("-") {
                courseScore.text = "\(differenceRC)"
            } else { courseScore.text = "+\(differenceRC)" }
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
