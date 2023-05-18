import UIKit
import Foundation

class Global {
    
    static let sharedInstance = Global()
    
    var baseUrl = "https://api.ezgolftech.com/api/v1/"
    var token: String = ""
    var refreshToken: String = ""
    var tokenExpireAt: Int = 0
    var tokenType: String = ""
    var user: User?
    
}
