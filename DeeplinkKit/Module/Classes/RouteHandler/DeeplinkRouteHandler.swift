//
//  DeeplinkRouteHandler.swift
//  DeeplinkKit
//
//  Created by Denis Se. Popov on 6/14/21.
//

import UIKit

open class DeeplinkRouteHandler: NSObject, RouteHandler {
    
    open var preferModalPresentation: Bool {
        false
    }
    
    open var targetViewController: DeeplinkTargetViewController? {
        nil
    }
    
    open func shouldHandle(_ deeplink: Deeplink) -> Bool {
        true
    }
    
    public func viewController(forPresentingDeeplink deeplink: Deeplink) -> UIViewController? {
        let window = UIApplication
            .shared
            .windows
            .first(where: \.isKeyWindow)
        
        let rootViewController = window?.rootViewController
        return rootViewController
    }
    
    public func present(
        _ targetViewController: DeeplinkTargetViewController,
        inViewController presentingViewController: UIViewController,
        animated: Bool = false
    ) {
        if
            let tabBarController = presentingViewController as? UITabBarController,
            let selectedViewController = tabBarController.selectedViewController {
            present(
                targetViewController,
                inViewController: selectedViewController,
                animated: animated
            )
            return
        }
        if preferModalPresentation || !presentingViewController.isKind(of: UINavigationController.self) {
            presentingViewController.present(targetViewController, animated: animated)
        } else if let navController = presentingViewController as? UINavigationController {
            navController.placeTargetViewController(targetViewController, animated: animated)
        }
    }
    
    
}
