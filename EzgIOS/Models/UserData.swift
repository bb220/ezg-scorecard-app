
import Foundation

struct UserData: Codable {

  var Id    : String? = nil
  var email : String? = nil

  enum CodingKeys: String, CodingKey {

    case Id    = "_id"
    case email = "email"

  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    Id    = try values.decodeIfPresent(String.self , forKey: .Id    )
    email = try values.decodeIfPresent(String.self , forKey: .email )

  }

  init() {

  }

}
