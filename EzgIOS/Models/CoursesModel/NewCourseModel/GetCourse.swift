//
//  GetCourse.swift
//  EzgIOS
//
//  Created by iMac on 05/09/23.
//

import Foundation


struct GetCourseId: Codable {

  var status : Bool? = nil
  var code : Int? = nil
  var message : String? = nil
  var data : CourseIdData?

  enum CodingKeys: String, CodingKey {

    case status = "status"
    case code = "code"
    case message = "message"
    case data = "data"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    status = try values.decodeIfPresent(Bool.self, forKey: .status)
    code = try values.decodeIfPresent(Int.self, forKey: .code)
    message = try values.decodeIfPresent(String.self, forKey: .message)
    data = try values.decodeIfPresent(CourseIdData.self, forKey: .data)
 
  }
    
}
