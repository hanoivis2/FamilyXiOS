//
//  PeopleView.swift
//  FamilyX
//
//  Created by Gia Huy on 19/03/2021.
//

import UIKit

protocol PeopleViewDelegate {
    func nodeTapped(people:People, sourceView:UIView)
}

class PeopleView : UIView {
    
    @IBOutlet weak var img_avatar: UIImageView!
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_birthday: UILabel!
    @IBOutlet weak var lbl_username: UILabel!
    @IBOutlet weak var constraint_height_avatar: NSLayoutConstraint!
    @IBOutlet weak var constraint_avatar_to_top: NSLayoutConstraint!
    
    var people = People()
    
    var delegate:PeopleViewDelegate?
 
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }

    


    func setupView() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.addGestureRecognizer(tapGesture)
    
        if people.connectedUser.id != "" {
            lbl_username.isHidden = false
            lbl_username.text = people.connectedUser.usernameConnectedUser
            constraint_avatar_to_top.constant = 12
        }
        else {
            lbl_username.isHidden = true
            constraint_avatar_to_top.constant = 4
        }
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        delegate?.nodeTapped(people: people, sourceView: self)
    }
    
    
}
