//
//  Alerts.swift
//  Sizzle
//
//  Created by Joshua Fredrickson on 11/29/17.
//  Copyright © 2017 Joshua Fredrickson. All rights reserved.
//

import Foundation
import UIKit

// allows you to get the topmost view at any current time
extension UIApplication {
    
    static func topViewController(base: UIViewController? = UIApplication.shared.delegate?.window??.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        
        return base
    }
}
// reqeust a permission
func requestPermissionAlert(title: String, message: String?, from: UIViewController?, handler: @escaping (Bool)->Void) {
    
    // Create the Alert Controller
    let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    
    // add the button actions - Left to right
    // Cancel Button
    alertController.addAction(UIAlertAction(title: "No Thanks", style: UIAlertActionStyle.default, handler: { (action) in
        handler(false)
    }))
    // OK Button
    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
        handler(true)
    }))
    
    // Present the Alert
    (from ?? UIApplication.topViewController()!).present(alertController, animated: true, completion: nil)
}

// send user a message
func messageAlert(title: String, message: String?, from: UIViewController?) {
    
    // Create the Alert Controller
    let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    // add the button actions - Left to right
    //    OK Button
    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
    
    // Present the Alert
    
    (from ?? UIApplication.topViewController()!).present(alertController, animated: true, completion: nil)
}

// send user an error message
func errorAlert(message: String?, from: UIViewController?) {
    // Create the Alert Controller
    let alertController = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
    // add the button actions - Left to right
    //    OK Button
    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
    
    // Present the Alert
    (from ?? UIApplication.topViewController()!).present(alertController, animated: true, completion: nil)
}

// send user an error message
func fatalErrorAlert(message: String?, from: UIViewController?) {
    // Create the Alert Controller
    let alertController = UIAlertController(title: "Fatal Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
    // add the button actions - Left to right
    //    OK Button
    let crashAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (alertAction) in
        fatalError(message!)
    }
    alertController.addAction(crashAction)
    
    // Present the Alert
    (from ?? UIApplication.topViewController()!).present(alertController, animated: true, completion: nil)
}
