//
//  RegistrationViewController.swift
//  yatriMitra
//
//  Created by IOS 2 on 25/06/24.
//

import UIKit
import Alamofire
import CoreLocation
import FacebookCore

class RegistrationViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var someView: UIView!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var genderTF: UITextField!
    @IBOutlet weak var userNameBGView: UIView!
    @IBOutlet weak var genderBGView: UIView!
    @IBOutlet weak var emailIDView: UIView!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var gestureView: UIView!
    @IBOutlet weak var genderImg: UIImageView!
    @IBOutlet weak var genderDropDownView: UIView!
    @IBOutlet weak var mLbl: UILabel!
    @IBOutlet weak var fLbl: UILabel!
    @IBOutlet weak var oLbl: UILabel!
    @IBOutlet weak var pLbl: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var buttonOpticity: UIButton!
    @IBOutlet weak var activityIndicatorView: UIView!
    @IBOutlet weak var registerActivityIndicator: UIActivityIndicatorView!
    
    var toggleView = false
    var mobileNumber:String?
    var member_master_profile_id : Int?
    var loader = UIActivityIndicatorView(style: .medium)
    var lastClickTime: CFTimeInterval = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        createNavigationBar()
        NetworkMonitor.shared
        userNameTF.delegate = self
        self.userNameBGView.layer.cornerRadius = 8
        self.genderBGView.layer.cornerRadius = 8
        self.genderDropDownView.layer.cornerRadius = 8
        self.emailIDView.layer.cornerRadius = 8
        self.registerBtn.layer.cornerRadius = 15
        addDoneButtonOnNumpad(textField: userNameTF)
        addDoneButtonOnNumpad(textField: genderTF)
        addDoneButtonOnNumpad(textField: emailTF)
        buttonOpticity.isHidden = true
        activityIndicator.isHidden = true
        loader.color = .white
                loader.translatesAutoresizingMaskIntoConstraints = false
        registerBtn.addSubview(loader)

                        // Center the activity indicator within the button
                        NSLayoutConstraint.activate([
                            loader.centerXAnchor.constraint(equalTo: registerBtn.centerXAnchor),
                            loader.centerYAnchor.constraint(equalTo: registerBtn.centerYAnchor)
                        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
                view.addGestureRecognizer(tapGesture)
        gestureviews()
        self.genderDropDownView.isHidden = true
        registerForKeyboardNotifications()
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillShowNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        print("******************** DEINIT RegistrationViewController REMOVED FROM MEMORY*********************")
    }
    @objc func keyboardWillShow(_ notification: Notification){
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
//        var userInfo = notification.userInfo!
//        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
//        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
//
//        var contentInset:UIEdgeInsets = self.scrollView.contentInset
//        contentInset.bottom = keyboardFrame.size.height
//        scrollView.contentInset = contentInset
        
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                let keyboardHeight = keyboardFrame.height
                
                // Calculate button's bottom position relative to the screen
            let buttonFrameInView = emailTF.convert(emailTF.bounds, to: self.view)
                let buttonBottom = buttonFrameInView.maxY + 20  // 20 points padding
                
                // Get screen height
                let screenHeight = UIScreen.main.bounds.height
                
                // If the button is hidden behind the keyboard, adjust the scrollView
                let offset = max(0, buttonBottom - (screenHeight - keyboardHeight))
                
                UIView.animate(withDuration: 0.3) {
                    self.scrollView.contentInset.bottom = keyboardHeight
                    self.scrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
                }
            }
    }

    @objc func keyboardWillHide(_ notification: Notification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    func gestureviews() {
        gestureView.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(genderTapped(_:)))
        gestureView.addGestureRecognizer(tapGestureRecognizer)
        
        mLbl.isUserInteractionEnabled = true
        let tapmLblTappedGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mLblTapped(_:)))
        mLbl.addGestureRecognizer(tapmLblTappedGestureRecognizer)
        
        fLbl.isUserInteractionEnabled = true
        let tapfLblTappedGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(fLblTapped(_:)))
        fLbl.addGestureRecognizer(tapfLblTappedGestureRecognizer)
        
        oLbl.isUserInteractionEnabled = true
        let tapoLblTappedGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(oLblTapped(_:)))
        oLbl.addGestureRecognizer(tapoLblTappedGestureRecognizer)
        
        pLbl.isUserInteractionEnabled = true
        let tappLblTappedGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pLblTapped(_:)))
        pLbl.addGestureRecognizer(tappLblTappedGestureRecognizer)
    }
    
    @objc func genderTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
        self.genderImg.image == UIImage(named: "genderselect") ? (self.toggleView = true) : (self.toggleView = false)
        if toggleView {
            self.genderDropDownView.isHidden = false
            self.genderImg.image = UIImage(named: "down")
            self.toggleView = false
        } else {
            self.genderDropDownView.isHidden = true
            self.genderImg.image = UIImage(named: "genderselect")
            self.toggleView = true
        }
        
    }
    
    
    @objc func dismissKeyboard() {
            view.endEditing(true) // This will dismiss the keyboard
        }
    @objc func mLblTapped(_ sender: UITapGestureRecognizer) {
        genderTF.text = "Male"
        self.genderDropDownView.isHidden = true
        self.genderImg.image = UIImage(named: "genderselect")
    }
    
    @objc func fLblTapped(_ sender: UITapGestureRecognizer) {
        genderTF.text = "Female"
        self.genderDropDownView.isHidden = true
        self.genderImg.image = UIImage(named: "genderselect")
    }
    
    @objc func oLblTapped(_ sender: UITapGestureRecognizer) {
        genderTF.text = "Other"
        self.genderDropDownView.isHidden = true
        self.genderImg.image = UIImage(named: "genderselect")
    }
    @objc func pLblTapped(_ sender: UITapGestureRecognizer){
        genderTF.text = "Prefer Not to Say"
        self.genderDropDownView.isHidden = true
        self.genderImg.image = UIImage(named: "genderselect")
    }
    
    func createNavigationBar() {
        let customBackButton = UIButton()
        customBackButton.setImage(UIImage(named: "back"), for: .normal)
        customBackButton.addTarget(self, action: #selector(customBackButtonTapped), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customBackButton)
    }
    private func registerForKeyboardNotifications() {
           NotificationCenter.default.addObserver(
               self,
               selector: #selector(keyboardWillShow(_:)),
               name: UIResponder.keyboardWillShowNotification,
               object: nil
           )
           NotificationCenter.default.addObserver(
               self,
               selector: #selector(keyboardWillHide(_:)),
               name: UIResponder.keyboardWillHideNotification,
               object: nil
           )
       }
       
//       @objc private func keyboardWillShow(_ notification: Notification) {
//           adjustViewForKeyboard(notification: notification, isKeyboardShowing: true)
//       }
//       
//       @objc private func keyboardWillHide(_ notification: Notification) {
//           adjustViewForKeyboard(notification: notification, isKeyboardShowing: false)
//       }
       
       private func adjustViewForKeyboard(notification: Notification, isKeyboardShowing: Bool) {
           guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
           
           let keyboardHeight = keyboardFrame.height
           let adjustmentHeight = isKeyboardShowing ? -keyboardHeight : 0
           
           UIView.animate(withDuration: 0.3) {
               self.someView.transform = CGAffineTransform(translationX: 0, y: adjustmentHeight)
           }
       }
    @objc func customBackButtonTapped() {
//        self.navigationController?.popViewController(animated: true)
        let alertController = UIAlertController(title: "",
                                                message: "Your changes are not saved, are you sure you want to go back?",
                                                preferredStyle: .alert)

        // Yes action
        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            print("Yes button tapped")
            // Perform actions when "Yes" is tapped
//            let mobileNoVC = self.storyboard?.instantiateViewController(identifier: "LoginRegisterViewController") as! LoginRegisterViewController
//            self.navigationController?.pushViewController(mobileNoVC, animated: true)
            if let viewControllers = self.navigationController?.viewControllers {
                for vc in viewControllers {
                    if vc is LoginRegisterViewController {
                        self.navigationController?.popToViewController(vc, animated: true)
                        break
                    }
                }
            }
        }

        let noAction = UIAlertAction(title: "No", style: .default, handler: nil)
        // No action
//        let noAction = UIAlertAction(title: "No", style: .cancel) { _ in
//            print("No button tapped")
//            // Perform actions when "No" is tapped
//        }

        // Add the actions to the alert controller
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        

        // Present the alert controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    func addDoneButtonOnNumpad(textField: UITextField) {
//        let keypadToolbar: UIToolbar = UIToolbar()
//        keypadToolbar.items=[
//            UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: textField, action: #selector(UITextField.resignFirstResponder)),
//            UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
//        ]
//        keypadToolbar.sizeToFit()
//        textField.inputAccessoryView = keypadToolbar
        let keypadToolbar: UIToolbar = UIToolbar()
        keypadToolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // Done button
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        
        // Add flexible space and done button to the toolbar
        keypadToolbar.items = [flexibleSpace, doneButton]
        textField.inputAccessoryView = keypadToolbar
    }
    
    
    @IBAction func registerBtnAction(_ sender: Any) {
        registerBtn.setTitle("", for: .normal)
        activityIndicatorView.isHidden = false
        registerActivityIndicator.startAnimating()
//        let currentTime = CACurrentMediaTime()

//         if currentTime - lastClickTime < 1 { // Ignore multiple clicks within 1 second
//             return
//         }
//
//         lastClickTime = currentTime

         // Handle button click action
         print("Button clicked")
        if NetworkMonitor.shared.isConnected{
            buttonOpticity.isHidden = false
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            registerBtn.setTitle("", for: .normal)
            registerBtn.isEnabled = false
            loader.startAnimating()
            if userNameTF.text == nil || userNameTF.text == ""{
                registerBtn.setTitle("Register", for: .normal)
                activityIndicatorView.isHidden = true
                registerActivityIndicator.stopAnimating()
                print("usrename is mandatory")
                activityIndicator.stopAnimating()
                activityIndicator.isHidden = true
                buttonOpticity.isHidden = true
                showAlert(message: "Please Enter Your Name")
            } else if genderTF.text == nil || genderTF.text == "" {
                registerBtn.setTitle("Register", for: .normal)
                activityIndicatorView.isHidden = true
                registerActivityIndicator.stopAnimating()
                print("gender is mandatory")
                activityIndicator.stopAnimating()
                activityIndicator.isHidden = true
                buttonOpticity.isHidden = true
                showAlert(message: "Please Select Gender")
            } else if let email = emailTF.text  {
                if isValidEmail(email) && !email.isEmpty{
                    print("Valid Email")
                    registerUser()
                    // Proceed with the desired action
                } else if !isValidEmail(email) && !email.isEmpty{
                    print("Invalid Email")
                    registerBtn.setTitle("Register", for: .normal)
                    activityIndicatorView.isHidden = true
                    registerActivityIndicator.stopAnimating()
                    activityIndicator.stopAnimating()
                    activityIndicator.isHidden = true
                    buttonOpticity.isHidden = true
                    showEmailAlert(message: "Please enter a valid email address.")
                }
                else {
                    registerUser()
                }
            } else {
                registerUser()
            }
        }
        else{
            print("you are not connected")
            let alert = UIAlertController(title: "No Internet Connection",
                                          message: "It looks like you're offline. Please check your internet connection.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default,handler: { [self] _ in
                loader.stopAnimating()
                registerBtn.isEnabled = true
                registerBtn.setTitle("Register", for: .normal)
                activityIndicatorView.isHidden = true
                registerActivityIndicator.stopAnimating()
                                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                            if UIApplication.shared.canOpenURL(url) {
                                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                            }
                                        }
            }))
            present(alert, animated: true, completion: nil)
        }

    }
    
    func showEmailAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] _ in
            loader.stopAnimating()
            registerBtn.isEnabled = true
            registerBtn.setTitle("Register", for: .normal)
            emailTF.text = ""
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "(?:[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\\.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-zA-Z0-9-]*[a-zA-Z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    func showAlert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [self] _ in
            loader.stopAnimating()
            registerBtn.isEnabled = true
            registerBtn.setTitle("Register", for: .normal)
            
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func registerUser() {
    let url = AppConfig.baseURL+"member/AddEditUser_Details"
        let params : [String : Any] = ["pk_member_master_profile_id": 0,
                                       "mobile_number": mobileNumber,
                                       "first_name": userNameTF.text,
                                       "gender": genderTF.text,
                                       "emailID": emailTF.text,
                                       "IMEI_No": UIDevice.current.identifierForVendor?.uuidString,
//                                       "DeviceToken": UserDefaults.standard.string(forKey: "auth_deviceToken"),
                                       "DeviceToken": UserDefaults.standard.string(forKey: "fcm_token"),
                                       "Device_name": "iOS",
                                       "versionNo": "1.1"]
        print("RegistrationViewController -> registerUser() -> url : \(url)")
        print("RegistrationViewController -> registerUser() -> params : \(params)")
        
        let token = UserDefaults.standard.string(forKey: "auth_deviceToken") ?? ""

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { [self] response in
            switch response.result {
                
            case .success (let data) :
                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let loginResult = json["result"] as? [String: Any] {
                            activityIndicator.stopAnimating()
                            activityIndicator.isHidden = true
                            buttonOpticity.isHidden = true
                            loader.stopAnimating()
                            registerBtn.isEnabled = true
                            registerBtn.setTitle("Register", for: .normal)
                            
                            let status = loginResult["status"] as? String ?? ""
                            let message = loginResult["message"] as? String ?? ""
                            let fk_member_master_profile_id = loginResult["fk_member_master_profile_id"] as? Int
                            self.member_master_profile_id=fk_member_master_profile_id
                            if status == "0" {
                                
                                //MARK: FACEBOOK INTEGRATION
                                
                                let parameters: [AppEvents.ParameterName: String] = [
                                    .registrationMethod: "phone",
                                    AppEvents.ParameterName("platform"): "ios"
                                ]

                                AppEvents.shared.logEvent(.completedRegistration, parameters: parameters)
                                AppEvents.shared.logEvent(AppEvents.Name("registration_successful"), parameters: [
                                        AppEvents.ParameterName("platform"): "ios"
                                    ])
                                
                                
                                //                            self.view.showToast(message: "User Registered Successfully")
                                registerBtn.setTitle("Register", for: .normal)
                                activityIndicatorView.isHidden = true
                                registerActivityIndicator.stopAnimating()
                                let alertController = UIAlertController(title: "", message: "User Registered Successfully", preferredStyle: .alert)
                                
                                // Present the alert controller
                                self.present(alertController, animated: true) {
                                    UserDefaults.standard.set("LoggedIN", forKey: "loggedin")
                                    
                                    //GOOGLE ANALYTICS
                                    AnalyticsManager.shared.signupComplete(method: "Registration Success")
                                    
                                    // Dismiss the alert after 5 seconds
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                        alertController.dismiss(animated: true) {
                                            if !CLLocationManager.locationServicesEnabled(){
                                                registerBtn.setTitle("Register", for: .normal)
                                                activityIndicatorView.isHidden = true
                                                registerActivityIndicator.stopAnimating()
                                                let otpVC = storyboard?.instantiateViewController(identifier: "GPSSettingViewController") as! GPSSettingViewController
                                                otpVC.member_master_profile_id=self.member_master_profile_id
                                                self.navigationController?.pushViewController(otpVC, animated: true)
                                            } else if CLLocationManager.authorizationStatus() == .notDetermined ||  CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied {
                                                registerBtn.setTitle("Register", for: .normal)
                                                activityIndicatorView.isHidden = true
                                                registerActivityIndicator.stopAnimating()
                                                let otpVC = storyboard?.instantiateViewController(identifier: "WelcomeViewController") as! WelcomeViewController
                                                otpVC.member_master_profile_id=self.member_master_profile_id
                                                self.navigationController?.pushViewController(otpVC, animated: true)
                                            } else {
                                                registerBtn.setTitle("Register", for: .normal)
                                                activityIndicatorView.isHidden = true
                                                registerActivityIndicator.stopAnimating()
                                                let otpVC = storyboard?.instantiateViewController(identifier: "MapViewController") as! MapViewController
                                                otpVC.showBanner = UserDefaults.standard.string(forKey: "showBanner")
                                                otpVC.member_master_profile_id=self.member_master_profile_id
                                                self.navigationController?.pushViewController(otpVC, animated: true)
                                            }
                                        }
                                        //                                    alertController.dismiss(animated: true, completion: nil)
                                    }
                                }
                                //                            let otpVC = self.storyboard?.instantiateViewController(identifier: "GPSSettingViewController") as! GPSSettingViewController
                                //                            otpVC.member_master_profile_id=self.member_master_profile_id
                                //                            self.navigationController?.pushViewController(otpVC, animated: true)
                            }
                        } else {
                            //                                       self.showAlert(title: "Error", message: "Invalid response format")
                        }
                    } catch {
                        //                                   self.showAlert(title: "Error", message: "Failed to parse JSON: \(error.localizedDescription)")
                        let alertController = UIAlertController(title: "Network Error", message: "", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                } else {
                    
                }
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    }

//MARK: UITEXTFIELD DELEGATES
extension RegistrationViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == userNameTF || textField == emailTF {
            self.genderDropDownView.isHidden = true
            self.genderImg.image = UIImage(named: "genderselect")
            self.toggleView = true
        }
    }
}

extension UIView {
    func showToast(message: String, duration: Double) {
        let toastLabel = UILabel(frame: CGRect(x: self.frame.size.width / 2 - 75, y: self.frame.size.height - 100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        self.addSubview(toastLabel)
        
        UIView.animate(withDuration: duration, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: { _ in
            toastLabel.removeFromSuperview()
        })
    }
}
