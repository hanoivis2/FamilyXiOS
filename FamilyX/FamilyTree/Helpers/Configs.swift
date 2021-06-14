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
var API_GET_REFRESH_TOKEN = "/api/v%@/authentication/refresh-access-token"
var API_GET_LIST_ALL_FAMILY_TREE = "/api/v%@/tree-management/trees"
var API_GET_LIST_ALL_FAMILY_TREE_WITH_KEYWORD = "/api/v%@/tree-management/trees-from-keyword"
var API_GET_LIST_FAMILY_TREE = "/api/v%@/tree-management/trees/list"
var API_GET_LIST_FAMILY_TREE_WITH_KEYWORD = "/api/v%@/tree-management/trees-from-keyword/list"
var API_GET_FAMILY_TREE_INFO = "/api/v%@/tree-management/tree/%d"
var API_ADD_FAMILY_TREE = "/api/v%@/tree-management/tree"
var API_DELETE_FAMILY_TREE = "/api/v%@/tree-management/tree/%d"
var API_EDIT_FAMILY_TREE = "/api/v%@/tree-management/tree/%d"
var API_ADD_CHILD = "/api/v%@/person-management/person/child"
var API_ADD_SPOUSE = "/api/v%@/person-management/person/%d/spouse"
var API_ADD_PARENT = "/api/v%@/person-management/person/%d/parent"
var API_DELETE_NODE = "/api/v%@/person-management/person/%d"
var API_UPDATE_NODE = "/api/v%@/person-management/person/%d"
var API_UPLOAD_IMAGE = "/api/v%@/file-upload/image"
var API_GET_ALL_USERS = "/api/v%@/user-management/users"
var API_GET_ALL_EDITORS = "/api/v%@/tree-management/tree/%d/editors"
var API_ADD_EDITOR_TO_TREE = "/api/v%@/tree-management/tree/%d/add-users-to-editor"
var API_REMOVE_EDITOR_FROM_TREE = "/api/v%@/tree-management/tree/%d/remove-users-from-editor"
var API_GET_FAMILY_TREE_MEMORIES = "/api/v%@/memory-management/memories/tree/%d"
var API_ADD_FAMILY_TREE_MEMORY = "/api/v%@/memory-management/memory"
var API_DELETE_FAMILY_TREE_MEMORY = "/api/v%@/memory-management/memory/%d"



var KEY_FIRST_RUN = "KEY_FIRST_RUN"
var KEY_VERSION = "KEY_VERSION"
var KEY_TAB_INDEX = "KEY_TAB_INDEX"
var KEY_ACCOUNT = "KEY_ACCOUNT"
var KEY_TOKEN = "KEY_TOKEN"

var InternetError = "No internet connection"
var ServerErrorText = "There is an error in the process of retrieving data"
var UnauthorizedError = "Your login term has expired, please log in again"

var _peopleNodeWidth:CGFloat = 40
var _peopleNodeHeight:CGFloat = 50
var _defaultPaddingTop:CGFloat = 30
var _defaultPaddingLeft:CGFloat = 30
var _nodeHorizontalSpace:CGFloat = 15
var _nodeVerticalSpace:CGFloat = 20
var _siblingsLineHeight:CGFloat = 8

var maxSizeInBytesUploadImage = 2097152 //About 1200 x 800
var _maxImageUploadBigSize:CGFloat = 1000
var _maxImageUpLoadSmallSize:CGFloat = 700
