//
//  AddPeopleViewController.swift
//  FamilyX
//
//  Created by Gia Huy on 20/03/2021.
//

import UIKit

protocol AddPeopleDelegate {
    func addPeople(name:String, birthday:String)
}

class AddPeopleViewController : UIViewController {

    @IBOutlet weak var textfield_name: UITextField!
    @IBOutlet weak var textfield_birthday: UITextField!
    
    var delegate:AddPeopleDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()


    }
    
    @IBAction func btn_close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btn_confirm(_ sender: Any) {
        delegate?.addPeople(name: textfield_name.text!, birthday: textfield_birthday.text!)
        self.dismiss(animated: true, completion: nil)
    }
}
