//
//  DeeplinkRegularExpression.swift
//  DeeplinkKit
//
//  Created by Denis Se. Popov on 6/14/21.
//

import Foundation

public final class DeeplinkRegularExpression: NSRegularExpression {
    
    
    // MARK: - Properties
    
    static let DPLNamedGroupComponentPattern = ":[a-zA-Z0-9-_]+[^/]*"
    static let DPLRouteParameterPattern = ":[a-zA-Z0-9-_]+"
    static let DPLURLParameterPattern = "([^/]+)"
    
    private let groupNames: [String]
    
    public override init(
        pattern: String,
        options: NSRegularExpression.Options = []
    ) throws {
        groupNames = DeeplinkRegularExpression.namedGroups(forString: pattern)
        let cleanedPattern = DeeplinkRegularExpression
            .removingNamedGroups(fromString: pattern)
        try super.init(pattern: cleanedPattern, options: options)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func matchResult(forString string: String) -> DeeplinkRegexMatchResult {
        let result = self.matches(
            in: string,
            options: .init(),
            range: NSRange(location: 0, length: string.count)
        )
        
        guard result.count > 0 else {
            return .init(isMatch: false, namedProperties: [:])
        }
        
        var routeParameters: [String: Any] = [:]
        
        result
            .dropFirst()
            .enumerated()
            .forEach { index, element in
                let name = groupNames[index]
                let value = NSString(string: string).substring(with: element.range(at: index))
                routeParameters[name] = value
            }
        return .init(isMatch: true, namedProperties: routeParameters)
    }
    
    
    // MARK: - Private
    
    static func namedGroupTokens(forString string: String) -> [String] {
        guard let componentRegex = try? NSRegularExpression(
            pattern: DPLNamedGroupComponentPattern,
            options: .init())
        else {
            return []
        }
        
        let matches = componentRegex.matches(
            in: string,
            options: .init(),
            range: NSRange(location: 0, length: string.count)
        )
        
        let group = matches.map {
            NSString(string: string).substring(with: $0.range)
        }
        return group
    }
    
    static func removingNamedGroups(fromString string: String) -> String {
        var modifiedStr = string
        let namedGroupExpressions = namedGroupTokens(forString: string)
        let parameterRegex = try? NSRegularExpression(
            pattern: DPLRouteParameterPattern,
            options: .init()
        )
        
        namedGroupExpressions.forEach { namedExpression in
            var replacementExpression = namedExpression
            let foundGroupNames = parameterRegex?.matches(
                in: namedExpression,
                options: .init(),
                range: NSRange(location: 0, length: namedExpression.count)
            )
            if let foundGroupName = foundGroupNames?.first {
                let stringToReplace = NSString(string: namedExpression)
                    .substring(with: foundGroupName.range)
                replacementExpression = replacementExpression
                    .replacingOccurrences(of: stringToReplace, with: "")
            }
            
            if replacementExpression.isEmpty {
                replacementExpression = DPLURLParameterPattern
            }
            
            modifiedStr = modifiedStr
                .replacingOccurrences(of: namedExpression, with: replacementExpression)
        }
        
        if !modifiedStr.isEmpty && !(modifiedStr.first == "/") {
            modifiedStr = "^\(modifiedStr)$"
        }
        
        return modifiedStr
    }
    
    static func namedGroups(forString string: String) -> [String] {
        var groupNames: [String] = []
        let namedGroupExpressions = namedGroupTokens(forString: string)
        let parameterRegex = try? NSRegularExpression(
            pattern: DPLRouteParameterPattern,
            options: .init()
        )
        
        namedGroupExpressions.forEach { namedExpression in
            let componentMatches = parameterRegex?.matches(
                in: namedExpression,
                options: .init(),
                range: NSRange(location: 0, length: namedExpression.count)
            )
            let foundGroupName = componentMatches?.first
            
            if let foundGroupName = foundGroupName {
                let stringToReplace = NSString(string: namedExpression)
                    .substring(with: foundGroupName.range)
                let variableName = stringToReplace.replacingOccurrences(of: ":", with: "")
                groupNames.append(variableName)
            }
            
        }
        
        return groupNames
    }
    
}
