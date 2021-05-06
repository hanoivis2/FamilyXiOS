//
//  ViewController.swift
//  Scanner App
//
//  Created by Trịnh Vũ Hoàng on 20/11/2020.
//

import UIKit


class ViewController:  UIViewController, NavigationControllerCustomDelegate {

    var window: UIWindow?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        if (ManageCacheObject.isLogin()) {
            let homeViewController:HomeViewController?
            homeViewController = UIStoryboard.homeViewController()
            self.navigationController!.pushViewController(homeViewController!, animated: false)
        }
        else {
            let loginViewController: LoginViewController?
            loginViewController = UIStoryboard.loginViewController()
            self.navigationController!.pushViewController(loginViewController!, animated: false)
        }
       

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
 
}

