import UIKit
import Foundation

class Global {
    
    static let sharedInstance = Global()
    
    var baseUrl = "http://44.202.136.185/api/v1/"
    var token: String = ""
    var tokenType: String = ""
    var user: User?
    
}
