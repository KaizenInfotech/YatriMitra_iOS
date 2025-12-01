//
//  EmergencyViewController.swift
//  yatriMitra
//
//  Created by Kaizen Infotech Solutions Private Limited. on 12/06/24.
//

import UIKit

class EmergencyViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    weak var profileBackVCDelegate: ProfileBackVC?
    
    var emergency = ["Ambulance", "Police"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        createNavigationBar()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func createNavigationBar() {
        let customBackButton = UIButton()
        customBackButton.setImage(UIImage(named: "back"), for: .normal)
        customBackButton.addTarget(self, action: #selector(customBackButtonTapped), for: .touchUpInside)
        
        // Set custom back button as left bar button item
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customBackButton)
        
        self.title = "Emergency"
        
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
    func dialNumber(phoneNumber: String) {
            if let phoneURL = URL(string: "tel://\(phoneNumber)"),
               UIApplication.shared.canOpenURL(phoneURL) {
                UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
            } else {
                print("Error: Cannot make a call.")
            }
        }
}


extension EmergencyViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emergency.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmergencyTableViewCell") as! EmergencyTableViewCell
       
        cell.selectionStyle = .none
        cell.emergencyLbl.text = emergency[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let emergencyType = emergency[indexPath.row]
                var phoneNumber: String?
                
        if emergencyType.contains("Ambulance"){
            dialNumber(phoneNumber: "102")
                } else if emergencyType.contains("Police") {
                    dialNumber(phoneNumber: "100")
                }
    }
}
