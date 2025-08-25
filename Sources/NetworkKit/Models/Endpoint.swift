import Foundation

public  struct Endpoint {
    let host:Host
    let path: String
    var url:URL {
        return URL(string: "\(host.name)\(path)")!
    }
}
