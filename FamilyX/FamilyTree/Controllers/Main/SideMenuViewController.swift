//
//  SideMenuViewController.swift
//  FamilyTree
//
//  Created by Gia Huy on 05/05/2021.
//

import UIKit
import SideMenu

protocol SideMenuDelegate {
    func logout()
    func profile()
    func notification()
    func calendar()
    func familyTreesList()
}

class SideMenuViewController : UIViewController {
    
    @IBOutlet weak var tbl_menu: UITableView!
    
    var delegate:SideMenuDelegate?
    var menuLabel = ["Family Trees List", "Users Profile", "Notification", "Calendar", "Log out"]
    var menuIcon = ["list", "user_profile", "notification", "schedule", "logout"]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tbl_menu.reloadData()
        tbl_menu.separatorStyle = .none
    
        let imageView = UIImageView(image: UIImage(named: "background"))
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        tbl_menu.backgroundView = imageView
        
    }
    
}

extension SideMenuViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuLabel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuItemTableViewCell") as! SideMenuItemTableViewCell

        cell.lbl_title.text = menuLabel[indexPath.row]
        cell.img_icon.image = UIImage(named: menuIcon[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            delegate?.familyTreesList()
        case 1:
            delegate?.profile()
        case 2:
            delegate?.notification()
        case 3:
            delegate?.calendar()
        default:
            delegate?.logout()
        }
    }
    
    
}

class SideMenuItemTableViewCell : UITableViewCell {
    @IBOutlet weak var img_icon: UIImageView!
    @IBOutlet weak var lbl_title: UILabel!
}
