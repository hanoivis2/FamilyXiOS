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
    var firstName = ""
    var lastName = ""
    var birthday = ""
    var deathday = ""
    var imageUrl = ""
    var fatherId = 0
    var motherId = 0
    var gender = GENDER_ID.MALE.rawValue
    var note = ""
    var userId:String?
    var spouse = [Spouse]()
    
    var maxX:CGFloat = 0
    var firstChildMaxX:CGFloat = CGFloat.greatestFiniteMagnitude
    
    init() {}
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map){
        id                                      <- map["id"]
        firstName                               <- map["firstName"]
        lastName                                <- map["lastName"]
        birthday                                <- map["dateOfBirth"]
        deathday                                <- map["dateOfDeath"]
        imageUrl                                <- map["imageUrl"]
        fatherId                                <- map["parent1Id"]
        motherId                                <- map["parent2Id"]
        gender                                  <- map["gender"]
        note                                    <- map["note"]
        spouse                                  <- map["spouses"]
        userId                                  <- map["userId"]
    }
    
}

class Spouse : Mappable {
    var id = 0
    var firstName = ""
    var lastName = ""
    var birthday = ""
    var deathday = ""
    var fatherId = 0
    var motherId = 0
    var gender = GENDER_ID.MALE.rawValue
    var note = ""
    
    var maxX:CGFloat = 0
    
    init() {}
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map){
        id                                      <- map["id"]
        firstName                               <- map["firstName"]
        lastName                                <- map["lastName"]
        birthday                                <- map["birthday"]
        deathday                                <- map["deathday"]
        fatherId                                <- map["fatherId"]
        motherId                                <- map["motherId"]
        gender                                  <- map["gender"]
        note                                    <- map["note"]
    }
}
