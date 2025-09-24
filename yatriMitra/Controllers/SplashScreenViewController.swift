//
//  SplashScreenViewController.swift
//  yatriMitra
//
//  Created by Kaizen Infotech Solutions Private Limited. on 22/07/24.
//

import UIKit
import CoreLocation


class SplashScreenViewController: UIViewController {
    var window: UIWindow?
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(transitionToMainScreen), userInfo: nil, repeats: false)
    }
    @objc private func transitionToMainScreen() {
//            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            if let mainViewController = mainStoryboard.instantiateViewController(withIdentifier: "MainViewController") as? UIViewController {
//                mainViewController.modalTransitionStyle = .crossDissolve
//                mainViewController.modalPresentationStyle = .fullScreen
//                present(mainViewController, animated: true, completion: nil)
//            }
//        
        if UserDefaults.standard.string(forKey: "fk_member_master_profile_id") == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let enabledVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
                navigationController?.pushViewController(enabledVC, animated: true)
//                if let windowScene = scene as? UIWindowScene {
//                    if let window = windowScene.windows.first {
//                        if let navigationController = window.rootViewController as? UINavigationController {
//                            navigationController.pushViewController(enabledVC, animated: true)
//                        } else if let rootViewController = window.rootViewController {
//                            rootViewController.present(enabledVC, animated: true, completion: nil)
//                        }
//                    }
//                }
                
            }
            
        } else if CLLocationManager.authorizationStatus() == .notDetermined ||  CLLocationManager.authorizationStatus() == .restricted {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let enabledVC = storyboard.instantiateViewController(withIdentifier: "WelcomeViewController") as? WelcomeViewController {
                navigationController?.pushViewController(enabledVC, animated: true)
//                if let windowScene = scene as? UIWindowScene {
//                    if let window = windowScene.windows.first {
//                        if let navigationController = window.rootViewController as? UINavigationController {
//                            navigationController.pushViewController(enabledVC, animated: true)
//                        } else if let rootViewController = window.rootViewController {
//                            rootViewController.present(enabledVC, animated: true, completion: nil)
//                        }
//                    }
//                }
                
            }
            
        } else {
            var memberprofile = UserDefaults.standard.string(forKey: "fk_member_master_profile_id")
            print("Member : \(memberprofile)")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let enabledVC = storyboard.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController {
                navigationController?.pushViewController(enabledVC, animated: true)
//                if let windowScene = scene as? UIWindowScene {
//                    if let window = windowScene.windows.first {
//                        if let navigationController = window.rootViewController as? UINavigationController {
//                            navigationController.pushViewController(enabledVC, animated: true)
//                        } else if let rootViewController = window.rootViewController {
//                            rootViewController.present(enabledVC, animated: true, completion: nil)
//                        }
//                    }
//                }
                
            }
            
        }
        }
}
