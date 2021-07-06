//
//  ListAllFamilyTreeViewController.swift
//  FamilyTree
//
//  Created by Gia Huy on 02/06/2021.
//

import UIKit
import JGProgressHUD
import Loaf
import ObjectMapper

class ListAllFamilyTreeViewController : UIViewController, NavigationControllerCustomDelegate {
    
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
        view.endEditing(true)
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
        
        ResAPI.sharedInstance.getListAllFamilyTree({ (data, message) -> Void in
            
          switch message {
            case "SUCCESS":
                if(data != nil){

                    let response:ResResponse = data as! ResResponse

                    if let trees = Mapper<FamilyTree>().mapArray(JSONObject: response.data) {
                        self.trees = trees
                        
                        self.tbl_trees.reloadData()
                        
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
        hud.dismiss()
        self.refreshControl.endRefreshing()
    }
    
    func getTreeListWithKeyword(keyword:String){
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Please wait..."
        hud.show(in: self.view)
        
        ResAPI.sharedInstance.getListAllFamilyTreeWithKeyword(keyword: keyword, { (data, message) -> Void in
            
          switch message {
            case "SUCCESS":
                if(data != nil){

                    let response:ResResponse = data as! ResResponse

                    if let trees = Mapper<FamilyTree>().mapArray(JSONObject: response.data) {
                        self.treesSearched = trees
                        
                        self.tbl_trees.reloadData()
                        
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
        hud.dismiss()
        self.refreshControl.endRefreshing()
    }
}

extension ListAllFamilyTreeViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (treesSearched.count > 0) ? (treesSearched.count) : (trees.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListFamilyTreeTableViewCell") as! ListFamilyTreeTableViewCell
        
        let tree = (treesSearched.count > 0) ? (treesSearched[indexPath.row]) : (trees[indexPath.row])
        
        cell.lbl_name.text = tree.name
        cell.lbl_description.text = tree.description

        let imageView = UIImageView()
        if let url = URL(string: tree.owner.avatarUrl) {
            
            
            imageView.kf.setImage(with: url, placeholder: UIImage(named: "no_image"), options: [.cacheOriginalImage], progressBlock: { receivedSize, totalSize in
                // Progress updated
            }, completionHandler: { result in
                if let image = imageView.image {
                    cell.img_owner.image = image
                }
            })
            
        } else {
            cell.img_owner.image = UIImage(named: "no_image")!
        }
        
        if tree.editors.count > 2 {
            cell.img_contributor_1.isHidden = false
            cell.img_contributor_2.isHidden = false
            cell.lbl_moreContributors.isHidden = false
            
            cell.lbl_moreContributors.clipsToBounds = true
            cell.lbl_moreContributors.layer.cornerRadius = 13
            cell.lbl_moreContributors.text = "\(tree.editors.count - 2)+"
    
            if let url = URL(string: tree.editors[0].avatarUrl) {
                
                let imageView1 = UIImageView()
                imageView1.kf.setImage(with: url, placeholder: UIImage(named: "no_image"), options: [.cacheOriginalImage], progressBlock: { receivedSize, totalSize in
                    // Progress updated
                }, completionHandler: { result in
                    if let image = imageView1.image {
                        cell.img_contributor_1.image = image
                    }
                })
                
            } else {
                cell.img_contributor_1.image = UIImage(named: "no_image")!
            }
            
            let imageView2 = UIImageView()
            if let url = URL(string: tree.editors[1].avatarUrl) {
                
                
                imageView2.kf.setImage(with: url, placeholder: UIImage(named: "no_image"), options: [.cacheOriginalImage], progressBlock: { receivedSize, totalSize in
                    // Progress updated
                }, completionHandler: { result in
                    if let image = imageView2.image {
                        cell.img_contributor_2.image = image
                    }
                })
                
            } else {
                cell.img_contributor_2.image = UIImage(named: "no_image")!
            }
        }
        else if tree.editors.count == 2 {
            cell.img_contributor_1.isHidden = false
            cell.img_contributor_2.isHidden = false
            cell.lbl_moreContributors.isHidden = true
    
            if let url = URL(string: tree.editors[0].avatarUrl) {
                
                let imageView1 = UIImageView()
                imageView1.kf.setImage(with: url, placeholder: UIImage(named: "no_image"), options: [.cacheOriginalImage], progressBlock: { receivedSize, totalSize in
                    // Progress updated
                }, completionHandler: { result in
                    if let image = imageView1.image {
                        cell.img_contributor_1.image = image
                    }
                })
                
            } else {
                cell.img_contributor_1.image = UIImage(named: "no_image")!
            }
            
            let imageView2 = UIImageView()
            if let url = URL(string: tree.editors[1].avatarUrl) {
                
                
                imageView2.kf.setImage(with: url, placeholder: UIImage(named: "no_image"), options: [.cacheOriginalImage], progressBlock: { receivedSize, totalSize in
                    // Progress updated
                }, completionHandler: { result in
                    if let image = imageView2.image {
                        cell.img_contributor_2.image = image
                    }
                })
                
            } else {
                cell.img_contributor_2.image = UIImage(named: "no_image")!
            }
        }
        else if tree.editors.count == 1 {
            cell.img_contributor_1.isHidden = false
            cell.img_contributor_2.isHidden = true
            cell.lbl_moreContributors.isHidden = true
            
            let imageView = UIImageView()
            if let url = URL(string: tree.editors[0].avatarUrl) {
                
                
                imageView.kf.setImage(with: url, placeholder: UIImage(named: "no_image"), options: [.cacheOriginalImage], progressBlock: { receivedSize, totalSize in
                    // Progress updated
                }, completionHandler: { result in
                    if let image = imageView.image {
                        cell.img_contributor_1.image = image
                    }
                })
                
            } else {
                cell.img_contributor_1.image = UIImage(named: "no_image")!
            }
        }
        else {
            cell.img_contributor_1.isHidden = true
            cell.img_contributor_2.isHidden = true
            cell.lbl_moreContributors.isHidden = true
        }
        
        cell.pos = indexPath.row
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }
    
}

extension ListAllFamilyTreeViewController : UISearchBarDelegate {
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

extension ListAllFamilyTreeViewController : ListFamilyTreeDelegate {
    func editTree(pos: Int) {
        
    }
    
    func deleteTree(pos: Int) {
        
    }
    
    func editTreeDetail(pos: Int) {
        
    }
}



