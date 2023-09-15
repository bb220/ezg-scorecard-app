//
//  CourseData.swift
//  EzgIOS
//
//  Created by iMac on 04/09/23.
//

import Foundation

struct CourseData: Codable {
    var _id : String?
    var user : UserData? = UserData()
    var name : String?
    var createdAt : String?
    var updatedAt : String?

    enum CodingKeys: String, CodingKey {

        case _id = "_id"
        case user = "user"
        case name = "name"
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        _id = try values.decodeIfPresent(String.self, forKey: ._id)
        user = try values.decodeIfPresent(UserData.self, forKey: .user)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
    }

}
