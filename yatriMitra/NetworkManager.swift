//
//  NetworkManager.swift
//  yatriMitra
//
//  Created by Kaizen Infotech Solutions Private Limited. on 22/07/24.
//

import Foundation
import Network
import UIKit

//class NetworkMonitor {
//
//    static let shared = NetworkMonitor()
//    
//    private let monitor = NWPathMonitor()
//    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
//
//    private init() {
//        monitor.pathUpdateHandler = { path in
//            if path.status == .satisfied {
//                print("Internet connection available")
//            } else {
//                DispatchQueue.main.async {
//                    self.showNoInternetAlert()
//                }
//            }
//        }
//        monitor.start(queue: queue)
//    }
//
//    private func showNoInternetAlert() {
//        if let topController = UIApplication.shared.keyWindow?.rootViewController {
//            let alert = UIAlertController(title: "No Internet Connection",
//                                          message: "Please check your internet connection and try again.",
//                                          preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default))
//            topController.present(alert, animated: true, completion: nil)
//        }
//    }
//}


//class NetworkMonitor {
//    static let shared = NetworkMonitor()
//    private let queue = DispatchQueue.global()
//    private var monitor = NWPathMonitor()
//    public private(set) var isConnected: Bool = false
//    public private(set) var connectionType : ConnectionType = .unknown
//    
//    enum ConnectionType {
//        case wifi
//        case cellular
//        case ethernet
//        case unknown
//    }
//    private init() {
//        monitor = NWPathMonitor()
//    }
//    public func startMonitoring() {
//        monitor.start(queue: queue)
//        monitor.pathUpdateHandler = {[weak self] path in
//            self?.isConnected = path.status == .satisfied
//            self?.getConnectionType(path)
//        }
//    }
//    public func stopMonitoring() {
//        monitor.cancel()
//    }
//    private func getConnectionType(_ path: NWPath) {
//        if path.usesInterfaceType(.wifi) {
//            connectionType = .wifi
//        } else if path.usesInterfaceType(.cellular) {
//            connectionType = .cellular
//        } else if path.usesInterfaceType(.wiredEthernet) {
//            connectionType = .ethernet
//        } else {
//            connectionType = .unknown
//        }
//    }
//}


class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let queue = DispatchQueue.global()
    var monitor: NWPathMonitor?
    public private(set) var isConnected: Bool = false
    public private(set) var connectionType: ConnectionType = .unknown
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }

    private init() {
        monitor = NWPathMonitor()
    }
    
    public func startMonitoring() {
        guard let monitor = monitor else { return }
        
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            self.isConnected = path.status == .satisfied
            self.getConnectionType(path)
        }
        
        monitor.start(queue: queue)
    }

    public func stopMonitoring() {
        monitor?.cancel()
        monitor = nil // Release monitor to break retain cycle
        print("******************** DEINIT NetworkMonitor REMOVED FROM MEMORY*********************")
    }

    private func getConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }
    }

    deinit {
        stopMonitoring()
    }
}
