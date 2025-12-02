//
//  GPSSettingViewController.swift
//  yatriMitra
//
//  Created by Kaizen Infotech Solutions Private Limited. on 04/06/24.
//

import UIKit
import CoreLocation

class GPSSettingViewController: UIViewController,CLLocationManagerDelegate {
    
    @IBOutlet weak var gpsTurnON: UIButton!
    
    var member_master_profile_id : Int?
    let locationManager = CLLocationManager()
    var lastClickTime: CFTimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        print("(member_master_profile_id : \(member_master_profile_id)")
        UserDefaults.standard.setValue(member_master_profile_id, forKey: "fk_member_master_profile_id")
        NetworkMonitor.shared
        gpsTurnON.layer.cornerRadius = 15
//        locationManager.delegate = self
//        if CLLocationManager.locationServicesEnabled() {
//            let enabledVC = storyboard?.instantiateViewController(withIdentifier: "WelcomeViewController") as? WelcomeViewController 
//            navigationController?.pushViewController(enabledVC!, animated: true)
//        }
        
//        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        locationManager.delegate = self
//        if !CLLocationManager.locationServicesEnabled() {
//                    showAlertForLocationDisabled()
//                } else {
//                    // Check the current authorization status
//                    checkLocationAuthorization()
//                }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("VIEW WILL APPEAR")
        UserDefaults.standard.setValue(member_master_profile_id, forKey: "fk_member_master_profile_id")

//            showAlertForLocationDisabled()
    }
    override func viewDidAppear(_ animated: Bool) {
        print("VIEW DID APPEAR")
    }

    func showAlertForLocationDisabled() {
        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .notDetermined ||  CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied {
                let enabledVC = storyboard?.instantiateViewController(withIdentifier: "WelcomeViewController") as? WelcomeViewController
                enabledVC?.member_master_profile_id = member_master_profile_id
                navigationController?.pushViewController(enabledVC!, animated: true)
            } else {
                let otpVC = storyboard?.instantiateViewController(identifier: "MapViewController") as! MapViewController
                otpVC.showBanner = UserDefaults.standard.string(forKey: "showBanner")
                otpVC.member_master_profile_id=self.member_master_profile_id
                self.navigationController?.pushViewController(otpVC, animated: true)
            }
        } else {
            let alertController = UIAlertController(title: "Location Services Disabled",
                                                    message: "Please enable location services in Settings to use this feature.",
                                                    preferredStyle: .alert)
            
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
                // Open app's settings
                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(appSettings) {
                        UIApplication.shared.open(appSettings)
                    }
                }
            }
//            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (_) in
                let enabledVC = self.storyboard?.instantiateViewController(withIdentifier: "WelcomeViewController") as? WelcomeViewController
                enabledVC?.member_master_profile_id = self.member_master_profile_id
                self.navigationController?.pushViewController(enabledVC!, animated: true)
            }
            
            alertController.addAction(settingsAction)
//            alertController.addAction(cancelAction)
            
            // Present the alert
            present(alertController, animated: true, completion: nil)
        }
    }
//    func label1TextModification() {
//        label1.textColor = UIColor(red: 0.342, green: 0.342, blue: 0.342, alpha: 1)
//        label1.font = UIFont(name: "Lato-Regular", size: 12)
//        label1.numberOfLines = 0
//        label1.lineBreakMode = .byWordWrapping
//        // Line height: 16.8 pt
//        label1.textAlignment = .center
//        label1.text = "Allow Yatri Mitra App to turn on your phone GPS for accurate pickup"
//    }

    @IBAction func gpsTurnOnAction(_ sender: Any) {
        let currentTime = CACurrentMediaTime()

         if currentTime - lastClickTime < 1 { // Ignore multiple clicks within 1 second
             return
         }

         lastClickTime = currentTime

         // Handle button click action
         print("Button clicked")
        showAlertForLocationDisabled()
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            checkLocationAuthorization()
        } else {
            navigateToPage(locationEnabled: false)
        }
    }
    
    func checkLocationAuthorization() {
           switch CLLocationManager.authorizationStatus() {
           case .authorizedWhenInUse, .authorizedAlways:
               navigateToPage(locationEnabled: true)
           case .denied, .restricted, .notDetermined:
               navigateToPage(locationEnabled: false)
           @unknown default:
               navigateToPage(locationEnabled: false)
           }
       }

    
    func showAlert(title: String, message: String, openSettings: SettingsType) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                var url: URL?
                switch openSettings {
                case .internet:
                    url = URL(string: UIApplication.openSettingsURLString)
                case .location:
                    url = URL(string: "App-Prefs:root=LOCATION_SERVICES")
                }
                if let settingsUrl = url {
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                    }
                }
            }))
            
            present(alert, animated: true, completion: nil)
        }
    
    func navigateToPage(locationEnabled: Bool) {
        if locationEnabled == true{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let enabledVC = storyboard.instantiateViewController(withIdentifier: "WelcomeViewController") as? WelcomeViewController {
                    enabledVC.member_master_profile_id = member_master_profile_id
                    navigationController?.pushViewController(enabledVC, animated: true)
                }
            } else {
                let alertController = UIAlertController(title: "Location Services Disabled",
                                                        message: "Please enable location services in Settings to use this feature.",
                                                        preferredStyle: .alert)
                
                let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
                    // Open app's settings
                    if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                        if UIApplication.shared.canOpenURL(appSettings) {
                            UIApplication.shared.open(appSettings)
                        }
                    }
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                alertController.addAction(settingsAction)
                alertController.addAction(cancelAction)
                
                // Present the alert
                present(alertController, animated: true, completion: nil)
            }
        }
}



enum SettingsType {
       case internet
       case location
   }
