//
//  People.swift
//  FamilyX
//
//  Created by Gia Huy on 07/04/2021.
//

import UIKit
import ObjectMapper

class People : Mappable {
    
    var id = 0
    var fullName = ""
    var birthday = ""
    var gender = 0
    var image = UIImage()
    
    
    var wifeId = 0
    var childrenId = [Int]()
    
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
