//
//  DeeplinkTargetViewController.swift
//  DeeplinkKit
//
//  Created by Denis Se. Popov on 6/14/21.
//

import UIKit

public protocol DeeplinkTargetViewController: UIViewController {
    func configure(withDeeplink deeplink: Deeplink)
}

extension UIViewController {
    
    open override func isEqual(_ object: Any?) -> Bool {
        guard
            let deeplink = deeplink,
            let objectDeeplink = (object as? UIViewController)?.deeplink else {
            return super.isEqual(object)
        }
        return deeplink.isEqual(objectDeeplink)
    }
    
    private enum AssociatedKeys {
        static var deeplink = "DeeplinkAssociatedKey"
    }

    // MARK: - Properties

    var deeplink: Deeplink? {
        get {
            objc_getAssociatedObject(
                self,
                &AssociatedKeys.deeplink
            ) as? Deeplink
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.deeplink,
                newValue,
                .OBJC_ASSOCIATION_RETAIN
            )
        }
    }
}
