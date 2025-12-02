//
//  MobileNoViewController.swift
//  RideON
//
//  Created by Kaizen Infotech Solutions Private Limited. on 31/05/24.
//

import UIKit
import Alamofire
import Network

@available(iOS 13.0, *)
class MobileNoViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var mobileNumberTxtField: UITextField!
    @IBOutlet weak var nxtBtn: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var buttonOpticity: UIButton!
    @IBOutlet weak var activityIndicatorView: UIView!
    @IBOutlet weak var nxtBtnActivityIndicator: UIActivityIndicatorView!
    var member_master_profile_id : Int?
    var lastClickTime: CFTimeInterval = 0
    
    var loader = UIActivityIndicatorView(style: .medium)
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        NetworkMonitor.shared
        mobileNumberTxtField.delegate=self
        modifyNxtBtn()
        addDoneButtonOnNumpad(textField: mobileNumberTxtField)
        createNavigationBar()
        activityIndicator.isHidden = true
        buttonOpticity.isHidden = true
        loader.color = .white
        loader.translatesAutoresizingMaskIntoConstraints = false
        nxtBtn.addSubview(loader)
        nxtBtn.isExclusiveTouch = true
        // Center the activity indicator within the button
        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: nxtBtn.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: nxtBtn.centerYAnchor)
        ])
        
        loader.hidesWhenStopped = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
    }

    @objc func dismissKeyboard() {
            view.endEditing(true) // This will dismiss the keyboard
        }
    func createNavigationBar() {
        let customBackButton = UIButton()
        customBackButton.setImage(UIImage(named: "back"), for: .normal)
        customBackButton.addTarget(self, action: #selector(customBackButtonTapped), for: .touchUpInside)
        
        // Set custom back button as left bar button item
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customBackButton)
    }
    @objc func customBackButtonTapped() {
        // Perform the custom back button action
        self.navigationController?.popViewController(animated: true)
    }
    
    func modifyNxtBtn() {
        nxtBtn.layer.cornerRadius = 15
    }
    
    
    
    @IBAction func nxtBtnAction(_ sender: Any) {
        nxtBtn.setTitle("", for: .normal)
        activityIndicatorView.isHidden = false
        nxtBtnActivityIndicator.startAnimating()
        let currentTime = CACurrentMediaTime()

         if currentTime - lastClickTime < 1 {
             nxtBtn.isEnabled = false // Ignore multiple clicks within 1 second
             return
         }
    
         lastClickTime = currentTime

         // Handle button click action
         print("Button clicked")
        print("nxtBtnAction Tapped")
        if mobileNumberTxtField.text!.count == 0 {
            nxtBtn.setTitle("Next", for: .normal)
            activityIndicatorView.isHidden = true
            nxtBtnActivityIndicator.stopAnimating()
            showAlert(message: "Please Enter Your Mobile Number")
        } else if mobileNumberTxtField.text!.count < 10 {
            nxtBtn.setTitle("Next", for: .normal)
            activityIndicatorView.isHidden = true
            nxtBtnActivityIndicator.stopAnimating()
            showAlert(message: "Mobile Number should be not less than 10 digits")
        }
        else if !isValidIndianMobileNumber(mobileNumberTxtField.text!) {
            nxtBtn.setTitle("Next", for: .normal)
            activityIndicatorView.isHidden = true
            nxtBtnActivityIndicator.stopAnimating()
            showAlert(message: "Invalid Mobile Number")
        } else {
            print("Network Status: \(NetworkMonitor.shared.isConnected)")
            if NetworkMonitor.shared.isConnected{
                print("you are connected")
                loginCheck()
            } else {
                print("you are not connected")
                let alert = UIAlertController(title: "No Internet Connection",
                                              message: "It looks like you're offline. Please check your internet connection.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default,handler: { [self] _ in
                    nxtBtn.isEnabled = true
                    nxtBtn.setTitle("Next", for: .normal)
                    activityIndicatorView.isHidden = true
                    nxtBtnActivityIndicator.stopAnimating()
                    loader.stopAnimating()
                    mobileNumberTxtField.text = ""
                    mobileNumberTxtField.becomeFirstResponder()
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                }))
                present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [self] _ in
            loader.stopAnimating()
            nxtBtn.setTitle("Next", for: .normal)
            nxtBtn.isEnabled = true
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    func isValidIndianMobileNumber(_ number: String) -> Bool {
        let mobileNumberPattern = "^[6-9]\\d{9}$"
        let mobileNumberPredicate = NSPredicate(format: "SELF MATCHES %@", mobileNumberPattern)
        return mobileNumberPredicate.evaluate(with: number)
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("******************** DEINIT MobileNoViewcontroller REMOVED FROM MEMORY*********************")
    }
}

//MARK: API IMPLEMENTATION
extension MobileNoViewController {
    
    func loginCheck() {
        print("mobilelogin -> imei : \(UIDevice.current.identifierForVendor?.uuidString)")
        let url = AppConfig.baseURL+"login/loginCheckForUser"
        let params :  [String : Any] = [
            "mobile_number": mobileNumberTxtField.text,
            "member_type": 1, //1 for user, 2 fro driver
            "Device_name" : "iOS"
        ]
        
        let token = UserDefaults.standard.string(forKey: "auth_deviceToken") ?? ""

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        print("MobileNoViewController -> loginCheck() -> url : \(url)")
        print("MobileNoViewController -> loginCheck() -> params : \(params)")
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { [self] response in
            print("response : \(response)")
            print("response.result : \(response.result)")
            
            switch response.result {
                
            case .success (let data) :
                
                //                let json = value as? [String : Any]
                //                let loginResult = json?["loginResult"] as? [String : Any]
                //                let status = loginResult?["status"] as? String ?? ""
                //                let message = loginResult?["message"] as? String ?? ""
                //
                //                if status == "-1"{
                //                    let alertController = UIAlertController(title: "", message: "Mobile Number not registered.", preferredStyle: .alert)
                //
                //                            // Add an action (button)
                //                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                //                            alertController.addAction(okAction)
                //
                //                            // Present the alert
                //                            self.present(alertController, animated: true, completion: nil)
                //                }
                if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let loginResult = json["result"] as? [String: Any] {
                        print("JSON -------\(json)")
                        let status = loginResult["status"] as? String ?? ""
                        let message = loginResult["message"] as? String ?? ""
                        let otp = loginResult["otp"] as? String ?? ""
                        let fk_member_master_profile_id = loginResult["fk_member_master_profile_id"] as? Int
                        self.member_master_profile_id=fk_member_master_profile_id
//                        UserDefaults.standard.setValue(member_master_profile_id, forKey: "fk_member_master_profile_id")
                        if status == "-1"{
                            //                            activityIndicator.stopAnimating()
                            //                            activityIndicator.isHidden = true
                            //                            buttonOpticity.isHidden = true
                            loader.stopAnimating()
                            nxtBtn.setTitle("Next", for: .normal)
                            activityIndicatorView.isHidden = true
                            nxtBtnActivityIndicator.stopAnimating()
                            nxtBtn.isEnabled = true
                            
//                            let alertController = UIAlertController(title: "", message: "Mobile Number not registered.", preferredStyle: .alert)
                            let alertController = UIAlertController(title: "", message: "Mobile Number does not exist", preferredStyle: .alert)
                            
                            // Add an action (button)
                            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
//                                let otpVC = self.storyboard?.instantiateViewController(identifier: "LoginRegisterViewController") as! LoginRegisterViewController
//                                self.navigationController?.pushViewController(otpVC, animated: true)
                                if let viewControllers = self.navigationController?.viewControllers {
                                    for vc in viewControllers {
                                        if vc is LoginRegisterViewController {
                                            self.navigationController?.popToViewController(vc, animated: true)
                                            break
                                        }
                                    }
                                }
                            }
                            alertController.addAction(okAction)
                            
                            // Present the alert
                            self.present(alertController, animated: true, completion: nil)
                        } else if status == "1"{
                            //                            activityIndicator.stopAnimating()
                            //                            activityIndicator.isHidden = true
                            //                            buttonOpticity.isHidden = true
                            loader.stopAnimating()
                            nxtBtn.setTitle("Next", for: .normal)
                            activityIndicatorView.isHidden = true
                            nxtBtnActivityIndicator.stopAnimating()
                            nxtBtn.isEnabled = true
                            
                            let alertController = UIAlertController(title: "", message: "OTP not sent to Mobile Number", preferredStyle: .alert)
                            
                            // Add an action (button)
                            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
//                                let otpVC = self.storyboard?.instantiateViewController(identifier: "LoginRegisterViewController") as! LoginRegisterViewController
//                                self.navigationController?.pushViewController(otpVC, animated: true)
                                if let viewControllers = self.navigationController?.viewControllers {
                                    for vc in viewControllers {
                                        if vc is LoginRegisterViewController {
                                            self.navigationController?.popToViewController(vc, animated: true)
                                            break
                                        }
                                    }
                                }
                            }
                            alertController.addAction(okAction)
                            
                            // Present the alert
                            self.present(alertController, animated: true, completion: nil)
                        } else if status == "0"{
//                            activityIndicator.stopAnimating()
//                            activityIndicator.isHidden = true
//                            buttonOpticity.isHidden = true
                            loader.stopAnimating()
                            nxtBtn.setTitle("Next", for: .normal)
                            activityIndicatorView.isHidden = true
                            nxtBtnActivityIndicator.stopAnimating()
                            
                            let otpVC = self.storyboard?.instantiateViewController(identifier: "OTPViewController") as! OTPViewController
                            otpVC.mobileNumber = self.mobileNumberTxtField.text
                            otpVC.otp = otp
                            otpVC.member_master_profile_id=self.member_master_profile_id
                            self.navigationController?.pushViewController(otpVC, animated: true)
                        }
                    } else {
                    }
                } catch {
                    nxtBtn.setTitle("Next", for: .normal)
                    activityIndicatorView.isHidden = true
                    nxtBtnActivityIndicator.stopAnimating()
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

//MARK: TEXTFIELD DELEGATES
extension MobileNoViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return true }
        let newLength = currentText.count + string.count - range.length
        return newLength <= 10
    }
}

