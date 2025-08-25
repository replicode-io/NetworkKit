import Foundation
import Combine
import UIKit

public class NetworkKit:NSObject, URLSessionDelegate {
    
    static let shared = NetworkKit()
    private let session: URLSession
    var isLoggingEnabled: Bool = false
    
    private override init() {
        self.session = URLSession.shared
        super.init()
    }

    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
    public func requestAsync<Response:Decodable>(
         _ method: HTTPMethod = .GET,
         to endpoint: Endpoint,
         body: Data?=nil,
         ofType type: Response.Type,
         token:String?=nil
    ) async throws -> Response {
        let url = endpoint.url
        print("[NetworkManager] requestAsync: \(url.absoluteString)")
        var request = URLRequest(
           url: url,
           cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
           timeoutInterval: 60
        )
        request.httpMethod = method.rawValue
        if let authorization = await endpoint.host.authorization() {
            switch authorization {
            case .bearer(let token):
                #if DEBUG
                print("[NetworkManager] token: \(token)")
                #endif
                let bearerToken = "Bearer \(token)"
                request.addValue(bearerToken, forHTTPHeaderField: "Authorization")
                break
            case .xiAPIKey(let apiKey):
                request.addValue(apiKey, forHTTPHeaderField: "xi-api-key")
                break
            }
        }
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        let (data, _) = try await session.data(for: request)
        
        if isLoggingEnabled {
            if
                let serial = try JSONSerialization.jsonObject(with: data) as? [String:Any]
            {
                print("[NetworkManager] json response:")
                print(serial)
            }
        }
        let decoder = JSONDecoder()
        return try decoder.decode(Response.self, from: data)
    }
    
    public func requestDataAsync(
         _ method: HTTPMethod = .GET,
         to endpoint: Endpoint,
         body: Data?=nil,
         token:String?=nil
    ) async throws -> Data {
        let url = endpoint.url
        print("[NetworkManager] requestAsync: \(url.absoluteString)")
        var request = URLRequest(
           url: url,
           cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
           timeoutInterval: 60
        )
        request.httpMethod = method.rawValue
        if let authorization = await endpoint.host.authorization() {
            switch authorization {
            case .bearer(let token):
                let bearerToken = "Bearer \(token)"
                request.addValue(bearerToken, forHTTPHeaderField: "Authorization")
                break
            case .xiAPIKey(let apiKey):
                request.addValue(apiKey, forHTTPHeaderField: "xi-api-key")
                break
            }
        }
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        let (data, _) = try await session.data(for: request)
        return data
    }

}
