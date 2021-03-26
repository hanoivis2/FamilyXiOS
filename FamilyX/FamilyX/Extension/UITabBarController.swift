//
//  UITabBarController.swift
//  Techres-Customer
//
//  Created by lê phú hảo on 5/5/20.
//  Copyright © 2020 aloapp. All rights reserved.
//

import Foundation
import UIKit

extension UITabBarController {
    func orderedTabBarItemViews() -> [UIView] {
        let interactionViews = tabBar.subviews.filter({$0.isUserInteractionEnabled})
    return interactionViews.sorted(by: {$0.frame.minX < $1.frame.minX})
    }
}
