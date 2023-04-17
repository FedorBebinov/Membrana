//
//  MainVCService.swift
//  Membrana
//
//  Created by Fedor Bebinov on 03.04.23.
//

import Foundation

class MainVCService {
    let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func getUserData(completion: @escaping (Data?, Error?) -> Void) {
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
    
    func sendData(username: String,
                  connections: [String],
                  drawingGestureType: Int,
                  tapGestureLocation: [CGFloat]? = nil,
                  completion: @escaping (Data?, Error?) -> Void ) {
        
        let post = ["userName": username,
                    "connections": connections,
                    "drawingGestureType": drawingGestureType,
                    "tapGestureLocation": tapGestureLocation ?? []] as [String : Any]
        let jsonData = try? JSONSerialization.data(withJSONObject: post, options: .prettyPrinted)
        let url = URL(string: "http://localhost:3000/sendData")!
        let headers = ["Content-Type" : "application/json"]
        
        networkManager.post(url: url, body: jsonData, headers: headers) { result in
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
    
    func logoutUserNameMain(username: String, completion: @escaping (Data?, Error?) -> Void) {
        let put = ["userName": username] as [String: Any]
        let jsonData = try? JSONSerialization.data(withJSONObject: put, options: .prettyPrinted)
        let url = URL(string: "http://localhost:3000/logout")!
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
    
    func resetUserData(username: String, completion: @escaping (Data?, Error?) -> Void) {
        let put = ["userName": username] as [String: Any]
        let jsonData = try? JSONSerialization.data(withJSONObject: put, options: .prettyPrinted)
        let url = URL(string: "http://localhost:3000/resetData")!
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
