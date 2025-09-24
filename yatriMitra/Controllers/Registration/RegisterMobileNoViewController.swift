//
//  RegisterMobileNoViewController.swift
//  yatriMitra
//
//  Created by Kaizen Infotech Solutions Private Limited. on 02/07/24.
//

import UIKit
import Alamofire


class RegisterMobileNoViewController: UIViewController {

    @IBOutlet weak var buttonOpticity: UIButton!
    @IBOutlet weak var mobileNumberTxtField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var nxtBtn: UIButton!
    @IBOutlet weak var activityIndicatorView: UIView!
    @IBOutlet weak var nxtBtnActivityIndicator: UIActivityIndicatorView!
    
    var loader = UIActivityIndicatorView(style: .medium)
    var lastClickTime: CFTimeInterval = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(false, animated: true)
        mobileNumberTxtField.delegate=self
        NetworkMonitor.shared
        createNavigationBar()
        buttonOpticity.isHidden = true
        activityIndicator.isHidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
                view.addGestureRecognizer(tapGesture)
        loader.color = .white
                loader.translatesAutoresizingMaskIntoConstraints = false
                nxtBtn.addSubview(loader)

                        // Center the activity indicator within the button
                        NSLayoutConstraint.activate([
                            loader.centerXAnchor.constraint(equalTo: nxtBtn.centerXAnchor),
                            loader.centerYAnchor.constraint(equalTo: nxtBtn.centerYAnchor)
                        ])
        modifyNxtBtn()
        addDoneButtonOnNumpad(textField: mobileNumberTxtField)
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

    @objc func dismissKeyboard() {
            view.endEditing(true) // This will dismiss the keyboard
        }
    
    @IBAction func nxtBtnAction(_ sender: Any) {
        nxtBtn.setTitle("", for: .normal)
        activityIndicatorView.isHidden = false
        nxtBtnActivityIndicator.startAnimating()
        let currentTime = CACurrentMediaTime()

         if currentTime - lastClickTime < 1 { // Ignore multiple clicks within 1 second
             return
         }

         lastClickTime = currentTime

         // Handle button click action
         print("Button clicked")
        if NetworkMonitor.shared.isConnected{
            nxtBtn.isEnabled = false
            nxtBtn.setTitle("", for: .normal)
            loader.startAnimating()
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
            } else if !isValidIndianMobileNumber(mobileNumberTxtField.text!) {
                nxtBtn.setTitle("Next", for: .normal)
                activityIndicatorView.isHidden = true
                nxtBtnActivityIndicator.stopAnimating()
                showAlert(message: "Invalid Mobile Number")
            } else {
                buttonOpticity.isHidden = false
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
                mobileNoCheck()
            }
        }
        else
        {
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
    
    func modifyNxtBtn() {
        nxtBtn.layer.cornerRadius = 15
    }

    func showAlert(message: String) {
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [self] _ in
            nxtBtn.isEnabled = true
                                nxtBtn.setTitle("Next", for: .normal)
                                loader.stopAnimating()
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
//          UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: textField, action: #selector(UITextField.resignFirstResponder)),
//          UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
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
    func mobileNoCheck() {
        let url = AppConfig.baseURL+"registration/Verify_and_check_mobile_number_sent_OTP"
        let params :  [String : Any] = [
            "mobile_number": mobileNumberTxtField.text,
            "Device_name" : "iOS",
            "member_type": 1 //1 for user, 2 fro driver
        ]
        print("RegisterMobileNoViewController -> url() -> url : \(url)")
        print("RegisterMobileNoViewController -> getOTP() -> params : \(params)")
        let token = UserDefaults.standard.string(forKey: "auth_deviceToken") ?? ""

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { [self] response in
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
                            let status = loginResult["status"] as? String ?? ""
                            let message = loginResult["message"] as? String ?? ""
                            let otp = loginResult["otp"] as? String
                            print("loginResult (Register New User) -> \(loginResult)")
                            if status == "-1"{
                                activityIndicator.stopAnimating()
                                activityIndicator.isHidden = true
                                buttonOpticity.isHidden = true
                                nxtBtn.setTitle("Next", for: .normal)
                                activityIndicatorView.isHidden = true
                                nxtBtnActivityIndicator.stopAnimating()
                                nxtBtn.isEnabled = true
                                loader.stopAnimating()
                                let alertController = UIAlertController(title: "", message: "Mobile Number already exists.", preferredStyle: .alert)
                                
                                // Add an action (button)
                                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
//                                    let otpVC = self.storyboard?.instantiateViewController(identifier: "LoginRegisterViewController") as! LoginRegisterViewController
//                                    self.navigationController?.pushViewController(otpVC, animated: true)
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
                                activityIndicator.stopAnimating()
                                activityIndicator.isHidden = true
                                buttonOpticity.isHidden = true
                                nxtBtn.setTitle("Next", for: .normal)
                                activityIndicatorView.isHidden = true
                                nxtBtnActivityIndicator.stopAnimating()
                                nxtBtn.isEnabled = true
                                loader.stopAnimating()
                                let alertController = UIAlertController(title: "", message: "OTP not sent to Mobile Number", preferredStyle: .alert)
                                
                                // Add an action (button)
                                //                                           let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                                //                                               let otpVC = self.storyboard?.instantiateViewController(identifier: "ViewController") as! ViewController
                                //                                               self.navigationController?.pushViewController(otpVC, animated: true)
                                //                                           }
                                let okAction = UIAlertAction(title: "OK", style: .default)
                                alertController.addAction(okAction)
                                
                                // Present the alert
                                self.present(alertController, animated: true, completion: nil)
                            } else {
                                activityIndicator.stopAnimating()
                                activityIndicator.isHidden = true
                                buttonOpticity.isHidden = true
                                nxtBtn.isEnabled = true
                                nxtBtn.setTitle("Next", for: .normal)
                                activityIndicatorView.isHidden = true
                                nxtBtnActivityIndicator.stopAnimating()
                                loader.stopAnimating()
                                let otpVC = self.storyboard?.instantiateViewController(identifier: "RegisterOTPViewController") as! RegisterOTPViewController
                                otpVC.mobileNumber = self.mobileNumberTxtField.text
                                otpVC.otp = otp
                                self.navigationController?.pushViewController(otpVC, animated: true)
                            }
                        } else {
                            //                                       self.showAlert(title: "Error", message: "Invalid response format")
                        }
                    } catch {
                        //                                   self.showAlert(title: "Error", message: "Failed to parse JSON: \(error.localizedDescription)")
                        nxtBtn.setTitle("Next", for: .normal)
                        activityIndicatorView.isHidden = true
                        nxtBtnActivityIndicator.stopAnimating()
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("******************** DEINIT RegistermobilenoViewcontroller REMOVED FROM MEMORY*********************")
    }
}


extension RegisterMobileNoViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return true }
                let newLength = currentText.count + string.count - range.length
                return newLength <= 10
    }
}


