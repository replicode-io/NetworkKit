import Foundation

public struct Endpoint {
    public let host:Host
    public let path: String
    public var url:URL {
        return URL(string: "\(host.name)\(path)")!
    }
    
    public init(
        host: Host,
        path: String
    ) {
        self.host = host
        self.path = path
    }
}
