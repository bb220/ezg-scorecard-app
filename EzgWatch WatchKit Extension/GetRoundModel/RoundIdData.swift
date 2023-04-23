//
//  RoundIdData.swift
//  EzgWatch WatchKit Extension
//
//  Created by iMac on 14/03/23.
//

import Foundation

struct RoundIdData: Codable {

  var Id   : String? = nil
  var name : String? = nil

  enum CodingKeys: String, CodingKey {

    case Id   = "_id"
    case name = "name"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    Id   = try values.decodeIfPresent(String.self , forKey: .Id   )
    name = try values.decodeIfPresent(String.self , forKey: .name )
 
  }

  init() {

  }

}
