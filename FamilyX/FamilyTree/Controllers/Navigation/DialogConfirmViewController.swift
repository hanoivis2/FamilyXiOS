//
//  DialogConfirmViewController.swift
//  Scanner App
//
//  Created by Gia Huy on 10/12/2020.
//

import UIKit

protocol DialogConfirmDelegate {
    func accept()
    func deny()
}

class DialogConfirmViewController : UIViewController {
    
    @IBOutlet weak var lbl_title:UILabel!
    @IBOutlet weak var lbl_content:UILabel!
    @IBOutlet weak var view_top: UIView!
    
    var delegate:DialogConfirmDelegate?
    var dialogTitle = ""
    var content = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbl_title.text = dialogTitle
        lbl_content.text = content
        
        view_top.roundCorners(corners: [.topLeft, .topRight], radius: 20)
    }
    
    @IBAction func accept(_ sender:Any) {
        delegate?.accept()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deny(_ sender:Any) {
        delegate?.deny()
        self.dismiss(animated: true, completion: nil)
    }
}
