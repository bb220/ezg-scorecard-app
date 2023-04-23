import Foundation
import ObjectMapper

struct ServerError : Mappable {
    
    var medicalNumber : [String]?
    var phoneNumber : [String]?

    init?() {

    }
    
    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        medicalNumber <- map["medical_number"]
        phoneNumber <- map["phone_number"]
        
    }

}
