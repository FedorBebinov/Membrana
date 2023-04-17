//
//  User.swift
//  Membrana
//
//  Created by Fedor Bebinov on 16.04.23.
//

import Foundation

struct User: Codable {
    let userName: String
    let isActive: Bool

    let isInSession: Bool
    let connections: [String]
    let drawingGestureType: Int
    let tapGestureLocation: [Double]
}

struct ErrorData: Decodable {
    let statusCode: Int
    let message: String
}
