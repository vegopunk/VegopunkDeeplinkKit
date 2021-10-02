//
//  Applink.swift
//  DeeplinkKit
//
//  Created by Denis Se. Popov on 6/14/21.
//

import Foundation

public protocol Applink {
    var appLinkData: [String: Any]? { get }
    var targetUrl: URL? { get }
    var extras: [String: Any]? { get }
    var version: String? { get }
    var userAgent: String? { get }
    
    var referrerTargetURL: URL? { get }
    var referrerURL: URL? { get }
    var referrerAppName: String? { get }
}
