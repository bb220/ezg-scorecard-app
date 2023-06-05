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
    let session = WCSession.default
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }

    @IBAction func yesClicked() {
        data = ["call": true]
        NotificationCenter.default.post(name: NSNotification.Name("response"), object: nil, userInfo: data)
        dismiss()
    }
    
    @IBAction func noClicked() {
        data = ["call": false]
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
