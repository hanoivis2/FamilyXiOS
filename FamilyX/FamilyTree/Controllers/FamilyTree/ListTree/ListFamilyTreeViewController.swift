//
//  ListFamilyTreeViewController.swift
//  FamilyTree
//
//  Created by Gia Huy on 04/05/2021.
//

import UIKit
import JGProgressHUD
import Loaf
import ObjectMapper

class ListFamilyTreeViewController : UIViewController, NavigationControllerCustomDelegate {
    
    @IBOutlet weak var tbl_trees: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var trees = [FamilyTree]()
    var treesSearched = [FamilyTree]()
    var refreshControl = UIRefreshControl()
    var deleteTreeWithId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.setHidesBackButton(true, animated: false)
        tbl_trees.separatorStyle = .none
        tbl_trees.allowsSelection = false
        searchBar.backgroundImage = UIImage()
        searchBar.placeholder = "Enter some keywords to search..."
        getTreeList()
        
        setupRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.navigationItem.backBarButtonItem?.isEnabled = false
    }
    
    @IBAction func btn_addTree(_ sender: Any) {
        let addFamilyTreeViewController:AddFamilyTreeViewController?
        addFamilyTreeViewController =  UIStoryboard.addFamilyTreeViewController()
        addFamilyTreeViewController?.delegate = self
        addFamilyTreeViewController?.modalTransitionStyle = .crossDissolve
        self.present(addFamilyTreeViewController!, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refreshControl.didMoveToSuperview()
    }
    
    func setupRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        self.tbl_trees.addSubview(refreshControl)
        
    }
    
    @objc func refresh(_ sender: AnyObject) {
        // Code to refresh table view
        getTreeList()
    }
    
    @IBAction func btn_search(_ sender: Any) {
        if !searchBar.text!.isEmpty {
            self.getTreeListWithKeyword(keyword: searchBar.text!)
        }
    }
    
    func getTreeList(){
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Please wait..."
        hud.show(in: self.view)
        
        ResAPI.sharedInstance.getListFamilyTree({ (data, message) -> Void in
            
          switch message {
            case "SUCCESS":
                if(data != nil){

                    let response:ResResponse = data as! ResResponse

                    if let trees = Mapper<FamilyTree>().mapArray(JSONObject: response.data) {
                        self.trees = trees
                        
                        self.tbl_trees.reloadData()
                        self.refreshControl.endRefreshing()
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
              self.getTreeList()
            case "NOTFOUND":
                Loaf.init("Request not found", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
            case "DATA":
                Loaf.init("Data error", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
            default:
                if data != nil {
                    let response = data as! ResResponse
                    if !response.message!.isEmpty {
                        Loaf.init(response.message!, state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
                    }
                }
                
            }
            
            hud.dismiss()
        })
    }
    
    func getTreeListWithKeyword(keyword:String){
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Please wait..."
        hud.show(in: self.view)
        
        ResAPI.sharedInstance.getListFamilyTreeWithKeyword(keyword: keyword, { (data, message) -> Void in
            
          switch message {
            case "SUCCESS":
                if(data != nil){

                    let response:ResResponse = data as! ResResponse

                    if let trees = Mapper<FamilyTree>().mapArray(JSONObject: response.data) {
                        self.treesSearched = trees
                        
                        self.tbl_trees.reloadData()
                        self.refreshControl.endRefreshing()
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
              self.getTreeListWithKeyword(keyword: keyword)
            case "NOTFOUND":
                Loaf.init("Request not found", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
            case "DATA":
                Loaf.init("Data error", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
            default:
                if data != nil {
                    let response = data as! ResResponse
                    if !response.message!.isEmpty {
                        Loaf.init(response.message!, state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
                    }
                }
                
            }
            
            hud.dismiss()
        })
    }
    
    func addTree(name:String, des:String){
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Please wait..."
        hud.show(in: self.view)
        
        ResAPI.sharedInstance.addFamilyTree(name: name, description: des, { (data, message) -> Void in
            
            switch message {
              case "SUCCESS":
                if(data != nil){

                    let response:ResResponse = data as! ResResponse

                    if let newTree = Mapper<FamilyTree>().map(JSONObject: response.data) {
                        
                        self.trees.append(newTree)
                        self.tbl_trees.reloadData()
                        self.tbl_trees.scrollToRow(at: IndexPath(row: self.trees.count - 1, section: 0), at: .bottom, animated: true)
                        
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
                self.addTree(name: name, des: des)
              case "NOTFOUND":
                  Loaf.init("Request not found", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
              case "DATA":
                  Loaf.init("Data error", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
              default:
                  if data != nil {
                      let response = data as! ResResponse
                      if !response.message!.isEmpty {
                          Loaf.init(response.message!, state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
                      }
                  }
                  
              }
            
            hud.dismiss()
        })
    }
    
    
    func deleteTree(id:Int){
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Please wait..."
        hud.show(in: self.view)
        
        ResAPI.sharedInstance.deleteFamilyTree(treeId: id, { (data, message) -> Void in
            
            switch message {
              case "SUCCESS":
                self.getTreeList()
                Loaf.init("Delete successfully", state: .success, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(3), completionHandler: nil)
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
                self.deleteTree(id: id)
              case "NOTFOUND":
                  Loaf.init("Request not found", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
              case "DATA":
                  Loaf.init("Data error", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
              default:
                  if data != nil {
                      let response = data as! ResResponse
                      if !response.message!.isEmpty {
                          Loaf.init(response.message!, state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
                      }
                  }
                  
              }
            
            hud.dismiss()
        })
    }
    
    func editTree(id:Int, name:String, description:String){
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Please wait..."
        hud.show(in: self.view)
        
        ResAPI.sharedInstance.editFamilyTree(name:name, description:description, treeId: id, { (data, message) -> Void in
            
            switch message {
              case "SUCCESS":
                self.getTreeList()
                Loaf.init("Edit successfully", state: .success, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(3), completionHandler: nil)
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
                self.editTree(id: id, name: name, description: description)
              case "NOTFOUND":
                  Loaf.init("Request not found", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
              case "DATA":
                  Loaf.init("Data error", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
              default:
                  if data != nil {
                      let response = data as! ResResponse
                      if !response.message!.isEmpty {
                          Loaf.init(response.message!, state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
                      }
                  }
                  
              }
            
            hud.dismiss()
        })
    }
}

extension ListFamilyTreeViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (treesSearched.count > 0) ? (treesSearched.count) : (trees.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListFamilyTreeTableViewCell") as! ListFamilyTreeTableViewCell
        
        let tree = (treesSearched.count > 0) ? (treesSearched[indexPath.row]) : (trees[indexPath.row])
        
        cell.lbl_name.text = tree.name
        cell.lbl_description.text = tree.description
        cell.lbl_owner.text = "Owner: \(tree.owner.username)"
        cell.pos = indexPath.row
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
}

extension ListFamilyTreeViewController : AddFamilyTreeViewDelegate {
    func addTree(name: String, description: String) {
        addTree(name: name, des: description)
    }
}

extension ListFamilyTreeViewController : ListFamilyTreeDelegate {
    
    func editTreeDetail(pos: Int) {
        let editFamilyTreeAndEditorsViewController:EditFamilyTreeAndEditorsViewController?
        editFamilyTreeAndEditorsViewController = UIStoryboard.editFamilyTreeAndEditorsViewController()
        editFamilyTreeAndEditorsViewController?.treeId = trees[pos].id
        navigationController?.pushViewController(editFamilyTreeAndEditorsViewController!, animated: true)
    }
    
    func editTree(pos: Int) {
        let editFamilyTreeInfoViewController:EditFamilyTreeInfoViewController?
        editFamilyTreeInfoViewController =  UIStoryboard.editFamilyTreeInfoViewController()
        editFamilyTreeInfoViewController?.treeInfo = trees[pos]
        editFamilyTreeInfoViewController?.delegate = self
        editFamilyTreeInfoViewController?.modalTransitionStyle = .crossDissolve
        self.present(editFamilyTreeInfoViewController!, animated: true, completion: nil)
    }
    
    func deleteTree(pos: Int) {
        let dialogConfirmViewController:DialogConfirmViewController?
        dialogConfirmViewController = UIStoryboard.dialogConfirmViewController()
        dialogConfirmViewController?.delegate = self
        dialogConfirmViewController?.dialogTitle = "Confirm"
        dialogConfirmViewController?.content = "Are you sure to delete \(trees[pos].name)?"
        deleteTreeWithId = trees[pos].id
        self.present(dialogConfirmViewController!, animated: false, completion: nil)
    }
    
    
}

extension ListFamilyTreeViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.isEmpty {
            treesSearched.removeAll()
            tbl_trees.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
}

extension ListFamilyTreeViewController : DialogConfirmDelegate {
    func accept() {
        deleteTree(id: deleteTreeWithId)
    }
    
    func deny() {
        
    }
    
    
}

extension ListFamilyTreeViewController : EditFamilyTreeInfoViewDelegate {
    func editTreeInfo(id:Int, name: String, description: String) {
        editTree(id: id, name: name, description: description)
    }
}

protocol ListFamilyTreeDelegate {
    func editTree(pos:Int)
    func deleteTree(pos:Int)
    func editTreeDetail(pos:Int)
}

class ListFamilyTreeTableViewCell : UITableViewCell {
    
    @IBOutlet weak var lbl_name:UILabel!
    @IBOutlet weak var lbl_description:UILabel!
    @IBOutlet weak var lbl_owner: UILabel!
    @IBOutlet weak var img_avatar:UIImageView!
    
    var delegate:ListFamilyTreeDelegate?
    var pos = 0
    
    @IBAction func btn_edit(_ sender: Any) {
        delegate?.editTree(pos: pos)
    }
    
    @IBAction func btn_delete(_ sender: Any) {
        delegate?.deleteTree(pos: pos)
    }
    
    @IBAction func btn_edit_details(_ sender: Any) {
        delegate?.editTreeDetail(pos: pos)
    }
}
