//
//  FamilyTree.swift
//  FamilyTree
//
//  Created by Gia Huy on 04/05/2021.
//

import UIKit
import ObjectMapper

class FamilyTree: Mappable {
    
    var id = 0
    var name = ""
    var description = ""
    var owner = FamilyTreeCollaborator()
    var editors = [FamilyTreeCollaborator]()
    var people = [People]()
    
    init() {}
    
    required  init?(map: Map) {
        mapping(map: map)
    }
    
    func  mapping(map: Map) {
        id                                  <- map["id"]
        name                                <- map["name"]
        description                         <- map["description"]
        owner                               <- map["owner"]
        editors                             <- map["editors"]
        people                              <- map["people"]
    }
}

class FamilyTreeCollaborator: Mappable {
    
    var id = ""
    var username = ""
    var avatarUrl = ""
    
    init() {}
    
    required  init?(map: Map) {
        mapping(map: map)
    }
    
    func  mapping(map: Map) {
        id                                      <- map["id"]
        username                                <- map["username"]
        avatarUrl                               <- map["avatarUrl"]
    }
}
