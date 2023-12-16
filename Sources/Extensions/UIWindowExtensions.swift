//
//  UIWindow.swift
//  AppleInspiredPuller
//
//  Created by Fabian Hasse on 16.12.23.
//

import UIKit

extension UIWindow {
    
    // MARK: - Variables
    static var keyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
