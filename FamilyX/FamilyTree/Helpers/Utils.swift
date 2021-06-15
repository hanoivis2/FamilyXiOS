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
            
            
            imageView.kf.setImage(with: url, placeholder: UIImage(named: "no_image"), options: [.cacheOriginalImage], progressBlock: { receivedSize, totalSize in
                // Progress updated
            }, completionHandler: { result in
                if let image = imageView.image {
                    resultImage = image
                }
            })
            
        } else {
            return UIImage(named: "no_image")!
        }
        
        return resultImage
    }
    
    
    static func bestImageDataForUpload(data:Data, item:UIImage) -> Data {
        
        var imageData = data
        
        if imageData.count > maxSizeInBytesUploadImage {
            
            let ratio = item.size.width / item.size.height
            
            if ratio > 1 {
                
                if (_maxImageUploadBigSize / ratio) <= _maxImageUpLoadSmallSize {
                    imageData = (item.resized(to: CGSize(width: _maxImageUploadBigSize, height: _maxImageUploadBigSize / ratio))?.pngData())!
                }
                else {
                    imageData = (item.resized(to: CGSize(width: _maxImageUpLoadSmallSize*ratio, height: _maxImageUpLoadSmallSize))?.pngData())!
                }
                
            }
            else {
                if (_maxImageUploadBigSize * ratio) <= _maxImageUpLoadSmallSize {
                    imageData = (item.resized(to: CGSize(width: _maxImageUploadBigSize*ratio, height: _maxImageUploadBigSize))?.pngData())!
                }
                else {
                    imageData = (item.resized(to: CGSize(width: _maxImageUpLoadSmallSize, height: _maxImageUpLoadSmallSize / ratio))?.pngData())!
                }
            }
            
        }
        
        return imageData
    }
}
