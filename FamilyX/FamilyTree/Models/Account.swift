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
    var emailConfirmed = false
    var firstName = ""
    var midName = ""
    var lastName = ""
    var avatarUrl = ""
    var address = ""
    var phone = ""
    var gender = 0
    var birthday = ""
    var createdDate = ""
    
    
    var accessToken = ""
    var refreshToken = ""
    
    
    //local
    var isShared = false
    
    init() {}
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map){
        id                                  <- map["id"]
        username                            <- map["userName"]
        email                               <- map["email"]
        emailConfirmed                      <- map["emailConfirmed"]
        firstName                           <- map["firstName"]
        midName                             <- map["midName"]
        lastName                            <- map["lastName"]
        avatarUrl                           <- map["avatarUrl"]
        address                             <- map["address"]
        phone                               <- map["phone"]
        gender                              <- map["gender"]
        birthday                            <- map["dateOfBirth"]
        createdDate                         <- map["createdDate"]
        accessToken                         <- map["accessToken"]
        refreshToken                        <- map["refreshToken"]
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

class AccountRefreshRes : Mappable {
    
    var user = Account()
    var accessToken = ""
    var newRefreshToken:String?
    
    
    init() {}
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map){
        user                                    <- map["user"]
        accessToken                             <- map["accessToken"]
        newRefreshToken                         <- map["newRefreshToken"]
    }
    
}
