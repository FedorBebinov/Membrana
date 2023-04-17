//
//  InfoVCService.swift
//  Membrana
//
//  Created by Fedor Bebinov on 03.04.23.
//

import Foundation

class InfoVCService {
    
    let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func postUserNameRegister(username: String, completion: @escaping (Data?, Error?) -> Void ) {
        let post = ["userName": username] as [String : Any]
        let jsonData = try? JSONSerialization.data(withJSONObject: post, options: .prettyPrinted)
        let url = URL(string: "http://localhost:3000/register")!
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
    
    func postUserNameLogin(username: String, completion: @escaping (Data?, Error?) -> Void ) {
        let post = ["userName": username] as [String : Any]
        let jsonData = try? JSONSerialization.data(withJSONObject: post, options: .prettyPrinted)
        let url = URL(string: "http://localhost:3000/login")!
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
    
    func editUserName(username: String, newUserName: String, completion: @escaping (Data?, Error?) -> Void) {
        let put = ["userName": username, "newUserName": newUserName] as [String: Any]
        let jsonData = try? JSONSerialization.data(withJSONObject: put, options: .prettyPrinted)
        let url = URL(string: "http://localhost:3000/updateUsername")!
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
    
    func logoutUserName(username: String, completion: @escaping (Data?, Error?) -> Void) {
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
    
    func connectWithUser(username: String, withUser: String, completion: @escaping (Data?, Error?) -> Void ) {
        let post = ["userName": username, "userToConnectWith": withUser] as [String : Any]
        let jsonData = try? JSONSerialization.data(withJSONObject: post, options: .prettyPrinted)
        let url = URL(string: "http://localhost:3000/connect")!
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
}
