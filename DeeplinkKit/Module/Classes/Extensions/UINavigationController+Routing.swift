//
//  UINavigationController+Routing.swift
//  DeeplinkKit
//
//  Created by Denis Se. Popov on 6/14/21.
//

import UIKit

extension UINavigationController {
    
    public func placeTargetViewController(
        _ targetViewController: UIViewController,
        animated: Bool = false
    ) {
        if let sameController = viewControllers.first(where: { $0.isEqual(targetViewController) }) {
            popToViewController(sameController, animated: animated)
//            popViewController(animated: animated)
//            if sameController.isEqual(topViewController) {
//                setViewControllers([targetViewController], animated: animated)
//            }
        } else {
            pushViewController(targetViewController, animated: animated)
        }
//        if viewControllers.contains(targetViewController) {
//            popToViewController(targetViewController, animated: false)
//        } else {
//            for controller in viewControllers {
//
//                if controller.isEqual(targetViewController) {
//                    popToViewController(controller, animated: false)
//                    popViewController(animated: false)
//                    if controller.isEqual(self.topViewController) {
//                        setViewControllers([targetViewController], animated: false)
//                    }
//                }
//                break
//            }
//        }
        
//        if topViewController?.isEqual(targetViewController) == false {
//            pushViewController(targetViewController, animated: animated)
//        }
            
    }
}
