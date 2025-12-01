//
//  DeleteAccountViewController.swift
//  yatriMitra
//
//  Created by Kaizen Infotech Solutions Private Limited. on 17/01/25.
//

import UIKit
import WebKit

class DeleteAccountViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    weak var profileBackVCDelegate: ProfileBackVC?
    
    var urlString: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        // Do any additional setup after loading the view.
        createNavigationBar()
        loadURL()
    }
    

    func createNavigationBar() {
        let customBackButton = UIButton()
        customBackButton.setImage(UIImage(named: "back"), for: .normal)
        customBackButton.addTarget(self, action: #selector(customBackButtonTapped), for: .touchUpInside)
        
        // Set custom back button as left bar button item
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customBackButton)
        self.title = "Delete Account"
        
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
    func loadURL() {
            guard let urlString = urlString, let url = URL(string: urlString) else {
                print("Invalid URL")
                return
            }
            let request = URLRequest(url: url)
            webView.load(request)
        }

}
