//
//  CustomActionTableViewCell.swift
//  FamilyX
//
//  Created by Gia Huy on 06/04/2021.
//

import UIKit

class CustomActionTableViewCell : UITableViewCell {
    
    @IBOutlet weak var img_icon:UIImageView!
    @IBOutlet weak var lbl_action:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
