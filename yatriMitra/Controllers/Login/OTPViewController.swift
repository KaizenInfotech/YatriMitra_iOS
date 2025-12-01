//
//  OTPViewController.swift
//  RideON
//
//  Created by Kaizen Infotech Solutions Private Limited. on 31/05/24.
//

import UIKit
import Alamofire
import CoreLocation

class OTPViewController: UIViewController, CustomTextFieldDelegate {
    
    @IBOutlet weak var otpTextField1: CustomTextField!
    @IBOutlet weak var otpTextField2: CustomTextField!
    @IBOutlet weak var otpTextField3: CustomTextField!
    @IBOutlet weak var otpTextField4: CustomTextField!
    @IBOutlet weak var verifyBtn: UIButton!
    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var resendBtn: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var buttonOpticity: UIButton!
    @IBOutlet weak var otpImage1: UIView!
    @IBOutlet weak var otpImage2: UIView!
    @IBOutlet weak var otpImage3: UIView!
    @IBOutlet weak var otpImage4: UIView!
    
    
    var mobileNumber:String?
    var otp:String?
    var member_master_profile_id : Int?
    var timer: Timer?
    var remainingSeconds: Int = 59
    var loader = UIActivityIndicatorView(style: .medium)
    var lastClickTime: CFTimeInterval = 0
    var remainingTime: Int = 120
    var keyBoardAppears = true
    var identifyTF = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TimerManager.shared.stopAllTimers()
        createNavigationBar()
        otpCircleRadius()
        NetworkMonitor.shared
        modifyNxtBtn()
        print("mobile number : \(mobileNumber)")
        lbl1.text = "Please Wait.\nWe will auto verify the OTP \nsent to +91 \(mobileNumber ?? "")"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.otpTextField1.becomeFirstResponder()
        }
        textFieldProperties()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        let attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        let buttonTitle = "Resend"
        let attributedTitle = NSAttributedString(string: buttonTitle, attributes: attributes)
        resendBtn.setAttributedTitle(attributedTitle, for: .normal)
        buttonOpticity.isHidden = true
        activityIndicator.isHidden = true
        resendBtn.isHidden = true
        loader.color = .white
        loader.translatesAutoresizingMaskIntoConstraints = false
        verifyBtn.addSubview(loader)
        
        // Center the activity indicator within the button
        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: verifyBtn.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: verifyBtn.centerYAnchor)
        ])
        
        loader.hidesWhenStopped = true
        startCountdown(from: 60)
        NotificationCenter.default.addObserver(self, selector: #selector(saveTimerState), name: UIApplication.didEnterBackgroundNotification, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(restoreTimerState), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    func otpCircleRadius() {
        otpImage1.layer.cornerRadius = otpImage1.frame.size.width/2
        otpImage2.layer.cornerRadius = otpImage2.frame.size.width/2
        otpImage3.layer.cornerRadius = otpImage3.frame.size.width/2
        otpImage4.layer.cornerRadius = otpImage4.frame.size.width/2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        TimerManager.shared.stopAllTimers()
    }
    func textFieldProperties() {
        otpTextField1.textContentType = .oneTimeCode
        otpTextField2.textContentType = .oneTimeCode
        otpTextField3.textContentType = .oneTimeCode
        otpTextField4.textContentType = .oneTimeCode
       
        otpTextField1.keyboardType = .numberPad
        otpTextField2.keyboardType = .numberPad
        otpTextField3.keyboardType = .numberPad
        otpTextField4.keyboardType = .numberPad
        otpTextField1.layer.cornerRadius = otpTextField1.bounds.height / 2
        otpTextField1.layer.masksToBounds = true
        otpTextField4.layer.cornerRadius = otpTextField4.bounds.height / 2
        otpTextField4.layer.masksToBounds = true
        otpTextField2.layer.cornerRadius = otpTextField2.bounds.height / 2
        otpTextField2.layer.masksToBounds = true
        otpTextField3.layer.cornerRadius = otpTextField3.bounds.height / 2
        otpTextField3.layer.masksToBounds = true
        otpTextField1.tintColor = UIColor.clear
        otpTextField2.tintColor = UIColor.clear
        otpTextField3.tintColor = UIColor.clear
        otpTextField4.tintColor = UIColor.clear
        addDoneButtonOnNumpad(textField: otpTextField1)
        addDoneButtonOnNumpad(textField: otpTextField2)
        addDoneButtonOnNumpad(textField: otpTextField3)
        addDoneButtonOnNumpad(textField: otpTextField4)
        [otpTextField1, otpTextField2, otpTextField3, otpTextField4].forEach {
            $0.delegate = self
                    $0.backspaceDelegate = self
                    $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
                }
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
           guard let customTextField = textField as? CustomTextField else { return }
           let text = customTextField.text ?? ""

           if text.count == 1 {
               // Automatically move to the next text field
               switch customTextField {
               case otpTextField1:
                   otpImage1.isHidden = true
                   otpTextField2.becomeFirstResponder()
               case otpTextField2:
                   otpImage2.isHidden = true
                   otpTextField3.becomeFirstResponder()
               case otpTextField3:
                   otpImage3.isHidden = true
                   otpTextField4.becomeFirstResponder()
               case otpTextField4:
                   otpImage4.isHidden = true
                   otpTextField4.resignFirstResponder() // Close keyboard on the last field
                       if NetworkMonitor.shared.isConnected{
                           print("you are connected")
                           
                           
                           if let text = textField.text, !text.isEmpty {
                               textField.leftViewMode = .never // Hide the image
                               otpImage1.isHidden = true
                           } else {
               //                let imageView4 = UIImageView(image: UIImage(named: "Ellipse 1"))
               //                imageView4.contentMode = .scaleAspectFit
               //                otpTextField4.leftView = imageView4
               //                otpTextField4.leftViewMode = .always
               //                otpTextField4.textAlignment = .left
               //                textField.leftViewMode = .always // Show the image when empty
                               otpImage2.isHidden = false
                               otpTextField3.becomeFirstResponder()
                           }
                           if textField.text?.count ?? 0 >= 1
                           {
                               //          self.nextBtn(self)
                               textField.resignFirstResponder()
                               //            buttonOpticity.isHidden = false
                               //            activityIndicator.isHidden = false
                               //            activityIndicator.startAnimating()
                               verifyBtn.isEnabled = false
                               verifyBtn.setTitle("", for: .normal)
                               loader.startAnimating()
                               verifyOTP()
                           } else {
                               otpTextField3.becomeFirstResponder()
                           }
                       } else {
                           print("you are not connected")
                           let alert = UIAlertController(title: "No Internet Connection",
                                                         message: "It looks like you're offline. Please check your internet connection.",
                                                         preferredStyle: .alert)
                           alert.addAction(UIAlertAction(title: "OK", style: .default,handler: { [self] _ in
                               self.otpTextField1.text = ""
                               self.otpTextField2.text = ""
                               self.otpTextField3.text = ""
                               self.otpTextField4.text = ""
                               textFieldProperties()
                               otpTextField1.becomeFirstResponder()
                               verifyBtn.isEnabled = true
                               verifyBtn.setTitle("Next", for: .normal)
                               loader.stopAnimating()
                               if let url = URL(string: UIApplication.openSettingsURLString) {
                                   if UIApplication.shared.canOpenURL(url) {
                                       UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                   }
                               }
                           }))
                           present(alert, animated: true, completion: nil)
                       }
               default:
                   break
               }
           }
       }

       func textFieldDidPressBackspace(_ textField: CustomTextField) {
           // Navigate to the previous text field on backspace
           switch textField {
           case otpTextField2:
               otpTextField1.text = ""
               otpImage1.isHidden = false
               otpTextField1.becomeFirstResponder()
           case otpTextField3:
               otpTextField2.text = ""
               otpImage2.isHidden = false
               otpTextField2.becomeFirstResponder()
           case otpTextField4:
               otpTextField3.text = ""
               otpImage3.isHidden = false
               otpTextField3.becomeFirstResponder()
           default:
               break
           }
       }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        return updatedText.count <= 1
    }
    func createNavigationBar() {
        let customBackButton = UIButton()
        customBackButton.setImage(UIImage(named: "back"), for: .normal)
        customBackButton.addTarget(self, action: #selector(customBackButtonTapped), for: .touchUpInside)
        
        // Set custom back button as left bar button item
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customBackButton)
    }
    
    @objc func dismissKeyboard() {
        
        if keyBoardAppears {
            view.endEditing(true) // This will dismiss the keyboard
            keyBoardAppears = false
        } else {
            if (otpTextField1.text?.count == 0){
                self.otpTextField1.becomeFirstResponder()
            } else if (otpTextField1.text?.count == 1 && otpTextField2.text?.count == 0){
                self.otpTextField2.becomeFirstResponder()
            } else if (otpTextField2.text?.count == 1 && otpTextField3.text?.count == 0){
                self.otpTextField3.becomeFirstResponder()
            }else if (otpTextField3.text?.count == 1 && otpTextField4.text?.count == 0){
                self.otpTextField4.becomeFirstResponder()
            }
            keyBoardAppears = true
        }
    }
    
    @objc func customBackButtonTapped() {
        // Perform the custom back button action
        self.navigationController?.popViewController(animated: true)
    }
    
    func modifyNxtBtn() {
        verifyBtn.layer.cornerRadius = 15
    }
    
    @objc func textFieldDidChange1(_ textField: UITextField)
    {
        if let text = textField.text, !text.isEmpty, text.count == 1 {
            textField.leftViewMode = .never // Hide the image
            otpImage1.isHidden = true
            otpTextField2.becomeFirstResponder()
        } else {
//            let imageView = UIImageView(image: UIImage(named: "Ellipse 1"))
//            imageView.contentMode = .scaleAspectFit
//            otpTextField1.leftView = imageView
//            otpTextField1.leftViewMode = .always
//            otpTextField1.textAlignment = .left
//            textField.leftViewMode = .always // Show the image when empty
            otpImage1.isHidden = false
        }
        
        //        if textField.text?.count ?? 0 >= 1
        //        {
        //            otpTextField2.becomeFirstResponder()
        //        } else {
        //            otpTextField1.becomeFirstResponder()
        //        }
    }
    @objc func textFieldDidChange2(_ textField: UITextField)
    {
        if let text = textField.text, !text.isEmpty, text.count == 1 {
            textField.leftViewMode = .never // Hide the image
            otpImage2.isHidden = true
            otpTextField3.becomeFirstResponder()
        } else if let text = textField.text, text.isEmpty {
//            let imageView2 = UIImageView(image: UIImage(named: "Ellipse 1"))
//            imageView2.contentMode = .scaleAspectFit
//            otpTextField2.leftView = imageView2
//            otpTextField2.leftViewMode = .always
//            otpTextField2.textAlignment = .left
//            textField.leftViewMode = .always // Show the image when empty
            
            otpImage2.isHidden = false
            otpTextField1.becomeFirstResponder()
        }
        
        //        if textField.text?.count ?? 0 >= 1
        //        {
        //            otpTextField3.becomeFirstResponder()
        //        } else {
        //
        //            otpTextField1.becomeFirstResponder()
        //        }
    }
    @objc func textFieldDidChange3(_ textField: UITextField)
    {
        if let text = textField.text, !text.isEmpty {
            textField.leftViewMode = .never // Hide the image
            otpImage3.isHidden = true
            otpTextField4.becomeFirstResponder()
        } else {
//            let imageView3 = UIImageView(image: UIImage(named: "Ellipse 1"))
//            imageView3.contentMode = .scaleAspectFit
//            otpTextField3.leftView = imageView3
//            otpTextField3.leftViewMode = .always
//            otpTextField3.textAlignment = .left
//            textField.leftViewMode = .always // Show the image when empty
            otpImage3.isHidden = false
            otpTextField2.becomeFirstResponder()
        }
        if textField.text?.count ?? 0 >= 1
        {
            otpImage3.isHidden = true
            otpTextField4.becomeFirstResponder()
        } else {
            otpTextField2.becomeFirstResponder()
        }
    }
    @objc func textFieldDidChange4(_ textField: UITextField)
    {
        if NetworkMonitor.shared.isConnected{
            print("you are connected")
            
            
            if let text = textField.text, !text.isEmpty {
                textField.leftViewMode = .never // Hide the image
                otpImage1.isHidden = true
            } else {
//                let imageView4 = UIImageView(image: UIImage(named: "Ellipse 1"))
//                imageView4.contentMode = .scaleAspectFit
//                otpTextField4.leftView = imageView4
//                otpTextField4.leftViewMode = .always
//                otpTextField4.textAlignment = .left
//                textField.leftViewMode = .always // Show the image when empty
                otpImage2.isHidden = false
                otpTextField3.becomeFirstResponder()
            }
            if textField.text?.count ?? 0 >= 1
            {
                //          self.nextBtn(self)
                textField.resignFirstResponder()
                //            buttonOpticity.isHidden = false
                //            activityIndicator.isHidden = false
                //            activityIndicator.startAnimating()
                verifyBtn.isEnabled = false
                verifyBtn.setTitle("", for: .normal)
                loader.startAnimating()
                verifyOTP()
            } else {
                otpTextField3.becomeFirstResponder()
            }
        } else {
            print("you are not connected")
            let alert = UIAlertController(title: "No Internet Connection",
                                          message: "It looks like you're offline. Please check your internet connection.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default,handler: { [self] _ in
                self.otpTextField1.text = ""
                self.otpTextField2.text = ""
                self.otpTextField3.text = ""
                self.otpTextField4.text = ""
                textFieldProperties()
                otpTextField1.becomeFirstResponder()
                verifyBtn.isEnabled = true
                verifyBtn.setTitle("Next", for: .normal)
                loader.stopAnimating()
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    func verifyOTP() {
        var otpEntered = (otpTextField1.text ?? "") + (otpTextField2.text ?? "") + (otpTextField3.text ?? "") + (otpTextField4.text ?? "")
        print("otpEntered : \(otpEntered)")
        if otpEntered == "" || otpEntered == nil {
            
            
            let alertController = UIAlertController(title: "", message: "Please Enter OTP", preferredStyle: .alert)
            
            // Add an action (button)
            //                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            let okAction = UIAlertAction(title: "OK", style: .default) { [self] _ in
                self.otpTextField1.text = ""
                self.otpTextField2.text = ""
                self.otpTextField3.text = ""
                self.otpTextField4.text = ""
                loader.stopAnimating()
                verifyBtn.setTitle("Verify", for: .normal)
                verifyBtn.isEnabled = true
                // Set the focus to otpTextField1
                self.otpTextField1.becomeFirstResponder()
                textFieldProperties()
            }
            alertController.addAction(okAction)
            
            // Present the alert
            self.present(alertController, animated: true, completion: nil)
        }
        else if otpEntered != otp {
            //            activityIndicator.stopAnimating()
            //            activityIndicator.isHidden = true
            //            buttonOpticity.isHidden = true
            
            let alertController = UIAlertController(title: "", message: "Entered OTP is Invalid", preferredStyle: .alert)
            
            // Add an action (button)
            //                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            let okAction = UIAlertAction(title: "OK", style: .default) { [self] _ in
                otpImage1.isHidden = false
                otpImage2.isHidden = false
                otpImage3.isHidden = false
                otpImage4.isHidden = false
                self.otpTextField1.text = ""
                self.otpTextField2.text = ""
                self.otpTextField3.text = ""
                self.otpTextField4.text = ""
                loader.stopAnimating()
                verifyBtn.setTitle("Verify", for: .normal)
                verifyBtn.isEnabled = true
                // Set the focus to otpTextField1
                self.otpTextField1.becomeFirstResponder()
                textFieldProperties()
            }
            alertController.addAction(okAction)
            
            // Present the alert
            self.present(alertController, animated: true, completion: nil)
        } else {
            checkOTP()
        }
    }
    func addDoneButtonOnNumpad(textField: UITextField) {
//        let keypadToolbar: UIToolbar = UIToolbar()
//             keypadToolbar.sizeToFit()
//             let doneButton = UIBarButtonItem(title: "Done", style: .done, target: textField, action: #selector(UITextField.resignFirstResponder))
////             let cancelButton = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelButtonTapped))
//             let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//             keypadToolbar.items = [doneButton, flexibleSpace] // Assign the toolbar to the text field's input accessory view
//             textField.inputAccessoryView = keypadToolbar
        let keypadToolbar: UIToolbar = UIToolbar()
        keypadToolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // Done button
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        
        // Add flexible space and done button to the toolbar
        keypadToolbar.items = [flexibleSpace, doneButton]
        textField.inputAccessoryView = keypadToolbar
         }
    @objc func cancelButtonTapped() {
        if self.otpTextField1.text != "" {
            if self.otpTextField2.text == "" {
                otpImage1.isHidden = false
                self.otpTextField1.becomeFirstResponder()
                self.otpTextField1.text = ""
            }
        }
        if self.otpTextField1.text != "" && self.otpTextField2.text != "" {
            if self.otpTextField3.text == "" {
                otpImage2.isHidden = false
                self.otpTextField2.becomeFirstResponder()
                self.otpTextField2.text = ""
            }
        }
        if self.otpTextField1.text != "" && self.otpTextField2.text != "" && self.otpTextField3.text != "" {
            if self.otpTextField4.text == "" {
                otpImage3.isHidden = false
                self.otpTextField3.becomeFirstResponder()
                self.otpTextField3.text = ""
            } else {
                self.otpTextField4.text = ""
            }
        }
        //      textFieldProperties()
    }
    
    
    @IBAction func resendBtnAction(_ sender: Any) {
        let currentTime = CACurrentMediaTime()
        
        if currentTime - lastClickTime < 1 { // Ignore multiple clicks within 1 second
            return
        }
        
        lastClickTime = currentTime
        
        // Handle button click action
        print("Button clicked")
        if NetworkMonitor.shared.isConnected{
            timerLabel.isHidden = false
            startCountdown(from: 60)
            buttonOpticity.isHidden = false
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            resendBtn.isHidden = true
            getOTP()
        } else {
            print("you are not connected")
            let alert = UIAlertController(title: "No Internet Connection",
                                          message: "It looks like you're offline. Please check your internet connection.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default,handler: { [self] _ in
                verifyBtn.isEnabled = true
                verifyBtn.setTitle("Next", for: .normal)
                loader.stopAnimating()
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func verifyBtnAction(_ sender: Any) {
        UserDefaults.standard.setValue(member_master_profile_id, forKey: "fk_member_master_profile_id")
        let currentTime = CACurrentMediaTime()
        
        if currentTime - lastClickTime < 1 { // Ignore multiple clicks within 1 second
            return
        }
        
        lastClickTime = currentTime
        
        // Handle button click action
        print("Button clicked")
        if NetworkMonitor.shared.isConnected{
            print("verifyBtnAction tapped")
            verifyBtn.isEnabled = false
            verifyBtn.setTitle("", for: .normal)
            loader.startAnimating()
            verifyOTP()
        }else {
            print("you are not connected")
            let alert = UIAlertController(title: "No Internet Connection",
                                          message: "It looks like you're offline. Please check your internet connection.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default,handler: { [self] _ in
                verifyBtn.isEnabled = true
                verifyBtn.setTitle("Next", for: .normal)
                loader.stopAnimating()
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    deinit {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
        print("******************** DEINIT OTPViewController REMOVED FROM MEMORY*********************")
    }
}

extension OTPViewController: UITextFieldDelegate{
    //    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    //        let newLength = (textField.text?.count ?? 0) + string.count - range.length
    //            return newLength <= 1 && (textField.text ?? "") != string
    //    }
    
//    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        let currentText = textField.text ?? ""
//        //        let newLength = currentText.count + string.count - range.length
//        let newLength = (currentText as NSString).replacingCharacters(in: range, with: string)
//        
//        // Detecting delete (backspace) key press
//        //        if string.isEmpty {
//        //            if textField == otpTextField1 && range.location == 0 { otpTextField1.text = ""}
//        //            else if textField == otpTextField2 && range.location == 0 {
//        //                otpTextField2.text = ""
//        //                otpTextField1.becomeFirstResponder()
//        //                return false
//        //            } else if textField == otpTextField3 && range.location == 0 {
//        //                otpTextField3.text = ""
//        //                otpTextField2.becomeFirstResponder()
//        //                return false
//        //            }else if textField == otpTextField4 && range.location == 0 {
//        //                otpTextField4.text = ""
//        //                otpTextField3.becomeFirstResponder()
//        //                return false
//        //            }
//        //        } else {
//        //            // Limit to 1 character and ensure the new string is not the same as the current text
//        //            if newLength <= 1 && currentText != string {
//        //                return true
//        //            } else {
//        //                return false
//        //            }
//        //        }
//        
//        return newLength.count <= 1
////        if let char = string.cString(using: String.Encoding.utf8) {
////               let isBackSpace = strcmp(char, "\\b")
////               if (isBackSpace == -92) {
////                   print("Backspace was pressed")
////               }
////           }
////        if textField == otpTextField1 {
////            if otpTextField1.text?.count == 1 {
////                otpTextField2.becomeFirstResponder()
////            }
////        }
////           return true
////        
////        
//    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("================================================>")
        print("textFieldShouldEndEditing")
        if textField == otpTextField1 {
            print("textFieldShouldEndEditing : otpTextField1")
        } else if textField == otpTextField2 {
            print("textFieldShouldEndEditing : otpTextField2")
        } else if textField == otpTextField3 {
            print("textFieldShouldEndEditing : otpTextField3")
        } else if textField == otpTextField4 {
            print("textFieldShouldEndEditing : otpTextField4")
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("================================================>")
        print("textFieldDidBeginEditing")
        if textField == otpTextField1 {
            print("textFieldDidBeginEditing : otpTextField1")
            
        } else if textField == otpTextField2 {
            print("textFieldDidBeginEditing : otpTextField2")
            otpTextField2.becomeFirstResponder()
        } else if textField == otpTextField3 {
            print("textFieldDidBeginEditing : otpTextField3")
            
        } else if textField == otpTextField4 {
            print("textFieldDidBeginEditing : otpTextField4")
        }
        
        
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        print("================================================>")
        print("textFieldShouldClear")
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("================================================>")
        print("textFieldShouldReturn")
        if textField == otpTextField1 {
            print("textFieldShouldReturn : otpTextField1")
        } else if textField == otpTextField2 {
            print("textFieldShouldReturn : otpTextField2")
        } else if textField == otpTextField3 {
            print("textFieldShouldReturn : otpTextField3")
        } else if textField == otpTextField4 {
            print("textFieldShouldReturn : otpTextField4")
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("================================================>")
        print("textFieldDidEndEditing")
        if textField == otpTextField1 {
            print("textFieldDidEndEditing : otpTextField1")
        } else if textField == otpTextField2 {
            print("textFieldDidEndEditing : otpTextField2")
        } else if textField == otpTextField3 {
            print("textFieldDidEndEditing : otpTextField3")
        } else if textField == otpTextField4 {
            print("textFieldDidEndEditing : otpTextField4")
        }
    }
    
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        print("================================================>")
        print("textFieldDidChangeSelection")
        if textField == otpTextField1 {
            print("textFieldDidChangeSelection : otpTextField1")
        } else if textField == otpTextField2 {
            print("textFieldDidChangeSelection : otpTextField2")
        } else if textField == otpTextField3 {
            print("textFieldDidChangeSelection : otpTextField3")
        } else if textField == otpTextField4 {
            print("textFieldDidChangeSelection : otpTextField4")
        }
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("================================================>")
        print("textFieldShouldBeginEditing")
        if textField == otpTextField1 {
            print("textFieldShouldBeginEditing : otpTextField1")
        } else if textField == otpTextField2 {
            print("textFieldShouldBeginEditing : otpTextField2")
        } else if textField == otpTextField3 {
            print("textFieldShouldBeginEditing : otpTextField3")
        } else if textField == otpTextField4 {
            print("textFieldShouldBeginEditing : otpTextField4")
        }
        return true
    }
    
    
}


//MARK: TIMER
extension OTPViewController {
    func startCountdown(from seconds: Int?) {
            // Invalidate any existing timer
            timer?.invalidate()

            // Set the initial remaining seconds if provided
            if let seconds = seconds {
                remainingSeconds = seconds
            }

            // Create a new timer
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        }

        @objc func updateTimer() {
            if remainingSeconds > 0 {
                remainingSeconds -= 1
                updateTimerLabel()
            } else {
                // Timer finished
                timer?.invalidate()
                timer = nil
                timerLabel.text = "00:00"
                // Handle timer completion (e.g., show alert, update UI)
                timerLabel.isHidden = true
                resendBtn.isHidden = false
            }
        }

        func updateTimerLabel() {
            let minutes = remainingSeconds / 60
            let seconds = remainingSeconds % 60
            timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
        }

        @objc func saveTimerState() {
            // Save the current date and remaining seconds
            UserDefaults.standard.set(Date(), forKey: "timerBackgroundDate")
            UserDefaults.standard.set(remainingSeconds, forKey: "remainingTime")
            UserDefaults.standard.synchronize()
            timer?.invalidate()
        }

        @objc func restoreTimerState() {
            // Calculate the elapsed time
            if let backgroundDate = UserDefaults.standard.object(forKey: "timerBackgroundDate") as? Date {
                let elapsed = Int(Date().timeIntervalSince(backgroundDate))
                remainingSeconds = max(0, UserDefaults.standard.integer(forKey: "remainingTime") - elapsed)
            }

            if remainingSeconds > 0 {
                startCountdown(from: remainingSeconds)
            } else {
                // Timer already expired
                print("Timer already expired")
                timerLabel.text = "00:00"
                timerLabel.isHidden = true
                resendBtn.isHidden = false
            }
        }
}

extension OTPViewController{
    func checkOTP() {
        print("mobilelogin -> imei : \(UIDevice.current.identifierForVendor?.uuidString)")
        let url = AppConfig.baseURL+"login/UpdateUserDetailsAfterValidate"
        let params :  [String : Any] = [
            "fk_member_master_profile_id": member_master_profile_id,
            "imeI_No": UIDevice.current.identifierForVendor?.uuidString,
            //            "deviceToken": UserDefaults.standard.string(forKey: "auth_deviceToken"),
            "deviceToken": UserDefaults.standard.string(forKey: "fcm_token"),
            "device_name": "iOS",
            "versionNo": "1.1"
        ]
        print("MobileNoViewController -> loginCheck() -> url : \(url)")
        print("MobileNoViewController -> loginCheck() -> params : \(params)")
        let token = UserDefaults.standard.string(forKey: "auth_deviceToken") ?? ""

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
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
                        if status == "0" {
                            UserDefaults.standard.set("LoggedIN", forKey: "loggedin")
                            //            activityIndicator.stopAnimating()
                            //            activityIndicator.isHidden = true
                            //            buttonOpticity.isHidden = true
                            AnalyticsManager.shared.loginSuccess(method: "Login Success")
                            loader.stopAnimating()
                            verifyBtn.setTitle("Verify", for: .normal)
                            verifyBtn.isEnabled = true
                            print("TAPPED")
                            driverAprroachingTowardsPassengerPending()
//                            if !CLLocationManager.locationServicesEnabled(){
//                                let otpVC = storyboard?.instantiateViewController(identifier: "GPSSettingViewController") as! GPSSettingViewController
//                                resendBtn.isHidden = true
//                                otpVC.member_master_profile_id=self.member_master_profile_id
//                                self.navigationController?.pushViewController(otpVC, animated: true)
//                            } else if CLLocationManager.authorizationStatus() == .notDetermined ||  CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied {
//                                let otpVC = storyboard?.instantiateViewController(identifier: "WelcomeViewController") as! WelcomeViewController
//                                resendBtn.isHidden = true
//                                otpVC.member_master_profile_id=self.member_master_profile_id
//                                self.navigationController?.pushViewController(otpVC, animated: true)
//                            } else {
//                                let otpVC = storyboard?.instantiateViewController(identifier: "MapViewController") as! MapViewController
//                                resendBtn.isHidden = true
//                                otpVC.member_master_profile_id=self.member_master_profile_id
//                                self.navigationController?.pushViewController(otpVC, animated: true)
//                            }
                        }
                    }
                }
                catch {
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
    
    func getOTP() {
        let url = AppConfig.baseURL+"login/loginCheck"
        let params :  [String : Any] = [
            "mobile_number": mobileNumber,
            "member_type": 1, //1 for user, 2 fro driver
            "imeI_No": UIDevice.current.identifierForVendor?.uuidString,
            //            "deviceToken": UserDefaults.standard.string(forKey: "auth_deviceToken"),
            "deviceToken": UserDefaults.standard.string(forKey: "fcm_token"),
            "device_name": "iOS",
            "versionNo": "1.1"
        ]
        print("MobileNoViewController -> loginCheck() -> params : \(params)")
        let token = UserDefaults.standard.string(forKey: "auth_deviceToken") ?? ""

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
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
                            activityIndicator.stopAnimating()
                            activityIndicator.isHidden = true
                            buttonOpticity.isHidden = true
                            print("JSON -------\(json)")
                            let status = loginResult["status"] as? String ?? ""
                            let message = loginResult["message"] as? String ?? ""
                            let otpfromAPI = loginResult["otp"] as? String ?? ""
                            let fk_member_master_profile_id = loginResult["fk_member_master_profile_id"] as? Int
                            self.member_master_profile_id=fk_member_master_profile_id
                            otp = otpfromAPI
                        } else {
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
    
    func pendingRide() {
        let url = AppConfig.baseURL+"Book/get_PendingRide"
        let params :  [String : Any] = [
            //            "fk_bookride_id": 169
//            "fk_member_master_profile_id": Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "")
            "fk_member_master_profile_id": member_master_profile_id
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
                                        driverAprroachingTowardsPassengerPending()
                                    } else {
                                        print("Output: \(output)")
                                        if let firstDict = output.first {
                                            let initialViewController = storyboard?.instantiateViewController(identifier: "RideStartedViewController") as! RideStartedViewController
                                            initialViewController.member_master_profile_id=self.member_master_profile_id
                                            initialViewController.rideStatus = "active"
//                                            initialViewController.pickup_latitude = pickup_latitude
//                                            initialViewController.pickup_longitude = pickup_longitude
                                            initialViewController.latitudes_destination = firstDict["latitudes_destination"] as? String
                                            initialViewController.longitudes_destination = firstDict["longitudes_destination"] as? String
                                            initialViewController.driver_current_latitude = firstDict["driver_current_latitude"] as? String
                                            initialViewController.driver_current_longitude = firstDict["driver_current_longitude"] as? String
                                            initialViewController.pk_bookride_id = firstDict["bookingid"] as? Int
                                            initialViewController.vehiclePhotoString = firstDict["vehicle_Photo"] as? String
                                            initialViewController.driverPhotoString = firstDict["driver_Photo"] as? String
                                            if let vehicleNumber = firstDict["vehicle_Number"] as? String {
                                                initialViewController.vehicleNumberString = vehicleNumber
                                            } else {
                                                print("vehicleNumber is nil")
                                            }
                                            //Vehicle Model
                                            if let vehicleModel = firstDict["vehicle_Model"] as? String {
                                                initialViewController.vehicleModelString = vehicleModel
                                            } else {
                                                print("vehicleModel is nil")
                                            }
                                            //Driver Name
                                            if let driverName = firstDict["driverName"] as? String {
                                                initialViewController.driverNameString = driverName
                                            } else {
                                                print("driverName is nil")
                                            }

                                            if let driverMobileNumber = firstDict["driver_Mobile_Number"] as? String {
                                                initialViewController.driverMobileNumberString = driverMobileNumber
                                            } else {
                                                print("driverMobileNumber is nil")
                                            }
                                            self.navigationController?.pushViewController(initialViewController, animated: true)
                                            
                                            
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
//            "fk_member_master_profile_id": Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "")
            "fk_member_master_profile_id": member_master_profile_id
        ]
        print("driverAprroachingTowardsPassengerPending() -> url : \(url)")
        print("driverAprroachingTowardsPassengerPending() -> parameters : \(params)")
        let token = UserDefaults.standard.string(forKey: "auth_deviceToken") ?? ""

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
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
                                        if !CLLocationManager.locationServicesEnabled() {
                                            let otpVC = storyboard?.instantiateViewController(identifier: "GPSSettingViewController") as! GPSSettingViewController
                                            resendBtn.isHidden = true
                                            otpVC.member_master_profile_id=self.member_master_profile_id
                                            self.navigationController?.pushViewController(otpVC, animated: true)
                                        } else if CLLocationManager.authorizationStatus() == .notDetermined ||  CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied {
                                            let otpVC = storyboard?.instantiateViewController(identifier: "WelcomeViewController") as! WelcomeViewController
                                            resendBtn.isHidden = true
                                            otpVC.member_master_profile_id=self.member_master_profile_id
                                            self.navigationController?.pushViewController(otpVC, animated: true)
                                        } else {
                                            let otpVC = storyboard?.instantiateViewController(identifier: "MapViewController") as! MapViewController
                                            resendBtn.isHidden = true
                                            otpVC.showBanner = UserDefaults.standard.string(forKey: "showBanner")
                                            otpVC.member_master_profile_id=self.member_master_profile_id
                                            self.navigationController?.pushViewController(otpVC, animated: true)
                                        }
                                    } else {
                                        print("Output: \(listing)")
                                        if let firstDict = listing.first {
                                            let initialViewController = storyboard?.instantiateViewController(identifier: "BookACabViewController") as! BookACabViewController
                                            initialViewController.member_master_profile_id = self.member_master_profile_id
                                            initialViewController.rideStatus = "driverApproachingTowardsPassengerPending"
                                            initialViewController.otpInt = firstDict["pin"] as? Int
                                            initialViewController.pickup_latitude = firstDict["pickup_latitude"] as? String
                                            initialViewController.pickup_longitude = firstDict["pickup_longitude"] as? String
                                            initialViewController.destination_latitude = firstDict["destination_latitude"] as? String
                                            initialViewController.destination_longitude = firstDict["destination_longitude"] as? String
                                            initialViewController.driver_current_latitude = firstDict["driver_current_latitude"] as? String
                                            initialViewController.driver_current_longitude = firstDict["driver_current_longitude"] as? String
                                            initialViewController.pk_bookride_id = firstDict["fk_bookride_id"] as? Int
                                            initialViewController.vehicle_Photo_afterAppTermination = firstDict["vehicle_image_url"] as? String
                                            initialViewController.driver_Photo_afterAppTermination = firstDict["driver_image_url"] as? String
                                            if let vehicleNumber = firstDict["vehicle_no"] as? String {
                                                initialViewController.vehicleNumberString = vehicleNumber
                                            } else {
                                                print("vehicleNumber is nil")
                                            }
                                            //Vehicle Model
                                            if let vehicleModel = firstDict["vehicle_Brand_Model"] as? String {
                                                initialViewController.vehicleModelString = vehicleModel
                                            } else {
                                                print("vehicleModel is nil")
                                            }
                                            //Driver Name
                                            if let driverName = firstDict["driver_Name"] as? String {
                                                initialViewController.driverNameString = driverName
                                            } else {
                                                print("driverName is nil")
                                            }

                                            if let driverMobileNumber = firstDict["driver_Mob_No"] as? String {
                                                initialViewController.driverMobileNumberString = driverMobileNumber
                                            } else {
                                                print("driverMobileNumber is nil")
                                            }
                                            self.navigationController?.pushViewController(initialViewController, animated: true)
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


/*verify button action old code
 {
 var otpEntered = (otpTextField1.text ?? "") + (otpTextField2.text ?? "") + (otpTextField3.text ?? "") + (otpTextField4.text ?? "")
 print("otpEntered : \(otpEntered)")
 if otpEntered == "" || otpEntered == nil {
 let alertController = UIAlertController(title: "", message: "Please Enter OTP", preferredStyle: .alert)
 
 // Add an action (button)
 //                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
 let okAction = UIAlertAction(title: "OK", style: .default) { _ in
 self.otpTextField1.text = ""
 self.otpTextField2.text = ""
 self.otpTextField3.text = ""
 self.otpTextField4.text = ""
 
 // Set the focus to otpTextField1
 self.otpTextField1.becomeFirstResponder()
 }
 alertController.addAction(okAction)
 
 // Present the alert
 self.present(alertController, animated: true, completion: nil)
 }
 else if otpEntered != otp {
 let alertController = UIAlertController(title: "", message: "Invalid OTP.", preferredStyle: .alert)
 
 // Add an action (button)
 //                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
 let okAction = UIAlertAction(title: "OK", style: .default) { _ in
 self.otpTextField1.text = ""
 self.otpTextField2.text = ""
 self.otpTextField3.text = ""
 self.otpTextField4.text = ""
 
 // Set the focus to otpTextField1
 self.otpTextField1.becomeFirstResponder()
 }
 alertController.addAction(okAction)
 
 // Present the alert
 self.present(alertController, animated: true, completion: nil)
 } else {
 print("TAPPED")
 let otpVC = storyboard?.instantiateViewController(identifier: "GPSSettingViewController") as! GPSSettingViewController
 resendBtn.isHidden = true
 otpVC.member_master_profile_id=self.member_master_profile_id
 self.navigationController?.pushViewController(otpVC, animated: true)
 }
 }
 
 
 
 */
