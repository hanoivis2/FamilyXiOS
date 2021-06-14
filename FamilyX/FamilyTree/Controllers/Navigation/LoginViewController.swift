//
//  LoginViewController.swift
//  Scanner App
//
//  Created by Gia Huy on 29/11/2020.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase
import JGProgressHUD
import ObjectMapper
import Loaf

class LoginViewController : UIViewController, NavigationControllerCustomDelegate {
    
    @IBOutlet weak var txt_email: UITextField!
    @IBOutlet weak var txt_password: UITextField!
    
    var navigationControllerCustom : NavigationControllerCustom?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //custom navigation bar
        navigationControllerCustom = self.navigationController as? NavigationControllerCustom
        navigationControllerCustom!.setUpNavigationBar(self, hideBackButton: true, title: "")
        navigationControllerCustom!.navigationBar.isHidden = true
        self.navigationItem.hidesBackButton = true
        self.navigationController?.title = "Login"
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height * (1/3)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    @IBAction func btn_sigUp ( _ sender:Any) {
        let signUpViewController:SignUpViewController?
        signUpViewController = UIStoryboard.signUpViewController()
        navigationController?.pushViewController(signUpViewController!, animated: true)
    }
    
    @IBAction func btn_signIn(_ sender: Any) {
       
        let email = txt_email.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = txt_password.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        login(username: email, password: password)
        
    }
    
    func login(username:String, password:String){
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Please wait..."
        hud.show(in: self.view)
        
        ResAPI.sharedInstance.login(username: username,password: password, { (data, message) -> Void in
            
            switch message {
            case "SUCCESS":
                if(data != nil){
                    
                    let response:ResResponse = data as! ResResponse

                    if let accountRes = Mapper<AccountRes>().map(JSONObject: response.data) {
                        let account = accountRes.user
                        account.refreshToken = accountRes.refreshToken
                        account.accessToken = accountRes.accessToken

                        ManageCacheObject.saveCurrentAccount(account)
                        
                        hud.dismiss()
                        self.goToMainViewController()
                    }
                    else {
                        Loaf.init(response.message ?? "", state: .info, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
                    }
                    
                }
            case "UNAUTHORIZED":
                ManageCacheObject.saveCurrentAccount(Account())
                for controller in self.navigationController!.viewControllers as Array {
                    if controller.isKind(of: LoginViewController.self) {
                        self.navigationController!.popToViewController(controller, animated: true)
                        return
                    }
                }

                let loginViewController: LoginViewController?
                loginViewController = UIStoryboard.loginViewController()
                self.navigationController!.pushViewController(loginViewController!, animated: false)
                
                Loaf.init(UnauthorizedError, state: .info, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(4), completionHandler: nil)
            case "RECALL":
                self.login(username: username, password: password)
            case "NOTFOUND":
                Loaf.init("Request not found", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
            case "DATA":
                Loaf.init("Data error", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
            case "FORBIDEN":
                Loaf.init("You don't have permission to do this function", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
            default:
                if data != nil {
                    let response = data as! ResResponse
                    if !response.message!.isEmpty {
                        Loaf.init(response.message!, state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
                    }
                }
                
            }
            
            hud.dismiss()
        })
    }
    
    func goToMainViewController() {
        self.txt_password.text = ""
        self.view.endEditing(true)
        let homeViewController:HomeViewController?
        homeViewController = UIStoryboard.homeViewController()
        self.navigationController!.pushViewController(homeViewController!, animated: false)
    }
}
