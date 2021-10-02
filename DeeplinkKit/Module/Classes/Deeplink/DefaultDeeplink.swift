//
//  Deeplink.swift
//  DeeplinkKit
//
//  Created by Denis Se. Popov on 6/14/21.
//

import Foundation

public final class DefaultDeeplink: Deeplink {
    
    // MARK: - Properties
    
    public let deeplinkErrorDomain = "deeplink.error"
    public let deeplinkCallbackUrlKey = "callback.url"
    public let deeplinkJSONEncodedFieldNamesKey = "json.encoded.fields"
    
    public let DPLAppLinksDataKey = "al_applink_data"
    public let DPLAppLinksTargetURLKey = "target_url"
    public let DPLAppLinksExtrasKey = "extras"
    public let DPLAppLinksVersionKey = "version"
    public let DPLAppLinksUserAgentKey = "user_agent"
    public let DPLAppLinksReferrerAppLinkKey = "referer_app_link"
    public let DPLAppLinksReferrerTargetURLKey = "target_url"
    public let DPLAppLinksReferrerURLKey = "url"
    public let DPLAppLinksReferrerAppNameKey = "app_name"
    
    public let url: URL
    public let queryParameters: [String : Any]
    
    public var _routeParameters: [String: Any] = [:]
    public var routeParameters: [String : Any] {
        _routeParameters
    }
    
    public var callbackUrl: URL? {
        guard
            let urlString = queryParameters[deeplinkCallbackUrlKey] as? String
        else {
            return nil
        }
        return URL(string: urlString)
    }
    
    public var hash: Int {
        url.hashValue
    }
    
    public var description: String {
        let components = [
            "\n\(self)\n",
            "\n URL: \(url)\n",
            "\n queryParameters: \(queryParameters)\n",
            "\n routeParameters: \(routeParameters)\n",
            "\n callbackUrl: \(String(describing: callbackUrl))\n"
        ]
        return components.joined()
    }
    
    public init(_ url: URL) {
        self.url = url
        self.queryParameters = url.query?.parametersFromQueryString ?? [:]
        
    }
    
    public subscript(key: String) -> Any? {
        let value = routeParameters[key]
        if value == nil {
            return queryParameters[key]
        }
        return value
    }
    
    
    // MARK: - Public
    
    public func setRouteParameters(_ dictionary: [String: Any]) {
        _routeParameters = dictionary
    }
    
    public func isEqual(_ deeplink: Deeplink) -> Bool {
        self.url == deeplink.url
    }
}

// MARK: - Applink

extension DefaultDeeplink {
    public var appLinkData: [String : Any]? {
        queryParameters[DPLAppLinksDataKey] as? [String : Any]
    }
    
    public var targetUrl: URL? {
        guard
            let data = appLinkData?[DPLAppLinksTargetURLKey] as? String
        else {
            return nil
        }
        return URL(string: data)
    }
    
    public var extras: [String : Any]? {
        appLinkData?[DPLAppLinksExtrasKey] as? [String : Any]
    }
    
    public var version: String? {
        appLinkData?[DPLAppLinksVersionKey] as? String
    }
    
    public var userAgent: String? {
        appLinkData?[DPLAppLinksUserAgentKey] as? String
    }
    
    public var referrerTargetURL: URL? {
        guard
            let data = appLinkData?[DPLAppLinksReferrerTargetURLKey] as? String
        else {
            return nil
        }
        return URL(string: data)
    }
    
    public var referrerURL: URL? {
        guard
            let data = appLinkData?[DPLAppLinksReferrerURLKey] as? String
        else {
            return nil
        }
        return URL(string: data)
    }
    
    public var referrerAppName: String? {
        appLinkData?[DPLAppLinksReferrerAppNameKey] as? String
    }
}
