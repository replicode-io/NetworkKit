import Foundation

public struct Endpoint {
    let host:Host
    let path: String
    var url:URL {
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
