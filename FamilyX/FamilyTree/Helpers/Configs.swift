//
//  Configs.swift
//  Scanner App
//
//  Created by Gia Huy on 28/11/2020.
//

import Foundation
import UIKit

var OAUTH_SERVER_URL = "https://family-tree.azurewebsites.net"
var API_LOGIN = "/api/v%@/authentication/login"
var API_SIGN_UP = "/api/v%@/authentication/register"
var API_GET_LIST_FAMILY_TREE = "/api/v%@/tree-management/tree"
var API_GET_FAMILY_TREE_INFO = "/api/v%@/tree-management/tree/%d"



var KEY_FIRST_RUN = "KEY_FIRST_RUN"
var KEY_VERSION = "KEY_VERSION"
var KEY_TAB_INDEX = "KEY_TAB_INDEX"
var KEY_ACCOUNT = "KEY_ACCOUNT"
var KEY_TOKEN = "KEY_TOKEN"

var InternetError = "No internet connection\nTouch to reconnect"
var ServerErrorText = "There is an error in the process of retrieving data \nTouch to reconnect"
var SERVER_ERROR = "Server error. Please try again!"

var _peopleNodeWidth:CGFloat = 40
var _peopleNodeHeight:CGFloat = 50
var _defaultPaddingTop:CGFloat = 30
var _defaultPaddingLeft:CGFloat = 30
var _nodeHorizontalSpace:CGFloat = 15
var _nodeVerticalSpace:CGFloat = 20
var _siblingsLineHeight:CGFloat = 8
