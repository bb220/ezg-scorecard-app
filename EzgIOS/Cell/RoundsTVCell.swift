//
//  RoundsTVCell.swift
//  EzgIOS
//
//  Created by iMac on 10/03/23.
//

import UIKit

class RoundsTVCell: UITableViewCell {

    @IBOutlet var backView: UIView!
    @IBOutlet var roundName: UILabel!
    @IBOutlet var roundDate: UILabel!
    @IBOutlet var roundScore: UILabel!
    
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
        let HoleData = holeModelData?.filter {
            ($0.round?.Id == modelData?[index].Id)
        }
        if HoleData!.count > 0 {
            for i in 0...HoleData!.count - 1 {
                total = total + (HoleData?[i].score)!
            }
            roundScore.text = "\(total)"
        } else {
            roundScore.text = "-"
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
