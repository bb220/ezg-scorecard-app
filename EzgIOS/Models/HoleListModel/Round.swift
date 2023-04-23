
import Foundation

struct Round: Codable {

  var Id         : String? = nil
  var user       : String? = nil
  var name       : String? = nil
  var playedDate : String? = nil
  var isDeleted  : Bool?   = nil
  var createdAt  : String? = nil
  var updatedAt  : String? = nil
  var _v         : Int?    = nil

  enum CodingKeys: String, CodingKey {

    case Id         = "_id"
    case user       = "user"
    case name       = "name"
    case playedDate = "played_date"
    case isDeleted  = "is_deleted"
    case createdAt  = "createdAt"
    case updatedAt  = "updatedAt"
    case _v         = "__v"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    Id         = try values.decodeIfPresent(String.self , forKey: .Id         )
    user       = try values.decodeIfPresent(String.self , forKey: .user       )
    name       = try values.decodeIfPresent(String.self , forKey: .name       )
    playedDate = try values.decodeIfPresent(String.self , forKey: .playedDate )
    isDeleted  = try values.decodeIfPresent(Bool.self   , forKey: .isDeleted  )
    createdAt  = try values.decodeIfPresent(String.self , forKey: .createdAt  )
    updatedAt  = try values.decodeIfPresent(String.self , forKey: .updatedAt  )
    _v         = try values.decodeIfPresent(Int.self    , forKey: ._v         )
 
  }

  init() {

  }

}