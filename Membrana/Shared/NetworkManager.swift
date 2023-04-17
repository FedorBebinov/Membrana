//
//  NetworkManager.swift
//  Membrana
//
//  Created by Fedor Bebinov on 02.04.23.
//
import Foundation

class NetworkManager {
    
    typealias CompletionHandler = (Result<Data, Error>) -> Void
    
    enum ManagerErrors: Error {
        case invalidResponse
        case invalidStatusCode(Int)
    }
    
    enum HTTPMethod: String {
        case get
        case post
        case put
        case delete
        
        var value: String { rawValue.uppercased() }
    }
    
    private func makeRequest(url: URL, method: HTTPMethod = .get, body: Data?, headers: [String: String]? = nil, completion: @escaping CompletionHandler) {
        
        var request = URLRequest(url: url)
        request.httpMethod = method.value
        request.httpBody = body
        
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let urlResponse = response as? HTTPURLResponse else { return completion(.failure(ManagerErrors.invalidResponse)) }
            if !(200..<300).contains(urlResponse.statusCode) {
                return completion(.failure(ManagerErrors.invalidStatusCode(urlResponse.statusCode)))
            }
            
            guard response is HTTPURLResponse else { return completion(.failure(ManagerErrors.invalidResponse)) }
            
            if let data {
                completion(.success(data))
            }
        }
        
        task.resume()
    }
    
    func post(url: URL, body: Data?, headers: [String: String]? = nil, completion: @escaping CompletionHandler) {
        makeRequest(url: url, method: .post, body: body, headers: headers, completion: completion)
    }
    
    func put(url: URL, body: Data?, headers: [String: String]? = nil, completion: @escaping CompletionHandler) {
        makeRequest(url: url, method: .put, body: body, headers: headers, completion: completion)
    }
    
    func get(url: URL, headers: [String: String]? = nil, completion: @escaping CompletionHandler) {
        makeRequest(url: url, method: .get, body: nil, headers: headers, completion: completion)
    }
    
    func delete(url: URL, headers: [String: String]? = nil, completion: @escaping CompletionHandler) {
        makeRequest(url: url, method: .delete, body: nil, headers: headers, completion: completion)
    }
}
