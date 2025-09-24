//
//  EndTripViewController.swift
//  yatriMitra
//
//  Created by Kaizen Infotech Solutions Private Limited. on 21/08/24.
//

import UIKit
import Alamofire
import DotLottie
import Lottie

class EndTripViewController: UIViewController {
    
    @IBOutlet weak var fareView: UIView!
    @IBOutlet weak var pickupamountLbl: UILabel!

    @IBOutlet weak var fareAmountLbl: UILabel!
    @IBOutlet weak var totalAmoutLbl: UILabel!
    @IBOutlet weak var pickupChargesLbl: UILabel!
    @IBOutlet weak var fareTitleLbl: UILabel!
    @IBOutlet weak var estimatedRideCharges: UILabel!
    @IBOutlet weak var gifanimationView: UIView!
    @IBOutlet weak var okButton: UIButton!
    
    //Modified Outlets
    @IBOutlet weak var pickupORtotalamountLBL: UILabel!
    @IBOutlet weak var pickupORtotalchargesLBL: UILabel!
    @IBOutlet weak var pickupORtotalcommentLBL: UILabel!
    
    @IBOutlet weak var pleasePayAsPerMeterView: UIView!
    
    
    var startimer: Timer?
    var pickupamout : Int?
    var fareAmount : Int?
    var totalAmout : Int?
    var vehicle_type_id : Int?
    var member_master_profile_id : Int?
    var rideStatus : String?
    var iOSversion: String?
    var apiTimer : Timer?
    var animationView: LottieAnimationView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pleasePayAsPerMeterView.layer.cornerRadius = 12
        pleasePayAsPerMeterView.layer.masksToBounds = true
        pleasePayAsPerMeterView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner]

        
        member_master_profile_id = Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "")
        print("EndTripViewController -> member_master_profile_id : \(member_master_profile_id)")
        //        let animation = LottieAnimationView()
        //        animation.loopMode = .loop
        //        animationView1 = animation
        //
        //        let url = Bundle.main.url(forResource: "Animation - 1744005140184", withExtension: "lottie")!
        //        DotLottieFile.loadedFrom(url: url) { result in
        //            switch result {
        //            case .success(let success) :
        //                animation.loadAnimation(from: success)
        //            case .failure(let failure) :
        //                print("failure : \(failure)")
        //            }
        //        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleForceUpdate),
                                               name: .forceUpdate,
                                               object: nil)
        
        if let animation = LottieAnimation.named("green_tick") {
                    animationView = LottieAnimationView(animation: animation)
            
                    animationView?.frame = CGRect(x: 0, y: 0, width: 300, height: 300)

                    animationView?.center = view.center
                    animationView?.contentMode = .scaleAspectFit
                    animationView?.loopMode = .loop
                    animationView?.play()

                    if let animView = animationView {
                        view.addSubview(animView)
                    }
                } else {
                    print("Animation not found!")
                }
        
        
        if let apiTimer = apiTimer {
            TimerManager.shared.registerTimer(apiTimer)
        }
        
        
        okButton.layer.cornerRadius = 10
        fareView.roundCorners([.topLeft, .topRight], radius: 10)
        startimer?.invalidate()
        startimer = nil
        if pickupamout == 0 {
            pickupChargesLbl.isHidden = true
            pickupamountLbl.isHidden = true
            NSLayoutConstraint.activate([
                estimatedRideCharges.topAnchor.constraint(equalTo: self.fareTitleLbl.bottomAnchor, constant: 10)
            ])
        } else {
            pickupamountLbl.text = "Rs " + String(Int(pickupamout ?? 0))
        }
        fareAmountLbl.text = "Rs " + String(Int(fareAmount ?? 0))
        totalAmoutLbl.text = "Rs " + String(Int(totalAmout ?? 0))
        apiTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(sessionTimeOut), userInfo: nil, repeats: true)
        
        //        let animationView = DotLottieAnimation(fileName: "Animation - 1744005140184", config: AnimationConfig(autoplay: true, loop: true))
        //        let animationView = DotLottieAnimationView
        //        gifAnimationView = DotLottieAnimationView(dotLottieViewModel: animationView)
        //        gifAnimationView.addSubview(animationView)
        
        
        modifyLabel()
    }
    
    func animation() {
        guard let filePath = Bundle.main.path(forResource: "Animation - 1744005140184", ofType: "lottie"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
            print("File not found")
            return
        }
        
        //                DotLottieFile.loadedFrom(from: filePath) { result in
        //                    switch result {
        //                    case .success(let dotLottieFile):
        //                        if let animationModel = dotLottieFile.animations.first {
        //                            let animationView = DotLottieAnimationView(dotLottieViewModel: animationModel)
        //                            animationView.translatesAutoresizingMaskIntoConstraints = false
        //                            self.view.addSubview(animationView)
        //
        //                            // Layout using Auto Layout
        //                            NSLayoutConstraint.activate([
        //                                animationView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        //                                animationView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        //                                animationView.widthAnchor.constraint(equalToConstant: 300),
        //                                animationView.heightAnchor.constraint(equalToConstant: 300)
        //                            ])
        //
        //                            animationView.play()
        //                            self.animationView = animationView
        //                        }
        //                    case .failure(let error):
        //                        print("DotLottie load error: \(error)")
        //                    }
        //                }
    }
    
    @IBAction func okButtonAction(_ sender: Any) {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        TimerManager.shared.stopAllTimers()
        self.apiTimer = nil
        self.apiTimer?.invalidate()
        let mapVC = storyboard?.instantiateViewController(identifier: "MapViewController") as! MapViewController
        mapVC.member_master_profile_id = self.member_master_profile_id
        self.navigationController?.pushViewController(mapVC, animated: true)
        
    }
    
    func modifyLabel() {                
        if vehicle_type_id == 3 {
            pickupORtotalamountLBL.text = "₹ \(totalAmout ?? 0)"
            pickupORtotalchargesLBL.text = "Total charges"
            pickupORtotalcommentLBL.text = "Please pay the above amount to the driver."
        } else {
            pickupORtotalamountLBL.text = "₹ \(pickupamout ?? 0)"
            pickupORtotalchargesLBL.text = "Pickup charges"
            pickupORtotalcommentLBL.text = "Please pay pickup charges + meter charges"
        }
    }
    
    @objc func handleForceUpdate(_ notification: Notification) {
        sessionTimeOut()
    }
    
    @objc func sessionTimeOut() {
        //        gpsdisableAlert()
        if Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "") != 0 || UserDefaults.standard.string(forKey: "fk_member_master_profile_id") !=  nil {
            let url = AppConfig.baseURL+"login/SessionTimeOut_VersionCheck"
            let params :  [String : Any] = [
                "imeI_No": UIDevice.current.identifierForVendor?.uuidString,
                "fk_member_master_profile_id": Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "")
            ]
            let token = UserDefaults.standard.string(forKey: "auth_deviceToken") ?? ""

            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]
            print("EndTripViewController() -> sessionTimeOut() -> url : \(url)")
            print("EndTripViewController() -> sessionTimeOut() -> params : \(params)")
            AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { [self] response in
                
                print("recentSearchList() -> response : \(response.result)")
                switch response.result {
                    
                case .success (let data) :
                    if let data = data {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                               let loginResult = json["result"] as? [String: Any] {
                                print("EndTripViewController() -> sessionTimeOut() -> JSON -------\(json)")
                                let status = loginResult["status"] as? String ?? ""
                                let message = loginResult["message"] as? String ?? ""
                                let version = loginResult["version"] as? [[String: Any]]
                                
                                if status == "0" {
                                    if let version = version {
                                        print("EndTripViewController() -> sessionTimeOut() -> version : \(version)")
                                        for dict in version {
                                            iOSversion = dict["ios"] as? String
                                        }
                                        if let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let apiVersion = iOSversion {
                                            print("APIVersion : \(apiVersion)")
                                            print("codeVersion : \(versionString)")
                                            
                                            if Int(versionString) ?? 0 < Int(apiVersion) ?? 0 {
                                                apiTimer?.invalidate()
                                                apiTimer = nil
                                                TimerManager.shared.stopAllTimers()
                                                
                                                let alert = UIAlertController(title:  "New Version Available", message: "There is a newer version avaliable for download! Please update the app by visiting the App Store", preferredStyle: UIAlertController.Style.alert)
                                                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler:{(action:UIAlertAction) in
                                                    AppConfig.gotoAppStore()
                                                }));
                                                self.present(alert, animated: true, completion: nil)
                                                
                                            }
                                            
                                        }
                                    }
                                }
                                else if status == "-1" {
                                    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                                    UserDefaults.standard.set("", forKey: "loggedin")
                                    if Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "") != 0 && UserDefaults.standard.string(forKey: "fk_member_master_profile_id") != nil && member_master_profile_id != nil {
                                        apiTimer?.invalidate()
                                        apiTimer = nil
                                        TimerManager.shared.stopAllTimers()
                                        member_master_profile_id = nil
                                        UserDefaults.standard.setValue(member_master_profile_id, forKey: "fk_member_master_profile_id")
                                        
                                        
                                        // Add an action (button)
                                        //                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                        //                                    if !(self is ViewController) && !(self is MobileNoViewController) && !(self is OTPViewController) && !(self is RegisterMobileNoViewController) && !(self is RegisterOTPViewController) && !(self is RegistrationViewController) {
                                        // Check if it's MapViewController or any other allowed view controller
                                        //                                             let alertController = UIAlertController(title: "", message: "Session Time out , Member is deleted!!", preferredStyle: .alert)
                                        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
                                        
                                        let okAction = UIAlertAction(title: "OK", style: .default) { [self] _ in
//                                            let otpVC = storyboard?.instantiateViewController(identifier: "LoginRegisterViewController") as! LoginRegisterViewController
                                            member_master_profile_id = nil
                                            UserDefaults.standard.setValue(member_master_profile_id, forKey: "fk_member_master_profile_id")
//                                            self.navigationController?.pushViewController(otpVC, animated: false)
                                            
                                            let otpVC = self.storyboard?.instantiateViewController(identifier: "LoginRegisterViewController") as! LoginRegisterViewController
                                            let navController = UINavigationController(rootViewController: otpVC)

                                            DispatchQueue.main.async {

                                                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                                                    sceneDelegate.window?.rootViewController = navController
                                                    sceneDelegate.window?.makeKeyAndVisible()
                                                }
                                            }
                                        }
                                        
                                        alertController.addAction(okAction)
                                        self.present(alertController, animated: true, completion: nil)
                                        //                                    }
                                    }
                                    
                                } else if status == "-2" {
                                    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                                    UserDefaults.standard.set("", forKey: "loggedin")
                                    if Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "") != 0 && UserDefaults.standard.string(forKey: "fk_member_master_profile_id") != nil && member_master_profile_id != nil {
                                        apiTimer?.invalidate()
                                        apiTimer = nil
                                        TimerManager.shared.stopAllTimers()
                                        member_master_profile_id = nil
                                        UserDefaults.standard.setValue(member_master_profile_id, forKey: "fk_member_master_profile_id")
                                        //                                    if !(self is ViewController) && !(self is MobileNoViewController) && !(self is OTPViewController) && !(self is RegisterMobileNoViewController) && !(self is RegisterOTPViewController) && !(self is RegistrationViewController) {
                                        //                                        if self.isKind(of: MapViewController.self) {
                                        //                                             let alertController = UIAlertController(title: "", message: "Session Timeout. Another user logged in with the same number!", preferredStyle: .alert)
                                        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
                                        
                                        let okAction = UIAlertAction(title: "OK", style: .default) { [self] _ in
//                                            let otpVC = storyboard?.instantiateViewController(identifier: "LoginRegisterViewController") as! LoginRegisterViewController
                                            member_master_profile_id = nil
                                            UserDefaults.standard.setValue(member_master_profile_id, forKey: "fk_member_master_profile_id")
//                                            self.navigationController?.pushViewController(otpVC, animated: false)
                                            
                                            let otpVC = self.storyboard?.instantiateViewController(identifier: "LoginRegisterViewController") as! LoginRegisterViewController
                                            let navController = UINavigationController(rootViewController: otpVC)

                                            DispatchQueue.main.async {

                                                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                                                    sceneDelegate.window?.rootViewController = navController
                                                    sceneDelegate.window?.makeKeyAndVisible()
                                                }
                                            }
                                        }
                                        
                                        alertController.addAction(okAction)
                                        self.present(alertController, animated: true, completion: nil)
                                        //                                        }
                                        //                                    }
                                        
                                    }
                                    
                                }
                                //                                else if status == "1" {
                                //                                    let alertController = UIAlertController(title: "", message: "No Record Found!!", preferredStyle: .alert)
                                //
                                //                                    // Add an action (button)
                                //                                    //                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                //                                    let okAction = UIAlertAction(title: "OK", style: .default) { [self] _ in
                                //                                        member_master_profile_id = "0"
                                //                                        UserDefaults.standard.setValue(member_master_profile_id, forKey: "fk_member_master_profile_id")
                                //                                        let otpVC = storyboard?.instantiateViewController(identifier: "ViewController") as! ViewController
                                //
                                //                                        self.navigationController?.pushViewController(otpVC, animated: true)
                                //                                    }
                                //                                    alertController.addAction(okAction)
                                //
                                //                                    // Present the alert
                                //                                    self.present(alertController, animated: true, completion: nil)
                                //
                                //
                                //                                }
                                
                            }
                        } catch {
                            //                                   self.showAlert(title: "Error", message: "Failed to parse JSON: \(error.localizedDescription)")
                            let alertController = UIAlertController(title: "Network Error", message: "", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    } else {
                        print("Data is nil")
                    }
                    
                case .failure(let error):
                    print("Request failed with error: \(error)")
                }
            }
        }
    }
}
