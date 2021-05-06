//
//  Account.swift
//  Scanner App
//
//  Created by Gia Huy on 28/11/2020.
//

import UIKit
import ObjectMapper

class Account : Mappable {
    
    var id = ""
    var username = ""
    var email = ""
    var firstName = ""
    var midName = ""
    var lastName = ""
    var avatarUrl = ""
    var address = ""
    var phone = ""
    var gender = 0
    var birthday = ""
    
    
    var accessToken = ""
    var refreshToken = ""
    
    init() {}
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map){
        id                                  <- map["id"]
        username                            <- map["username"]
        email                               <- map["email"]
        firstName                           <- map["firstName"]
        midName                             <- map["midName"]
        lastName                            <- map["lastName"]
        avatarUrl                           <- map["avatarUrl"]
        address                             <- map["address"]
        phone                               <- map["phone"]
        gender                              <- map["gender"]
        birthday                            <- map["dateOfBirth"]
    }
    
}

class AccountRes : Mappable {
    
    var user = Account()
    var accessToken = ""
    var refreshToken = ""
    
    
    init() {}
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map){
        user                                    <- map["user"]
        accessToken                             <- map["accessToken"]
        refreshToken                            <- map["refreshToken"]
    }
    
}
