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
    @objc optional func filterTap()
    @objc optional func searchTap()
    @objc optional func actionTap()
    @objc optional func voiceTap()
    @objc optional func addTap()
    
}

class NavigationControllerCustom: UINavigationController {

    var backButton : UIButton!
    var voiceButton : UIButton!
    var filterButton : UIButton!
    var searchButton : UIButton!
    var addButton : UIButton!
    var touchTarget : NavigationControllerCustomDelegate?
    var textTitle : UILabel!
    var logo :UIImageView!
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
        textTitle.frame.origin.y = centerY;
        backButton.frame.origin.y = centerY;
        voiceButton.frame.origin.y = centerY;
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let heightNavi = self.navigationBar.frame.size.height
        let widthNavi = self.navigationBar.frame.size.width
        let statusBarSize = UIApplication.shared.statusBarFrame.size
        heightNavigationBar = heightNavi + statusBarSize.height
        
        self.navigationItem.hidesBackButton = true
 //       self.navigationBar.barTintColor = ColorUtils.toolbar()
        self.navigationBar.barTintColor = ColorUtils.main_color()
        let viewBackground = UIView(frame: CGRect(x: 0, y: -45, width: widthNavi, height: heightNavi+45))
 //       viewBackground.backgroundColor = ColorUtils.toolbar()
         viewBackground.backgroundColor = ColorUtils.main_color()
        self.navigationBar.addSubview(viewBackground)

        
        textTitle = UILabel(frame: CGRect(x: widthNavi/2 - (widthNavi - 80)/2, y: 0, width: widthNavi - 80, height: heightNavi))
        textTitle.backgroundColor = UIColor.clear
        textTitle.textColor = UIColor.white
        textTitle.textAlignment = NSTextAlignment.center
        textTitle.font = UIFont(name: "Helvetica-Bold", size: 14.0)
        textTitle.isUserInteractionEnabled = true
        self.navigationBar.addSubview(textTitle)
        
        logo = UIImageView(frame: CGRect(x: widthNavi/2 - 50, y: 5, width: 150, height: 30))
        logo.backgroundColor = UIColor.clear
        let logo_image = UIImage(named: "header_logo.png")
        logo.image = logo_image
        
        self.navigationBar.addSubview(logo)
     
       let searcch = UISearchBar(frame: CGRect(x: widthNavi/2 - 50, y: 5, width: 150, height: 30))
        self.navigationController?.searchDisplayController?.displaysSearchBarInNavigationBar = true
        
        
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
        
        addButton = UIButton(frame: CGRect(x: widthNavi - 80, y: 5, width: 60, height: 30))
        addButton.clipsToBounds = true
        addButton.layer.cornerRadius = 4
        addButton?.showsTouchWhenHighlighted = true
//        if let image = UIImage(named: "icon_add") {
//            addButton.setImage(image, for: .normal)
//            addButton.tintColor = ColorUtils.white()
//        }
        
        addButton.titleLabel?.font = UIFont(name: "Helvetica-SemiBold", size: 14.0)
//        addButton.contentVerticalAlignment = .center
//        addButton.contentHorizontalAlignment = .center
        addButton.titleLabel?.textAlignment = .center
        addButton.setTitleColor(ColorUtils.main_color(), for: UIControl.State())
        addButton.setTitleColor(UIColor.COLOR_ICON_TOUCH(), for: UIControl.State.highlighted)
        
        addButton.setTitle("THÊM", for: .normal)
        addButton.backgroundColor = .white
        addButton.addTarget(self, action:#selector(NavigationControllerCustom.addTap), for: UIControl.Event.touchUpInside)
//        addButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -40, bottom: 0, right: 0)
        self.navigationBar.addSubview(addButton)
        
        
        voiceButton = UIButton(frame: CGRect(x: 10.0, y: 0, width: 30, height: 30))
        voiceButton?.showsTouchWhenHighlighted = true
        if let image = UIImage(named: "icon_voice") {
            voiceButton.setImage(image, for: .normal)
            voiceButton.tintColor = .white
        }
        
        voiceButton.setTitleColor(UIColor.white, for: UIControl.State())
        voiceButton.setTitleColor(UIColor.COLOR_ICON_TOUCH(), for: UIControl.State.highlighted)
        voiceButton.addTarget(self, action:#selector(NavigationControllerCustom.voiceTap), for: UIControl.Event.touchUpInside)
        voiceButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        self.navigationBar.addSubview(voiceButton)
        
        
        
        filterButton = UIButton(frame: CGRect(x: widthNavi - 50, y: 0, width: 40, height: 40))
        filterButton?.showsTouchWhenHighlighted = true
        if let image = UIImage(named: "filter_list") {
            filterButton.setImage(image, for: .normal)
        }
        
        filterButton.setTitleColor(UIColor.white, for: UIControl.State())
        filterButton.setTitleColor(UIColor.COLOR_ICON_TOUCH(), for: UIControl.State.highlighted)
        filterButton.tintColor = .white
        filterButton.addTarget(self, action:#selector(NavigationControllerCustom.filterTap), for: UIControl.Event.touchUpInside)
        filterButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        self.navigationBar.addSubview(filterButton)
        
        
        searchButton = UIButton(frame: CGRect(x: widthNavi - 50, y: 0, width: 35, height: 35))
        searchButton?.showsTouchWhenHighlighted = true
        if let image = UIImage(named: "icon_search") {
            searchButton.setImage(image, for: .normal)
        }
        
        searchButton.setTitleColor(UIColor.white, for: UIControl.State())
        searchButton.setTitleColor(UIColor.COLOR_ICON_TOUCH(), for: UIControl.State.highlighted)
        searchButton.tintColor = .white
        searchButton.addTarget(self, action:#selector(NavigationControllerCustom.searchTap), for: UIControl.Event.touchUpInside)
        searchButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        self.navigationBar.addSubview(searchButton)
 
        numberLabel = UILabel(frame: CGRect(x: widthNavi - widthButton, y: 20, width: widthButton , height: heightButton))
        numberLabel.backgroundColor = UIColor.clear
        numberLabel.textAlignment = NSTextAlignment.center
        numberLabel.font = UIFont.fontDefaultRegularSize(11.0)
        numberLabel.text = "99+"
        numberLabel.isHidden = true
        numberLabel.textColor = UIColor.yellow
        numberLabel.isUserInteractionEnabled = false
        backButton.isHidden = true
        textTitle.isHidden = true
        filterButton.isHidden = true
        addButton.isHidden = true
        logo.isHidden = true
        voiceButton.isHidden = true
        searchButton.isHidden = true
        navigationController?.navigationItem.hidesBackButton = true
    }
    
    func add(){
//        self.panGestureRecognizer = UIPanGestureRecognizer(target: touchTarget!, action: Selector(("handlePanGesture:")))
//        self.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    func remove(){
//        self.view.removeGestureRecognizer(self.panGestureRecognizer)
    }
    
    func setUpNavigationBar(_ target:NavigationControllerCustomDelegate, backButton:Bool, title:String){
        self.backButton.isHidden = backButton
        self.filterButton.isHidden = true
        self.addButton.isHidden = true
        self.voiceButton.isHidden = true
        self.searchButton.isHidden = true
        if(title != ""){
            self.textTitle.isHidden = false
            self.textTitle.text = title
        }else{
            self.textTitle.isHidden = true
        }
       
        self.textTitle.isHidden = true
    }
    func setUpNavigationBar(_ target:NavigationControllerCustomDelegate,  backButton:Bool, logo:Bool, title:String){
        self.backButton.isHidden = backButton
        self.logo.isHidden = logo
        self.filterButton.isHidden = true
        self.addButton.isHidden = true
        self.voiceButton.isHidden = true
        self.touchTarget = target
        self.searchButton.isHidden = true
        
        if(title != ""){
            self.textTitle.isHidden = false
            self.textTitle.text = title
        }else{
            self.textTitle.isHidden = true
        }
    }
    
    func setUpNavigationBar(_ target:NavigationControllerCustomDelegate,  backButton:Bool, voiceButton:Bool, filter:Bool, add:Bool, title:String){
        self.backButton.isHidden = backButton
        self.voiceButton.isHidden = voiceButton
        self.filterButton.isHidden = filter
        self.addButton.isHidden = add
        self.searchButton.isHidden = true
        self.touchTarget = target
        if(title != ""){
            self.textTitle.isHidden = false
            self.textTitle.text = title
        }else{
            self.textTitle.isHidden = true
        }
    }
    
    func setUpNavigationBar(_ target:NavigationControllerCustomDelegate,  hideBackButton:Bool, hideFilterButton:Bool, title:String){
        self.backButton.isHidden = hideBackButton
        self.filterButton.isHidden = hideFilterButton
        self.addButton.isHidden = true
        self.voiceButton.isHidden = true
        self.searchButton.isHidden = true
        self.touchTarget = target
        if(title != ""){
            self.textTitle.isHidden = false
            self.textTitle.text = title
        }else{
            self.textTitle.isHidden = true
        }
    }
    
    func setUpNavigationBar(_ target:NavigationControllerCustomDelegate,  backButton:Bool, addButton:Bool, title:String){
        self.backButton.isHidden = backButton
        self.addButton.isHidden = addButton
        self.voiceButton.isHidden = true
        self.filterButton.isHidden = true
        self.searchButton.isHidden = true
        
        self.touchTarget = target
        if(title != ""){
            self.textTitle.isHidden = false
            self.textTitle.text = title
        }else{
            self.textTitle.isHidden = true
        }
    }
    func setUpNavigationBar(_ target:NavigationControllerCustomDelegate,  backButton:Bool, searchButton:Bool, title:String){
        self.backButton.isHidden = backButton
        self.searchButton.isHidden = searchButton
        self.voiceButton.isHidden = true
        self.filterButton.isHidden = true
        self.addButton.isHidden = true
        self.touchTarget = target
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

    @objc func actionTap(){
        debugPrint("action Tap")
        touchTarget?.actionTap!()
    }
    
    @objc func voiceTap(){
        debugPrint("voice Tap")
        touchTarget?.voiceTap!()
    }
    
    @objc func filterTap(){
        debugPrint("filter Tap")
        touchTarget?.filterTap!()
    }
    
    @objc func addTap(){
        debugPrint("add Tap")
        touchTarget?.addTap!()
    }
    @objc func searchTap(){
        debugPrint("search Tap")
        touchTarget?.searchTap!()
    }
    
}
