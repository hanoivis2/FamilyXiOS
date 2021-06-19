//
//  ResAPI.swift
//  GS_iOS
//
//  Created by kelvin on 11/7/18.
//  Copyright © 2018 vn.eteacher. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import ReachabilitySwift
import SystemConfiguration
import Loaf

class ResAPI: UIResponder {
    
    
    var sessionManager : SessionManager!
    
    class var sharedInstance: ResAPI {

        struct Singleton {
           
            static let instance = ResAPI()
        }
        
        return Singleton.instance
    }
    
    override init() {
        super.init()
        self.sessionManager = Alamofire.SessionManager.default
    }
    
    
    func checkInternet() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }

    
    //MARK: POST METHOD CALL API
    func callServiceWithPOSTMethod(params : Dictionary<String, AnyObject>, url : String, postCompleted : @escaping (_ data:AnyObject?, _ statusCode: Int?) -> ()){
        
        var auth_header = ["Authorization": "Bearer \(ManageCacheObject.getCurrentAccount().accessToken)"]
        
        auth_header = ManageCacheObject.isLogin() ? ["Authorization": "Bearer \(ManageCacheObject.getCurrentAccount().accessToken)"] : ["Authorization": "Basic \(ManageCacheObject.getCurrentAccount().accessToken)"]
        
        
        debugPrint(url,params,auth_header)
        Alamofire.request(url, method: .post, parameters: params,  encoding: JSONEncoding.default, headers: auth_header).validate().responseJSON { response in
            
            debugPrint("REQUEST  \(String(describing: response.request))")
            debugPrint("RESPONSE \(String(describing: response.result.value))")
            
            
            switch response.result {
            case .success:
                return postCompleted(response.result.value as AnyObject?, response.response?.statusCode)
            case .failure( _):
                return postCompleted(nil, response.response?.statusCode)
            }
        }
        
    }
    
    //MARK: GET METHOD CALL API
    func callServiceWithGETMethod(params : Dictionary<String, AnyObject>, url : String, postCompleted : @escaping (_ data:AnyObject?, _ statusCode: Int?) -> ()){
        
        var auth_header = ["Authorization": "Bearer \(ManageCacheObject.getCurrentAccount().accessToken)"]
        
        auth_header = ManageCacheObject.isLogin() ? ["Authorization": "Bearer \(ManageCacheObject.getCurrentAccount().accessToken)"] : ["Authorization": "Basic \(ManageCacheObject.getCurrentAccount().accessToken)"]

        
        debugPrint(url,params,auth_header)
        Alamofire.request(url, method:.get, parameters: params, encoding: URLEncoding.default, headers: auth_header).validate().responseJSON { response in
            
            debugPrint("REQUEST  \(String(describing: response.request))")
            debugPrint("RESPONSE \(String(describing: response.result.value))")
            
            switch response.result {
            case .success:
                
                return postCompleted(response.result.value as AnyObject?, response.response?.statusCode)
                
            case .failure( _):
                return postCompleted(nil, response.response?.statusCode)
            }
        }
        
    }
    
    //MARK: DELETE METHOD CALL API
    func callServiceWithDELETEMethod(params : Dictionary<String, AnyObject>, url : String, postCompleted : @escaping (_ data:AnyObject?, _ statusCode: Int?) -> ()){
        
        var auth_header = ["Authorization": "Bearer \(ManageCacheObject.getCurrentAccount().accessToken)"]
        
        auth_header = ManageCacheObject.isLogin() ? ["Authorization": "Bearer \(ManageCacheObject.getCurrentAccount().accessToken)"] : ["Authorization": "Basic \(ManageCacheObject.getCurrentAccount().accessToken)"]

        
        debugPrint(url,params,auth_header)
        Alamofire.request(url, method:.delete, parameters: params, encoding: URLEncoding.default, headers: auth_header).validate().responseJSON { response in
            
            debugPrint("REQUEST  \(String(describing: response.request))")
            debugPrint("RESPONSE \(String(describing: response.result.value))")
            
            switch response.result {
            case .success:
                
                return postCompleted(response.result.value as AnyObject?, response.response?.statusCode)
                
            case .failure( _):
                return postCompleted(nil, response.response?.statusCode)
            }
        }
        
    }
    
    //MARK: DELETE METHOD CALL API
    func callServiceWithPUTMethod(params : Dictionary<String, AnyObject>, url : String, postCompleted : @escaping (_ data:AnyObject?, _ statusCode: Int?) -> ()){
        
        var auth_header = ["Authorization": "Bearer \(ManageCacheObject.getCurrentAccount().accessToken)"]
        
        auth_header = ManageCacheObject.isLogin() ? ["Authorization": "Bearer \(ManageCacheObject.getCurrentAccount().accessToken)"] : ["Authorization": "Basic \(ManageCacheObject.getCurrentAccount().accessToken)"]
        
        debugPrint(url,params,auth_header)
        Alamofire.request(url, method: .put, parameters: params,  encoding: JSONEncoding.default, headers: auth_header).validate().responseJSON { response in
            
            debugPrint("REQUEST  \(String(describing: response.request))")
            debugPrint("RESPONSE \(String(describing: response.result.value))")
            
            switch response.result {
            case .success:
                return postCompleted(response.result.value as AnyObject?, response.response?.statusCode)
            case .failure( _):
                return postCompleted(nil, response.response?.statusCode)
            }
        }
        
    }
    
    //MARK:checkOnlineCallServiceWithMethod
    func checkOnlineCallServiceWithMethod(params : NSDictionary?,files: NSDictionary? = nil, url : String, method : Int, postCompleted : @escaping (_ data:AnyObject?,_ error :String) -> ()){
        var parseParams : Dictionary<String, AnyObject>? = params as? Dictionary<String, AnyObject>
        if(parseParams == nil){
            parseParams = Dictionary<String, AnyObject>()
        }
        parseParams?.updateValue("familyx_ios" as AnyObject, forKey: "os_name")

        
        if self.checkInternet() {
            
            switch method {
            case REQUEST_METHOD.POST.rawValue:
                self.callServiceWithPOSTMethod(params: parseParams!, url: url, postCompleted: { (data, statusCode) -> () in
                    
                    switch statusCode {
                    case STATUS_REQUEST.STATUS_UNAUTHORIZED.rawValue:
                        
                        self.refreshToken() { (message, newAccessToken) in
                            if message == "LOGOUT" {
                                return postCompleted(nil, "UNAUTHORIZED")
                            }
                            else {
                                return postCompleted(nil, "RECALL")
                            }
                        }
                        
                        
                    case STATUS_REQUEST.STATUS_SUCCESS.rawValue:
                        if let response:ResResponse = Mapper<ResResponse>().map(JSONObject: data) {
                            return postCompleted(response, "SUCCESS")
                        }
                        else {
                            return postCompleted(nil, "SUCCESS")
                        }
                    case STATUS_REQUEST.STATUS_NOT_FOUND.rawValue:
                        if let response:ResResponse = Mapper<ResResponse>().map(JSONObject: data) {
                            return postCompleted(response, "NOTFOUND")
                        }
                        else {
                            return postCompleted(nil, "NOTFOUND")
                        }
                    case STATUS_REQUEST.STATUS_DATA.rawValue:
                        if let response:ResResponse = Mapper<ResResponse>().map(JSONObject: data) {
                            return postCompleted(response, "DATA")
                        }
                        else {
                            return postCompleted(nil, "DATA")
                        }
                    case STATUS_REQUEST.STATUS_FORBIDEN.rawValue:
                        if let response:ResResponse = Mapper<ResResponse>().map(JSONObject: data) {
                            return postCompleted(response, "FORBIDEN")
                        }
                        else {
                            return postCompleted(nil, "FORBIDEN")
                        }
                    default:
                        if let response:ResResponse = Mapper<ResResponse>().map(JSONObject: data) {
                            return postCompleted(response, "")
                            
                        }else{
                            return postCompleted(nil, "")
                        }
                    }
                    
                })
            case REQUEST_METHOD.GET.rawValue:
                self.callServiceWithGETMethod(params: parseParams!, url: url,  postCompleted: { (data, statusCode) -> () in
                    
                    switch statusCode {
                    case STATUS_REQUEST.STATUS_UNAUTHORIZED.rawValue:
                        self.refreshToken() { (message, newAccessToken) in
                            if message == "LOGOUT" {
                                return postCompleted(nil, "UNAUTHORIZED")
                            }
                            else {
                                return postCompleted(nil, "RECALL")
                            }
                        }
                        
                    case STATUS_REQUEST.STATUS_SUCCESS.rawValue:
                        if let response:ResResponse = Mapper<ResResponse>().map(JSONObject: data) {
                            return postCompleted(response, "SUCCESS")
                        }
                        else {
                            return postCompleted(nil, "SUCCESS")
                        }
                    case STATUS_REQUEST.STATUS_NOT_FOUND.rawValue:
                        if let response:ResResponse = Mapper<ResResponse>().map(JSONObject: data) {
                            return postCompleted(response, "NOTFOUND")
                        }
                        else {
                            return postCompleted(nil, "NOTFOUND")
                        }
                    case STATUS_REQUEST.STATUS_DATA.rawValue:
                        if let response:ResResponse = Mapper<ResResponse>().map(JSONObject: data) {
                            return postCompleted(response, "DATA")
                        }
                        else {
                            return postCompleted(nil, "DATA")
                        }
                    case STATUS_REQUEST.STATUS_FORBIDEN.rawValue:
                        if let response:ResResponse = Mapper<ResResponse>().map(JSONObject: data) {
                            return postCompleted(response, "FORBIDEN")
                        }
                        else {
                            return postCompleted(nil, "FORBIDEN")
                        }
                    default:
                        if let response:ResResponse = Mapper<ResResponse>().map(JSONObject: data) {
                            return postCompleted(response, "")
                            
                        }else{
                            return postCompleted(nil, "")
                        }
                    }
                })
            case REQUEST_METHOD.DELETE.rawValue:
                self.callServiceWithDELETEMethod(params: parseParams!, url: url, postCompleted: { (data, statusCode) -> () in
                    
                    switch statusCode {
                    case STATUS_REQUEST.STATUS_UNAUTHORIZED.rawValue:
                        self.refreshToken() { (message, newAccessToken) in
                            if message == "LOGOUT" {
                                return postCompleted(nil, "UNAUTHORIZED")
                            }
                            else {
                                return postCompleted(nil, "RECALL")
                            }
                        }
                    case STATUS_REQUEST.STATUS_SUCCESS.rawValue:
                        if let response:ResResponse = Mapper<ResResponse>().map(JSONObject: data) {
                            return postCompleted(response, "SUCCESS")
                        }
                        else {
                            return postCompleted(nil, "SUCCESS")
                        }
                    case STATUS_REQUEST.STATUS_NOT_FOUND.rawValue:
                        if let response:ResResponse = Mapper<ResResponse>().map(JSONObject: data) {
                            return postCompleted(response, "NOTFOUND")
                        }
                        else {
                            return postCompleted(nil, "NOTFOUND")
                        }
                    case STATUS_REQUEST.STATUS_DATA.rawValue:
                        if let response:ResResponse = Mapper<ResResponse>().map(JSONObject: data) {
                            return postCompleted(response, "DATA")
                        }
                        else {
                            return postCompleted(nil, "DATA")
                        }
                    case STATUS_REQUEST.STATUS_FORBIDEN.rawValue:
                        if let response:ResResponse = Mapper<ResResponse>().map(JSONObject: data) {
                            return postCompleted(response, "FORBIDEN")
                        }
                        else {
                            return postCompleted(nil, "FORBIDEN")
                        }
                    default:
                        if let response:ResResponse = Mapper<ResResponse>().map(JSONObject: data) {
                            return postCompleted(response, "")
                            
                        }else{
                            return postCompleted(nil, "")
                        }
                    }
                    
                                        
                })
            case REQUEST_METHOD.PUT.rawValue:
                self.callServiceWithPUTMethod(params: parseParams!, url: url, postCompleted: { (data, statusCode) -> () in
                    
                    switch statusCode {
                    case STATUS_REQUEST.STATUS_UNAUTHORIZED.rawValue:
                        self.refreshToken() { (message, newAccessToken) in
                            if message == "LOGOUT" {
                                return postCompleted(nil, "UNAUTHORIZED")
                            }
                            else {
                                return postCompleted(nil, "RECALL")
                            }
                        }
                    case STATUS_REQUEST.STATUS_SUCCESS.rawValue:
                        if let response:ResResponse = Mapper<ResResponse>().map(JSONObject: data) {
                            return postCompleted(response, "SUCCESS")
                        }
                        else {
                            return postCompleted(nil, "SUCCESS")
                        }
                    case STATUS_REQUEST.STATUS_NOT_FOUND.rawValue:
                        if let response:ResResponse = Mapper<ResResponse>().map(JSONObject: data) {
                            return postCompleted(response, "NOTFOUND")
                        }
                        else {
                            return postCompleted(nil, "NOTFOUND")
                        }
                    case STATUS_REQUEST.STATUS_DATA.rawValue:
                        if let response:ResResponse = Mapper<ResResponse>().map(JSONObject: data) {
                            return postCompleted(response, "DATA")
                        }
                        else {
                            return postCompleted(nil, "DATA")
                        }
                    case STATUS_REQUEST.STATUS_FORBIDEN.rawValue:
                        if let response:ResResponse = Mapper<ResResponse>().map(JSONObject: data) {
                            return postCompleted(response, "FORBIDEN")
                        }
                        else {
                            return postCompleted(nil, "FORBIDEN")
                        }
                    default:
                        if let response:ResResponse = Mapper<ResResponse>().map(JSONObject: data) {
                            return postCompleted(response, "")
                            
                        }else{
                            return postCompleted(nil, "")
                        }
                    }
                    
                })
            default:
                return
            }

            
        }else{
            return postCompleted(nil, "INTERNET")
        }
        
    }
    
    func checkOnlineCallServiceRefreshTokenWithMethod(params : NSDictionary?,files: NSDictionary? = nil, url : String, method : Int, postCompleted : @escaping (_ data:AnyObject?,_ error :String) -> ()){
        var parseParams : Dictionary<String, AnyObject>? = params as? Dictionary<String, AnyObject>
        if(parseParams == nil){
            parseParams = Dictionary<String, AnyObject>()
        }
        parseParams?.updateValue("familyx_ios" as AnyObject, forKey: "os_name")

        
        if self.checkInternet() {
            
            self.callServiceWithPOSTMethod(params: parseParams!, url: url, postCompleted: { (data, statusCode) -> () in
                
                
                if statusCode == STATUS_REQUEST.STATUS_SUCCESS.rawValue {
                    if let response:ResResponse = Mapper<ResResponse>().map(JSONObject: data) {
                        return postCompleted(response, "RECALL")
                    }
                }
                else if statusCode == STATUS_REQUEST.STATUS_BAD_REQUEST.rawValue {
                    return postCompleted(nil, "LOGOUT")
                }
                
            })
            
        }else{
            return postCompleted(nil, "INTERNET")
        }
        
    }
    
    
    //=========================== API  Link  ======================
    func login(username:String, password:String, _ callBack: @escaping (_ data : AnyObject? , _ message : String?)->Void) ->Void{
        ManageCacheObject.setToken("")
        ManageCacheObject.saveCurrentAccount(Account())
        
        let url: String  = OAUTH_SERVER_URL + String(format: API_LOGIN, ManageCacheObject.getVersion())

        debugPrint(url)
        
        
        let params = [
            "usernameOrEmail":username,
            "password":password,
            "getRefreshToken":true
        ] as [String : Any]


        checkOnlineCallServiceWithMethod(params: params as NSDictionary , url:url, method : REQUEST_METHOD.POST.rawValue) { (data, error) -> () in
            return callBack(data, error)
        }
        
    }

    func signUp(username:String, email:String, phone:String, password:String, firstName:String, midName:String, lastName:String, _ callBack: @escaping (_ data : AnyObject? , _ message : String?)->Void) ->Void{
  
        
        let url: String  = OAUTH_SERVER_URL + String(format: API_SIGN_UP, ManageCacheObject.getVersion())

        debugPrint(url)
        
        let params = [
            "userName": username,
            "email": email,
            "password": password,
            "phone": phone,
            "firstName": firstName,
            "lastName": lastName,
            "midName": midName,
            "getRefreshToken": true
        ] as [String : Any]


        checkOnlineCallServiceWithMethod(params: params as NSDictionary , url:url, method : REQUEST_METHOD.POST.rawValue) { (data, error) -> () in
            return callBack(data, error)
        }
        
    }
 
    func getListFamilyTree( _ callBack: @escaping (_ data : AnyObject? , _ message : String?)->Void) ->Void{

        
        let url: String  = OAUTH_SERVER_URL + String(format: API_GET_LIST_FAMILY_TREE, ManageCacheObject.getVersion())

        debugPrint(url)
        
        let params = [
            :
        ] as [String : Any]


        checkOnlineCallServiceWithMethod(params: params as NSDictionary , url:url, method : REQUEST_METHOD.GET.rawValue) { (data, error) -> () in
            return callBack(data, error)
        }
        
    }
    
    func getListFamilyTreeWithKeyword(keyword:String, _ callBack: @escaping (_ data : AnyObject? , _ message : String?)->Void) ->Void{

        
        let url: String  = OAUTH_SERVER_URL + String(format: API_GET_LIST_FAMILY_TREE_WITH_KEYWORD, ManageCacheObject.getVersion())

        debugPrint(url)
        
        let params = [
            "q":keyword
        ] as [String : Any]


        checkOnlineCallServiceWithMethod(params: params as NSDictionary , url:url, method : REQUEST_METHOD.GET.rawValue) { (data, error) -> () in
            return callBack(data, error)
        }
        
    }
    
    func getListAllFamilyTree( _ callBack: @escaping (_ data : AnyObject? , _ message : String?)->Void) ->Void{

        
        let url: String  = OAUTH_SERVER_URL + String(format: API_GET_LIST_ALL_FAMILY_TREE, ManageCacheObject.getVersion())

        debugPrint(url)
        
        let params = [
            :
        ] as [String : Any]


        checkOnlineCallServiceWithMethod(params: params as NSDictionary , url:url, method : REQUEST_METHOD.GET.rawValue) { (data, error) -> () in
            return callBack(data, error)
        }
        
    }
    
    func getListAllFamilyTreeWithKeyword(keyword:String, _ callBack: @escaping (_ data : AnyObject? , _ message : String?)->Void) ->Void{

        
        let url: String  = OAUTH_SERVER_URL + String(format: API_GET_LIST_ALL_FAMILY_TREE_WITH_KEYWORD, ManageCacheObject.getVersion())

        debugPrint(url)
        
        let params = [
            "q":keyword
        ] as [String : Any]


        checkOnlineCallServiceWithMethod(params: params as NSDictionary , url:url, method : REQUEST_METHOD.GET.rawValue) { (data, error) -> () in
            return callBack(data, error)
        }
        
    }
    
    func getFamilyTreeInfo(treeId:Int, _ callBack: @escaping (_ data : AnyObject? , _ message : String?)->Void) ->Void{

        
        let url: String  = OAUTH_SERVER_URL + String(format: API_GET_FAMILY_TREE_INFO, ManageCacheObject.getVersion(), treeId)

        debugPrint(url)
        
        let params = [
            :
        ] as [String : Any]


        checkOnlineCallServiceWithMethod(params: params as NSDictionary , url:url, method : REQUEST_METHOD.GET.rawValue) { (data, error) -> () in
            return callBack(data, error)
        }
        
    }
    
    func addFamilyTree(name:String, description:String, _ callBack: @escaping (_ data : AnyObject? , _ message : String?)->Void) ->Void{

        
        let url: String  = OAUTH_SERVER_URL + String(format: API_ADD_FAMILY_TREE, ManageCacheObject.getVersion())

        debugPrint(url)
        
        let params = [
            "name": name,
            "description": description
        ] as [String : Any]


        checkOnlineCallServiceWithMethod(params: params as NSDictionary , url:url, method : REQUEST_METHOD.POST.rawValue) { (data, error) -> () in
            return callBack(data, error)
        }
        
    }
    
    func deleteFamilyTree(treeId:Int, _ callBack: @escaping (_ data : AnyObject? , _ message : String?)->Void) ->Void{

        
        let url: String  = OAUTH_SERVER_URL + String(format: API_DELETE_FAMILY_TREE, ManageCacheObject.getVersion(), treeId)

        debugPrint(url)
        
        let params = [
            :
        ] as [String : Any]


        checkOnlineCallServiceWithMethod(params: params as NSDictionary , url:url, method : REQUEST_METHOD.DELETE.rawValue) { (data, error) -> () in
            return callBack(data, error)
        }
        
    }
    
    func editFamilyTree(name:String, description:String, treeId:Int, _ callBack: @escaping (_ data : AnyObject? , _ message : String?)->Void) ->Void{

        
        let url: String  = OAUTH_SERVER_URL + String(format: API_EDIT_FAMILY_TREE, ManageCacheObject.getVersion(), treeId)

        debugPrint(url)
        
        let params = [
            "name": name,
            "description": description
        ] as [String : Any]


        checkOnlineCallServiceWithMethod(params: params as NSDictionary , url:url, method : REQUEST_METHOD.PUT.rawValue) { (data, error) -> () in
            return callBack(data, error)
        }
        
    }
    
    func addChild(child:People, _ callBack: @escaping (_ data : AnyObject? , _ message : String?)->Void) ->Void{

        
        let url: String  = OAUTH_SERVER_URL + String(format: API_ADD_CHILD, ManageCacheObject.getVersion())

        debugPrint(url)
        
        let params = [
            "fatherId": child.fatherId,
            "motherId": child.motherId,
            "childInfo": Mapper().toJSON(child)
        ] as [String : Any]


        checkOnlineCallServiceWithMethod(params: params as NSDictionary , url:url, method : REQUEST_METHOD.POST.rawValue) { (data, error) -> () in
            return callBack(data, error)
        }
        
    }
    
    func addSpouse(spouse:People, relativePeopleId:Int, _ callBack: @escaping (_ data : AnyObject? , _ message : String?)->Void) ->Void{

        
        let url: String  = OAUTH_SERVER_URL + String(format: API_ADD_SPOUSE, ManageCacheObject.getVersion(), relativePeopleId)

        debugPrint(url)
        
        let params = [
            "gender": spouse.gender,
            "firstName": spouse.firstName,
            "lastName": spouse.lastName,
            "dateOfBirth": spouse.birthday,
            "dateOfDeath": spouse.deathday,
            "userId": spouse.userId,
            "imageUrl": spouse.imageUrl,
            "note": spouse.note
        ] as [String : Any?]


        checkOnlineCallServiceWithMethod(params: params as NSDictionary , url:url, method : REQUEST_METHOD.POST.rawValue) { (data, error) -> () in
            return callBack(data, error)
        }
        
    }
    
    func addParent(parent:People, relativePeopleId:Int, _ callBack: @escaping (_ data : AnyObject? , _ message : String?)->Void) ->Void{

        
        let url: String  = OAUTH_SERVER_URL + String(format: API_ADD_PARENT, ManageCacheObject.getVersion(), relativePeopleId)

        debugPrint(url)
        
        let params = [
            "gender": parent.gender,
            "firstName": parent.firstName,
            "lastName": parent.lastName,
            "dateOfBirth": parent.birthday,
            "dateOfDeath": parent.deathday,
            "userId": parent.userId,
            "imageUrl": parent.imageUrl,
            "note": parent.note
        ] as [String : Any?]


        checkOnlineCallServiceWithMethod(params: params as NSDictionary , url:url, method : REQUEST_METHOD.POST.rawValue) { (data, error) -> () in
            return callBack(data, error)
        }
        
    }
    
    func updateNode(person:People, _ callBack: @escaping (_ data : AnyObject? , _ message : String?)->Void) ->Void{

        
        let url: String  = OAUTH_SERVER_URL + String(format: API_UPDATE_NODE, ManageCacheObject.getVersion(), person.id)

        debugPrint(url)
        
        let params = [
            "gender": person.gender,
            "firstName": person.firstName,
            "lastName": person.lastName,
            "dateOfBirth": person.birthday,
            "dateOfDeath": person.deathday,
            "userId": person.userId,
            "imageUrl": person.imageUrl,
            "note": person.note
        ] as [String : Any?]


        checkOnlineCallServiceWithMethod(params: params as NSDictionary , url:url, method : REQUEST_METHOD.PUT.rawValue) { (data, error) -> () in
            return callBack(data, error)
        }
        
    }
    
    func deleteNode(personId:Int, _ callBack: @escaping (_ data : AnyObject? , _ message : String?)->Void) ->Void{

        
        let url: String  = OAUTH_SERVER_URL + String(format: API_DELETE_NODE, ManageCacheObject.getVersion(), personId)

        debugPrint(url)
        
        let params = [
            :
        ] as [String : Any?]


        checkOnlineCallServiceWithMethod(params: params as NSDictionary , url:url, method : REQUEST_METHOD.DELETE.rawValue) { (data, error) -> () in
            return callBack(data, error)
        }
        
    }
    
    func getAllUsers( _ callBack: @escaping (_ data : AnyObject? , _ message : String?)->Void) ->Void{

        
        let url: String  = OAUTH_SERVER_URL + String(format: API_GET_ALL_USERS, ManageCacheObject.getVersion())

        debugPrint(url)
        
        let params = [
            :
        ] as [String : Any?]


        checkOnlineCallServiceWithMethod(params: params as NSDictionary , url:url, method : REQUEST_METHOD.POST.rawValue) { (data, error) -> () in
            return callBack(data, error)
        }
        
    }
    
    func getUserProfile(userId:String, _ callBack: @escaping (_ data : AnyObject? , _ message : String?)->Void) ->Void{

        
        let url: String  = OAUTH_SERVER_URL + String(format: API_GET_USER_PROFILE, ManageCacheObject.getVersion(), userId)

        debugPrint(url)
        
        let params = [
            :
        ] as [String : Any?]


        checkOnlineCallServiceWithMethod(params: params as NSDictionary , url:url, method : REQUEST_METHOD.GET.rawValue) { (data, error) -> () in
            return callBack(data, error)
        }
        
    }
    
    func editProfileUser(firstName:String, midName:String, lastName:String, avatarUrl:String, address:String, phone:String, gender:Int, birthday:String, _ callBack: @escaping (_ data : AnyObject? , _ message : String?)->Void) ->Void{

        
        let url: String  = OAUTH_SERVER_URL + String(format: API_EDIT_PROFILE_USER, ManageCacheObject.getVersion())

        debugPrint(url)
        
        let params = [
            "firstName": firstName,
            "midName": midName,
            "lastName": lastName,
            "avatarUrl": avatarUrl,
            "address": address,
            "phone": phone,
            "gender": gender,
            "dateOfBirth": birthday
        ] as [String : Any?]


        checkOnlineCallServiceWithMethod(params: params as NSDictionary , url:url, method : REQUEST_METHOD.PUT.rawValue) { (data, error) -> () in
            return callBack(data, error)
        }
        
    }
    
    func getAllEditors(treeId:Int, _ callBack: @escaping (_ data : AnyObject? , _ message : String?)->Void) ->Void{

        
        let url: String  = OAUTH_SERVER_URL + String(format: API_GET_ALL_EDITORS, ManageCacheObject.getVersion(), treeId)

        debugPrint(url)
        
        let params = [
            :
        ] as [String : Any?]


        checkOnlineCallServiceWithMethod(params: params as NSDictionary , url:url, method : REQUEST_METHOD.GET.rawValue) { (data, error) -> () in
            return callBack(data, error)
        }
        
    }
    
    func addEditorToTree(treeId:Int, editorsUsername:[String], _ callBack: @escaping (_ data : AnyObject? , _ message : String?)->Void) ->Void{

        
        let url: String  = OAUTH_SERVER_URL + String(format: API_ADD_EDITOR_TO_TREE, ManageCacheObject.getVersion(), treeId)

        debugPrint(url)
        
        let params = [
            "usernames":editorsUsername
        ] as [String : Any?]


        checkOnlineCallServiceWithMethod(params: params as NSDictionary , url:url, method : REQUEST_METHOD.POST.rawValue) { (data, error) -> () in
            return callBack(data, error)
        }
        
    }
    
    func removeEditorFromTree(treeId:Int, editorsUsername:[String], _ callBack: @escaping (_ data : AnyObject? , _ message : String?)->Void) ->Void{

        
        let url: String  = OAUTH_SERVER_URL + String(format: API_REMOVE_EDITOR_FROM_TREE, ManageCacheObject.getVersion(), treeId)

        debugPrint(url)
        
        let params = [
            "usernames":editorsUsername
        ] as [String : Any?]


        checkOnlineCallServiceWithMethod(params: params as NSDictionary , url:url, method : REQUEST_METHOD.POST.rawValue) { (data, error) -> () in
            return callBack(data, error)
        }
        
    }
    
    func getFamilyTreeMemories(treeId:Int, _ callBack: @escaping (_ data : AnyObject? , _ message : String?)->Void) ->Void{

        
        let url: String  = OAUTH_SERVER_URL + String(format: API_GET_FAMILY_TREE_MEMORIES, ManageCacheObject.getVersion(), treeId)

        debugPrint(url)
        
        let params = [
            :
        ] as [String : Any?]


        checkOnlineCallServiceWithMethod(params: params as NSDictionary , url:url, method : REQUEST_METHOD.GET.rawValue) { (data, error) -> () in
            return callBack(data, error)
        }
        
    }
    
    func addFamilyTreeMemory(treeId:Int, description:String, memoryDate:String, imageUrls:[String], _ callBack: @escaping (_ data : AnyObject? , _ message : String?)->Void) ->Void{

        
        let url: String  = OAUTH_SERVER_URL + String(format: API_ADD_FAMILY_TREE_MEMORY, ManageCacheObject.getVersion())

        debugPrint(url)
        
        let params = [
            "familyTreeId": treeId,
            "description": description,
            "memoryDate": memoryDate,
            "imageUrls": imageUrls
        ] as [String : Any?]


        checkOnlineCallServiceWithMethod(params: params as NSDictionary , url:url, method : REQUEST_METHOD.POST.rawValue) { (data, error) -> () in
            return callBack(data, error)
        }
        
    }
    
    func deleteFamilyTreeMemory(memoryId:Int, _ callBack: @escaping (_ data : AnyObject? , _ message : String?)->Void) ->Void{

        
        let url: String  = OAUTH_SERVER_URL + String(format: API_DELETE_FAMILY_TREE_MEMORY, ManageCacheObject.getVersion(), memoryId)

        debugPrint(url)
        
        let params = [
            :
        ] as [String : Any?]


        checkOnlineCallServiceWithMethod(params: params as NSDictionary , url:url, method : REQUEST_METHOD.DELETE.rawValue) { (data, error) -> () in
            return callBack(data, error)
        }
        
    }
    
    func getNotifications(_ callBack: @escaping (_ data : AnyObject? , _ message : String?)->Void) ->Void{

        
        let url: String  = OAUTH_SERVER_URL + String(format: API_GET_NOTIFICATION, ManageCacheObject.getVersion())

        debugPrint(url)
        
        let params = [
            :
        ] as [String : Any?]


        checkOnlineCallServiceWithMethod(params: params as NSDictionary , url:url, method : REQUEST_METHOD.GET.rawValue) { (data, error) -> () in
            return callBack(data, error)
        }
        
    }
    
    func postRefreshToken( _ callBack: @escaping (_ data : AnyObject? , _ message : String?)->Void) ->Void{

        
        let url: String  = OAUTH_SERVER_URL + String(format: API_GET_REFRESH_TOKEN, ManageCacheObject.getVersion())

        debugPrint(url)
        
        let params = [
            "refreshToken" : ManageCacheObject.getCurrentAccount().refreshToken
        ] as [String : Any]


        checkOnlineCallServiceRefreshTokenWithMethod(params: params as NSDictionary , url:url, method : REQUEST_METHOD.POST.rawValue) { (data, error) -> () in
            return callBack(data, error)
        }
        
    }
    
    func refreshToken(completion: ((String, String) -> Void)?) {
        ResAPI.sharedInstance.postRefreshToken( { (data, message) -> Void in
          
            if message == "RECALL" {
                if(data != nil){
                    
                    let response:ResResponse = data as! ResResponse

                    if let accountRes = Mapper<AccountRefreshRes>().map(JSONObject: response.data) {
                        
                        let user = ManageCacheObject.getCurrentAccount()
                        user.accessToken = accountRes.accessToken
                        user.refreshToken = accountRes.newRefreshToken ?? ""
                        ManageCacheObject.saveCurrentAccount(user)
                        
                        completion!("RECALL",accountRes.accessToken)
                    }
                    
                }
            }
            else if message == "LOGOUT" {
                completion!("LOGOUT", "")
            }
            else {
                
            }

        })
    }
}
