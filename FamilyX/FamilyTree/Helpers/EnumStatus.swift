//
//  EnumStatus.swift
//  Scanner App
//
//  Created by Gia Huy on 28/11/2020.
//

import Foundation

enum GENDER_ID : Int {
    case FEMALE = 1
    case MALE = 0
}

enum STATUS_REQUEST: Int{
    case STATUS_SUCCESS = 200
    case STATUS_NOT_FOUND = 404
    case STATUS_BAD_REQUEST = 400
    case STATUS_UNAUTHORIZED = 401
    case STATUS_FORBIDEN = 403
    case STATUS_DATA = 500
}

enum REQUEST_METHOD: Int {
    case POST
    case GET
    case PUT
    case DELETE
}
