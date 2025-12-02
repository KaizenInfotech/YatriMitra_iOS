//
//  FareCardViewController.swift
//  yatriMitra
//
//  Created by Kaizen Infotech Solutions Private Limited. on 17/01/25.
//

import UIKit
import WebKit

class FareCardViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    var urlString: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        createNavigationBar()
        loadURL()
    }
    

    func createNavigationBar() {
        let customBackButton = UIButton()
        customBackButton.setImage(UIImage(named: "back"), for: .normal)
        customBackButton.addTarget(self, action: #selector(customBackButtonTapped), for: .touchUpInside)
        
        // Set custom back button as left bar button item
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customBackButton)
        self.title = "Fare Card"
        
        // Optional: Customize the title appearance
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 20, weight: .bold)
        ]
        self.navigationController?.navigationBar.titleTextAttributes = titleAttributes
    }
    
    @objc func customBackButtonTapped() {
        // Perform the custom back button action
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
