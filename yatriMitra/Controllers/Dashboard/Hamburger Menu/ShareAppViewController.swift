//
//  ShareAppViewController.swift
//  yatriMitra
//
//  Created by Kaizen Infotech Solutions Private Limited. on 29/01/25.
//

import UIKit

class ShareAppViewController: UIViewController {
    
    @IBOutlet weak var shareQRcodeLbl: UILabel!
    @IBOutlet weak var downloadLinkView: UIView!
    @IBOutlet weak var linkLBL: UILabel!
    @IBOutlet weak var shareQRcodeBtn: UIButton!
    @IBOutlet weak var scanQRcodeView: UIView!
    
    weak var profileBackVCDelegate: ProfileBackVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        scanQRcodeView.layer.cornerRadius = 10
        downloadLinkView.layer.cornerRadius = 10
        shareQRcodeBtn.layer.cornerRadius = 10
        shareQRcodeLbl.text = "Scan the QR Code \n To Download the App"
        //        let imageAttachment = NSTextAttachment()
        //        imageAttachment.image = UIImage(named: "yourImageName") // Replace with your image name
        //        imageAttachment.bounds = CGRect(x: 0, y: -3, width: 20, height: 20) // Adjust size and position
        //
        //        let attributedString = NSMutableAttributedString(attachment: imageAttachment)
        //        let textString = NSAttributedString(string: " Share QR Code", attributes: [
        //            .font: UIFont.systemFont(ofSize: 16),
        //            .foregroundColor: UIColor.black
        //        ])
        //        shareQRcodeBtn.append(textString)
        //        linkLBL.text = "https://apps.apple.com/in/app/yatri-mitra/id6529536162"
        //        let text = "https://apps.apple.com/in/app/yatri-mitra/id6529536162"
        let text = "https://onelink.to/cgexnu"
        let attributedString = NSMutableAttributedString(string: text)
        
        // Add underline attribute
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.count))
        
        // Set attributed text to label
        linkLBL.attributedText = attributedString
        shareQRcodeBtn.setImage(UIImage(named: "shareImg"), for: .normal)
        
        //        shareQRcodeBtn.setAttributedTitle(attributedString, for: .normal)
        createNavigationBar()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openAppStore))
        linkLBL.isUserInteractionEnabled = true
        linkLBL.addGestureRecognizer(tapGesture)
        
        //GOOGLE ANALYTICS
        AnalyticsManager.shared.appShare()

    }
    func createNavigationBar() {
        let customBackButton = UIButton()
        customBackButton.setImage(UIImage(named: "back"), for: .normal)
        customBackButton.addTarget(self, action: #selector(customBackButtonTapped), for: .touchUpInside)
        
        // Set custom back button as left bar button item
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customBackButton)
        self.title = "Share App"
        
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
    
    
    @IBAction func copyDownloadLinkAction(_ sender: Any) {
        let link = "https://onelink.to/cgexnu"
        
        // Copy link to clipboard
        UIPasteboard.general.string = link
        
        // Show toast message
        if let copiedText = UIPasteboard.general.string, copiedText == link {
            //            let alertController = UIAlertController(title: "Link copied!", message: "", preferredStyle: .alert)
            let alertController = UIAlertController(title: "Text copied!", message: "", preferredStyle: .alert)
            
            // Present the alert controller
            self.present(alertController, animated: true) {
                // Dismiss the alert after 5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    alertController.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            let alertController = UIAlertController(title: "Failed to copy link", message: "", preferredStyle: .alert)
            
            // Present the alert controller
            self.present(alertController, animated: true) {
                // Dismiss the alert after 5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    alertController.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func shareQRcodeBtnAction(_ sender: Any) {
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
        // Create an array with the items to share  WhatsApp Image 2025-01-29 at 5.57.55 PM
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
    
    @objc func openAppStore() {
        if let url = URL(string: "https://apps.apple.com/in/app/yatri-mitra/id6529536162") {
            UIApplication.shared.open(url)
        }
    }
}
