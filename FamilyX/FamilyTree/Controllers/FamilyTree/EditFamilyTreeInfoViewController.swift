//
//  EditFamilyTreeInfoViewController.swift
//  FamilyTree
//
//  Created by Gia Huy on 31/05/2021.
//

import UIKit
import Loaf

protocol EditFamilyTreeInfoViewDelegate {
    func editTreeInfo(id:Int, name:String, description:String)
}

class EditFamilyTreeInfoViewController : UIViewController {
    
    
    @IBOutlet weak var txt_name:UITextField!
    @IBOutlet weak var txt_description:UITextField!
    @IBOutlet weak var view_top: UIView!
    
    var delegate:EditFamilyTreeInfoViewDelegate?
    var treeInfo = FamilyTree()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view_top.roundCorners(corners: [.topLeft, .topRight], radius: 20)
        
        txt_name.text = treeInfo.name
        txt_description.text = treeInfo.description
    }
    
    @IBAction func btn_confirm(_ sender: Any) {
        
        if txt_name.text!.isEmpty {
            Loaf.init("Please enter name of tree!", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
        }
        else {
            delegate?.editTreeInfo(id:treeInfo.id, name: txt_name.text!, description: txt_description.text ?? "")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func btn_cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

