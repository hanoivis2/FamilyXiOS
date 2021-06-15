//
//  Notification.swift
//  FamilyTree
//
//  Created by Gia Huy on 16/06/2021.
//

import UIKit
import ObjectMapper

class NotificationSystem: Mappable {
    
    var id = 0
    var message = ""
    var isRead = false
    var dateCreated = ""
    var lastModified = ""
    
    init() {}
    
    required  init?(map: Map) {
        mapping(map: map)
    }
    
    func  mapping(map: Map) {
        id                                              <- map["id"]
        message                                         <- map["message"]
        isRead                                          <- map["isRead"]
        dateCreated                                     <- map["dateCreated"]
        lastModified                                    <- map["lastModified"]
    }
}
