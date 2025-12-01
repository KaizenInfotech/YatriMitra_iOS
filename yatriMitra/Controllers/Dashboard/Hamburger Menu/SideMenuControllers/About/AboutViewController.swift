//
//  AboutViewController.swift
//  yatriMitra
//
//  Created by Kaizen Infotech Solutions Private Limited. on 12/06/24.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var versionLbl: UILabel!
    @IBOutlet weak var shareAppbtn: UIButton!
    @IBOutlet weak var termsOfServiceView: UIView!
    @IBOutlet weak var privacyPolicyView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var version:String = "6.6.5"
    var aboutArray = ["Terms of Service", "Privacy Policy"]
    
    weak var profileBackVCDelegate: ProfileBackVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        createNavigationBar()
//        versionLbl.text = "Version " + "\(version)"
        versionLbl.text = "Version " + (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        shareAppbtn.layer.cornerRadius = 10
        label1.setHTMLFromFile(fileName: "About_Html_code")
        label2.setHTMLFromFile(fileName: "About_Html_code 2")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(navigateToTermsandConditionsInAppViewController))
        termsOfServiceView.addGestureRecognizer(tapGesture)
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(navigateToPrivacyPolicyInAppViewController))
        privacyPolicyView.addGestureRecognizer(tapGesture1)
    }
    
    
    @objc func navigateToTermsandConditionsInAppViewController() {
        let otpVC = storyboard?.instantiateViewController(identifier: "TermsandConditionsInAppViewController") as! TermsandConditionsInAppViewController
        otpVC.urlString = "https://yatrimitra.com/public/terms.html"
        self.navigationController?.pushViewController(otpVC, animated: true)
    }
    
    @objc func navigateToPrivacyPolicyInAppViewController() {
        let otpVC = storyboard?.instantiateViewController(identifier: "PrivacyPolicyInAppViewController") as! PrivacyPolicyInAppViewController
        otpVC.urlString = "https://yatrimitra.com/public/privacy.html"
        self.navigationController?.pushViewController(otpVC, animated: true)
    }
    
    func createNavigationBar() {
        let customBackButton = UIButton()
        customBackButton.setImage(UIImage(named: "back"), for: .normal)
        customBackButton.addTarget(self, action: #selector(customBackButtonTapped), for: .touchUpInside)
        
        // Set custom back button as left bar button item
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customBackButton)
        self.title = "About"
        
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
    
    @IBAction func shareAppBtnAction(_ sender: Any) {
//        let message = """
//        App Link : https://onelink.to/cgexnu
//        """
        let message = """
        🚖 Ride Smart. Ride Fair. Ride Yatri Mitra! 🛺
        
        Say goodbye to surge pricing & hidden fees! With Yatri Mitra, you pay only what’s on the meter—no extra charges, no surprises!

        ✅ Meter-Based Fares – Fair & transparent
        ✅ Zero Commission – More earnings for drivers
        ✅ No Surge Pricing – Affordable rides, always

        📲 Download now: https://onelink.to/cgexnu
        """
        // Create an array with the items to share
        if let image = UIImage(named: "shareQRcodeImg 1") {
            // Create an array with the text and image to share
            let itemsToShare: [Any] = [image, message]
            
            // Initialize the UIActivityViewController
            let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
            
            // Exclude some activity types if necessary
            activityViewController.excludedActivityTypes = [.assignToContact, .saveToCameraRoll, .print]
            
            // Present the share sheet
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
}

extension AboutViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aboutArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AboutTableViewCell") as! AboutTableViewCell
        cell.selectionStyle = .none
        cell.labelTxt.text = aboutArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Tapped this")
        let result = aboutArray[indexPath.row]
        print("result : \(result)")
        if result == "Terms of Service" {
            print("Terms of Service")
//            if let url = URL(string: "https://yatrimitra.com/public/terms.html") {
//                   UIApplication.shared.open(url, options: [:], completionHandler: nil)
//               }
            let otpVC = storyboard?.instantiateViewController(identifier: "TermsandConditionsInAppViewController") as! TermsandConditionsInAppViewController
            otpVC.urlString = "https://yatrimitra.com/public/terms.html"
            self.navigationController?.pushViewController(otpVC, animated: true)
        } else  if result == "Privacy Policy" {
            print("Privacy Policy")
//            if let url = URL(string: "https://yatrimitra.com/public/privacy.html") {
//                   UIApplication.shared.open(url, options: [:], completionHandler: nil)
//               }
            let otpVC = storyboard?.instantiateViewController(identifier: "PrivacyPolicyInAppViewController") as! PrivacyPolicyInAppViewController
            otpVC.urlString = "https://yatrimitra.com/public/privacy.html"
            self.navigationController?.pushViewController(otpVC, animated: true)
        }
    }

}

extension UILabel {
    func setHTMLFromFile(fileName: String) {
        // Get the file path from the bundle
        guard let filePath = Bundle.main.path(forResource: fileName, ofType: "html") else {
            print("File not found")
            return
        }
        
        do {
            // Read HTML content as a String
            let htmlString = try String(contentsOfFile: filePath, encoding: .utf8)
            
            // Convert HTML string to NSAttributedString
            guard let data = htmlString.data(using: .utf8) else { return }
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]
            
            // Set the attributed text
            if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
                self.attributedText = attributedString
            }
        } catch {
            print("Error loading HTML file: \(error.localizedDescription)")
        }
    }
}
