//
//  GetRound.swift
//  EzgWatch WatchKit Extension
//
//  Created by iMac on 14/03/23.
//

import Foundation

struct GetRoundId: Codable {

  var status  : Bool?   = nil
  var code    : Int?    = nil
  var message : String? = nil
  var data    : RoundIdData?   = RoundIdData()

  enum CodingKeys: String, CodingKey {

    case status  = "status"
    case code    = "code"
    case message = "message"
    case data    = "data"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    status  = try values.decodeIfPresent(Bool.self   , forKey: .status  )
    code    = try values.decodeIfPresent(Int.self    , forKey: .code    )
    message = try values.decodeIfPresent(String.self , forKey: .message )
    data    = try values.decodeIfPresent(RoundIdData.self   , forKey: .data    )
 
  }

  init() {

  }

}
