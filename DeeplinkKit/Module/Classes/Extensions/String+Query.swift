//
//  String+Query.swift
//  DeeplinkKit
//
//  Created by Denis Se. Popov on 6/14/21.
//

import Foundation

extension String {
    var parametersFromQueryString: [String: Any] {
        let params = components(separatedBy: "&")
        var paramsDict: [String: Any] = [:]
        
        params.forEach { param in
            let pairs = param.components(separatedBy: "=")
            if
                pairs.count == 2,
                let key = pairs[0].removingPercentEncoding,
                let value = pairs[1].removingPercentEncoding {
                paramsDict[key] = value
            } else if
                pairs.count == 1,
                let key = pairs[0].removingPercentEncoding {
                paramsDict[key] = ""
            }
        }
        return paramsDict
    }
    
}
