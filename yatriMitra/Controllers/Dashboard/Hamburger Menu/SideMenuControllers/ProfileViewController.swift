//
//  ProfileViewController.swift
//  yatriMitra
//
//  Created by Kaizen Infotech Solutions Private Limited. on 12/06/24.
//

import UIKit
import Alamofire

protocol ProfileBackVC: AnyObject {
    func profileBackVC(memberID: Int?, banner: String?)
}

class ProfileViewController: UIViewController {
    
    
    @IBOutlet weak var nameTxtField: UITextField!
    @IBOutlet weak var mobileNoTxtField: UITextField!
    @IBOutlet weak var genderTxtField: UITextField!
    @IBOutlet weak var emailidTxtField: UITextField!
    @IBOutlet weak var genderBGView: UIView!
    @IBOutlet weak var gestureView: UIView!
    @IBOutlet weak var genderDropDownView: UIView!
    @IBOutlet weak var genderImg: UIImageView!
    @IBOutlet weak var mLbl: UILabel!
    @IBOutlet weak var fLbl: UILabel!
    @IBOutlet weak var buttonOpticity: UIButton!
    @IBOutlet weak var oLbl: UILabel!
    @IBOutlet weak var pLbl: UILabel!
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    weak var profileBackVCDelegate: ProfileBackVC?
    
    var toggleView = false
    var loader = UIActivityIndicatorView(style: .medium)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        createNavigationBar()
        addDoneButtonOnNumpad(textField: nameTxtField)
        addDoneButtonOnNumpad(textField: mobileNoTxtField)
        addDoneButtonOnNumpad(textField: genderTxtField)
        addDoneButtonOnNumpad(textField: emailidTxtField)
        updateBtn.layer.cornerRadius=10
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        gestureviews()
        self.genderDropDownView.isHidden = true
        activityIndicator.startAnimating()
        loader.color = .white
        loader.translatesAutoresizingMaskIntoConstraints = false
        updateBtn.addSubview(loader)
        
        // Center the activity indicator within the button
        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: updateBtn.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: updateBtn.centerYAnchor)
        ])
        registerForKeyboardNotifications()
        myProfileAPIcall()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true) // This will dismiss the keyboard
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
            let buttonFrameInView = emailidTxtField.convert(emailidTxtField.bounds, to: self.view)
            let buttonBottom = buttonFrameInView.maxY + 20  // 20 points padding
            
            // Get screen height
            let screenHeight = UIScreen.main.bounds.height
            
            // If the button is hidden behind the keyboard, adjust the scrollView
            let offset = max(0, buttonBottom - (screenHeight - keyboardHeight))
            
            UIView.animate(withDuration: 0.3) {
                self.scrollView.contentInset.bottom = keyboardHeight
                self.scrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
            }
//            NSLayoutConstraint.activate([
//                updateBtn.topAnchor.constraint(equalTo: emailidTxtField.bottomAnchor, constant: 20),
//                updateBtn.heightAnchor.constraint(equalToConstant: 35)
//            ])
        }
    }

    @objc func keyboardWillHide(_ notification: Notification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
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
    func createNavigationBar() {
        let customBackButton = UIButton()
        customBackButton.setImage(UIImage(named: "back"), for: .normal)
        customBackButton.addTarget(self, action: #selector(customBackButtonTapped), for: .touchUpInside)
        
        // Set custom back button as left bar button item
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customBackButton)
        
        self.title = "My Profile"
        
        // Optional: Customize the title appearance
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 20, weight: .bold)
        ]
        self.navigationController?.navigationBar.titleTextAttributes = titleAttributes
    }
    
    @objc func customBackButtonTapped() {
        self.profileBackVCDelegate?.profileBackVC(memberID: Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? ""), banner: "false")
        self.navigationController?.popViewController(animated: true)
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
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [self] _ in
            loader.stopAnimating()
            updateBtn.isEnabled = true
            updateBtn.setTitle("Update", for: .normal)
            
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func showEmailAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] _ in
            loader.stopAnimating()
            updateBtn.isEnabled = true
            updateBtn.setTitle("Update", for: .normal)
            emailidTxtField.text = ""
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "(?:[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\\.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-zA-Z0-9-]*[a-zA-Z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    @IBAction func updateBtnAction(_ sender: Any) {
        if NetworkMonitor.shared.isConnected
        //        {
        //            buttonOpticity.isHidden = false
        //            activityIndicator.isHidden = false
        //            activityIndicator.startAnimating()
        //            updateBtn.isEnabled = false
        //            updateBtn.setTitle("", for: .normal)
        //            loader.startAnimating()
        //            updateProfile()
        //        }
        {
            nameTxtField.resignFirstResponder()
            emailidTxtField.resignFirstResponder()
            genderDropDownView.isHidden = true
            self.genderImg.image = UIImage(named: "genderselect")
            buttonOpticity.isHidden = false
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            updateBtn.setTitle("", for: .normal)
            updateBtn.isEnabled = false
            loader.startAnimating()
            if nameTxtField.text == nil || nameTxtField.text == ""{
                print("username is mandatory")
                activityIndicator.stopAnimating()
                activityIndicator.isHidden = true
                buttonOpticity.isHidden = true
                showAlert(message: "Please Enter Your Name")
            } else if genderTxtField.text == nil || genderTxtField.text == "" {
                print("gender is mandatory")
                activityIndicator.stopAnimating()
                activityIndicator.isHidden = true
                buttonOpticity.isHidden = true
                showAlert(message: "Please select Gender")
            } else if let email = emailidTxtField.text  {
                if isValidEmail(email) && !email.isEmpty{
                    print("Valid Email")
                    updateProfile()
                    // Proceed with the desired action
                } else if !isValidEmail(email) && !email.isEmpty{
                    print("Invalid Email")
                    activityIndicator.stopAnimating()
                    activityIndicator.isHidden = true
                    buttonOpticity.isHidden = true
                    showEmailAlert(message: "Please enter correct Email ID")
                }
                else {
                    activityIndicator.stopAnimating()
                    activityIndicator.isHidden = true
                    buttonOpticity.isHidden = true
                    updateProfile()
                }
            } else {
                activityIndicator.stopAnimating()
                activityIndicator.isHidden = true
                buttonOpticity.isHidden = true
                updateProfile()
            }
        }
        
        else {
            print("you are not connected")
            let alert = UIAlertController(title: "No Internet Connection",
                                          message: "It looks like you're offline. Please check your internet connection.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default,handler: { [self] _ in
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


extension ProfileViewController{
    func myProfileAPIcall() {
        
        let url = AppConfig.baseURL+"member/My_Profile_View"
        let params :  [String : Any] = [
            //            "fk_bookride_id": 6
            "fk_member_master_profile_id": Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "")
        ]
        print("myProfileAPIcall() -> url : \(url)")
        print("myProfileAPIcall() -> parameters : \(params)")
        
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
                            let resultOut = loginResult["resultOut"] as? [[String : Any]]
                            print("resultOut : \(resultOut)")
                            if let results = resultOut {
                                print("entered in resultsOut")
                                for resultsOut in results {
                                    nameTxtField.text = resultsOut["first_name"] as? String ?? ""
                                    mobileNoTxtField.text = resultsOut["mobile_number"] as? String ?? ""
                                    genderTxtField.text = resultsOut["gender"] as? String ?? ""
                                    emailidTxtField.text = resultsOut["emailID"] as? String ?? ""
                                }
                            }
                            
                        } else {
                        }
                    } catch {
                        //                                   self.showAlert(title: "Error", message: "Failed to parse JSON: \(error.localizedDescription)")
                        let alertController = UIAlertController(title: "Network Error", message: "", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }else {
                    
                }
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    func updateProfile() {
        
        let url = AppConfig.baseURL+"member/AddEditUser_Details"
        let params : [String : Any] = ["pk_member_master_profile_id": Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? ""),
                                       "mobile_number": mobileNoTxtField.text,
                                       "first_name": nameTxtField.text,
                                       "gender": genderTxtField.text,
                                       "emailID": emailidTxtField.text,
                                       "IMEI_No": UIDevice.current.identifierForVendor?.uuidString,
//                                       "DeviceToken": UserDefaults.standard.string(forKey: "auth_deviceToken"),
                                       "DeviceToken": UserDefaults.standard.string(forKey: "fcm_token"),
                                       "Device_name": "iOS",
                                       "versionNo": "1.1"]
        print("updateProfile() -> url : \(url)")
        print("updateProfile() -> params : \(params)")
        
        let token = UserDefaults.standard.string(forKey: "auth_deviceToken") ?? ""

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { [self] response in
            print("updateProfile() -> response : \(response)")
            print("updateProfile() -> response.result : \(response.result)")
            
            switch response.result {
                
            case .success (let data) :
                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let loginResult = json["result"] as? [String: Any] {
                            print("updateProfile() -> JSON -------\(json)")
                            let status = loginResult["status"] as? String ?? ""
                            let message = loginResult["message"] as? String ?? ""
                            let fk_member_master_profile_id = loginResult["fk_member_master_profile_id"] as? Int
                            print("fk_member_master_profile_id : \(fk_member_master_profile_id)")
                            
                            if status == "0" || message == "OK"{
                                activityIndicator.stopAnimating()
                                activityIndicator.isHidden = true
                                buttonOpticity.isHidden = true
                                loader.stopAnimating()
                                updateBtn.setTitle("Update", for: .normal)
                                updateBtn.isEnabled = true
                                
                                //                            let alertController = UIAlertController(title: "Success", message: "Profile Updated Successfully", preferredStyle: .alert)
                                //                            let okaction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                //
                                //                            alertController.addAction(okaction)
                                //                            self.present(alertController, animated: true, completion: nil)
                                //                            self.view.showToast(message: "Profile Updated Successfully", duration: 10.0)
                                //                            let alertController = UIAlertController(title: "Success", message: "Profile Updated Successfully", preferredStyle: .alert)
                                let alertController = UIAlertController(title: "Success", message: "Successfully Updated", preferredStyle: .alert)
                                
                                // Present the alert controller
                                self.present(alertController, animated: true) {
                                    // Dismiss the alert after 5 seconds
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                        alertController.dismiss(animated: true, completion: nil)
                                    }
                                }
                            } else {
                                activityIndicator.stopAnimating()
                                activityIndicator.isHidden = true
                                buttonOpticity.isHidden = true
                                //                            let alertController = UIAlertController(title: "", message: "Update unsuccessful. Please check your internet and try again.", preferredStyle: .alert)
                                //                            let okaction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                //
                                //                            alertController.addAction(okaction)
                                //                            self.present(alertController, animated: true, completion: nil)
                                //                            self.view.showToast(message: "Update unsuccessful. Please check your internet and try again.", duration: 0.10)
                                let alertController = UIAlertController(title: "Update unsuccessful", message: "Please try again", preferredStyle: .alert)
                                
                                // Present the alert controller
                                self.present(alertController, animated: true) {
                                    // Dismiss the alert after 5 seconds
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                                        alertController.dismiss(animated: true, completion: nil)
                                    }
                                }
                            }
                        } else {
                        }
                    } catch {
                        //                                   self.showAlert(title: "Error", message: "Failed to parse JSON: \(error.localizedDescription)")
                        let alertController = UIAlertController(title: "Network Error", message: "", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }else {
            }
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
}


extension ProfileViewController{
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
    
    @objc func mLblTapped(_ sender: UITapGestureRecognizer) {
        genderTxtField.text = "Male"
        self.genderDropDownView.isHidden = true
        self.genderImg.image = UIImage(named: "genderselect")
    }
    
    @objc func fLblTapped(_ sender: UITapGestureRecognizer) {
        genderTxtField.text = "Female"
        self.genderDropDownView.isHidden = true
        self.genderImg.image = UIImage(named: "genderselect")
    }
    
    @objc func oLblTapped(_ sender: UITapGestureRecognizer) {
        genderTxtField.text = "Other"
        self.genderDropDownView.isHidden = true
        self.genderImg.image = UIImage(named: "genderselect")
    }
    @objc func pLblTapped(_ sender: UITapGestureRecognizer) {
        genderTxtField.text = "Prefer Not to Say"
        self.genderDropDownView.isHidden = true
        self.genderImg.image = UIImage(named: "genderselect")
    }
}
