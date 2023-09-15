
import Foundation

struct RoundData: Codable {
  var Id : String? = nil
  var user : UserData? = UserData()
  var course : Course? = Course()
  var name : String? = nil
  var playedDate : String? = nil
  var createdAt : String? = nil
  var updatedAt : String? = nil

  enum CodingKeys: String, CodingKey {
    case Id = "_id"
    case user = "user"
    case course = "course"
    case name = "name"
    case playedDate = "played_date"
    case createdAt = "createdAt"
    case updatedAt = "updatedAt"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    Id = try values.decodeIfPresent(String.self, forKey: .Id)
    user = try values.decodeIfPresent(UserData.self, forKey: .user)
    course = try values.decodeIfPresent(Course.self, forKey: .course)
    name = try values.decodeIfPresent(String.self, forKey: .name)
    playedDate = try values.decodeIfPresent(String.self, forKey: .playedDate)
    createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
    updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
  }
  init() { }
}



struct Course: Codable {
  var Id    : String? = nil
  var name  : String? = nil
  var total : Int?    = nil

  enum CodingKeys: String, CodingKey {
    case Id    = "_id"
    case name  = "name"
    case total = "total"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    Id    = try values.decodeIfPresent(String.self , forKey: .Id    )
    name  = try values.decodeIfPresent(String.self , forKey: .name  )
    total = try values.decodeIfPresent(Int.self    , forKey: .total )
 
  }
  init() { }
}

