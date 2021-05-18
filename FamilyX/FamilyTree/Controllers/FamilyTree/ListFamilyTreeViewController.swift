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
    
    var trees = [FamilyTree]()
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.setHidesBackButton(true, animated: false)
        tbl_trees.separatorStyle = .none
        getTreeList()
        
        setupRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //custom navigation bar
        let navigationControllerCustom : NavigationControllerCustom = self.navigationController as! NavigationControllerCustom
        navigationControllerCustom.setUpNavigationBar(self, hideBackButton: false, hideAddButton: false, title: "FAMILY TREES LIST")
        navigationControllerCustom.touchTarget = self
        navigationControllerCustom.navigationBar.barTintColor = ColorUtils.toolbar()
        navigationControllerCustom.navigationBar.isHidden = false
        
    }
    
    func backTap() {
        navigationController?.popViewController(animated: true)
    }
    
    func addTap() {
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
    
    func getTreeList(){
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Please wait..."
        hud.show(in: self.view)
        
        ResAPI.sharedInstance.getListFamilyTree({ (data, Message) -> Void in
            if(data != nil){

                let response:ResResponse = data as! ResResponse

                if response.data != nil {
                    self.trees = Mapper<FamilyTree>().mapArray(JSONObject: response.data) ?? [FamilyTree]()
                    
                    self.tbl_trees.reloadData()
                    self.refreshControl.endRefreshing()
                }
                else {
                    Loaf.init(response.message ?? "", state: .info, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
                }
                
                
            }else{
                Loaf.init(SERVER_ERROR, state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
            }
            
            hud.dismiss()
        })
    }
    
    func addTree(name:String, des:String){
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Please wait..."
        hud.show(in: self.view)
        
        ResAPI.sharedInstance.addFamilyTree(name: name, description: des, { (data, Message) -> Void in
            if(data != nil){

                let response:ResResponse = data as! ResResponse

                if response.data != nil {
                    let newTree = Mapper<FamilyTree>().map(JSONObject: response.data) ?? FamilyTree()
                    
                    self.trees.append(newTree)
                    self.tbl_trees.reloadData()
                    self.tbl_trees.scrollToRow(at: IndexPath(row: self.trees.count - 1, section: 0), at: .bottom, animated: true)
                    
                }
                else {
                    Loaf.init(response.message ?? "", state: .info, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
                }
                
                
            }else{
                Loaf.init(SERVER_ERROR, state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
            }
            
            hud.dismiss()
        })
    }
    
}

extension ListFamilyTreeViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trees.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListFamilyTreeTableViewCell") as! ListFamilyTreeTableViewCell
        
        let tree = trees[indexPath.row]
        
        cell.lbl_name.text = tree.name
        cell.lbl_description.text = tree.description
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let editFamilyTreeViewController:EditFamilyTreeViewController?
        editFamilyTreeViewController = UIStoryboard.editFamilyTreeViewController()
        editFamilyTreeViewController?.treeId = trees[indexPath.row].id
        navigationController?.pushViewController(editFamilyTreeViewController!, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension ListFamilyTreeViewController : AddFamilyTreeViewDelegate {
    func addTree(name: String, description: String) {
        addTree(name: name, des: description)
    }
}

class ListFamilyTreeTableViewCell : UITableViewCell {
    
    @IBOutlet weak var lbl_name:UILabel!
    @IBOutlet weak var lbl_description:UILabel!
    @IBOutlet weak var img_avatar:UIImageView!
    
}
