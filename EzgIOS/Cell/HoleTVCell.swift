//
//  HoleTVCell.swift
//  EzgIOS
//
//  Created by iMac on 10/03/23.
//

import UIKit
import Alamofire

class HoleTVCell: UITableViewCell {
    
    var scoreLongPress = false
    var puttLongPress = false
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    var tmpData: [data] = []
    var roundId: String = ""
    var courseHoleObj: CourseHoleData?
    let innerBorderView = UIView()

    weak var delegate: ScorecardViewControllerDelegate?
    weak var scoreDelegate: ChangeScoreValueDelegate?
    
    @IBOutlet var scoreView: UIView!
    @IBOutlet var puttView: UIView!
    @IBOutlet var holeBackView: UIView!
    @IBOutlet var holeName: UILabel!
    @IBOutlet var scoreButton: UIButton!
    @IBOutlet var puttButton: UIButton!
    @IBOutlet var courseParLbl: UILabel!
    @IBOutlet weak var visualView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        holeBackView.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        holeBackView.dropShadow(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.06), opacity: 1, offSet: CGSize(width: 0, height: 0), radius: 16, scale: true)
    }
    
    func createHoleAPI(hole: Int, putt: Bool) {
        Utility.isValidateToken { [self] isValid in
            if isValid {
                createHole(hole: hole, putt: putt)
            } else {
                Utility.refreshToken { [self] success in
                    if success {
                        createHole(hole: hole, putt: putt)
                    } else {
                        print("Error in createHoleAPI")
                    }
                }
            }
        }
    }
    
    func createHole(hole: Int, putt: Bool) {
        let parameters: Parameters = [
            "round": roundId,
            "number": hole,
            "par": 0,
            "score": 1,
            "putts": (putt ? 1 : 0)
        ]
        let token = "\(UserDefaults.standard.string(forKey: "token") ?? "")"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        let url = "\(Global.sharedInstance.baseUrl)hole/"
        Alamofire.request(url, method: .post, parameters: parameters, headers: headers).responseJSON { response in
            switch response.result {
            case .success(_):
                DispatchQueue.main.async { [self] in
                    tmpData.append(data.init(number: hole, putt: (putt ? 1 : 0), score: 1))
                    DispatchQueue.main.async {
                        self.delegate?.updateTmpData(tmpData: tmpData)
                        self.delegate?.incrementScore(value: hole-1)
                    }
                    DispatchQueue.main.async {
                        self.delegate?.reloadTableView()
                    }
                }
            case .failure(let error):
                print("API error: \(error)")
            }
        }
    }
    
    func updateTmp(number: Int, putt: Int, score: Int) {
        var update: Bool = false
        for val in 0...tmpData.count - 1 {
            if tmpData[val].number == number {
                tmpData[val].putt = putt
                tmpData[val].score = score
                update = true
                break
            }
        }
        DispatchQueue.main.async { [self] in
            if update {
                delegate?.updateTmpData(tmpData: tmpData)
            }
        }
    }
    
    //MARK: button Actions
    @objc func scorePressed(_ sender: UIButton) {
        let title = sender.titleLabel?.text
        if title == "  " {
            createHoleAPI(hole: sender.tag + 1, putt: false)
            sender.isEnabled = false
        } else {
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
                updateTmp(number: number ?? 0, putt: putts ?? 0, score: score ?? 0)
                sender.isEnabled = false
            }
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
                        updateTmp(number: number ?? 0, putt: putts ?? 0, score: score ?? 0)
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
        if scoreTitle == "  " {
            createHoleAPI(hole: sender.tag + 1, putt: true)
            sender.isEnabled = false
        } else {
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
                updateTmp(number: number ?? 0, putt: putts ?? 0, score: score ?? 0)
                sender.isEnabled = false
            }
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
                    updateTmp(number: number ?? 0, putt: putts ?? 0, score: score ?? 0)
                }
            }
            puttLongPress = true
        }
        else if sender.state == .ended {
            puttLongPress = false
        }
    }
    
    //MARK: Set Visual View
    func visualViewCalculateFromDf(_ isEditable: Bool, _ courseDataCount: Int, _ modelData: [data], _ index: Int) {
        
        var dfRC = 0
        visualView.layer.borderWidth = 0
        visualView.layer.borderColor = UIColor.clear.cgColor
        visualView.layer.cornerRadius = 0
        innerBorderView.removeFromSuperview()
        visualView.isHidden = true
        innerBorderView.isHidden = true

        if isEditable == true && courseDataCount > 0 {
            if modelData.count > index {
            if courseHoleObj != nil  {
                    if let roundScore = modelData[index].score {
                        let coursePar = courseHoleObj?.par
                        dfRC = roundScore - coursePar!
//                        print("hole no:" , index + 1, "DfRC = ", dfRC )
                        if dfRC >= 1 {
                            switch dfRC {
                            case 1:
                                squareVisualView(borderWidth: 1, isInnerViewAdd: false)
                            case 2:
                                squareVisualView(borderWidth: 1, isInnerViewAdd: true)
                            case 3...Int.max:
                                squareVisualView(borderWidth: 3, isInnerViewAdd: false)
                            default:
                                visualView.isHidden = true
                            }
                        } else if dfRC <= -1 {
                            switch dfRC {
                            case -1:
                                circleVisualView(borderWidth: 1, isInnerViewAdd: false)
                            case -2:
                                circleVisualView(borderWidth: 1, isInnerViewAdd: true)
                            case Int.min...(-3):
                                circleVisualView(borderWidth: 3, isInnerViewAdd: false)
                            default:
                                visualView.isHidden = true
                            }
                        }
                    }
                }
            }
        }
    }
    
    func circleVisualView(borderWidth: Int, isInnerViewAdd: Bool) {
        visualView.isHidden = false
        visualView.layer.borderWidth = CGFloat(borderWidth)
        visualView.cornerRadius = visualView.frame.width / 2
        visualView.layer.borderColor = UIColor.black.cgColor
        if isInnerViewAdd {
            innerBorderView.isHidden = false
            innerBorderView.frame = CGRect(x: 5, y: 5, width: visualView.frame.width - 10, height: visualView.frame.height - 10)
            innerBorderView.layer.borderWidth = 1.0
            innerBorderView.layer.borderColor = UIColor.black.cgColor
            innerBorderView.cornerRadius = innerBorderView.frame.width / 2
            visualView.addSubview(innerBorderView)
        }
    }
    
    func squareVisualView(borderWidth: Int, isInnerViewAdd: Bool) {
        visualView.isHidden = false
        visualView.layer.borderWidth = CGFloat(borderWidth)
        visualView.layer.borderColor = UIColor.black.cgColor
        if isInnerViewAdd {
            innerBorderView.isHidden = false
            innerBorderView.frame = CGRect(x: 5, y: 5, width: visualView.frame.width - 10, height: visualView.frame.height - 10)
            innerBorderView.layer.borderWidth = 1.0
            innerBorderView.layer.borderColor = UIColor.black.cgColor
            visualView.addSubview(innerBorderView)
        }
    }
    
    
    //MARK: Set value on cell
    func setValueOnCell(index: IndexPath, modelData: [data], isEditable: Bool, courseDataCount: Int) {
        tmpData = modelData
        let index = index.row
        holeName.text = "\(index + 1)"
        scoreButton.tag = index
        puttButton.tag = index
        
        scoreButton.addTarget(self, action: #selector(scorePressed(_:)), for: .touchUpInside)
        puttButton.addTarget(self, action: #selector(puttPressed(_:)), for: .touchUpInside)
        
        let scoreLongPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(scoreLongPressed(_:)))
        scoreLongPressGesture.minimumPressDuration = 0.5
        scoreButton.addGestureRecognizer(scoreLongPressGesture)
        
        visualViewCalculateFromDf(isEditable, courseDataCount, modelData, index)

        let puttLongPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(puttLongPressed(_:)))
        puttLongPressGesture.minimumPressDuration = 0.5
        puttButton.addGestureRecognizer(puttLongPressGesture)
        if index < tmpData.count {
            if tmpData[index].score != nil {
                scoreButton.isEnabled = (isEditable ? false : true)
                puttButton.isEnabled = (isEditable ? false : true)
                scoreView.backgroundColor = (isEditable ? UIColor.clear : UIColor.systemGray5)
                puttView.backgroundColor = (isEditable ? UIColor.clear : UIColor.systemGray5)
                scoreButton.setTitle("\(tmpData[index].score ?? 0)", for: .normal)
                puttButton.setTitle("\(tmpData[index].putt ?? 0)", for: .normal)
            }
        } else if index == tmpData.count && !isEditable {
            scoreButton.isEnabled = true
            puttButton.isEnabled = true
            scoreButton.setTitle("  ", for: .normal)
            puttButton.setTitle("  ", for: .normal)
            scoreView.backgroundColor = UIColor.systemGray5
            puttView.backgroundColor = UIColor.systemGray5
        } else {
            scoreButton.isEnabled = false
            puttButton.isEnabled = false
            scoreView.backgroundColor = (isEditable ? UIColor.clear : UIColor.systemGray5)
            puttView.backgroundColor = (isEditable ? UIColor.clear : UIColor.systemGray5)
            scoreButton.setTitle(" ", for: .normal)
            puttButton.setTitle(" ", for: .normal)
        }
    }
}

protocol ScorecardViewControllerDelegate: AnyObject {
    func incrementScore(value: Int)
    func decrementScore(value: Int)
    func reloadTableView()
    func updateTmpData(tmpData: [data])
}

protocol ChangeScoreValueDelegate: AnyObject {
    func scoreUpdate(number:Int, par:Int, score:Int, putts:Int)
}
