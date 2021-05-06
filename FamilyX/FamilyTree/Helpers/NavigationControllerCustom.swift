//
//  NavigationControllerCustom.swift
//  kelvin
//
//  Created by kelvin on 11/3/18.
//  Copyright © 2018 vn.printstudio. All rights reserved.
//

import UIKit
import Foundation


@objc protocol NavigationControllerCustomDelegate {
    @objc optional func menuTap()
    @objc optional func backTap()
    @objc optional func addTap()
}

class NavigationControllerCustom: UINavigationController {

    var backButton : UIButton!
    var menuButton : UIButton!
    var addButton : UIButton!
    var touchTarget : NavigationControllerCustomDelegate?
    var textTitle : UILabel!
    var numberLabel : UILabel!
    var heightNavigationBar : CGFloat = 0
    var heightButton : CGFloat = 20
    var fontSizeButton : CGFloat = 14
    var widthButton : CGFloat = 30
    var setTopAction : Bool = false
    var labelNotification:UILabel!
    var isMenuHidden = true
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let centerY: CGFloat  = self.navigationBar.frame.size.height / 2 - textTitle.frame.size.height / 2
        textTitle.frame.origin.y = centerY
        backButton.frame.origin.y = centerY
        menuButton.frame.origin.y = centerY
        addButton.frame.origin.y = centerY
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let heightNavi = self.navigationBar.frame.size.height
        let widthNavi = self.navigationBar.frame.size.width
        let statusBarSize = UIApplication.shared.statusBarFrame.size
        heightNavigationBar = heightNavi + statusBarSize.height
        
        self.navigationItem.hidesBackButton = true
        self.navigationBar.barTintColor = .clear
        self.navigationBar.backgroundColor = .clear
        let viewBackground = UIView(frame: CGRect(x: 0, y: -45, width: widthNavi, height: heightNavi+45))
         viewBackground.backgroundColor = ColorUtils.main_color()
        self.navigationBar.addSubview(viewBackground)

        
        textTitle = UILabel(frame: CGRect(x: widthNavi/2 - (widthNavi - 80)/2, y: 0, width: widthNavi - 80, height: heightNavi))
        textTitle.backgroundColor = UIColor.clear
        textTitle.textColor = UIColor.white
        textTitle.textAlignment = NSTextAlignment.center
        textTitle.font = UIFont(name: "Helvetica-Bold", size: 14.0)
        textTitle.isUserInteractionEnabled = true
        self.navigationBar.addSubview(textTitle)

        
        backButton = UIButton(frame: CGRect(x: 10.0, y: 0, width: 40, height: 40))
        backButton?.showsTouchWhenHighlighted = true
        
        if let image = UIImage(named: "icon_back") {
            backButton.setImage(image, for: .normal)
            backButton.tintColor = .white
        }
        backButton.setTitleColor(UIColor.white, for: UIControl.State())
        backButton.setTitleColor(UIColor.COLOR_ICON_TOUCH(), for: UIControl.State.highlighted)
        backButton.addTarget(self, action:#selector(NavigationControllerCustom.backTap), for: UIControl.Event.touchUpInside)
        backButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        self.navigationBar.addSubview(backButton)
        
        
        menuButton = UIButton(frame: CGRect(x: 10.0, y: 0, width: 40, height: 40))
        menuButton?.showsTouchWhenHighlighted = true
        
        if let image = UIImage(named: "icon_menu") {
            menuButton.setImage(image, for: .normal)
            menuButton.tintColor = .white
        }
        menuButton.setTitleColor(UIColor.white, for: UIControl.State())
        menuButton.setTitleColor(UIColor.COLOR_ICON_TOUCH(), for: UIControl.State.highlighted)
        menuButton.addTarget(self, action:#selector(NavigationControllerCustom.menuTap), for: UIControl.Event.touchUpInside)
        menuButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        self.navigationBar.addSubview(menuButton)
        
        addButton = UIButton(frame: CGRect(x: widthNavi - 50, y: 0, width: 40, height: 40))
        addButton?.showsTouchWhenHighlighted = true
        
        if let image = UIImage(named: "icon_add") {
            addButton.setImage(image, for: .normal)
            addButton.tintColor = .white
        }
        addButton.setTitleColor(UIColor.white, for: UIControl.State())
        addButton.setTitleColor(UIColor.COLOR_ICON_TOUCH(), for: UIControl.State.highlighted)
        addButton.addTarget(self, action:#selector(NavigationControllerCustom.addTap), for: UIControl.Event.touchUpInside)
        addButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        self.navigationBar.addSubview(addButton)

        

 
        numberLabel = UILabel(frame: CGRect(x: widthNavi - widthButton, y: 20, width: widthButton , height: heightButton))
        numberLabel.backgroundColor = UIColor.clear
        numberLabel.textAlignment = NSTextAlignment.center
        numberLabel.font = UIFont.fontDefaultRegularSize(11.0)
        numberLabel.text = "99+"
        numberLabel.isHidden = true
        numberLabel.textColor = UIColor.yellow
        numberLabel.isUserInteractionEnabled = false
        backButton.isHidden = true
        menuButton.isHidden = true
        addButton.isHidden = true
        textTitle.isHidden = true
        navigationController?.navigationItem.hidesBackButton = true
    }
    

    
    func setUpNavigationBar(_ target:NavigationControllerCustomDelegate, hideBackButton:Bool, title:String){
        self.backButton.isHidden = hideBackButton
        self.menuButton.isHidden = true
        self.addButton.isHidden = true
        
        if(title != ""){
            self.textTitle.isHidden = false
            self.textTitle.text = title
        }else{
            self.textTitle.isHidden = true
        }
       
    }
    
    func setUpNavigationBar(_ target:NavigationControllerCustomDelegate, hideMenuButton:Bool, title:String){
  
        self.backButton.isHidden = true
        self.menuButton.isHidden = hideMenuButton
        self.addButton.isHidden = true
        
        if(title != ""){
            self.textTitle.isHidden = false
            self.textTitle.text = title
        }else{
            self.textTitle.isHidden = true
        }
       
    }
    
    func setUpNavigationBar(_ target:NavigationControllerCustomDelegate, hideAddButton:Bool, title:String){
        self.backButton.isHidden = true
        self.menuButton.isHidden = true
        self.addButton.isHidden = hideAddButton
        
        if(title != ""){
            self.textTitle.isHidden = false
            self.textTitle.text = title
        }else{
            self.textTitle.isHidden = true
        }
        
    }
    
    func setUpNavigationBar(_ target:NavigationControllerCustomDelegate, hideBackButton:Bool, hideAddButton:Bool, title:String){
        self.backButton.isHidden = hideBackButton
        self.menuButton.isHidden = true
        self.addButton.isHidden = hideAddButton
        
        if(title != ""){
            self.textTitle.isHidden = false
            self.textTitle.text = title
        }else{
            self.textTitle.isHidden = true
        }
        
    }
    
    
    func setTitleHeader(_ title : String){
        if(title != ""){
            self.textTitle.isHidden = false
            self.textTitle.text = title
        }else{
            self.textTitle.isHidden = true
        }
    }
    
    func showNotification(){
        
        if(self.isMenuHidden){
            self.labelNotification!.isHidden = true
        }
        else{
            if(UserDefaults.standard.bool(forKey: "ShowNotification")){
                self.labelNotification!.isHidden = false
                self.labelNotification.text = String(format : "%d",UIApplication.shared.applicationIconBadgeNumber)
            }
        }
    }
    func navigationController(_ navigationController: UINavigationController, willShow: UIViewController, animated: Bool){
    
    }
  
   @objc func backTap(){
        debugPrint("back Tap")
        touchTarget?.backTap!()
    }
    
    @objc func addTap(){
        debugPrint("add Tap")
        touchTarget?.addTap!()
    }
    
    @objc func menuTap(){
        debugPrint("menu Tap")
        touchTarget?.menuTap!()
    }
    
}
