//
//  SceneDelegate.swift
//  yatriMitra
//
//  Created by Kaizen Infotech Solutions Private Limited. on 04/06/24.
//

import UIKit
import CoreLocation
import Alamofire

@available(iOS 14.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    let locationManager = CLLocationManager()
    var goMapVC : Bool?
    var memberprofile : Int?
    var rideStatus : String?
    var bookingid: Int?
    var latitudes_destination: String?
    var longitudes_destination: String?
    var vehicle_Number: String?
    var vehicle_Model: String?
    var driverName: String?
    var driver_Photo: String?
    var dp_poliline_points: String?
    var vehicle_Photo: String?
    var driver_Mobile_Number: String?
    var destinationPlaceName: String?
    var sourcePlaceName: String?
    
    var pin : Int?
    var driver_current_latitude : String?
    var driver_current_longitude : String?
    var pickup_latitude : String?
    var pickup_longitude : String?
    var destination_latitude : String?
    var destination_longitude : String?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        print("------scene()------------")
        guard let _ = (scene as? UIWindowScene) else { return }
        goMapVC = true
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        print("------sceneDidDisconnect()------------")
        TimerManager.shared.stopAllTimers()
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        print("------sceneDidBecomeActive()------------")
              print("✅ Scene became active")
        (UIApplication.shared.delegate as? AppDelegate)?.requestTrackingPermission()
        (UIApplication.shared.delegate as? AppDelegate)?.getRemoteConfig_ComingSoon()
        (UIApplication.shared.delegate as? AppDelegate)?.deviceToken()
        NotificationCenter.default.post(name: .forceUpdate, object: nil)
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        print("------sceneWillResignActive()------------")
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        print("------sceneWillEnterForeground()------------")
        var userLogout : Int?
        if let userLogoutString = UserDefaults.standard.string(forKey: "user_logout"),
           let userLogoutInt = Int(userLogoutString) {
            print("User logout value as integer: \(userLogoutInt)")
            userLogout = userLogoutInt
        } else {
            // Handle the case where the string is nil or not convertible to Int
            print("Failed to convert user_logout to an integer")
        }
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        print("------sceneDidEnterBackground()------------")
        goMapVC = false
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
    func goToVC() {
            if UserDefaults.standard.string(forKey: "fk_member_master_profile_id") == nil || (Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "") == 0) ||  UserDefaults.standard.string(forKey: "fk_member_master_profile_id") == ""{
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                
                let navigationController = UINavigationController(rootViewController: initialViewController)
                window?.rootViewController = navigationController
                window?.makeKeyAndVisible()
                
            }
            
        else {
            if rideStatus == "driverApproachingTowardsPassengerPending" {
                memberprofile = Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "")
                print("Member : \(memberprofile)")
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "BookACabViewController") as! BookACabViewController
                initialViewController.member_master_profile_id = memberprofile
                initialViewController.rideStatus = rideStatus
                initialViewController.otpInt = pin
                initialViewController.sourcePlaceName = sourcePlaceName
                initialViewController.destinationPlaceName = destinationPlaceName
                initialViewController.pickup_latitude = pickup_latitude
                initialViewController.pickup_longitude = pickup_longitude
                initialViewController.destination_latitude = destination_latitude
                initialViewController.destination_longitude = destination_longitude
                initialViewController.driver_current_latitude = driver_current_latitude
                initialViewController.driver_current_longitude = driver_current_longitude
                initialViewController.pk_bookride_id = bookingid
                initialViewController.vehicle_Photo_afterAppTermination = vehicle_Photo
                initialViewController.driver_Photo_afterAppTermination = driver_Photo
                initialViewController.dp_poliline_points = dp_poliline_points
                if let vehicleNumber = vehicle_Number {
                    initialViewController.vehicleNumberString = vehicleNumber
                } else {
                    print("vehicleNumber is nil")
                }
                //Vehicle Model
                if let vehicleModel = vehicle_Model {
                    initialViewController.vehicleModelString = vehicleModel
                } else {
                    print("vehicleModel is nil")
                }
                //Driver Name
                if let driverName = driverName {
                    initialViewController.driverNameString = driverName
                } else {
                    print("driverName is nil")
                }
                
                if let driverMobileNumber = driver_Mobile_Number {
                    initialViewController.driverMobileNumberString = driverMobileNumber
                } else {
                    print("driverMobileNumber is nil")
                }
                let navigationController = UINavigationController(rootViewController: initialViewController)
                window?.rootViewController = navigationController
                window?.makeKeyAndVisible()
            }
            else if rideStatus == "active" {
                memberprofile = Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "")
                print("Member : \(memberprofile)")

                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "RideStartedViewController") as! RideStartedViewController
                initialViewController.member_master_profile_id = memberprofile
                initialViewController.rideStatus = rideStatus
                initialViewController.latitudes_destination = latitudes_destination
                initialViewController.longitudes_destination = longitudes_destination
                initialViewController.driver_current_latitude = driver_current_latitude
                initialViewController.driver_current_longitude = driver_current_longitude
                initialViewController.pk_bookride_id = bookingid
                initialViewController.driverPhotoString = driver_Photo
                initialViewController.vehiclePhotoString = vehicle_Photo
                if let vehicleNumber = vehicle_Number {
                    initialViewController.vehicleNumberString = vehicleNumber
                } else {
                    print("vehicleNumber is nil")
                }
                //Vehicle Model
                if let vehicleModel = vehicle_Model {
                    initialViewController.vehicleModelString = vehicleModel
                } else {
                    print("vehicleModel is nil")
                }
                //Driver Name
                if let driverName = driverName {
                    initialViewController.driverNameString = driverName
                } else {
                    print("driverName is nil")
                }
                
                if let driverMobileNumber = driver_Mobile_Number {
                    initialViewController.driverMobileNumberString = driverMobileNumber
                } else {
                    print("driverMobileNumber is nil")
                }
                let navigationController = UINavigationController(rootViewController: initialViewController)
                window?.rootViewController = navigationController
                window?.makeKeyAndVisible()
            }

                else {
                    memberprofile = Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "")
                    print("Member : \(memberprofile)")
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                   
                    let initialViewController = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
                    initialViewController.member_master_profile_id = memberprofile
                    let navigationController = UINavigationController(rootViewController: initialViewController)
                    window?.rootViewController = navigationController
                    window?.makeKeyAndVisible()
                }
                
            }
    }
    
    
    func pendingRide() {
        let url = AppConfig.baseURL+"Book/get_PendingRide"
        let params :  [String : Any] = [
            "fk_member_master_profile_id": Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "")
        ]
        print("pendingRide() -> url : \(url)")
        print("pendingRide() -> parameters : \(params)")
        
        let token = UserDefaults.standard.string(forKey: "auth_deviceToken") ?? ""

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default,headers: headers, interceptor: nil).response { [self] response in
            print("pendingRide() -> response : \(response)")
            print("pendingRide() -> response.result : \(response.result)")
            let statusCode = response.response?.statusCode
            print("statusCode : \(statusCode)")
            
            switch response.result {
                
            case .success (let data) :
                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let loginResult = json["result"] as? [String: Any] {
                            print("pendingRide() -> JSON -------\(json)")
                            let status = loginResult["status"] as? String ?? ""
                            let message = loginResult["message"] as? String ?? ""
                            if status == "0" && message == "OK"{
                                if let  output = loginResult["output"] as? [[String: Any]] {
                                    print("pendingRide() -> output---- : \(output)")
                                    if output == nil || output.isEmpty == true {
                                        print("nil")
                                        goToVC()
                                    } else {
                                        print("Output: \(output)")
                                        if let firstDict = output.first {
                                            bookingid = firstDict["bookingid"] as? Int
                                            latitudes_destination = firstDict["latitudes_destination"] as? String
                                            longitudes_destination = firstDict["longitudes_destination"] as? String
                                            driver_current_latitude = firstDict["driver_current_latitude"] as? String
                                            driver_current_longitude = firstDict["driver_current_longitude"] as? String
                                            vehicle_Number = firstDict["vehicle_Number"] as? String
                                            vehicle_Model = firstDict["vehicle_Model"] as? String
                                            driverName = firstDict["driverName"] as? String
                                            driver_Photo = firstDict["driver_Photo"] as? String
                                            vehicle_Photo = firstDict["vehicle_Photo"] as? String
                                            driver_Mobile_Number = firstDict["driver_Mobile_Number"] as? String
                                            rideStatus = "active"
                                            goToVC()
                                        }
                                    }
                                    
                                }
                            }
                        } else {
                        }
                    } catch {
                       
                    }
                }
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    func driverAprroachingTowardsPassengerPending() {
        let url = AppConfig.baseURL+"DriverRides/getDriverridedetailsAftertermination"
        let params :  [String : Any] = [
            "fk_member_master_profile_id": Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "")
        ]
        print("driverAprroachingTowardsPassengerPending() -> url : \(url)")
        print("driverAprroachingTowardsPassengerPending() -> parameters : \(params)")
        
        let token = UserDefaults.standard.string(forKey: "auth_deviceToken") ?? ""

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default,headers: headers, interceptor: nil).response { [self] response in
            print("driverAprroachingTowardsPassengerPending() -> response : \(response)")
            print("driverAprroachingTowardsPassengerPending() -> response.result : \(response.result)")
            let statusCode = response.response?.statusCode
            print("statusCode : \(statusCode)")
            
            switch response.result {
                
            case .success (let data) :
                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let loginResult = json["result"] as? [String: Any] {
                            print("driverAprroachingTowardsPassengerPending() -> JSON -------\(json)")
                            let status = loginResult["status"] as? String ?? ""
                            let message = loginResult["message"] as? String ?? ""
                            if status == "0" && message == "OK"{
                                if let  listing = loginResult["listing"] as? [[String: Any]] {
                                    print("listing() -> listing---- : \(listing)")
                                    if listing == nil || listing.isEmpty == true {
                                        print("nil")
                                        pendingRide()
                                    } else {
                                        print("Output: \(listing)")
                                        if let firstDict = listing.first {
                                            bookingid = firstDict["fk_bookride_id"] as? Int
                                            pin = firstDict["pin"] as? Int
                                            sourcePlaceName = firstDict["sourcePlaceName"] as? String
                                            destinationPlaceName = firstDict["destinationPlaceName"] as? String
                                            driver_current_latitude = firstDict["driver_current_latitude"] as? String
                                            driver_current_longitude = firstDict["driver_current_longitude"] as? String
                                            pickup_latitude = firstDict["pickup_latitude"] as? String
                                            pickup_longitude = firstDict["pickup_longitude"] as? String
                                            destination_latitude = firstDict["destination_latitude"] as? String
                                            destination_longitude = firstDict["destination_longitude"] as? String
                                            vehicle_Number = firstDict["vehicle_no"] as? String
                                            vehicle_Model = firstDict["vehicle_Brand_Model"] as? String
                                            driverName = firstDict["driver_Name"] as? String
                                            driver_Photo = firstDict["driver_image_url"] as? String
                                            vehicle_Photo = firstDict["vehicle_image_url"] as? String
                                            driver_Mobile_Number = firstDict["driver_Mob_No"] as? String
                                            dp_poliline_points = firstDict["dp_poliline_points"] as? String
                                            rideStatus = "driverApproachingTowardsPassengerPending"
                                            goToVC()
                                            

                                        }
                                    }
                                    
                                }
                            }
                        } else {
                        }
                    } catch {
                       
                    }
                }
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
}

