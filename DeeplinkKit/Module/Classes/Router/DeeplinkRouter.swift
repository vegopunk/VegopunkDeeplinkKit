//
//  DeeplinkRouter.swift
//  DeeplinkKit
//
//  Created by Denis Se. Popov on 6/14/21.
//

import Foundation

public typealias RouteHandlerBlock = (Deeplink) -> Void
public typealias ApplicationCanHandleDeepLinksBlock = () -> Bool
public typealias RouteCompletionBlock = (_ handled: Bool, _ error: Error?) -> Void

public protocol Router {
    
    func register(_ handlerClass: RouteHandler.Type, forRoute route: String)
    func register(_ routeHandlerBlock: RouteHandlerBlock?, forRoute route: String)
    func register(_ route: String, routeHandlerBlock: RouteHandlerBlock?)
    
    func handle(url: URL?, animated: Bool, withCompletion completion: RouteCompletionBlock?) -> Bool
    func handle(userActivity: NSUserActivity, withCompletion completion: RouteCompletionBlock?) -> Bool
    func setApplicationCanHandleDeepLinksBlock(_ block: ApplicationCanHandleDeepLinksBlock?)
    
    subscript(key: String) -> Any? { get }
    
}


public final class DeeplinkRouter: Router {
    
    // MARK: - Properties
    
    public static let shared = DeeplinkRouter()
    
    public var routes: NSMutableOrderedSet
    public var classesByRoute: NSMutableDictionary
    public var blocksByRoute: NSMutableDictionary
    public var applicationCanHandleDeepLinksBlock: ApplicationCanHandleDeepLinksBlock?
    
    // MARK: - Lifecycle
    
    init() {
        routes = .init()
        classesByRoute = .init()
        blocksByRoute = .init()
    }
    
    // Configuration
    
    var applicationCanHandleDeeplinks: Bool {
        applicationCanHandleDeepLinksBlock?() ?? true
    }
    
    // MARK: - Registering Routes
    
    public func setApplicationCanHandleDeepLinksBlock(_ block: ApplicationCanHandleDeepLinksBlock?) {
        self.applicationCanHandleDeepLinksBlock = block
    }
    
    public func register(_ handlerClass: RouteHandler.Type, forRoute route: String) {
        
        guard !route.isEmpty else { return }
        routes.add(route)
        blocksByRoute.removeObject(forKey: route)
        classesByRoute[route] = handlerClass
    }
    
    public func register(_ routeHandlerBlock: ((Deeplink) -> Void)?, forRoute route: String) {
        guard
            let routeHandlerBlock = routeHandlerBlock, !route.isEmpty
        else {
            return
        }
        routes.add(route)
        classesByRoute.removeObject(forKey: route)
        blocksByRoute[route] = routeHandlerBlock
    }
    
    public func register(_ route: String, routeHandlerBlock: ((Deeplink) -> Void)?) {
        register(routeHandlerBlock, forRoute: route)
    }
    
    
    public func handle(url: URL?, animated: Bool = true, withCompletion completion: ((Bool, Error?) -> Void)?) -> Bool {
        
        guard
            let url = url
        else {
            return false
        }
        
        if !applicationCanHandleDeeplinks {
            completeRouteWithSuccess(false, error: nil, completionHandler: completion)
            return false
        }
        
        var error: Error?
        var deeplink: Deeplink?
        
        var isHandled = false
        
        for route in routes {
            guard let route = route as? String else { break }
            let matcher = DeeplinkRouteMatcher(route: route)
            deeplink = matcher.deeplink(withUrl: url)
            if let deeplink = deeplink {
                let result = try? handleRoute(route, withDeeplink: deeplink, animated: animated)
                isHandled = result ?? false
                if isHandled {
                    break
                }
            }
        }
        
        if deeplink == nil {
            let userInfo = [NSLocalizedDescriptionKey: "The passed URL does not match a registered route."]
            error = NSError(domain: "ErrorDomain", code: 0, userInfo: userInfo)
        }
        
        completeRouteWithSuccess(isHandled, error: error, completionHandler: completion)
        
        return isHandled
    }
    
    public func handle(userActivity: NSUserActivity, withCompletion completion: ((Bool, Error?) -> Void)?) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            return handle(url: userActivity.webpageURL, animated: false, withCompletion: completion)
        }
        return false
    }
    
    
    public subscript(key: String) -> Any? {
        guard
            !key.isEmpty
        else {
            return nil
        }
        return classesByRoute[key] ?? blocksByRoute[key]
    }
    
    // MARK: - Private
    
    private func handleRoute(_ route: String, withDeeplink deeplink: Deeplink, animated: Bool) throws -> Bool {
        guard let handler = self[route] else { return false }
        
        if let routeHandlerBlock = handler as? RouteHandlerBlock {
            routeHandlerBlock(deeplink)
        } else if
            let objType = handler as? NSObject.Type,
            let routeHandler = objType.init() as? RouteHandler {
            if !routeHandler.shouldHandle(deeplink) {
                return false
            }
            
            if
                let presentingViewController = routeHandler.viewController(forPresentingDeeplink: deeplink),
                let targetViewController = routeHandler.targetViewController {
                targetViewController.deeplink = deeplink
                targetViewController.configure(withDeeplink: deeplink)
                routeHandler.present(targetViewController, inViewController: presentingViewController, animated: animated)
            } else {
                let userInfo = [NSLocalizedDescriptionKey: "The matched route handler does not specify a target view controller."]
                let error = NSError(domain: "ErrorDomain", code: 0, userInfo: userInfo)
                throw error
            }
        }
        
        return true
    }
    
    private func completeRouteWithSuccess(_ handled: Bool, error: Error?, completionHandler: RouteCompletionBlock?) {
        if let completionHandler = completionHandler {
            DispatchQueue.main.async {
                completionHandler(handled, error)
            }
        }
    }
    
    
}
