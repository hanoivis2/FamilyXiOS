//
//  FamilyTreeMemory.swift
//  FamilyTree
//
//  Created by Gia Huy on 12/06/2021.
//

import UIKit
import ObjectMapper

class FamilyTreeMemory: Mappable {
    
    var id = 0
    var familyTreeId = 0
    var description = ""
    var memoryDate = ""
    var imageUrls = [String]()
    var dateCreated = ""
    var creator = Account()
    
    init() {}
    
    required  init?(map: Map) {
        mapping(map: map)
    }
    
    func  mapping(map: Map) {
        id                                          <- map["id"]
        familyTreeId                                <- map["familyTreeId"]
        description                                 <- map["description"]
        memoryDate                                  <- map["memoryDate"]
        imageUrls                                   <- map["imageUrls"]
        dateCreated                                 <- map["dateCreated"]
        creator                                     <- map["creator"]
    }
}
