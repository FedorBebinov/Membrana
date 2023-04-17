//
//  SceneVCService.swift
//  Membrana
//
//  Created by Fedor Bebinov on 16.04.23.
//

import Foundation

public class SceneVCService  {
    let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func getPendingConnection(completion: @escaping (Data?, Error?) -> Void) {
        guard let username = UserDefaults.standard.string(forKey: "username") else { return }
        
        var components = URLComponents(string: "http://localhost:3000/users")
        components?.queryItems = [URLQueryItem(name: "userName", value: username)]
        
        guard let url  = components?.url else { return }
        let headers = ["Content-Type" : "application/json"]
        
        networkManager.get(url: url, headers: headers) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    completion(data, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
        }
    }
    
    func updateSessionStatus(for username: String, connections: [String], completion: @escaping (Data?, Error?) -> Void) {
        let put = ["userName": username, "connections": connections] as [String: Any]
        let jsonData = try? JSONSerialization.data(withJSONObject: put, options: .prettyPrinted)
        let url = URL(string: "http://localhost:3000/updateSessionStatus")!
        let headers = ["Content-Type" : "application/json"]
        
        networkManager.put(url: url, body: jsonData, headers: headers) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    completion(data, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
        }
    }
}

