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

class ResAPI: UIResponder {
    let POST = true
    let GET = false
    
    var alamofireManager : SessionManager!
    
    class var sharedInstance: ResAPI {

        struct Singleton {
           
            static let instance = ResAPI()
        }
        
        return Singleton.instance
    }
    
    override init() {
        super.init()
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
    
    //MARK: Check error service
    func checkErrorService(data:AnyObject?,error : String?)->(data:AnyObject?, Message : String){
        if(data == nil && error == nil){
            return (nil,InternetError)
        }else if (data == nil && error != nil){
            return (data,ServerErrorText)
        }else{
            return (data, "")
        }
    }
    
    
    
    //MARK: POST METHOD CALL API
    func callServiceWithPOSTMethod(params : Dictionary<String, AnyObject>, url : String, postCompleted : @escaping (_ data:AnyObject?, _ statusCode: Int?) -> ()){
        
        var auth_header = ["Authorization": "Bearer \(ManageCacheObject.getCurrentAccount().accessToken)"]
        
        auth_header = ManageCacheObject.isLogin() ? ["Authorization": "Bearer \(ManageCacheObject.getCurrentAccount().accessToken)"] : ["Authorization": "Basic \(ManageCacheObject.getCurrentAccount().accessToken)"]
        
        debugPrint(url,params,auth_header)
        Alamofire.request(url, method: .post, parameters: params,  encoding: JSONEncoding.default, headers: auth_header).responseJSON { response in
            switch response.result {
            case .success:
                debugPrint(response.result)
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
        Alamofire.request(url, method:.get, parameters: params, encoding: URLEncoding.default, headers: auth_header).responseJSON { response in
            
            debugPrint("REQUEST  \(String(describing: response.request))")
            
            debugPrint("RESPONSE \(String(describing: response.result.value))")
            debugPrint(response.result)
            
            switch response.result {
            case .success:
                
                return postCompleted(response.result.value as AnyObject?, response.response?.statusCode)
                
            case .failure( _):
                return postCompleted(nil, response.response?.statusCode)
            }
        }
        
    }
    //MARK:checkOnlineCallServiceWithMethod
    func checkOnlineCallServiceWithMethod(params : NSDictionary?,files: NSDictionary? = nil, url : String, postMethod : Bool, postCompleted : @escaping (_ data:AnyObject?,_ error :String) -> ()){
        var parseParams : Dictionary<String, AnyObject>? = params as? Dictionary<String, AnyObject>
        if(parseParams == nil){
            parseParams = Dictionary<String, AnyObject>()
        }
        parseParams?.updateValue("familyx_ios" as AnyObject, forKey: "os_name")

        
        if self.checkInternet() {
            if(postMethod){
                self.callServiceWithPOSTMethod(params: parseParams!, url: url, postCompleted: { (data, statusCode) -> () in
                    if(statusCode == STATUS_REQUEST.STATUS_SUCCESS.rawValue){// code successs
                        if(data != nil){
                            let response:ResResponse = Mapper<ResResponse>().map(JSONObject: data)!
                            if(response.status == 401){
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ERROR_UNAUTHORIZED"), object: nil)
                            }else if(response.status == 411){
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ERROR_UNAUTHORIZED"), object: nil)
                            }else{
                                let completeData = self.checkErrorService(data: response, error: "")
                                return postCompleted(completeData.0, completeData.1)
                            }
                            
                        }else{
                            let completeData = self.checkErrorService(data: nil, error: "")
                            return postCompleted(completeData.0, completeData.1)
                        }
                        
                    }else if(statusCode == 411){
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ERROR_UNAUTHORIZED"), object: nil)
                    }else{
                        let completeData = self.checkErrorService(data: nil, error: "")
                        return postCompleted(completeData.0, completeData.1)
                    }
                })
            }else{
                self.callServiceWithGETMethod(params: parseParams!, url: url,  postCompleted: { (data, statusCode) -> () in
                    
                    if(statusCode == STATUS_REQUEST.STATUS_SUCCESS.rawValue){// code successs
                        if(data != nil){
                            let response:ResResponse = Mapper<ResResponse>().map(JSONObject: data)!
                            if(response.status == 401){
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ERROR_UNAUTHORIZED"), object: nil)
                            }else if(response.status == 411){
                                 NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ERROR_UNAUTHORIZED"), object: nil)
                            }else{
                                let completeData = self.checkErrorService(data: response, error: "")
                                return postCompleted(completeData.0, completeData.1)
                            }
                        }else{
                            let completeData = self.checkErrorService(data: nil, error: "")
                            return postCompleted(completeData.0, completeData.1)
                        }
                    }else if(statusCode == 411){
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ERROR_UNAUTHORIZED"), object: nil)
                    }
                    else{
                        let completeData = self.checkErrorService(data: nil, error: "")
                        return postCompleted(completeData.0, completeData.1)
                    }
                })
            }
            
        }else{
            let completeData = self.checkErrorService(data: nil, error: nil)
            return postCompleted(completeData.0, completeData.1)
        }
        
    }
    
    
    //=========================== API  Link  ======================
    func login(username:String, password:String, _ callBack: @escaping (_ data : AnyObject? , _ Message : String?)->Void) ->Void{
        ManageCacheObject.setToken("")
        ManageCacheObject.saveCurrentAccount(Account())
        
        let url: String  = OAUTH_SERVER_URL + String(format: API_LOGIN, ManageCacheObject.getVersion())

        debugPrint(url)
        
        
        let params = [
            "usernameOrEmail":username,
            "password":password,
            "getRefreshToken":true
        ] as [String : Any]


        checkOnlineCallServiceWithMethod(params: params as NSDictionary , url:url, postMethod : POST) { (data, error) -> () in
            return callBack(data, error)
        }
        
    }

    func signUp(username:String, email:String, phone:String, password:String, firstName:String, midName:String, lastName:String, _ callBack: @escaping (_ data : AnyObject? , _ Message : String?)->Void) ->Void{
        ManageCacheObject.setToken("")
        ManageCacheObject.saveCurrentAccount(Account())
        
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


        checkOnlineCallServiceWithMethod(params: params as NSDictionary , url:url, postMethod : POST) { (data, error) -> () in
            return callBack(data, error)
        }
        
    }
 
    func getListFamilyTree( _ callBack: @escaping (_ data : AnyObject? , _ Message : String?)->Void) ->Void{
        ManageCacheObject.setToken("")
        ManageCacheObject.saveCurrentAccount(Account())
        
        let url: String  = OAUTH_SERVER_URL + String(format: API_GET_LIST_FAMILY_TREE, ManageCacheObject.getVersion())

        debugPrint(url)
        
        let params = [
            :
        ] as [String : Any]


        checkOnlineCallServiceWithMethod(params: params as NSDictionary , url:url, postMethod : GET) { (data, error) -> () in
            return callBack(data, error)
        }
        
    }
}
