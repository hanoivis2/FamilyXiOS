//
//  ResResponse.swift
//  FamilyTree
//
//  Created by Gia Huy on 27/04/2021.
//

import UIKit
import ObjectMapper

class ResResponse: Mappable {
    var status: Int?
    var data: AnyObject?
    var errors:String?
    var message:String?
    
    init() {}
    
    required  init?(map: Map) {
        mapping(map: map)
    }
    
    func  mapping(map: Map) {
        status                      <- map["status"]
        data                        <- map["data"]
        errors                      <- map["errors"]
        message                     <- map["message"]
    }
}
