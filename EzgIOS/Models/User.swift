import Foundation
import ObjectMapper

struct User : Mappable {
    
    var id : Int?
    var email : String?

    init?() {

    }
    
    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        id <- map["id"]
        email <- map["email"]
        
    }

}
