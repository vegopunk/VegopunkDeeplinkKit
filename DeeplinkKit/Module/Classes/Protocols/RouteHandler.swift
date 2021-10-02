//
//  RouteHandler.swift
//  DeeplinkKit
//
//  Created by Denis Se. Popov on 6/14/21.
//

import UIKit

public protocol RouteHandler: NSObject {
    var preferModalPresentation: Bool { get }
    var targetViewController: DeeplinkTargetViewController? { get }
    func shouldHandle(_ deeplink: Deeplink) -> Bool
    func viewController(forPresentingDeeplink deeplink: Deeplink) -> UIViewController?
    func present(_ targetViewController: DeeplinkTargetViewController, inViewController presentingViewController: UIViewController, animated: Bool)
}
