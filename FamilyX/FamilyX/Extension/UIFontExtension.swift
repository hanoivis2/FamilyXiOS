//
//  UIFontExtension.swift
//  CungMua
//
//  Created by Hieu Nguyen Thi Trung on 6/22/15.
//  Copyright (c) 2015 Kelvin. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    
    class func fontDefaultBoldSize(_ size: CGFloat) -> UIFont{
        return UIFont(name: "OPENSANS-BOLD", size: size)!
    }
    
    class func fontDefaultBoldItalicSize(_ size: CGFloat) -> UIFont{
        return UIFont(name: "OPENSANS-BOLDITALIC", size: size)!
    }
    
    class func fontDefaultExtraBoldSize(_ size: CGFloat) -> UIFont{
        return UIFont(name: "OPENSANS-EXTRABOLD", size: size)!
    }
    
    class func fontDefaultExtraBoldItalicSize(_ size: CGFloat) -> UIFont{
        return UIFont(name: "OPENSANS-EXTRABOLDITALIC", size: size)!
    }
    
    class func fontDefaultItalicSize(_ size: CGFloat) -> UIFont{
        return UIFont(name: "OPENSANS-ITALIC", size: size)!
    }
    
    class func fontDefaultLightSize(_ size: CGFloat) -> UIFont{
//        return UIFont(name: "OPENSANS-LIGHT", size: size)!
//        return UIFont(name: "Roboto-Light", size: size)!
        return UIFont()
    }
    
    class func fontDefaultRegularSize(_ size: CGFloat) -> UIFont{
//         return UIFont(name: "Roboto-Light", size: size)!
        return UIFont()
    }
    
    class func fontDefaultSemiBoldSize(_ size: CGFloat) -> UIFont{
        return UIFont(name: "Helvetica-Bold", size: size)!
    }
    
    class func fontDefaultSemiBoldItalicSize(_ size: CGFloat) -> UIFont{
        return UIFont(name: "OPENSANS-SEMIBOLDITALIC", size: size)!
    }
    class func sizeOfString (_ string: String, constrainedToWidth width: CGFloat) -> CGFloat {
        if let ns_str:NSString = string as NSString? {
            return ns_str.boundingRect(
                with: CGSize(width: width, height: CGFloat.infinity),
                options: NSStringDrawingOptions.usesLineFragmentOrigin,
                attributes: [NSAttributedString.Key.font: UIFont.fontDefaultRegularSize(15)],
                context: nil).size.height
        }
        return 0
    }
    
}
