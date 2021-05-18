//
//  AddFamilyTreeViewController.swift
//  FamilyTree
//
//  Created by Gia Huy on 14/05/2021.
//

import UIKit
import Loaf

protocol AddFamilyTreeViewDelegate {
    func addTree(name:String, description:String)
}

class AddFamilyTreeViewController : UIViewController {
    
    
    @IBOutlet weak var txt_name:UITextField!
    @IBOutlet weak var txt_description:UITextField!
    @IBOutlet weak var view_top: UIView!
    
    var delegate:AddFamilyTreeViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view_top.roundCorners(corners: [.topLeft, .topRight], radius: 20)
    }
    
    @IBAction func btn_confirm(_ sender: Any) {
        
        if txt_name.text!.isEmpty {
            Loaf.init("Please enter name of tree!", state: .error, location: .bottom, presentingDirection: .left, dismissingDirection: .vertical, sender: self).show(.custom(2.5), completionHandler: nil)
        }
        else {
            delegate?.addTree(name: txt_name.text!, description: txt_description.text ?? "")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func btn_cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
