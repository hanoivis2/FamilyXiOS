//
//  DateExtension.swift
//  Techres-Customer
//
//  Created by lê phú hảo on 4/8/20.
//  Copyright © 2020 aloapp. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    func timeAgoDisplay() -> String {
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        let year = 12 * month
        
        let secondAgo = Int(Date().timeIntervalSince(self))
        //if less than 60 second -> seccond
        if(secondAgo < minute) {
            return "Vừa xong"
        }
        //if less than 60*60(60 minutes)  -> seccond
        else if (secondAgo < hour) {
            return "\(secondAgo / minute) phút trước"
        }
        //if less than 60*60*24(24 hours)  -> hour
        else if (secondAgo < day) {
            return "\(secondAgo / hour) giờ trước"
        }
        //if less than 60*60*24*7(7 day)  -> day
        else if (secondAgo < week) {
            return "\(secondAgo / day) ngày trước"
        }
        //if less than 60*60*24*7(7 day)  -> day
        else if (secondAgo < month) {
            return "\(secondAgo / week) tuần trước"
        }
        else if (secondAgo < year) {
            return "\(secondAgo / month) tháng trước"
        }
        //week
        return "\(secondAgo / year) năm trước"
    }
}
