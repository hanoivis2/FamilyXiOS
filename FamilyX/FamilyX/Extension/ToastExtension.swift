//
//  ToastExtension.swift
//  Techres-Customer
//
//  Created by lê phú hảo on 5/20/20.
//  Copyright © 2020 aloapp. All rights reserved.
//

import Foundation
import UIKit

extension Toast {
    static func showDeveloping(controller: UIViewController) {
        self.show(message: "Chức năng sẽ có mặt ở phiên bản tiếp theo.", controller: controller)
    }
}
