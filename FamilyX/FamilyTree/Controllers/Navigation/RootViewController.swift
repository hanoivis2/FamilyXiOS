//
//  RootViewController.swift
//  Scanner App
//
//  Created by Gia Huy on 28/11/2020.
//

import UIKit


class RootViewController: BaseViewController {

    var baseNavigationController: NavigationControllerCustom!
    var mainViewController:ViewController?
    let centerPanelExpandedOffset: CGFloat = UIScreen.main.bounds.width - 80
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        mainViewController = UIStoryboard.viewController()
        baseNavigationController = NavigationControllerCustom(rootViewController: mainViewController!)
        
        view.addSubview(baseNavigationController.view)
        baseNavigationController.didMove(toParent: self)
      

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
}

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }


}
