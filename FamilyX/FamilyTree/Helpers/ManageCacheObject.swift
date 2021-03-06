//
//  ManageCacheObject.swift
//  Scanner App
//
//  Created by Gia Huy on 28/11/2020.
//

import UIKit
import ObjectMapper

class ManageCacheObject: NSObject {
    
    // MARK: - setFirstRun
    static func setFirstRun(_ fisrt_run:Bool){
        UserDefaults.standard.set(fisrt_run, forKey:KEY_FIRST_RUN)
    }
    
    static func getFirstRun()->Bool{
        if let first_run : Bool = UserDefaults.standard.object(forKey: KEY_FIRST_RUN) as? Bool{
            return first_run
        }else{
            return false
        }
    }
    
    // MARK: - setTabIndex
    static func setTabIndex(_ tabIndex:Int){
        UserDefaults.standard.set(tabIndex, forKey:KEY_TAB_INDEX)
    }
    
    static func setToken(_ token:String){
        UserDefaults.standard.set(token, forKey:KEY_TOKEN)
    }
    
    static func getCurrentTabIndex()->Int{
        if let tabIndex : Int = UserDefaults.standard.object(forKey: KEY_TAB_INDEX) as? Int{
            return tabIndex
        }else{
            return 0
        }
    }
    
    static func clearData() {
        UserDefaults.standard.set(nil, forKey:KEY_ACCOUNT)
    }
        
    static func saveCurrentAccount(_ account : Account){
        UserDefaults.standard.set(Mapper<Account>().toJSON(account), forKey:KEY_ACCOUNT)
    }
    
    static func getCurrentAccount() -> Account{
        if let userJson = UserDefaults.standard.object(forKey: KEY_ACCOUNT){
            let user : Account = Mapper<Account>().map(JSONObject: userJson)!
            return user
        }else
        {
            let account = Account()
            return account
        }
    }
    
    static func setVersion(_ version : String){
        UserDefaults.standard.set(version, forKey:KEY_VERSION)
    }
    
    static func getVersion() -> String{
        if let version = UserDefaults.standard.object(forKey: KEY_VERSION) {
            return version as! String
        }else
        {
            return "1"
        }
    }
    
    static func isLogin()->Bool{
        let account = ManageCacheObject.getCurrentAccount()
        if(account.id == ""){
            return false
        }
        return true
    }
    
    static func clearUser(){
        UserDefaults.standard.set(nil, forKey: KEY_ACCOUNT)
    }

}
