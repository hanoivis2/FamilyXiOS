//
//  HomeViewController.swift
//  FamilyTree App
//
//  Created by Gia Huy on 02/12/2020.
//

import UIKit
import ObjectMapper
import SideMenu


class HomeViewController: UIViewController, NavigationControllerCustomDelegate {

    @IBOutlet weak var lbl_version: UILabel!
    
    private var popGesture: UIGestureRecognizer?
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        lbl_version.text = "Version \(ManageCacheObject.getVersion())"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //custom navigation bar
        let navigationControllerCustom : NavigationControllerCustom = self.navigationController as! NavigationControllerCustom
        navigationControllerCustom.setUpNavigationBar(self, hideMenuButton: false, title: "HOME")
        navigationControllerCustom.touchTarget = self
        navigationControllerCustom.navigationBar.barTintColor = ColorUtils.toolbar()
        navigationControllerCustom.navigationBar.isHidden = false
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.navigationItem.backBarButtonItem?.isEnabled = false
        
    }
  
    func menuTap() {
        showMenu()
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == .right {
            showMenu()
        }
    }
    
    func showMenu() {
        let modalVC = UIStoryboard.sideMenuNavigationController()
        
        let presentationStyle = SideMenuPresentationStyle.viewSlideOut
        presentationStyle.backgroundColor = ColorUtils.main_color()
        presentationStyle.menuStartAlpha = CGFloat(1)
        presentationStyle.menuScaleFactor = CGFloat(1)
        presentationStyle.onTopShadowOpacity = 1
        presentationStyle.presentingEndAlpha = CGFloat(1)
        presentationStyle.presentingScaleFactor = CGFloat(1)

        var settings = SideMenuSettings()
        settings.presentationStyle = presentationStyle
        settings.menuWidth = view.frame.width * CGFloat(0.5)
        settings.blurEffectStyle = nil
        settings.statusBarEndAlpha = 1
        modalVC!.settings = settings
        
        self.present(modalVC!, animated: true, completion: nil)
    }
    
}

extension HomeViewController: SideMenuNavigationControllerDelegate {
    
    func sideMenuWillAppear(menu: SideMenuNavigationController, animated: Bool) {
        
    }
    
    func sideMenuDidAppear(menu: SideMenuNavigationController, animated: Bool) {
        let vc = menu.viewControllers[0] as! SideMenuViewController
        vc.delegate = self
    }
    
    func sideMenuWillDisappear(menu: SideMenuNavigationController, animated: Bool) {
        
    }
    
    func sideMenuDidDisappear(menu: SideMenuNavigationController, animated: Bool) {
        
    }
}

extension HomeViewController : SideMenuDelegate {
    func logout() {
        self.dismiss(animated: true, completion: nil)
        let dialogConfirmViewController:DialogConfirmViewController?
        dialogConfirmViewController = UIStoryboard.dialogConfirmViewController()
        dialogConfirmViewController?.dialogTitle = "Confirm"
        dialogConfirmViewController?.content = "Are you sure to logout?"
        dialogConfirmViewController?.delegate = self
        self.present(dialogConfirmViewController!, animated: true, completion: nil)
    }
    
    func familyTreesList() {
        self.dismiss(animated: true, completion: nil)
        let familyTreeManageViewController:FamilyTreeManageViewController?
        familyTreeManageViewController = UIStoryboard.familyTreeManageViewController()
        navigationController!.pushViewController(familyTreeManageViewController!, animated:true)
    }
}

extension HomeViewController : DialogConfirmDelegate {
    func accept() {
        self.dismiss(animated: true, completion: nil)
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
    }
    
    func deny() {
        
    }
}
