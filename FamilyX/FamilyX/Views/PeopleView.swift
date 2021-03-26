//
//  PeopleView.swift
//  FamilyX
//
//  Created by Gia Huy on 19/03/2021.
//

import UIKit

class PeopleView : UIView {
    
    @IBOutlet weak var img_avatar: UIImageView!
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_birthday: UILabel!
    @IBOutlet weak var lbl_phone: UILabel!
    @IBOutlet weak var constraint_height_avatar: NSLayoutConstraint!
    
 
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    


    private func setupView() {
        
        
        
    }
}
