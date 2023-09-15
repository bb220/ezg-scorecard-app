
import Foundation

struct GetRoundList: Codable {

  var status      : Bool?   = nil
  var code        : Int?    = nil
  var message     : String? = nil
  var currentPage : Int?    = nil
  var totalPages  : Int?    = nil
  var total_rounds: Int?    = nil
  var data        : [RoundData]? = []

  enum CodingKeys: String, CodingKey {

    case status      = "status"
    case code        = "code"
    case message     = "message"
    case currentPage = "current_page"
    case totalPages  = "total_pages"
    case total_rounds = "total_rounds"
    case data        = "data"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    status      = try values.decodeIfPresent(Bool.self   , forKey: .status      )
    code        = try values.decodeIfPresent(Int.self    , forKey: .code        )
    message     = try values.decodeIfPresent(String.self , forKey: .message     )
    currentPage = try values.decodeIfPresent(Int.self    , forKey: .currentPage )
    totalPages  = try values.decodeIfPresent(Int.self    , forKey: .totalPages  )
    total_rounds = try values.decodeIfPresent(Int.self, forKey: .total_rounds   )
    data        = try values.decodeIfPresent([RoundData].self , forKey: .data   )

  }

  init() {

  }

}
