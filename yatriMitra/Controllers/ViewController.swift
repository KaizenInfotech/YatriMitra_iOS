//
//  ViewController.swift
//  RideON
//
//  Created by Kaizen Infotech Solutions Private Limited. on 31/05/24.
//

import UIKit
import Alamofire
import CoreLocation

@available(iOS 13.0, *)
class ViewController: UIViewController,UITextViewDelegate {
    
    
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
    var vehicletypeid: Int?
    var amount: Int?
    var distance: Float?
    var routMap_photo: String?
    var sd_poliline_points: String?
    var driver_profile_id : Int?
    var pin : Int?
    var driver_current_latitude : String?
    var driver_current_longitude : String?
    var pickup_latitude : String?
    var pickup_longitude : String?
    var destination_latitude : String?
    var destination_longitude : String?
    var pickup_duration : Int?
    
    var showBanner = ""
    var bannerURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                                       selector: #selector(handleBanner),
                                               name: .bannerImgShow,
                                                       object: nil)
        NotificationCenter.default.addObserver(self,
                                                       selector: #selector(handleBanner),
                                               name: .bannerImgURL,
                                                       object: nil)
        // Do any additional setup after loading the view.
        TimerManager.shared.stopAllTimers()

        DispatchQueue.main.async { [self] in
            if UserDefaults.standard.string(forKey: "fk_member_master_profile_id") == nil {
                goToVC()
            } else {
                searchingRideContinued()
            }
        }
        
//        goToVC()
        
    }
    
    @objc func handleBanner(_ notification: Notification) {
        self.showBanner = UserDefaults.standard.string(forKey: "showBanner") ?? ""
        self.bannerURL = UserDefaults.standard.string(forKey: "banner_URL") ?? ""
           
        }
    
    func goToVC() {
            if UserDefaults.standard.string(forKey: "fk_member_master_profile_id") == nil || (Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "") == 0) ||  UserDefaults.standard.string(forKey: "fk_member_master_profile_id") == ""{
                //        if UserDefaults.standard.string(forKey: "fk_member_master_profile_id") == nil || UserDefaults.standard.string(forKey: "fk_member_master_profile_id") == "" || UserDefaults.standard.string(forKey: "fk_member_master_profile_id") == "0"{
                //            if goMapVC ?? true {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                //                if let enabledVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
                //                    if let windowScene = scene as? UIWindowScene {
                //                        if let window = windowScene.windows.first {
                //                            if let navigationController = window.rootViewController as? UINavigationController {
                //                                navigationController.pushViewController(enabledVC, animated: true)
                //                            } else if let rootViewController = window.rootViewController {
                //                                rootViewController.present(enabledVC, animated: true, completion: nil)
                ////                            }
                //                        }
                //                    }
                //
                //                }
                //            }
//                let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginRegisterViewController") as! LoginRegisterViewController
//                
//                self.navigationController?.pushViewController(initialViewController, animated: true)
                
                let otpVC = storyboard.instantiateViewController(identifier: "LoginRegisterViewController") as! LoginRegisterViewController
                let navController = UINavigationController(rootViewController: otpVC)

                DispatchQueue.main.async {

                    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                        sceneDelegate.window?.rootViewController = navController
                        sceneDelegate.window?.makeKeyAndVisible()
                    }
                }
                
            }
            //            else if UserDefaults.standard.string(forKey: "lastPausedPage") != nil {
            //            // Navigate to the last paused page
            //            if let lastPausedPage = UserDefaults.standard.string(forKey: "lastPausedPage") {
            //                let storyboard = UIStoryboard(name: "Main", bundle: nil)
            //                let lastVC = storyboard.instantiateViewController(withIdentifier: lastPausedPage)
            //                if let windowScene = scene as? UIWindowScene {
            //                    if let window = windowScene.windows.first {
            //                        if let navigationController = window.rootViewController as? UINavigationController {
            //                            navigationController.pushViewController(lastVC, animated: true)
            //                        } else if let rootViewController = window.rootViewController {
            //                            rootViewController.present(lastVC, animated: true, completion: nil)
            //                        }
            //                    }
            //                }
            //
            //            }
            //        }
        else {
            if rideStatus == "searchingRideContinued" {
                memberprofile = Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "")
                print("Member : \(memberprofile)")
                //            if goMapVC ?? true {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "BookACabViewController") as! BookACabViewController
                initialViewController.pk_bookride_id = bookingid
                initialViewController.member_master_profile_id = memberprofile
                initialViewController.rideStatus = rideStatus
                initialViewController.sourcePlaceName = sourcePlaceName
                initialViewController.destinationPlaceName = destinationPlaceName
                initialViewController.pickup_latitude = pickup_latitude
                initialViewController.pickup_longitude = pickup_longitude
                initialViewController.destination_latitude = destination_latitude
                initialViewController.destination_longitude = destination_longitude
                initialViewController.rideFare = amount
//                if let vehicleTypeIDInt = Int(vehicletypeid ?? "0") {
                    initialViewController.vehicleTypeID = vehicletypeid
//                }
                initialViewController.driver_current_longitude = driver_current_longitude
//                if let distanceFloat = distance {
                    initialViewController.distance = distance
//                }
                
                initialViewController.sd_poliline_points = sd_poliline_points
                initialViewController.routMap_photo = routMap_photo

                self.navigationController?.pushViewController(initialViewController, animated: true)
            }
            else if rideStatus == "driverApproachingTowardsPassengerPending" {
                memberprofile = Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "")
                print("Member : \(memberprofile)")
                //            if goMapVC ?? true {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "BookACabViewController") as! BookACabViewController
                initialViewController.member_master_profile_id = memberprofile
                initialViewController.rideStatus = rideStatus
                initialViewController.otpInt = pin
                initialViewController.driver_profile_id = driver_profile_id
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
                initialViewController.minutesFromAPI = pickup_duration
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
                self.navigationController?.pushViewController(initialViewController, animated: true)
            }
            else if rideStatus == "active" {
                memberprofile = Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "")
                print("Member : \(memberprofile)")
                //            if goMapVC ?? true {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "RideStartedViewController") as! RideStartedViewController
                initialViewController.member_master_profile_id = memberprofile
                initialViewController.rideStatus = rideStatus
                initialViewController.latitudes_destination = latitudes_destination
                initialViewController.longitudes_destination = longitudes_destination
                initialViewController.driver_current_latitude = driver_current_latitude
                initialViewController.driver_current_longitude = driver_current_longitude
                initialViewController.pk_bookride_id = bookingid
                initialViewController.current = sourcePlaceName
                initialViewController.destination = destinationPlaceName
                initialViewController.driverPhotoString = driver_Photo
                initialViewController.vehiclePhotoString = vehicle_Photo
                initialViewController.sd_poliline_points = sd_poliline_points
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
                //Driver Photo
                //                if let driverPhoto = driverPic.image {
                //                    initialViewController.driverPhotoUI = driverPhoto
                //                } else {
                //                    print("driverPhoto is nil")
                //                }
                //                //Vehicle Image
                //                if let vehicleImage = automobileImg.image {
                //                    initialViewController.vehicleImageUI = vehicleImage
                //                } else {
                //                    print("vehicleImage is nil")
                //                }
                //Driver Mobile Number
                if let driverMobileNumber = driver_Mobile_Number {
                    initialViewController.driverMobileNumberString = driverMobileNumber
                } else {
                    print("driverMobileNumber is nil")
                }
                self.navigationController?.pushViewController(initialViewController, animated: true)
            }
//            else if UserDefaults.standard.string(forKey: "ride") == "tappedNotificationBanner" {
//                print("Entered in endtripviewcontroller")
//            }
//            else if !CLLocationManager.locationServicesEnabled(){
//                memberprofile = Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "")
//                print("Member : \(memberprofile)")
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                //           if let enabledVC = storyboard.instantiateViewController(withIdentifier: "GPSSettingViewController") as? GPSSettingViewController {
//                //               if let windowScene = scene as? UIWindowScene {
//                //                   if let window = windowScene.windows.first {
//                //                       if let navigationController = window.rootViewController as? UINavigationController {
//                //                           navigationController.pushViewController(enabledVC, animated: true)
//                //                       } else if let rootViewController = window.rootViewController {
//                //                           rootViewController.present(enabledVC, animated: true, completion: nil)
//                //                       }
//                //                   }
//                //               }
//                //
//                //           }
//
//                let initialViewController = storyboard.instantiateViewController(withIdentifier: "GPSSettingViewController") as! GPSSettingViewController
//                initialViewController.member_master_profile_id = memberprofile
//                    let navigationController = UINavigationController(rootViewController: initialViewController)
//                    window?.rootViewController = navigationController
//                    window?.makeKeyAndVisible()
//                }
//            else if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied {
//                    memberprofile = Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "")
//                    print("Member : \(memberprofile)")
//                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                    //           if let enabledVC = storyboard.instantiateViewController(withIdentifier: "GPSSettingViewController") as? GPSSettingViewController {
//                    //               if let windowScene = scene as? UIWindowScene {
//                    //                   if let window = windowScene.windows.first {
//                    //                       if let navigationController = window.rootViewController as? UINavigationController {
//                    //                           navigationController.pushViewController(enabledVC, animated: true)
//                    //                       } else if let rootViewController = window.rootViewController {
//                    //                           rootViewController.present(enabledVC, animated: true, completion: nil)
//                    //                       }
//                    //                   }
//                    //               }
//                    //
//                    //           }
//
//                    let initialViewController = storyboard.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
//                    initialViewController.member_master_profile_id = memberprofile
//                    let navigationController = UINavigationController(rootViewController: initialViewController)
//                    window?.rootViewController = navigationController
//                    window?.makeKeyAndVisible()
//                }
                else {
                    memberprofile = Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "")
                    print("Member : \(memberprofile)")
                    //            if goMapVC ?? true {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let initialViewController = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
                    print("self.showBanner : \(self.showBanner)")
                    print("self.bannerURL : \(self.bannerURL)")
                    initialViewController.showBanner = self.showBanner
                    initialViewController.bannerURL = self.bannerURL
                    initialViewController.member_master_profile_id = memberprofile
                    self.navigationController?.pushViewController(initialViewController, animated: true)
                }
                
            }
    }
    
    func searchingRideContinued() {
        let url = AppConfig.baseURL+"Book/get_SearchRideTerminated"
        let params :  [String : Any] = [
            //            "fk_bookride_id": 169
            "fk_member_master_profile_id": Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "")
        ]
        print("searchingRideContinued() -> url : \(url)")
        print("searchingRideContinued() -> parameters : \(params)")
        let token = UserDefaults.standard.string(forKey: "auth_deviceToken") ?? ""

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        print("searchingRideContinued() -> Headers : \(token)")
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { [self] response in
            print("searchingRideContinued() -> response : \(response)")
            print("searchingRideContinued() -> response.result : \(response.result)")
            let statusCode = response.response?.statusCode
            print("statusCode : \(statusCode)")
            
            switch response.result {
                
            case .success (let data) :
                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let loginResult = json["result"] as? [String: Any] {
                            print("searchingRideContinued() -> JSON -------\(json)")
                            let status = loginResult["status"] as? String ?? ""
                            let message = loginResult["message"] as? String ?? ""
                            if status == "0" && message == "OK"{
                                if let  output = loginResult["output"] as? [[String: Any]] {
                                    print("searchingRideContinued() -> output---- : \(output)")
                                    if output == nil || output.isEmpty == true {
                                        print("nil")
                                        driverAprroachingTowardsPassengerPending()
                                    } else {
                                        print("Output: \(output)")
                                        if let firstDict = output.first {
                                            bookingid = firstDict["fk_bookride_id"] as? Int
                                            sourcePlaceName = firstDict["sourceaddress"] as? String
                                            destinationPlaceName = firstDict["distinationaddress"] as? String
                                            pickup_latitude = firstDict["sourcelatitude"] as? String
                                            pickup_longitude = firstDict["sourcelongitude"] as? String
                                            destination_latitude = firstDict["distinationlatitude"] as? String
                                            destination_longitude = firstDict["distinationlongitude"] as? String
                                            vehicletypeid = firstDict["vehicletypeid"] as? Int
                                            amount = firstDict["amount"] as? Int
                                            distance = firstDict["distance"] as? Float
                                            routMap_photo = firstDict["routMap_photo"] as? String
                                            sd_poliline_points = firstDict["sd_poliline_points"] as? String
                                            rideStatus = "searchingRideContinued"
                                            goToVC()
                                        }
                                    }
                                    
                                }
                            }
                        } else {
                        }
                    } catch {
                        let alertController = UIAlertController(title: "Network Error", message: "", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
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
            //            "fk_bookride_id": 169
            "fk_member_master_profile_id": Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "")
        ]
        print("driverAprroachingTowardsPassengerPending() -> url : \(url)")
        print("driverAprroachingTowardsPassengerPending() -> parameters : \(params)")
        let token = UserDefaults.standard.string(forKey: "auth_deviceToken") ?? ""

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        print("searchingRideContinued() -> Headers : \(token)")
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { [self] response in
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
                                            driver_profile_id = firstDict["fk_member_master_profile_Driver_id"] as? Int
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
                                            print(firstDict["pickupDuration"] as? Int)
                                            pickup_duration = firstDict["pickupDuration"] as? Int
                                            goToVC()
                                            

                                        }
                                    }
                                    
                                }
                            }
                        } else {
                        }
                    } catch {
                        let alertController = UIAlertController(title: "Network Error", message: "", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                       
                    }
                }
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    func pendingRide() {
        let url = AppConfig.baseURL+"Book/get_PendingRide"
        let params :  [String : Any] = [
            //            "fk_bookride_id": 169
            "fk_member_master_profile_id": Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "")
        ]
        print("pendingRide() -> url : \(url)")
        print("pendingRide() -> parameters : \(params)")
        let token = UserDefaults.standard.string(forKey: "auth_deviceToken") ?? ""

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { [self] response in
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
                                            sourcePlaceName = firstDict["sourceaddress"] as? String
                                            destinationPlaceName = firstDict["distinationaddress"] as? String
                                            vehicle_Number = firstDict["vehicle_Number"] as? String
                                            vehicle_Model = firstDict["vehicle_Model"] as? String
                                            driverName = firstDict["driverName"] as? String
                                            driver_Photo = firstDict["driver_Photo"] as? String
                                            vehicle_Photo = firstDict["vehicle_Photo"] as? String
                                            driver_Mobile_Number = firstDict["driver_Mobile_Number"] as? String
                                            sd_poliline_points = firstDict["sd_poliline_points"] as? String
                                            rideStatus = "active"
                                            goToVC()
                                        }
                                    }
                                    
                                }
                            }
                        } else {
                        }
                    } catch {
                        let alertController = UIAlertController(title: "Network Error", message: "", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                    }
                }
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    

    
    
}

