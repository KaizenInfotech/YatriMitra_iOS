//
//  WelcomeViewController.swift
//  yatriMitra
//
//  Created by IOS 2 on 03/07/24.
//

import UIKit
import CoreLocation

class WelcomeViewController: UIViewController, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var allowBtn: UIButton!
    var lastClickTime: CFTimeInterval = 0
    
    let locationManager = CLLocationManager()
    var member_master_profile_id : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        self.navigationItem.hidesBackButton = true
        UserDefaults.standard.setValue(member_master_profile_id, forKey: "fk_member_master_profile_id")
        NetworkMonitor.shared
        allowBtn.layer.cornerRadius = 15
        locationManager.requestAlwaysAuthorization()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("VIEW WILL APPEAR")
        UserDefaults.standard.setValue(member_master_profile_id, forKey: "fk_member_master_profile_id")
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if !checkLocationAuthorization() {
//            checkLocationServices()
//        }
    }
    @IBAction func allowAction(_ sender: Any) {
        let currentTime = CACurrentMediaTime()

         if currentTime - lastClickTime < 1 { // Ignore multiple clicks within 1 second
             return
         }

         lastClickTime = currentTime

         // Handle button click action
         print("Button clicked")
        //        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //        if let enabledVC = storyboard.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController {
        //            navigationController?.pushViewController(enabledVC, animated: true)
        //        }
        checkLocationServices()
    }
    
    
    func checkLocationServices() {
        if #available(iOS 14.0, *) {
            if  locationManager.authorizationStatus == .notDetermined || locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted
            {
                let alertController = UIAlertController(title: "Allow Permission to access your location while using this app",
                                                        message: "This will be used to manage your location.",
                                                        preferredStyle: .alert)
                
                let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
                    if let url = URL.init(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!)
                    }
                }
//                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (_) in
                    let enabledVC = self.storyboard?.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController
                    enabledVC?.showBanner = UserDefaults.standard.string(forKey: "showBanner")
                    enabledVC?.member_master_profile_id = self.member_master_profile_id
                    self.navigationController?.pushViewController(enabledVC!, animated: true)
                }
                alertController.addAction(settingsAction)
//                alertController.addAction(cancelAction)
                
                present(alertController, animated: true, completion: nil)
            }
            else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let enabledVC = storyboard.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController {
                    enabledVC.showBanner = UserDefaults.standard.string(forKey: "showBanner")
                    enabledVC.member_master_profile_id = member_master_profile_id
                    navigationController?.pushViewController(enabledVC, animated: true)
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func checkLocationAuthorization() -> Bool   {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            return true
        case .denied, .restricted, .notDetermined:
            return false
        @unknown default:
            return false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            DispatchQueue.main.async{
                self.locationManager.requestWhenInUseAuthorization()
            }
            break;
        case .restricted, .denied:
            print("No Location access")
            DispatchQueue.main.async{
                self.locationManager.requestWhenInUseAuthorization()
            }
            break;
        case .authorizedWhenInUse, .authorizedAlways:
            print("Requesting location access 'Always'.")
            
            //                    DispatchQueue.main.async{
            //                        self.locationManager.requestWhenInUseAuthorization()
            //                    }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let enabledVC = storyboard.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController {
                enabledVC.showBanner = UserDefaults.standard.string(forKey: "showBanner")
                enabledVC.member_master_profile_id = member_master_profile_id
                navigationController?.pushViewController(enabledVC, animated: true)
            }
            break;
//        case .authorizedAlways:
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            if let enabledVC = storyboard.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController {
//                enabledVC.member_master_profile_id = member_master_profile_id
//                navigationController?.pushViewController(enabledVC, animated: true)
//            }
//            break;
        default:
            return
        }
    }
    
    func navigateToPage(locationEnabled: Bool) {
        if locationEnabled {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let enabledVC = storyboard.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController {
                enabledVC.showBanner = UserDefaults.standard.string(forKey: "showBanner")
                enabledVC.member_master_profile_id = member_master_profile_id
                navigationController?.pushViewController(enabledVC, animated: true)
            }
        } else {
            //                let storyboard = UIStoryboard(name: "Main", bundle: nil)
            //                if let disabledVC = storyboard.instantiateViewController(withIdentifier: "LocationDisabledViewController") as? LocationDisabledViewController {
            //                    navigationController?.pushViewController(disabledVC, animated: true)
            //                }
            let alertController = UIAlertController(title: "Allow Permission to access your location while using this app",
                                                    message: "This will be used to manage your location.",
                                                    preferredStyle: .alert)
            
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
                if let url = URL.init(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!)
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                                alertController.addAction(settingsAction)
                                alertController.addAction(cancelAction)
            
                                present(alertController, animated: true, completion: nil)
        }
    }
}
