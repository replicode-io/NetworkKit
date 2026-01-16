import Foundation
import Combine
import UIKit

public class NetworkKit:NSObject, URLSessionDelegate {
    
    public static let shared = NetworkKit()
    public var isLoggingEnabled: Bool = false
    private let session: URLSession
    private var userAgent:UserAgent?
    
    private override init() {
        self.session = URLSession.shared
        super.init()
    }
    
    func loadUserAgent() async -> UserAgent? {
        if let userAgent = userAgent {
            return userAgent
        } else if
            let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String,
            let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        {
            let deviceModel = await UIDevice.current.model
            let systemName = await UIDevice.current.systemName
            let systemVersion = await UIDevice.current.systemVersion
            let screenScale = await UIScreen.main.scale
            let formattedScale = String(format: "%.2f", screenScale)

            self.userAgent = .init(
                appName: appName,
                appVersion: version,
                deviceModel: deviceModel,
                systemName: systemName,
                systemVersion: systemVersion,
                screenScale: screenScale,
                formattedScale: formattedScale
            )
            return self.userAgent
        }
        return nil
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
        if isLoggingEnabled {
            print("[NetworkManager] requestAsync: \(url.absoluteString)")
        }
        var request = URLRequest(
           url: url,
           cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
           timeoutInterval: 60
        )
        request.httpMethod = method.rawValue
        if let authorization = await endpoint.host.authorization() {
            switch authorization {
            case .bearer(let token):
                if isLoggingEnabled {
                    print("[NetworkManager] token: \(token)")
                }
                let bearerToken = "Bearer \(token)"
                request.addValue(bearerToken, forHTTPHeaderField: "Authorization")
                break
            case .apiKey(let apiKey):
                request.addValue(apiKey, forHTTPHeaderField: "xi-api-key")
                break
            }
        }
        if let userAgent = await self.loadUserAgent() {
            request.addValue(
                userAgent.value,
                forHTTPHeaderField: "User-Agent"
            )
            request.addValue(
                userAgent.appName,
                forHTTPHeaderField: "X-App-Name"
            )
            request.addValue(
                userAgent.appVersion,
                forHTTPHeaderField: "X-App-Version"
            )
            request.addValue(
                "iOS",
                forHTTPHeaderField: "X-Platform"
            )
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
        let decoder = JSONDecoder.iso8601WithFractionalSeconds
        return try decoder.decode(Response.self, from: data)
    }
    
    public func requestDataAsync(
         _ method: HTTPMethod = .GET,
         to endpoint: Endpoint,
         body: Data?=nil,
         token:String?=nil
    ) async throws -> Data {
        let url = endpoint.url
        if isLoggingEnabled {
            print("[NetworkManager] requestAsync: \(url.absoluteString)")
        }
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
            case .apiKey(let apiKey):
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

extension JSONDecoder {
    static let iso8601WithFractionalSeconds: JSONDecoder = {
        let decoder = JSONDecoder()

        let withFrac = ISO8601DateFormatter()
        withFrac.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let noFrac = ISO8601DateFormatter()
        noFrac.formatOptions = [.withInternetDateTime]

        decoder.dateDecodingStrategy = .custom { d in
            let container = try d.singleValueContainer()
            let s = try container.decode(String.self)
            if let date = withFrac.date(from: s) { return date }
            if let date = noFrac.date(from: s) { return date } // nice fallback
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid ISO8601 date: \(s)"
            )
        }
        return decoder
    }()
}
