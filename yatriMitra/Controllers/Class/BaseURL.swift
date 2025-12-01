//
//  BaseURL.swift
//  yatriMitra
//
//  Created by Kaizen Infotech Solutions Private Limited. on 10/01/25.
//

import Foundation
import UIKit

public struct AppConfig {
//    public static let baseURL = "https://demoapi.yatrimitra.com/api/"
    public static let baseURL = "https://api.yatrimitra.com/api/"  //--> LIVE
    
    public static func gotoAppStore() {
        if let url = URL(string:"https://apps.apple.com/us/app/yatri-mitra/id6529536162") {
           if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:]) { success in
                    if success {
                        print("The URL was successfully opened.")
                    } else {
                        print("Failed to open the URL.")
                    }
                }
            }
        }
    }

}
//
