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
    var wifeId = 0
    var fatherId = 0
    var image = UIImage()
    
    var maxX:CGFloat = 0
    
    init() {}
    required init?(map: Map) {
        mapping(map: map)
    }
    
    init(id:Int, fullName:String, birthday:String, gender:Int, image:UIImage, wifeId:Int, fatherId:Int) {
        self.id = id
        self.fullName = fullName
        self.birthday = birthday
        self.gender = gender
        self.image = image
        self.wifeId = wifeId
        self.fatherId = fatherId
    }
    
    func mapping(map: Map){
        id                          <- map["id"]
        fullName                    <- map["fullName"]
        birthday                    <- map["birthday"]
        gender                      <- map["gender"]
    }
    
}
