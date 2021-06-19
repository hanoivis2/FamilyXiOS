//
//  ListUserSharedTreeViewController.swift
//  FamilyTree
//
//  Created by Gia Huy on 02/06/2021.
//

import UIKit
import JGProgressHUD
import Loaf
import ObjectMapper

protocol ListUserSharedTreeDelegate {
    func addContributor()
    func logoutFromListEditors()
}

class ListUserSharedTreeViewController : UIViewController, NavigationControllerCustomDelegate {
    
    @IBOutlet weak var tbl_users:UITableView!
    
    var users = [Account]()
    var owner = Account()
    var refreshControl = UIRefreshControl()
    var treeId = 0
    var usernameEditorToRemove = ""
    var delegate:ListUserSharedTreeDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        tbl_users.allowsSelection = false
        tbl_users.separatorStyle = .none
        
        setupRefreshControl()
        getUserList()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let navigationControllerCustom : NavigationControllerCustom = self.navigationController as! NavigationControllerCustom
        navigationControllerCustom.setUpNavigationBar(self, hideBackButton: false, hideAddButton: true, title: "FAMILY TREE")
        navigationControllerCustom.touchTarget = self
        navigationControllerCustom.navigationBar.barTintColor = ColorUtils.toolbar()
        navigationControllerCustom.navigationBar.isHidden = false
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.navigationItem.backBarButtonItem?.isEnabled = false
        
    }
    
    func backTap() {
        navigationController?.popViewController(animated: true)
    }
    
    func setupRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        self.tbl_users.addSubview(refreshControl)
        
    }
    
    @objc func refresh(_ sender: AnyObject) {
        // Code to refresh table view
        getUserList()
    }
    
    @IBAction func btn_addContributor(_ sender: Any) {
        delegate?.addContributor()
    }
    
    func getUserList(){
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Please wait..."
        hud.show(in: self.view)
        
        ResAPI.sharedInstance.getAllEditors(treeId: treeId, { (data, message) -> Void in
            
          switch message {
            case "SUCCESS":
                if(data != nil){

                    let response:ResResponse = data as! ResResponse

                    if let editorsRes = Mapper<FamilyTreeEditor>().map(JSONObject: response.data) {
                        self.users = editorsRes.editors
                        self.owner = editorsRes.owner
                        self.tbl_users.reloadData()
                    }
                    else {
                        Loaf.init(response.message ?? "", state: .info, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
                    }
                    
                    
                }
          case "UNAUTHORIZED":
            self.delegate?.logoutFromListEditors()
          case "RECALL":
              self.getUserList()
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
            
        })
        self.refreshControl.endRefreshing()
        hud.dismiss()
    }
    
    func removeEditor(username:String){
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Please wait..."
        hud.show(in: self.view)
        
        ResAPI.sharedInstance.removeEditorFromTree(treeId: self.treeId, editorsUsername: [username], { (data, message) -> Void in
            
          switch message {
            case "SUCCESS":
                self.getUserList()
                Loaf.init("Removed successfully!", state: .success, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(3), completionHandler: nil)
            case "UNAUTHORIZED":
                self.delegate?.logoutFromListEditors()
          case "RECALL":
              self.removeEditor(username: username)
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
            
        })
        self.refreshControl.endRefreshing()
        hud.dismiss()
    }
}

extension ListUserSharedTreeViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = Bundle.main.loadNibNamed("ViewHeaderEditor", owner: self, options: nil)?.first as! ViewHeaderEditor
        
        if section == 0 {
            view.lbl_title.text = "Owner"
        }
        else {
            view.lbl_title.text = "Contributors"
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }
        else {
            return users.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListEditorsTreeTableViewCell") as! ListEditorsTreeTableViewCell
        
        var user = Account()
        
        if indexPath.section == 0 {
            user = owner
            cell.view_separator.isHidden = true
            cell.btn_delete.isEnabled = false
            cell.img_delete.isHidden = true
        }
        else {
            user = users[indexPath.row]
            cell.view_separator.isHidden = false
            
            if owner.id == ManageCacheObject.getCurrentAccount().id {
                cell.btn_delete.isEnabled = true
                cell.img_delete.isHidden = false
            }
            else {
                cell.btn_delete.isEnabled = false
                cell.img_delete.isHidden = true
            }
            
        }

        
        if user.avatarUrl == "" {
            if user.gender == GENDER_ID.MALE.rawValue {
                cell.img_avatar.image = UIImage(named: "male")
            }
            else {
                cell.img_avatar.image = UIImage(named: "female")
            }
        }
        else {
            let imageView = UIImageView()
            if let url = URL(string: user.avatarUrl) {
                
                
                imageView.kf.setImage(with: url, placeholder: UIImage(named: "no_image"), options: [.cacheOriginalImage], progressBlock: { receivedSize, totalSize in
                    // Progress updated
                }, completionHandler: { result in
                    if let image = imageView.image {
                        cell.img_avatar.image = image
                    }
                })
                
            } else {
                if user.gender == GENDER_ID.MALE.rawValue {
                    cell.img_avatar.image = UIImage(named: "male")
                }
                else {
                    cell.img_avatar.image = UIImage(named: "female")
                }
            }
        }
        
        cell.lbl_fullname.text = user.firstName + " " + user.midName + " " + user.lastName
        cell.lbl_username.text = user.username
        cell.pos = indexPath.row
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}

extension ListUserSharedTreeViewController : ListEditorsTreeTableViewCellDelegate {
    func remove(pos: Int) {
        usernameEditorToRemove = users[pos].username
        let dialogConfirmViewController:DialogConfirmViewController?
        dialogConfirmViewController = UIStoryboard.dialogConfirmViewController()
        dialogConfirmViewController?.delegate = self
        dialogConfirmViewController?.dialogTitle = "Confirm"
        dialogConfirmViewController?.content = "Are you sure to remove \(usernameEditorToRemove) as a contributor?"
        self.present(dialogConfirmViewController!, animated: false, completion: nil)
    }
}

extension ListUserSharedTreeViewController : DialogConfirmDelegate {
    func accept() {
        removeEditor(username: usernameEditorToRemove)
    }
    
    func deny() {
        
    }
}

protocol ListEditorsTreeTableViewCellDelegate {
    func remove(pos:Int)
}

class ListEditorsTreeTableViewCell : UITableViewCell {
    
    @IBOutlet weak var img_avatar: UIImageView!
    @IBOutlet weak var lbl_fullname: UILabel!
    @IBOutlet weak var lbl_username: UILabel!
    @IBOutlet weak var lbl_shared: UILabel!
    @IBOutlet weak var btn_delete: UIButton!
    @IBOutlet weak var view_separator: UIView!
    @IBOutlet weak var img_delete: UIImageView!
    
    var pos = 0
    var delegate:ListEditorsTreeTableViewCellDelegate?
    
    @IBAction func btn_selectRow(_ sender: Any) {
        delegate?.remove(pos: pos)
    }
}
