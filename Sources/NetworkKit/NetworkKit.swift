import Foundation
import Combine

public struct NetworkKit {
    
    static var session: NetworkSession = URLSession.shared
    
    static var authToken:String? {
        didSet {
            print("\n\n\(authToken ?? "No Token")\n\n")
        }
    }
    
    
    public static func configure(session:URLSession) {
        self.session = session
    }
    
    public static func setAuthToken(_ token:String) {
        self.authToken = token
    }
    
    public static func request<Response:Decodable>(_ method:HTTPMethod = .GET,
                                     url:URL,
                                     body: Data?=nil,       
                                     ofType type:Response.Type) -> AnyPublisher<Response, Error> {
        return self.session.publisher(method, for: url, body: body, token: self.authToken, ofType: type)
    }
        
}
