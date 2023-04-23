//
//  Model.swift
//  EzgWatch WatchKit Extension
//
//  Created by iMac on 10/04/23.
//

import Foundation

struct GetHoleList: Codable {

  var status      : Bool?   = nil
  var code        : Int?    = nil
  var message     : String? = nil
  var currentPage : Int?    = nil
  var totalPages  : Int?    = nil
  var data        : [HoleData]? = []

  enum CodingKeys: String, CodingKey {

    case status      = "status"
    case code        = "code"
    case message     = "message"
    case currentPage = "current_page"
    case totalPages  = "total_pages"
    case data        = "data"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    status      = try values.decodeIfPresent(Bool.self   , forKey: .status      )
    code        = try values.decodeIfPresent(Int.self    , forKey: .code        )
    message     = try values.decodeIfPresent(String.self , forKey: .message     )
    currentPage = try values.decodeIfPresent(Int.self    , forKey: .currentPage )
    totalPages  = try values.decodeIfPresent(Int.self    , forKey: .totalPages  )
    data        = try values.decodeIfPresent([HoleData].self , forKey: .data        )
 
  }

  init() {

  }

}

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
