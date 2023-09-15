
import Foundation

struct HoleData: Codable {

  var Id        : String? = nil
  var round     : Round?  = Round()
  var number    : Int?    = nil
  var par       : Int?    = nil
  var score     : Int?    = nil
  var putts     : Int?    = nil
  var user      : UserData?   = UserData()
  var createdAt : String? = nil
  var updatedAt : String? = nil

  enum CodingKeys: String, CodingKey {

    case Id        = "_id"
    case round     = "round"
    case number    = "number"
    case par       = "par"
    case score     = "score"
    case putts     = "putts"
    case user      = "user"
    case createdAt = "createdAt"
    case updatedAt = "updatedAt"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    Id        = try values.decodeIfPresent(String.self , forKey: .Id        )
    round     = try values.decodeIfPresent(Round.self  , forKey: .round     )
    number    = try values.decodeIfPresent(Int.self    , forKey: .number    )
    par       = try values.decodeIfPresent(Int.self    , forKey: .par       )
    score     = try values.decodeIfPresent(Int.self    , forKey: .score     )
    putts     = try values.decodeIfPresent(Int.self    , forKey: .putts     )
    user      = try values.decodeIfPresent(UserData.self   , forKey: .user      )
    createdAt = try values.decodeIfPresent(String.self , forKey: .createdAt )
    updatedAt = try values.decodeIfPresent(String.self , forKey: .updatedAt )
 
  }

  init() {

  }

}
