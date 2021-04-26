//
//  Account.swift
//  Scanner App
//
//  Created by Gia Huy on 28/11/2020.
//

import UIKit
import ObjectMapper

class Account : Mappable {
    
    var id = 0
    var fullName = ""
    var birthday = ""
    var gender = 0
    var image = UIImage()
    
    init() {}
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map){
        id                          <- map["id"]
        fullName                    <- map["fullName"]
        birthday                    <- map["birthday"]
        gender                      <- map["gender"]
    }
    
}
