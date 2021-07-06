//
//  ColorUtils.swift
//  Scanner App
//
//  Created by Gia Huy on 29/11/2020.
//

import Foundation
import UIKit

class ColorUtils{
    
    static func toolbar()->UIColor{
        return UIColor(hexString: "#163868")
    }
    
    static func main_color()->UIColor{
        return UIColor(hexString: "#163868")
    }
    
    static func male_color()->UIColor{
        return UIColor(hexString: "#BEDAF2")
    }
    
    static func female_color()->UIColor{
        return UIColor(hexString: "#ECBBD9")
    }

}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}
