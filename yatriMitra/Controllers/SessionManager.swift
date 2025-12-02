//
//  SessionManager.swift
//  yatriMitra
//
//  Created by Kaizen Infotech Solutions Private Limited. on 18/10/24.
//

import UIKit
import Alamofire

class SessionManager {
    static let shared = SessionManager()
    
    private init() {}

    var apiTimer: Timer?
    var member_master_profile_id : Int?
    var iOSversion: String?
    
    func startAPITimer() {
        apiTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(sessionTimeOut), userInfo: nil, repeats: true)
    }

    @objc func sessionTimeOut() {
        member_master_profile_id = Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "")
        let url = AppConfig.baseURL+"login/SessionTimeOut_VersionCheck"
        let params: [String: Any] = [
            "imeI_No": UIDevice.current.identifierForVendor?.uuidString ?? "",
            "fk_member_master_profile_id": member_master_profile_id
        ]
        
        let token = UserDefaults.standard.string(forKey: "auth_deviceToken") ?? ""

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]

        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default,headers: headers, interceptor: nil).response { response in
            switch response.result {
            case .success(let data):
                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let loginResult = json["result"] as? [String: Any] {
                            self.handleSessionResponse(loginResult, viewController: UIApplication.topViewController())
                        }
                    } catch {
                        print("Failed to parse JSON: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }

    private func handleSessionResponse(_ result: [String: Any], viewController: UIViewController?) {
        guard let status = result["status"] as? String else { return }
        let message = result["message"] as? String ?? ""

        if status == "0" {
            self.checkForVersionUpdate(result, viewController: viewController)
        } else if status == "-1" || status == "-2" {
            self.invalidateTimers()
            TimerManager.shared.stopAllTimers()
            member_master_profile_id = 0
            UserDefaults.standard.setValue(member_master_profile_id, forKey: "fk_member_master_profile_id")
            let alertMessage = (status == "-1") ? "Session Time out, Member is deleted!!" : "Session Timeout, Another user logged in with the same number!"
            self.presentSessionTimeoutAlert(message: alertMessage, viewController: viewController)
        }
    }

    private func checkForVersionUpdate(_ result: [String: Any], viewController: UIViewController?) {
        if let version = result["version"] as? [[String: Any]] {
            for dict in version {
                iOSversion = dict["ios"] as? String
            }

            let codeVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            if codeVersion ?? "" < iOSversion ?? "" {
                presentUpdateAlert(viewController: viewController)
            }
        }
    }

    private func invalidateTimers() {
        apiTimer?.invalidate()
        apiTimer = nil
        TimerManager.shared.stopAllTimers()
    }

    private func presentSessionTimeoutAlert(message: String, viewController: UIViewController?) {
        guard let vc = viewController else { return }
        if !(vc is ViewController || vc is MobileNoViewController || vc is OTPViewController || vc is RegisterMobileNoViewController || vc is RegisterOTPViewController || vc is RegistrationViewController) {
            TimerManager.shared.stopAllTimers()
            let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                let otpVC = vc.storyboard?.instantiateViewController(identifier: "LoginRegisterViewController") as! LoginRegisterViewController
                vc.navigationController?.pushViewController(otpVC, animated: true)
            }
            alertController.addAction(okAction)
            vc.present(alertController, animated: true, completion: nil)
        }
    }

    private func presentUpdateAlert(viewController: UIViewController?) {
        guard let vc = viewController else { return }
        let alertController = UIAlertController(title: "Force update", message: "There is a newer version available", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        vc.present(alertController, animated: true, completion: nil)
    }
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
