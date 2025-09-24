//
//  RegisterOTPViewController.swift
//  yatriMitra
//
//  Created by Kaizen Infotech Solutions Private Limited. on 02/07/24.
//

import UIKit
import Alamofire

class RegisterOTPViewController: UIViewController, CustomTextFieldDelegate{
    
    
    @IBOutlet weak var otpTextField1: CustomTextField!
    @IBOutlet weak var otpTextField2: CustomTextField!
    @IBOutlet weak var otpTextField3: CustomTextField!
    @IBOutlet weak var otpTextField4: CustomTextField!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var verifyBtn: UIButton!
    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var resendBtn: UIButton!
    @IBOutlet weak var buttonOpticity: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var otpImage1: UIView!
    @IBOutlet weak var otpImage2: UIView!
    @IBOutlet weak var otpImage3: UIView!
    @IBOutlet weak var otpImage4: UIView!
    
    
    var mobileNumber:String?
    var otp:String?
    var timer: Timer?
    var remainingSeconds: Int = 59
    var loader = UIActivityIndicatorView(style: .medium)
    var lastClickTime: CFTimeInterval = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        createNavigationBar()
        modifyNxtBtn()
        otpCircleRadius()
        NetworkMonitor.shared
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.otpTextField1.becomeFirstResponder()
        }
        textFieldProperties()
        print("mobile number : \(mobileNumber)")
        lbl1.text = "Please Wait.\nWe will auto verify the OTP \nsent to +91 \(mobileNumber ?? "")"
//        otpTextField1.becomeFirstResponder()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
                view.addGestureRecognizer(tapGesture)
        let attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        let buttonTitle = "Resend"
        let attributedTitle = NSAttributedString(string: buttonTitle, attributes: attributes)
        resendBtn.setAttributedTitle(attributedTitle, for: .normal)
        resendBtn.isHidden = true
        buttonOpticity.isHidden = true
        activityIndicator.isHidden = true
        loader.color = .white
        loader.translatesAutoresizingMaskIntoConstraints = false
        verifyBtn.addSubview(loader)
        
        // Center the activity indicator within the button
        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: verifyBtn.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: verifyBtn.centerYAnchor)
        ])
        startCountdown(from: 60)
    }
    
    func otpCircleRadius() {
        otpImage1.layer.cornerRadius = otpImage1.frame.size.width/2
        otpImage2.layer.cornerRadius = otpImage2.frame.size.width/2
        otpImage3.layer.cornerRadius = otpImage3.frame.size.width/2
        otpImage4.layer.cornerRadius = otpImage4.frame.size.width/2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        startCountdown(from: 60)
        otpTextField1.text = ""
        otpTextField2.text = ""
        otpTextField3.text = ""
        otpTextField4.text = ""
        
        // Set the focus to otpTextField1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.otpTextField1.becomeFirstResponder()
        }
        
    }
    
    func textFieldProperties() {
//        otpTextField1.delegate = self
//        otpTextField2.delegate = self
//        otpTextField3.delegate = self
//        otpTextField4.delegate = self
        otpTextField1.layer.cornerRadius = otpTextField1.bounds.height / 2
        otpTextField1.layer.masksToBounds = true
        otpTextField4.layer.cornerRadius = otpTextField4.bounds.height / 2
        otpTextField4.layer.masksToBounds = true
        otpTextField2.layer.cornerRadius = otpTextField2.bounds.height / 2
        otpTextField2.layer.masksToBounds = true
        otpTextField3.layer.cornerRadius = otpTextField3.bounds.height / 2
        otpTextField3.layer.masksToBounds = true
        otpTextField1.textContentType = .oneTimeCode
        otpTextField2.textContentType = .oneTimeCode
        otpTextField3.textContentType = .oneTimeCode
        otpTextField4.textContentType = .oneTimeCode
        //        let imageView = UIImageView(image: UIImage(named: "Ellipse 1"))
        //        imageView.contentMode = .scaleAspectFit
        //        otpTextField1.leftView = imageView
        //        otpTextField1.leftViewMode = .always
        //        let imageView2 = UIImageView(image: UIImage(named: "Ellipse 1"))
        //        imageView2.contentMode = .scaleAspectFit
        //        otpTextField2.leftView = imageView2
        //        otpTextField2.leftViewMode = .always
        //        let imageView3 = UIImageView(image: UIImage(named: "Ellipse 1"))
        //        imageView3.contentMode = .scaleAspectFit
        //        otpTextField3.leftView = imageView3
        //        otpTextField3.leftViewMode = .always
        //        let imageView4 = UIImageView(image: UIImage(named: "Ellipse 1"))
        //        imageView4.contentMode = .scaleAspectFit
        //        otpTextField4.leftView = imageView4
        //        otpTextField4.leftViewMode = .always
        //        otpTextField1.textAlignment = .left
        //        otpTextField2.textAlignment = .left
        //        otpTextField3.textAlignment = .left
        //        otpTextField4.textAlignment = .left
        otpTextField1.tintColor = UIColor.clear
        otpTextField2.tintColor = UIColor.clear
        otpTextField3.tintColor = UIColor.clear
        otpTextField4.tintColor = UIColor.clear
        addDoneButtonOnNumpad(textField: otpTextField1)
        addDoneButtonOnNumpad(textField: otpTextField2)
        addDoneButtonOnNumpad(textField: otpTextField3)
        addDoneButtonOnNumpad(textField: otpTextField4)
//        otpTextField1.addTarget(self, action: #selector(RegisterOTPViewController.textFieldDidChange1(_:)), for: UIControl.Event.editingChanged)
//        otpTextField2.addTarget(self, action: #selector(RegisterOTPViewController.textFieldDidChange2(_:)), for: UIControl.Event.editingChanged)
//        otpTextField3.addTarget(self, action: #selector(RegisterOTPViewController.textFieldDidChange3(_:)), for: UIControl.Event.editingChanged)
//        otpTextField4.addTarget(self, action: #selector(RegisterOTPViewController.textFieldDidChange4(_:)), for: UIControl.Event.editingChanged)
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
//                                         self.nextBtn(self)
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
    func autofillOTP(otp: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 7) { [self] in
            let otpArray = Array(otp)
            if otpArray.count == 4 { // assuming 4-digit OTP
                otpTextField1.text = String(otpArray[0])
                otpTextField2.text = String(otpArray[1])
                otpTextField3.text = String(otpArray[2])
                otpTextField4.text = String(otpArray[3])
                otpTextField1.isUserInteractionEnabled = false
                otpTextField2.isUserInteractionEnabled = false
                otpTextField3.isUserInteractionEnabled = false
                otpTextField4.isUserInteractionEnabled = false
                otpTextField1.resignFirstResponder()
                self.view.endEditing(true)
                buttonOpticity.isHidden = false
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [self] in
                    if NetworkMonitor.shared.isConnected{
                        verifyOTP()
                    } else {
                        verifyBtn.isEnabled = true
                        verifyBtn.setTitle("Verify", for: .normal)
                        loader.stopAnimating()
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                    }
                }
            }
        }
        
    }
    func createNavigationBar() {
        let customBackButton = UIButton()
        customBackButton.setImage(UIImage(named: "back"), for: .normal)
        customBackButton.addTarget(self, action: #selector(customBackButtonTapped), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customBackButton)
    }
    
    @objc func customBackButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func modifyNxtBtn() {
        verifyBtn.layer.cornerRadius = 15
    }
    
    @objc func textFieldDidChange1(_ textField: UITextField)
    {
//        if let text = textField.text, !text.isEmpty {
//            textField.leftViewMode = .never // Hide the image
//        } else {
//            textField.leftViewMode = .always // Show the image when empty
//        }
        if textField.text?.count ?? 0 > 0
        {
            otpImage1.isHidden = true
            otpTextField2.becomeFirstResponder()
        }
    }
    @objc func textFieldDidChange2(_ textField: UITextField)
    {
//        if let text = textField.text, !text.isEmpty {
//            textField.leftViewMode = .never // Hide the image
//        } else {
//            textField.leftViewMode = .always // Show the image when empty
//        }
        if textField.text?.count ?? 0 > 0
        {
            otpImage2.isHidden = true
            otpTextField3.becomeFirstResponder()
        } else {
//            otpTextField1.becomeFirstResponder()
            clearOTPTextFields()
        }
    }
    @objc func textFieldDidChange3(_ textField: UITextField)
    {
//        if let text = textField.text, !text.isEmpty {
//            textField.leftViewMode = .never // Hide the image
//        } else {
//            textField.leftViewMode = .always // Show the image when empty
//        }
        if textField.text?.count ?? 0 > 0
        {
            otpImage3.isHidden = true
            otpTextField4.becomeFirstResponder()
        } else {
//            otpTextField2.becomeFirstResponder()
            clearOTPTextFields()
        }
    }
    @objc func textFieldDidChange4(_ textField: UITextField)
    {
        if NetworkMonitor.shared.isConnected{
//            if let text = textField.text, !text.isEmpty {
//                textField.leftViewMode = .never // Hide the image
//            } else {
//                textField.leftViewMode = .always // Show the image when empty
//            }
            if textField.text?.count ?? 0 > 0
            {
                //          self.nextBtn(self)
                textField.resignFirstResponder()
                buttonOpticity.isHidden = false
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
                verifyBtn.isEnabled = false
                verifyBtn.setTitle("", for: .normal)
                loader.startAnimating()
                verifyOTP()
            } else {
                otpTextField3.becomeFirstResponder()
            }
        } else  {
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
                clearOTPTextFields()
                verifyBtn.isEnabled = true
                verifyBtn.setTitle("Verify", for: .normal)
                                    loader.stopAnimating()
                // Set the focus to otpTextField1
                self.otpTextField1.becomeFirstResponder()
                textFieldProperties()
            }
            alertController.addAction(okAction)
            
            // Present the alert
            self.present(alertController, animated: true, completion: nil)
        } else if otpEntered != otp {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            buttonOpticity.isHidden = true
            let alertController = UIAlertController(title: "", message: "Entered OTP is Invalid", preferredStyle: .alert)
            
            // Add an action (button)
            //                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            let okAction = UIAlertAction(title: "OK", style: .default) { [self] _  in
                clearOTPTextFields()
                verifyBtn.isEnabled = true
                verifyBtn.setTitle("Verify", for: .normal)
                                    loader.stopAnimating()
                // Set the focus to otpTextField1
                otpTextField1.becomeFirstResponder()
                textFieldProperties()
            }
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            buttonOpticity.isHidden = true
            verifyBtn.isEnabled = true
            verifyBtn.setTitle("Verify", for: .normal)
                                loader.stopAnimating()
            print("TAPPED")
            let otpVC = storyboard?.instantiateViewController(identifier: "RegistrationViewController") as! RegistrationViewController
            timer?.invalidate()
            resendBtn.isHidden = true
            otpVC.mobileNumber=mobileNumber
            self.navigationController?.pushViewController(otpVC, animated: true)
        }
    }
    
    
    func clearOTPTextFields() {
        otpImage1.isHidden = false
        otpImage2.isHidden = false
        otpImage3.isHidden = false
        otpImage4.isHidden = false
        otpTextField1.text = ""
        otpTextField2.text = ""
        otpTextField3.text = ""
        otpTextField4.text = ""
        otpTextField1.becomeFirstResponder()
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
    
    @objc func dismissKeyboard() {
            view.endEditing(true) // This will dismiss the keyboard
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
        let currentTime = CACurrentMediaTime()

         if currentTime - lastClickTime < 1 { // Ignore multiple clicks within 1 second
             return
         }

         lastClickTime = currentTime

         // Handle button click action
         print("Button clicked")
        verifyOTP()
    }
    
    deinit {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
        print("******************** DEINIT RegisterOTPViewController REMOVED FROM MEMORY*********************")
    }
    
}

extension RegisterOTPViewController: UITextFieldDelegate{
    //    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    //        let newLength = (textField.text?.count ?? 0) + string.count - range.length
    //            return newLength <= 1 && (textField.text ?? "") != string
    //    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        let currentText = textField.text ?? ""
////        let newLength = currentText.count + string.count - range.length
//        let newLength = (currentText as NSString).replacingCharacters(in: range, with: string)
//        // Detecting delete (backspace) key press
////        if string.isEmpty  {
////            if textField == otpTextField2 && range.location == 0 {
////                otpTextField2.text = ""
////                otpTextField1.becomeFirstResponder()
////                return false
////            } else if textField == otpTextField3 && range.location == 0 {
////                otpTextField3.text = ""
////                otpTextField2.becomeFirstResponder()
////                return false
////            }else if textField == otpTextField4 && range.location == 0 {
////                otpTextField4.text = ""
////                otpTextField3.becomeFirstResponder()
////                return false
////            }
////        } else {
////            // Limit to 1 character and ensure the new string is not the same as the current text
////            if newLength <= 1 && currentText != string {
////                return true
////            } else {
////                return false
////            }
////        }
////        
////        return true
//        return newLength.count <= 1
//    }
    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        if textField == otpTextField1
//        {
//            if textField.text?.count ?? 0 > 0
//          {
//              clearOTPTextFields()
//          }
//        }
//        else if textField == otpTextField2
//        {
//            if textField.text?.count ?? 0 > 0
//          {
//              clearOTPTextFields()
//          }
//        }
//        else if textField == otpTextField3
//        {
//            if textField.text?.count ?? 0 > 0
//          {
//              clearOTPTextFields()
//          }
//        }
//        else if textField == otpTextField4
//        {
//            if textField.text?.count ?? 0 > 0
//          {
//              clearOTPTextFields()
//          }
//        }
//        else
//        {
//            otpTextField1.becomeFirstResponder()
//            otpTextField1.text! = ""
//            otpTextField2.text! = ""
//            otpTextField3.text! = ""
//            otpTextField4.text! = ""
//        }
//      }










}

//MARK: TIMER
extension RegisterOTPViewController {
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

extension RegisterOTPViewController{
    func getOTP() {
        let url = AppConfig.baseURL+"registration/Verify_and_check_mobile_number_sent_OTP"
        let params :  [String : Any] = [
            "mobile_number": mobileNumber,
            "Device_name" : "iOS",
            "member_type": 1 //1 for user, 2 fro driver
        ]
        print("RegisterOTPViewController -> url() -> url : \(url)")
        print("RegisterOTPViewController -> getOTP() -> params : \(params)")
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
                            self.otp = otpfromAPI
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
}


/* verify button action old code
 
 {
     var otpEntered = (otpTextField1.text ?? "") + (otpTextField2.text ?? "") + (otpTextField3.text ?? "") + (otpTextField4.text ?? "")
     print("otpEntered : \(otpEntered)")
     
     if otpEntered != otp {
         activityIndicator.stopAnimating()
         activityIndicator.isHidden = true
         buttonOpticity.isHidden = true
         let alertController = UIAlertController(title: "", message: "Invalid OTP.", preferredStyle: .alert)
         
         // Add an action (button)
         //                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
         let okAction = UIAlertAction(title: "OK", style: .default) { [self] _  in
             otpTextField1.text = ""
             otpTextField2.text = ""
             otpTextField3.text = ""
             otpTextField4.text = ""
             
             // Set the focus to otpTextField1
             otpTextField1.becomeFirstResponder()
             textFieldProperties()
         }
         alertController.addAction(okAction)
         present(alertController, animated: true, completion: nil)
     } else {
         activityIndicator.stopAnimating()
         activityIndicator.isHidden = true
         buttonOpticity.isHidden = true
         print("TAPPED")
         let otpVC = storyboard?.instantiateViewController(identifier: "RegistrationViewController") as! RegistrationViewController
         timer?.invalidate()
         resendBtn.isHidden = true
         otpVC.mobileNumber=mobileNumber
         self.navigationController?.pushViewController(otpVC, animated: true)
     }
 }
 
 
 */
