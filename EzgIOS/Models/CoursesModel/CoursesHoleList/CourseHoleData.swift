//
//  CourseHoleData.swift
//  EzgIOS
//
//  Created by iMac on 04/09/23.
//

import Foundation


struct CourseHoleData : Codable {
    let _id : String?
    let course : String?
    var user : UserData? = UserData()
    let number : Int?
    let par : Int?
    let is_deleted : Bool?
    let createdAt : String?
    let updatedAt : String?
    let __v : Int?

    enum CodingKeys: String, CodingKey {

        case _id = "_id"
        case course = "course"
        case user = "user"
        case number = "number"
        case par = "par"
        case is_deleted = "is_deleted"
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
        case __v = "__v"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        _id = try values.decodeIfPresent(String.self, forKey: ._id)
        course = try values.decodeIfPresent(String.self, forKey: .course)
        user = try values.decodeIfPresent(UserData.self, forKey: .user)
        number = try values.decodeIfPresent(Int.self, forKey: .number)
        par = try values.decodeIfPresent(Int.self, forKey: .par)
        is_deleted = try values.decodeIfPresent(Bool.self, forKey: .is_deleted)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
        __v = try values.decodeIfPresent(Int.self, forKey: .__v)
    }

}
