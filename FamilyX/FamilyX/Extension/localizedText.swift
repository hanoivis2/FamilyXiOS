//
//  localizedText.swift
//  Aloapp_FrameSelfie
//
//  Created by Tuan Nguyen on 2/1/16.
//  Copyright © 2016 Kelvin. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    
    var localizedText: String {
        set (key) {
            text = NSLocalizedString(key, comment: "")
        }
        get {
            return text!
        }
    }
    
}
//extension String {
//    var localized: String {
//        return NSLocalizedString(self, comment:"")
//    }
//}
extension String {
    func  localizeds(_ lang:String) ->String {
        
        let path = Bundle.main.path(forResource: lang.lowercased(), ofType: "lproj")
        let bundle = Bundle(path: path!)
        
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
}

public extension UIView {
    
    /**
     Fade in a view with a duration
     
     - parameter duration: custom animation duration
     */
    func fadeIn(duration: TimeInterval = 1.0) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1.0
        })
    }
    
    /**
     Fade out a view with a duration
     
     - parameter duration: custom animation duration
     */
    func fadeOut(duration: TimeInterval = 1.0) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0.0
        })
    }
    
}


extension UIButton {
    var localizedTitleForNormal: String {
        set (key) {
            setTitle(NSLocalizedString(key, comment: ""), for: UIControl.State())
        }
        get {
            return title(for: UIControl.State())!
        }
    }
    
    var localizedTitleForHighlighted: String {
        set (key) {
            setTitle(NSLocalizedString(key, comment: ""), for: .highlighted)
        }
        get {
            return title(for: .highlighted)!
        }
    }
}
