//
//  FinishRoundController.swift
//  EzgWatch WatchKit Extension
//
//  Created by iMac on 06/03/23.
//

import WatchKit
import Foundation
import WatchConnectivity

class FinishRoundController: WKInterfaceController, WCSessionDelegate {
    
    var data = ["call": true]
    var put = 0
    var stroke = 0
    var total = 0
    var created: Bool = true
    let session = WCSession.default
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if let data = context as? [Any] {
            put = data[0] as! Int
            stroke = data[1] as! Int
            total = data[2] as! Int
            created = data[3] as! Bool
        }
    }

    @IBAction func yesClicked() {
        data = ["call": true, "created": created]
        NotificationCenter.default.post(name: NSNotification.Name("response"), object: nil, userInfo: data)
        dismiss()
    }
    
    @IBAction func noClicked() {
        data = ["call": false, "created": created]
        NotificationCenter.default.post(name: NSNotification.Name("response"), object: nil, userInfo: data)
        dismiss()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Error :- \(error.localizedDescription)")
        }
        print("ACTIVATION COMPLETE in WatchOS")
    }
}
