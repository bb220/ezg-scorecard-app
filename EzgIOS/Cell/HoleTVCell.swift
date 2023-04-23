//
//  HoleTVCell.swift
//  EzgIOS
//
//  Created by iMac on 10/03/23.
//

import UIKit

class HoleTVCell: UITableViewCell {
    
    var scoreLongPress = false
    var puttLongPress = false
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    var holeModelDataa: [HoleData] = []
    
    weak var delegate: ScorecardViewControllerDelegate?
    weak var scoreDelegate: ChangeScoreValueDelegate?

    @IBOutlet var scoreView: UIView!
    @IBOutlet var puttView: UIView!
    @IBOutlet var holeBackView: UIView!
    @IBOutlet var holeName: UILabel!
    @IBOutlet var scoreButton: UIButton!
    @IBOutlet var puttButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        holeBackView.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        holeBackView.dropShadow(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.06), opacity: 1, offSet: CGSize(width: 0, height: 0), radius: 16, scale: true)
    }
    
    @objc func scorePressed(_ sender: UIButton) {
        let title = sender.titleLabel?.text
        if let current = Int(title ?? "0") {
            let incrementedInt = current + 1
            let newTitle = "\(incrementedInt)"
            sender.setTitle(newTitle, for: .normal)
            feedbackGenerator.impactOccurred()
            delegate?.incrementScore(value: sender.tag)
            let number = Int(holeName.text ?? "0")
            let score = Int(scoreButton.currentTitle ?? "0")
            let putts = Int(puttButton.currentTitle ?? "0")
            scoreDelegate?.scoreUpdate(number: number ?? 0, par: 1, score: score ?? 0, putts: putts ?? 0)
        }
    }
    
    @objc func scoreLongPressed(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began && !scoreLongPress {
            let puttTitle = puttButton.currentTitle
            if let currentPutt = Int(puttTitle ?? "0") {
                guard let button = sender.view as? UIButton else { return }
                let title = button.title(for: .normal)
                if let current = Int(title ?? "0") {
                    if current > currentPutt {
                        let incrementedInt = current - 1
                        let newTitle = "\(incrementedInt)"
                        button.setTitle(newTitle, for: .normal)
                        feedbackGenerator.impactOccurred()
                        delegate?.decrementScore(value: button.tag)
                        let number = Int(holeName.text ?? "0")
                        let score = Int(scoreButton.currentTitle ?? "0")
                        let putts = Int(puttButton.currentTitle ?? "0")
                        scoreDelegate?.scoreUpdate(number: number ?? 0, par: 1, score: score ?? 0, putts: putts ?? 0)
                    }
                }
                scoreLongPress = true
            }
        }
        else if sender.state == .ended {
            scoreLongPress = false
        }
    }
    
    @objc func puttPressed(_ sender: UIButton) {
        let scoreTitle = scoreButton.currentTitle
        if let current = Int(scoreTitle ?? "0") {
            let incrementedInt = current + 1
            let newTitle = "\(incrementedInt)"
            scoreButton.setTitle(newTitle, for: .normal)
        }
        let title = sender.titleLabel?.text
        if let current = Int(title ?? "0") {
            let incrementedInt = current + 1
            let newTitle = "\(incrementedInt)"
            sender.setTitle(newTitle, for: .normal)
            feedbackGenerator.impactOccurred()
            delegate?.incrementScore(value: sender.tag)
            let number = Int(holeName.text ?? "0")
            let score = Int(scoreButton.currentTitle ?? "0")
            let putts = Int(puttButton.currentTitle ?? "0")
            scoreDelegate?.scoreUpdate(number: number ?? 0, par: 1, score: score ?? 0, putts: putts ?? 0)
        }
    }
    
    @objc func puttLongPressed(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began && !puttLongPress {
            guard let button = sender.view as? UIButton else { return }
            let title = button.title(for: .normal)
            if let current = Int(title ?? "0") {
                if current > 0 {
                    let incrementedInt = current - 1
                    let newTitle = "\(incrementedInt)"
                    button.setTitle(newTitle, for: .normal)
                    
                    let scoreTitle = scoreButton.currentTitle
                    if let current = Int(scoreTitle ?? "0") {
                        let incrementedInt = current - 1
                        let newTitle = "\(incrementedInt)"
                        scoreButton.setTitle(newTitle, for: .normal)
                    }
                    feedbackGenerator.impactOccurred()
                    delegate?.decrementScore(value: button.tag)
                    let number = Int(holeName.text ?? "0")
                    let score = Int(scoreButton.currentTitle ?? "0")
                    let putts = Int(puttButton.currentTitle ?? "0")
                    scoreDelegate?.scoreUpdate(number: number ?? 0, par: 1, score: score ?? 0, putts: putts ?? 0)
                }
            }
            puttLongPress = true
        }
        else if sender.state == .ended {
            puttLongPress = false
        }
    }
    
    func setValueOnCell(index: Int, holeModelData: [HoleData]?, isEditable: Bool) {
        holeModelDataa = holeModelData!
        holeName.text = "\(index + 1)"
        scoreButton.tag = index
        puttButton.tag = index
        
        scoreButton.addTarget(self, action: #selector(scorePressed(_:)), for: .touchUpInside)
        puttButton.addTarget(self, action: #selector(puttPressed(_:)), for: .touchUpInside)
        
        let scoreLongPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(scoreLongPressed(_:)))
        scoreLongPressGesture.minimumPressDuration = 0.5
        scoreButton.addGestureRecognizer(scoreLongPressGesture)
        
        let puttLongPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(puttLongPressed(_:)))
        puttLongPressGesture.minimumPressDuration = 0.5
        puttButton.addGestureRecognizer(puttLongPressGesture)
        
        if index < holeModelData?.count ?? 0 {
            if holeModelData?[index].score != nil {
                scoreButton.isEnabled = (isEditable ? false : true)
                puttButton.isEnabled = (isEditable ? false : true)
                scoreView.backgroundColor = (isEditable ? UIColor.clear : UIColor.systemGray5)
                puttView.backgroundColor = (isEditable ? UIColor.clear : UIColor.systemGray5)
                scoreButton.setTitle("\(holeModelData?[index].score ?? 0)", for: .normal)
                puttButton.setTitle("\(holeModelData?[index].putts ?? 0)", for: .normal)
            }
        } else {
            scoreButton.isEnabled = false
            puttButton.isEnabled = false
            scoreView.backgroundColor = .clear
            puttView.backgroundColor = .clear
            scoreButton.setTitle(" ", for: .normal)
            puttButton.setTitle(" ", for: .normal)
        }
    }
}

protocol ScorecardViewControllerDelegate: AnyObject {
    func incrementScore(value: Int)
    func decrementScore(value: Int)
}

protocol ChangeScoreValueDelegate: AnyObject {
    func scoreUpdate(number:Int, par:Int, score:Int, putts:Int)
}
