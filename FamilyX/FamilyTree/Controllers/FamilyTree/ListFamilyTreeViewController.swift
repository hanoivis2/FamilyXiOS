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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.setHidesBackButton(true, animated: false)
        
//        getTreeList()
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
        
    }
    
    func getTreeList(){
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Please wait..."
        hud.show(in: self.view)
        
        ResAPI.sharedInstance.getListFamilyTree({ (data, Message) -> Void in
            if(data != nil){
                
//                Loaf.init(response.message ?? "", state: .info, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
                
                self.trees = Mapper<FamilyTree>().mapArray(JSONObject: data) ?? [FamilyTree]()
                
                self.tbl_trees.reloadData()
                
                
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
        return 60
    }
    
}

class ListFamilyTreeTableViewCell : UITableViewCell {
    
    @IBOutlet weak var lbl_name:UILabel!
    @IBOutlet weak var lbl_description:UILabel!
    @IBOutlet weak var img_avatar:UIImageView!
    
}
