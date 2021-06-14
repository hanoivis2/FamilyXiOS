//
//  SignUpViewController.swift
//  Scanner App
//
//  Created by Gia Huy on 01/12/2020.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore
import JGProgressHUD
import Loaf
import ObjectMapper

class SignUpViewController : UIViewController, NavigationControllerCustomDelegate {
    
    @IBOutlet weak var txt_firstName: UITextField!
    @IBOutlet weak var txt_midName: UITextField!
    @IBOutlet weak var txt_lastName: UITextField!
    @IBOutlet weak var txt_userName: UITextField!
    @IBOutlet weak var txt_email: UITextField!
    @IBOutlet weak var txt_phone: UITextField!
    @IBOutlet weak var txt_password: UITextField!
    @IBOutlet weak var scrollView:UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        scrollView.backgroundColor = UIColor.clear
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        txt_firstName.delegate = self
        txt_midName.delegate = self
        txt_lastName.delegate = self
        txt_userName.delegate = self
        txt_email.delegate = self
        txt_phone.delegate = self
        txt_password.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //custom navigation bar
        let navigationControllerCustom : NavigationControllerCustom = self.navigationController as! NavigationControllerCustom
        navigationControllerCustom.setUpNavigationBar(self, hideBackButton: false, title: "SIGN UP")
        navigationControllerCustom.touchTarget = self
        navigationControllerCustom.navigationBar.barTintColor = ColorUtils.toolbar()
        navigationControllerCustom.navigationBar.isHidden = false
    }
    
    func backTap() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {

    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @IBAction func btn_signUp(_ sender: Any) {
        if txt_firstName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            txt_midName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            txt_lastName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            txt_userName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            txt_email.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            txt_phone.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            txt_password.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            Loaf.init("Please fill out all fields!", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
            return
        }
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "On the way..."
        hud.show(in: self.view)
        
        let firstName = txt_firstName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let midName = txt_midName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName = txt_lastName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let username = txt_userName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = txt_email.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let phone = txt_phone.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = txt_password.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        
        
        
        signUp(firstName: firstName, midName: midName, lastName: lastName, username: username, email: email, phone: phone, password: password)
    }
    
    func signUp(firstName:String, midName:String, lastName:String, username:String, email:String, phone:String, password:String){
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Please wait..."
        hud.show(in: self.view)
        
        ResAPI.sharedInstance.signUp(username: username, email: email, phone: phone, password: password, firstName: firstName, midName: midName, lastName: lastName, { (data, message) -> Void in
            
            switch message {
            case "SUCCESS":
                if(data != nil){
                    
                    let response:ResResponse = data as! ResResponse
                    
                    if  let accountRes = Mapper<AccountRes>().map(JSONObject: response.data) {
                        
                        let account = accountRes.user
                        account.refreshToken = accountRes.refreshToken
                        account.accessToken = accountRes.accessToken

                        ManageCacheObject.saveCurrentAccount(account)
                        
                        let homeViewController:HomeViewController?
                        homeViewController = UIStoryboard.homeViewController()
                        self.navigationController!.pushViewController(homeViewController!, animated: false)
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
                self.signUp(firstName: firstName, midName: midName, lastName: lastName, username: username, email: email, phone: phone, password: password)
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
}

extension SignUpViewController : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        switch textField.tag {
        case 4:
            UIView.animate(withDuration: 0.2,
                       delay: 0.1,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        self.view.frame.origin.y = -100
            }, completion: { (finished) -> Void in
                
            })
        case 5:
            UIView.animate(withDuration: 0.2,
                       delay: 0.1,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        self.view.frame.origin.y = -200
            }, completion: { (finished) -> Void in
                
            })
        case 6:
            UIView.animate(withDuration: 0.2,
                       delay: 0.1,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        self.view.frame.origin.y = -300
            }, completion: { (finished) -> Void in
                
            })
        default:
            break
        }
        
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
}

