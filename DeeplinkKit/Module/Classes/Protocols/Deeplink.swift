public protocol Deeplink: AnyObject, Applink {
    var url: URL { get }
    var queryParameters: [String: Any] { get }
    var routeParameters: [String: Any] { get }
    var callbackUrl: URL? { get }
    subscript(key: String) -> Any? { get }
    func isEqual(_ deeplink: Deeplink) -> Bool
}
