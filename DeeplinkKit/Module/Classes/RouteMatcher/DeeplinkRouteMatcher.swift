//
//  DeeplinkRouteMatcher.swift
//  DeeplinkKit
//
//  Created by Denis Se. Popov on 6/14/21.
//

import Foundation

public final class DeeplinkRouteMatcher {
    
    public let route: String
    public let scheme: String?
    public let regexMatcher: DeeplinkRegularExpression?
    
    public init(route: String) {
        self.route = route
        
        let parts = route.components(separatedBy: "://")
        scheme = parts.count > 1 ? parts.first : nil
        regexMatcher = parts.last.flatMap { try? DeeplinkRegularExpression(pattern: $0) }
    }
    
    public func deeplink(withUrl url: URL) -> Deeplink? {
        let deeplink = DefaultDeeplink(url)
        let deeplinkString = String(
            format: "%@%@",
            deeplink.url.host ?? "",
            deeplink.url.path
        )
        if
            let scheme = scheme,
            !scheme.isEmpty,
            scheme != deeplink.url.scheme {
            return nil
        }
        
        let matchResult = regexMatcher?.matchResult(forString: deeplinkString)
        if matchResult?.isMatch == false {
            return nil
        }
        
        let routeParameters = matchResult?.namedProperties ?? [:]
        deeplink.setRouteParameters(routeParameters)
        
        return deeplink
    }
}
