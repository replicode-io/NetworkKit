//
//  File.swift
//  
//
//  Created by Robert Canton on 2021-04-05.
//


import Foundation
import Combine

protocol NetworkSession: AnyObject {
    func publisher<Response:Decodable>(_ method:HTTPMethod,
                                for url: URL,
                                body: Data?,
                                token: String?,
                                ofType type:Response.Type) -> AnyPublisher<Response, Error>
}

extension URLSession: NetworkSession {
    
    
    func publisher<Response:Decodable>(_ method:HTTPMethod = .GET,
                                                        for url: URL,
                                                        body:Data?=nil,
                                                        token:String?=nil,
                                                        ofType type:Response.Type) -> AnyPublisher<Response, Error> {
        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 60)
        
        //self.log(message: "\(method.rawValue) \(url.absoluteString)")
        request.httpMethod = method.rawValue
        
        if let token = token {
            request.addValue(token, forHTTPHeaderField: "Authorization")
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = body

        return dataTaskPublisher(for: request)
            //.receive(on: DispatchQueue.global(qos: .background))
            .subscribe(on: DispatchQueue.global())
            .tryMap({ result in
                guard let httpResponse = result.response as? HTTPURLResponse,
                      200...299 ~= httpResponse.statusCode else {
                    let error = try JSONDecoder().decode(ServiceError.self, from: result.data)
                    
                    throw error
                }
                
                return result.data
                
            }).decode(type: Response.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
  }
}
