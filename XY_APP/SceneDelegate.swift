//
//  SceneDelegate.swift
//  XY_APP
//
//  Created by Maxime Franchot on 17/11/2020.
//

import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        API.shared.checkConnection(closure: { connectionStatus in
            switch connectionStatus {
            case .noConnection:
                // Load launchscreen with connection failure
                let launchScreenStoryboard:UIStoryboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
                DispatchQueue.main.async {
                    let newViewcontroller = launchScreenStoryboard.instantiateViewController(withIdentifier: "LaunchScreen") as! LaunchScreenViewController
                    API.shared.hasConnection = false
                    self.window!.rootViewController = newViewcontroller
                }
            case .hasConnection:
                // Load session details
                CoreDataManager.loadSession()
                
                // Check if session is active & valid
                Session.shared.requestSession(completion: { result in
                    switch result {
                    case .success(let message):

                        // Segue to main
                        let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        
                        DispatchQueue.main.async {
                            let newViewcontroller = mainstoryboard.instantiateViewController(withIdentifier: "MainViewController") as! UITabBarController
                            self.window!.rootViewController = newViewcontroller
                        }
                    case .failure(let error):
                        // No session found, segue to login
                        let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        DispatchQueue.main.async {
                            let newViewcontroller = mainstoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                            self.window!.rootViewController = newViewcontroller
                        }
                    }
                })
            }
        })
        
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        
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
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

