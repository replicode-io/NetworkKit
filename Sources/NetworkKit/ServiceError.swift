//
//  ServiceError.swift
//  
//
//  Created by Robert Canton on 2021-04-05.
//

import Foundation

struct ServiceError: Decodable, Error {
    let statusCode:Int
}
