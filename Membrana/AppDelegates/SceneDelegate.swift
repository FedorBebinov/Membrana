//
//  SceneDelegate.swift
//  Membrana
//
//  Created by Fedor Bebinov on 08.12.22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    let infoService = InfoVCService(networkManager: NetworkManager())
    let sceneService = SceneVCService(networkManager: NetworkManager())
    let mainService = MainVCService(networkManager: NetworkManager())
    
    
    var pendingConnectionTimer: Timer?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        
        let nav = UINavigationController()
        nav.navigationBar.backIndicatorImage = UIImage(named: "back_button")
        nav.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back_button")
        
        var vc: InfoViewController?
        if UserDefaults.standard.bool(forKey: "isNotFirstLaunch") {
            vc = InfoViewController(type: .getConnectionView)
            
        } else {
            vc = InfoViewController(type: .addUsernameView)
            UserDefaults.standard.set(true, forKey: "isNotFirstLaunch")
        }
        
        guard let vc = vc else { return }
        nav.viewControllers = [vc]
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        
        
    }
    
    @objc func handlePendingConnectionTimer() {
        print("debug: get pending connection")
        
        sceneService.getPendingConnection { [weak self] data, error in
            guard let self else { return }
            if error != nil  {
                print("debug: error while pending connection \(String(describing: error?.localizedDescription))")
            }
            
            var userInfo: User?
            if let data {
                do {
                    userInfo = try JSONDecoder().decode(User.self, from: data)
                } catch {
                    print(error)
                }
                
                
                if let connections = userInfo?.connections,
                   connections.count > 0 {
                    self.pendingConnectionTimer?.invalidate()
                    self.pendingConnectionTimer = nil
                    
                    
                    guard let topController = UIApplication.topViewController(),
                          !(topController is MainViewController) else { return }
                    
                    UserDefaults.standard.set(connections.first ?? "", forKey: "connectWithUser")
                    topController.navigationController?.pushViewController(MainViewController(), animated: true)
                    
                    guard let username = userInfo?.userName else { return }
                    
                    self.sceneService.updateSessionStatus(for: username, connections: connections) { [weak self] resp, error in
                        guard self != nil else { return }
                        if error != nil  {
                            print("debug: isInSession not updated with error : \(String(describing: error?.localizedDescription))")
                        }
                        
                        if resp != nil {
                            print("debug: isInSession property updated succesfully")
                        }
                    }
                }
            }
        }
    }
    
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        guard let username = UserDefaults.standard.string(forKey: "username") else { return }
        
        infoService.postUserNameLogin(username: username) { [weak self] resp, error in
            guard self != nil else { return }
            if error != nil  {
                print("debug: \(error?.localizedDescription)")
            }
            
            if resp != nil {
                print("debug: user is logged in")
            }
        }
        
        pendingConnectionTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(handlePendingConnectionTimer), userInfo: nil, repeats: true)
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        guard let username = UserDefaults.standard.string(forKey: "username") else { return }
        infoService.logoutUserName(username: username) { [weak self] resp, error in
            guard UserDefaults.standard.string(forKey: "username") != nil else { return }
            guard self != nil else { return }
            if error != nil  {
                print("debug: \(String(describing: error?.localizedDescription))")
            }
            
            if resp != nil {
                guard let topController = UIApplication.topViewController() else { return }
                topController.navigationController?.popToRootViewController(animated: true)
                print("debug: user is logged out")
            }
        }
    }
}
