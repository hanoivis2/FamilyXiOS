//
//  UserProfileViewController.swift
//  FamilyTree
//
//  Created by Gia Huy on 15/06/2021.
//

import UIKit

class UserProfileViewController : UIViewController, NavigationControllerCustomDelegate {
    
    @IBOutlet weak var img_avatar:UIImageView!
    @IBOutlet weak var lbl_fullname:UILabel!
    @IBOutlet weak var lbl_email:UILabel!
    @IBOutlet weak var lbl_address:UILabel!
    @IBOutlet weak var lbl_phone:UILabel!
    @IBOutlet weak var lbl_gender:UILabel!
    @IBOutlet weak var lbl_birthday:UILabel!
    @IBOutlet weak var lbl_joinDate:UILabel!
    @IBOutlet weak var btn_edit: UIButton!
    
    var account = Account()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if account.id != ManageCacheObject.getCurrentAccount().id {
            btn_edit.isHidden = true
        }
        
        lbl_fullname.text = account.firstName + " " + account.midName + " " + account.lastName
        lbl_email.text = account.email
        lbl_address.text = account.address
        lbl_phone.text = account.phone
        lbl_gender.text = (account.gender == GENDER_ID.MALE.rawValue) ? "Male" : "Female"
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date1 = dateFormatter.date(from: account.birthday)
        let date2 = dateFormatter.date(from: account.createdDate)
        dateFormatter.dateFormat = "dd/MM/yyyy"
        lbl_birthday.text = dateFormatter.string(from: date1 ?? Date())
        lbl_joinDate.text = dateFormatter.string(from: date2 ?? Date())
        
        let imageView = UIImageView()
        let imageHolder = UIImage(named: "no_image")!

        if let url = URL(string: account.avatarUrl) {
            
            
            imageView.kf.setImage(with: url, placeholder: imageHolder, options: [.cacheOriginalImage], progressBlock: { receivedSize, totalSize in
                // Progress updated
            }, completionHandler: { result in
                if let image = imageView.image {
                   self.img_avatar.image = image
                }
            })
            
        } else {
            
            self.img_avatar.image = imageHolder
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //custom navigation bar
        let navigationControllerCustom : NavigationControllerCustom = self.navigationController as! NavigationControllerCustom
        navigationControllerCustom.setUpNavigationBar(self, hideBackButton: false, hideAddButton: true, title: "USERS PROFILE")
        navigationControllerCustom.touchTarget = self
        navigationControllerCustom.navigationBar.barTintColor = ColorUtils.toolbar()
        navigationControllerCustom.navigationBar.isHidden = false
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.navigationItem.backBarButtonItem?.isEnabled = false
        
    }
    
    func backTap() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_edit(_ sender: Any) {
        let editUserProfileViewController:EditUserProfileViewController?
        editUserProfileViewController = UIStoryboard.editUserProfileViewController()
        navigationController?.pushViewController(editUserProfileViewController!, animated: true)
    }
    
}
