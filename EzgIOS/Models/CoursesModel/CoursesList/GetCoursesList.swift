//
//  GetCoursesList.swift
//  EzgIOS
//
//  Created by iMac on 04/09/23.
//

import Foundation

struct GetCoursesList : Codable {
    let status : Bool?
    let code : Int?
    let message : String?
    let current_page : Int?
    let total_pages : Int?
    let total_courses : Int?
    let data : [CourseData]?

    enum CodingKeys: String, CodingKey {

        case status = "status"
        case code = "code"
        case message = "message"
        case current_page = "current_page"
        case total_pages = "total_pages"
        case total_courses = "total_courses"
        case data = "data"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(Bool.self, forKey: .status)
        code = try values.decodeIfPresent(Int.self, forKey: .code)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        current_page = try values.decodeIfPresent(Int.self, forKey: .current_page)
        total_pages = try values.decodeIfPresent(Int.self, forKey: .total_pages)
        total_courses = try values.decodeIfPresent(Int.self, forKey: .total_courses)
        data = try values.decodeIfPresent([CourseData].self, forKey: .data)
    }

}

