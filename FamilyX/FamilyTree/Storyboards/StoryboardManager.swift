//
//  StoryboardManager.swift
//  Scanner App
//
//  Created by Gia Huy on 28/11/2020.
//

import Foundation
import UIKit
import SideMenu

extension UIStoryboard {
    
//    ============== define Main Storyboard ===============
    
    class func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: Bundle.main)
    }
    
    class func loginViewController() -> LoginViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
    }
    
    class func signUpViewController() -> SignUpViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController
    }
    
    class func viewController() -> ViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "ViewController") as? ViewController
    }
    
    class func dialogConfirmViewController() -> DialogConfirmViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "DialogConfirmViewController") as? DialogConfirmViewController
    }
    
    class func sideMenuNavigationController() -> SideMenuNavigationController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "SideMenuNavigationController") as? SideMenuNavigationController
    }
    
    class func homeViewController() -> HomeViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
    }
    
//    ============== define Family Tree Storyboard ===============
    
    class func familyTreeStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "FamilyTree", bundle: Bundle.main)
    }
    
    class func editFamilyTreeViewController() -> EditFamilyTreeViewController? {
        return familyTreeStoryboard().instantiateViewController(withIdentifier: "EditFamilyTreeViewController") as? EditFamilyTreeViewController
    }
    
    class func addPeopleViewController() -> AddPeopleViewController? {
        return familyTreeStoryboard().instantiateViewController(withIdentifier: "AddPeopleViewController") as? AddPeopleViewController
    }
    
    class func editPeopleViewController() -> EditPeopleViewController? {
        return familyTreeStoryboard().instantiateViewController(withIdentifier: "EditPeopleViewController") as? EditPeopleViewController
    }
    
    class func listFamilyTreeViewController() -> ListFamilyTreeViewController? {
        return familyTreeStoryboard().instantiateViewController(withIdentifier: "ListFamilyTreeViewController") as? ListFamilyTreeViewController
    }
}
