//
//  Utils.swift
//  Scanner App
//
//  Created by Gia Huy on 01/12/2020.
//

import UIKit
import Foundation

class Utils: NSObject {
    
    static func avatarAndReplaceWithLogo(avatar:String) -> UIImage {
        let imageView = UIImageView()
        var resultImage = UIImage(named: "male")!
        if let url = URL(string: avatar) {
            
            
            imageView.kf.setImage(with: url, placeholder: UIImage(named: "male"), options: [.cacheOriginalImage], progressBlock: { receivedSize, totalSize in
                // Progress updated
            }, completionHandler: { result in
                if let image = imageView.image {
                    resultImage = image
                }
            })
            
        } else {
            return UIImage(named: "male")!
        }
        
        return resultImage
    }
}
