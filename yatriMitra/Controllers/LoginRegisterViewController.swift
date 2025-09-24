//
//  LoginRegisterViewController.swift
//  yatriMitra
//
//  Created by Kaizen Infotech Solutions Private Limited. on 14/01/25.
//

import UIKit
import Alamofire
import Contacts
import AVFoundation

@available(iOS 13.0, *)

class LoginRegisterViewController: UIViewController ,UITextViewDelegate {
    
    @IBOutlet weak var yatriMitraLogoView: UIView!
    @IBOutlet weak var yatriMitraLogoViewHeight: NSLayoutConstraint!
    @IBOutlet weak var yatriMitraLogoViewWidth: NSLayoutConstraint!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var conditionsTxtView: UITextView!
    @IBOutlet weak var mainImge: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var loginBtnHeight: NSLayoutConstraint!
    @IBOutlet weak var registerBtnHeight: NSLayoutConstraint!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var rideON2ImgHeight: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
//        loginBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
//        registerBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        TimerManager.shared.stopAllTimers()
        let height = UIScreen.main.bounds.height
        print("height : \(height)")
        let width = UIScreen.main.bounds.width
        print("width : \(width)")
        if height > 800 {
            yatriMitraLogoViewWidth.constant = 175
            yatriMitraLogoViewHeight.constant = 200
            loginBtnHeight.constant = 35
            registerBtnHeight.constant = 35
            NSLayoutConstraint.activate([
                // Align the center X of yourView to the center X of the main view with a 10-point offset
                //                bottomView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 10),
                yatriMitraLogoView.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
                // Set the top of bottomView to be 20 points below the center Y of the main view
                bottomView.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 200)
                //
                //                        // Optionally, set width and height for yourView
                //                        yourView.widthAnchor.constraint(equalToConstant: 100),
                //                        yourView.heightAnchor.constraint(equalToConstant: 100)
            ])
        }
        rideON2ImgHeight.constant = height
        print("rideON2ImgHeight.constant : \(rideON2ImgHeight.constant)")
        bottomView.translatesAutoresizingMaskIntoConstraints = false

//        if let superview = bottomView.superview {
//            print("bottomView.superview")
//            NSLayoutConstraint.activate([
//                bottomView.topAnchor.constraint(equalTo: superview.bottomAnchor, constant: 10)
//            ])
//        }
//        setBackgroundImage(to: yatriMitraSecondView, with: "RIdeON2")
        let contactStore = CNContactStore()
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)

        if authorizationStatus == .notDetermined {
            // Request access if the status is not determined
            contactStore.requestAccess(for: .contacts) { (granted, error) in
                if granted {
                    print("Contacts permission granted.")
                    // Access contacts here
                } else {
                    print("Contacts permission denied.")
                    // Handle permission denial
                }
            }
        } else if authorizationStatus == .denied {
            print("Contacts permission is denied.")
            // Handle denied state (show an alert or guide user to settings)
        } else if authorizationStatus == .authorized {
            print("Contacts permission already granted.")
            // Access contacts directly if permission is granted
        } else {
            print("Contacts permission status is restricted.")
            // Handle restricted state
        }
        let microphoneStatus = AVAudioSession.sharedInstance().recordPermission

        if microphoneStatus == .undetermined {
            // Request access if the status is undetermined
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                if granted {
                    print("Microphone permission granted.")
                    // Start recording or use the microphone
                } else {
                    print("Microphone permission denied.")
                    // Handle permission denial (e.g., show an alert to guide the user)
                }
            }
        } else if microphoneStatus == .denied {
            print("Microphone permission is denied.")
            // Handle denied state (show an alert or guide user to settings)
        } else if microphoneStatus == .granted {
            print("Microphone permission already granted.")
            // Proceed with microphone usage
        } else {
            print("Microphone permission status is restricted.")
            // Handle restricted state (e.g., show an alert)
        }
        editContinueWithPhoneNoBtn()
        deviceToken()
        let imei = UIDevice.current.identifierForVendor?.uuidString
        print("imei : \(imei)")
        conditionsTxtViewAction()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
//        loginBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
//        registerBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        TimerManager.shared.stopAllTimers()
    }
    override func viewDidAppear(_ animated: Bool) {
        TimerManager.shared.stopAllTimers()
    }
    override func viewWillDisappear(_ animated: Bool) {
        TimerManager.shared.stopAllTimers()
    }
    override func viewDidDisappear(_ animated: Bool) {
        TimerManager.shared.stopAllTimers()
    }
    func setBackgroundImage(to view: UIView, with imageName: String) {
        // Create UIImageView with the desired image
        let backgroundImageView = UIImageView(frame: view.bounds)
        backgroundImageView.image = UIImage(named: imageName)
        
        // Ensure the image view resizes correctly with the view
        backgroundImageView.contentMode = .scaleAspectFill
        
        // Add the image view as a subview
        view.addSubview(backgroundImageView)
        
        // Send the image view to the back so it doesn't cover other subviews
        view.sendSubviewToBack(backgroundImageView)
    }
    func editContinueWithPhoneNoBtn() {
        loginBtn.layer.cornerRadius = 15
        registerBtn.layer.cornerRadius = 15
    }
    
//    func conditionsTxtViewAction() {
//           let text = "By continuing, you agree that you have read and accept our T&Cs and Privacy Policy"
//           let attributedString = NSMutableAttributedString(string: text)
//           
//           // Set attributes for T&Cs
//           let termsRange = (text as NSString).range(of: "T&Cs")
//           attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: termsRange)
//           attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: termsRange)
//           attributedString.addAttribute(.link, value: "https://yatrimitra.com/terms-conditions.html", range: termsRange)
//           
//           // Set attributes for Privacy Policy
//           let privacyRange = (text as NSString).range(of: "Privacy Policy")
//           attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: privacyRange)
//           attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: privacyRange)
//           attributedString.addAttribute(.link, value: "https://yatrimitra.com/public/privacy.html", range: privacyRange)
//
//           // Set attributes for Privacy Policy
//           conditionsTxtView.attributedText = attributedString
//           conditionsTxtView.isEditable = false
//           conditionsTxtView.isScrollEnabled = false
//           conditionsTxtView.delegate = self
//           
//           // Remove padding
//           conditionsTxtView.textContainerInset = .zero
//           conditionsTxtView.textContainer.lineFragmentPadding = 0
//       }
    
    func conditionsTxtViewAction() {
        let text = "By continuing, you agree that you have read and accept our T&Cs and Privacy Policy."
        let attributedString = NSMutableAttributedString(string: text)
        
        // Set attributes for T&Cs
        let termsRange = (text as NSString).range(of: "T&Cs")
        attributedString.addAttribute(.foregroundColor, value: UIColor.blue, range: termsRange)
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: termsRange)
        attributedString.addAttribute(.link, value: "termsAndConditions", range: termsRange)
        
        // Set attributes for Privacy Policy
        let privacyRange = (text as NSString).range(of: "Privacy Policy")
        attributedString.addAttribute(.foregroundColor, value: UIColor.blue, range: privacyRange)
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: privacyRange)
        attributedString.addAttribute(.link, value: "privacyPolicy", range: privacyRange)
        
        // Configure the UITextView
        conditionsTxtView.attributedText = attributedString
        conditionsTxtView.isEditable = false
        conditionsTxtView.isScrollEnabled = false
        conditionsTxtView.isUserInteractionEnabled = true
        conditionsTxtView.delegate = self
        
        // Remove padding
        conditionsTxtView.textContainerInset = .zero
        conditionsTxtView.textContainer.lineFragmentPadding = 0
    }

    @objc func labelTapped(_ gesture: UITapGestureRecognizer) {
        let mobileNoVC = storyboard?.instantiateViewController(identifier: "TermsandConditionsViewController") as! TermsandConditionsViewController
        mobileNoVC.urlString = "https://yatrimitra.com/public/terms.html"
        self.navigationController?.pushViewController(mobileNoVC, animated: true)
    }
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            if URL.absoluteString == "termsAndConditions" {
                let termsVC = storyboard?.instantiateViewController(withIdentifier: "TermsandConditionsViewController") as! TermsandConditionsViewController
                termsVC.urlString = "https://yatrimitra.com/public/terms.html"
                self.navigationController?.pushViewController(termsVC, animated: true)
            } else if URL.absoluteString == "privacyPolicy" {
                let privacyVC = storyboard?.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
                privacyVC.urlString = "https://yatrimitra.com/public/privacy.html"
                self.navigationController?.pushViewController(privacyVC, animated: true)
            }
            return false // Prevent default behavior of opening URLs in a browser
        }

    @IBAction func loginBtnAction(_ sender: Any) {
        let mobileNoVC = storyboard?.instantiateViewController(identifier: "MobileNoViewController") as! MobileNoViewController
        self.navigationController?.pushViewController(mobileNoVC, animated: true)
    }
    
    @IBAction func registerBtnAction(_ sender: Any) {
        let mobileNoVC = storyboard?.instantiateViewController(identifier: "RegisterMobileNoViewController") as! RegisterMobileNoViewController
        self.navigationController?.pushViewController(mobileNoVC, animated: true)
    }
    
    func deviceToken()  {
        let url = AppConfig.baseURL+"authtoken/authentication"
        var params: [String: String] = ["username": "YatriMitra", "Password": "YatriMitra@987654#$"]
        let headers: HTTPHeaders = [
              "Content-Type": "application/json"
            ]
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil, interceptor: nil).response { response in
            
            print("response authtoken2: \(response.result)")
                switch response.result {
                case .success(let data):
                    do{
                      guard let jsonData = data else {
                          print("Error: Data is nil")
                          return
                      }
                      let responseData = try JSONDecoder().decode(ResponseData.self, from: jsonData)
                      print("auth jsonData : ", responseData)
                        var deviceToken = responseData.result.token
                            print("deviceToken : \(deviceToken)")
                            UserDefaults.standard.setValue(deviceToken, forKey: "auth_deviceToken")
                    
                   } catch {
                       print("catch error: ",error.localizedDescription)
                       let alertController = UIAlertController(title: "Network Error", message: "", preferredStyle: .alert)
                           let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                           alertController.addAction(okAction)
                           self.present(alertController, animated: true, completion: nil)
                   }
                    //                    let dd = response as? NSDictionary
                    //                    let status = ((dd?.value(forKey: "result") as! AnyObject).value(forKey: "status"))
                    //                    let message = ((dd?.value(forKey: "result") as! AnyObject).value(forKey: "message"))
                    //                    let token = ((dd?.value(forKey: "result") as! AnyObject).value(forKey: "token"))
                    ////                    let status = loginResult?["status"] as? String
                    //                    print("status : \(status)")
                    ////                    let message = loginResult?["message"] as? String
                    //                    print("message : \(message)")
                    ////                    let token = loginResult?["token"] as? String
                    //                    print("token : \(token)")
                case .failure(let error):
                    print("Error : ",error.localizedDescription)
                }
            }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("******************** DEINIT LoginRegisterViewcontroller REMOVED FROM MEMORY*********************")
    }
}

struct LoginResult: Decodable {
    let status: String
    let message: String
    let token: String
}

struct ResponseData: Decodable {
    let result: LoginResult
}
