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
    
    class func addFamilyTreeViewController() -> AddFamilyTreeViewController? {
        return familyTreeStoryboard().instantiateViewController(withIdentifier: "AddFamilyTreeViewController") as? AddFamilyTreeViewController
    }
    
    class func editFamilyTreeInfoViewController() -> EditFamilyTreeInfoViewController? {
        return familyTreeStoryboard().instantiateViewController(withIdentifier: "EditFamilyTreeInfoViewController") as? EditFamilyTreeInfoViewController
    }
    
    class func familyTreeManageViewController() -> FamilyTreeManageViewController? {
        return familyTreeStoryboard().instantiateViewController(withIdentifier: "FamilyTreeManageViewController") as? FamilyTreeManageViewController
    }
    
    class func listAllFamilyTreeViewController() -> ListAllFamilyTreeViewController? {
        return familyTreeStoryboard().instantiateViewController(withIdentifier: "ListAllFamilyTreeViewController") as? ListAllFamilyTreeViewController
    }
    
    class func listUserToShareTreeViewController() -> ListUserToShareTreeViewController? {
        return familyTreeStoryboard().instantiateViewController(withIdentifier: "ListUserToShareTreeViewController") as? ListUserToShareTreeViewController
    }
    
    class func listUserSharedTreeViewController() -> ListUserSharedTreeViewController? {
        return familyTreeStoryboard().instantiateViewController(withIdentifier: "ListUserSharedTreeViewController") as? ListUserSharedTreeViewController
    }
    
    class func editFamilyTreeAndEditorsViewController() -> EditFamilyTreeAndEditorsViewController? {
        return familyTreeStoryboard().instantiateViewController(withIdentifier: "EditFamilyTreeAndEditorsViewController") as? EditFamilyTreeAndEditorsViewController
    }
    
    class func familyMemoriesViewController() -> FamilyMemoriesViewController? {
        return familyTreeStoryboard().instantiateViewController(withIdentifier: "FamilyMemoriesViewController") as? FamilyMemoriesViewController
    }
    
    class func addFamilyTreeMemoryViewController() -> AddFamilyTreeMemoryViewController? {
        return familyTreeStoryboard().instantiateViewController(withIdentifier: "AddFamilyTreeMemoryViewController") as? AddFamilyTreeMemoryViewController
    }
}
