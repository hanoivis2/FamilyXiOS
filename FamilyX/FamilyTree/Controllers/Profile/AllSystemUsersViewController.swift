//
//  AllSystemUsersViewController.swift
//  FamilyTree
//
//  Created by Gia Huy on 15/06/2021.
//

import UIKit
import JGProgressHUD
import ObjectMapper
import Loaf

class AllSystemUsersViewController : UIViewController, NavigationControllerCustomDelegate {
    
    @IBOutlet weak var search_bar:UISearchBar!
    @IBOutlet weak var tbl_users:UITableView!
    
    var users = [Account]()
    var usersFilter = [Account]()
    var myAccount = Account()
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        search_bar.backgroundImage = UIImage()
        tbl_users.allowsSelection = false
        tbl_users.separatorStyle = .none
        
        setupRefreshControl()
        
        getUserList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //custom navigation bar
        let navigationControllerCustom : NavigationControllerCustom = self.navigationController as! NavigationControllerCustom
        navigationControllerCustom.setUpNavigationBar(self, hideBackButton: false, hideAddButton: true, title: "USERS IN SYSTEM")
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
    
    func getUserList(){
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Please wait..."
        hud.show(in: self.view)
        
        ResAPI.sharedInstance.getAllUsers({ (data, message) -> Void in
            
          switch message {
            case "SUCCESS":
                if(data != nil){

                    let response:ResResponse = data as! ResResponse

                    if let usersRes = Mapper<Account>().mapArray(JSONObject: response.data) {
                        self.users = usersRes
                        
                        for i in 0..<self.users.count {
                            let item = self.users[i]
                            if item.id == ManageCacheObject.getCurrentAccount().id {
                                self.myAccount = item
                                self.users.remove(at: i)
                                break
                            }
                        }
                        
                        self.usersFilter = self.users
                        self.tbl_users.reloadData()
                    }
                    else {
                        Loaf.init(response.message ?? "", state: .info, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
                    }
                    
                    
                }
            case "UNAUTHORIZED":
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
                
                Loaf.init(UnauthorizedError, state: .info, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(4), completionHandler: nil)
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
}

extension AllSystemUsersViewController : ListUserTableViewCellDelegate {
    func select(pos: IndexPath) {
        if pos.section == 0 {
            let userProfileViewController:UserProfileViewController?
            userProfileViewController = UIStoryboard.userProfileViewController()
            userProfileViewController?.account = myAccount
            navigationController?.pushViewController(userProfileViewController!, animated: true)
        }
        else {
            let userProfileViewController:UserProfileViewController?
            userProfileViewController = UIStoryboard.userProfileViewController()
            userProfileViewController?.account = usersFilter[pos.row]
            navigationController?.pushViewController(userProfileViewController!, animated: true)
        }
    }
}


extension AllSystemUsersViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = Bundle.main.loadNibNamed("ViewHeaderEditor", owner: self, options: nil)?.first as! ViewHeaderEditor
        
        if section == 0 {
            view.lbl_title.text = "My Account"
        }
        else {
            view.lbl_title.text = "Users"
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
            return usersFilter.count
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListUserTableViewCell") as! ListUserTableViewCell
        
        var user = Account()
        
        if indexPath.section == 0 {
            user = myAccount
            cell.view_separator.isHidden = true
        }
        else {
            user = usersFilter[indexPath.row]
            cell.view_separator.isHidden = false
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
        
        cell.lbl_shared.isHidden = true
        cell.img_share.isHidden = true
        cell.btn_shared.isEnabled = true
        
        cell.pos = indexPath
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
}

extension AllSystemUsersViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.dismissKeyboard()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.dismissKeyboard()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        self.search_bar.text = searchText
        self.usersFilter = self.search_bar.text!.lowercased().isEmpty ? users : users.filter { (item: Account) -> Bool in

            return item.firstName.lowercased().range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            || item.midName.lowercased().range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            || item.lastName.lowercased().range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            || item.email.lowercased().range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        
        tbl_users.reloadData()
    }
}


protocol ListUserTableViewCellDelegate {
    func select(pos:IndexPath)
}

class ListUserTableViewCell : UITableViewCell {
    
    @IBOutlet weak var img_avatar: UIImageView!
    @IBOutlet weak var lbl_fullname: UILabel!
    @IBOutlet weak var lbl_username: UILabel!
    @IBOutlet weak var img_share: UIImageView!
    @IBOutlet weak var lbl_shared: UILabel!
    @IBOutlet weak var btn_shared: UIButton!
    @IBOutlet weak var view_separator: UIView!
    
    var pos = IndexPath()
    var delegate:ListUserTableViewCellDelegate?
    
    @IBAction func btn_selectRow(_ sender: Any) {
        delegate?.select(pos: pos)
    }
}
