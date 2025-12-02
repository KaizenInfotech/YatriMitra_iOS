//
//  analytics.swift
//  yatriMitra
//
//  Created by Manikandan on 25/11/25.
//

import Foundation
import FirebaseAnalytics

final class AnalyticsManager {

    static let shared = AnalyticsManager()
    private init() {}

    // MARK: - Standard Parameters
    private func baseParams(extra: [String: Any] = [:]) -> [String: Any] {
        
//        let uid = Auth.auth().currentUser?.uid
//        Analytics.setUserID(uid)

        let userId = UserDefaults.standard.string(forKey: "user_id") ?? ""
//        let city = UserDefaults.standard.string(forKey: "user_city") ?? ""
        let sourceMedium = UserDefaults.standard.string(forKey: "utm_source_medium") ?? ""

        var params: [String: Any] = [
            "user_id": userId,
            "user_type": "passenger",
            "platform": "ios",
            "city": "Mumbai",
            "timestamp": Int(Date().timeIntervalSince1970),
            "source_medium": sourceMedium
        ]

        // Add extra event-specific parameters
        extra.forEach { params[$0.key] = $0.value }
        return params
    }

    // MARK: - Log Event
    private func log(_ name: String, params: [String: Any] = [:]) {
        Analytics.logEvent(name, parameters: baseParams(extra: params))
        print(" GA Event: \(name) → \(params)")
    }

    
    // MARK: - Passenger App Events

    func appOpen() {
        log("app_open")
    }

    func signupComplete(method: String) {
        log("signup_complete", params: [
            "method": method
        ])
    }

    func loginSuccess(method: String) {
        log("login_success", params: [
            "method": method
        ])
    }

    func rideSearch(pickup: String, drop: String, distance: Double) {
        log("ride_search", params: [
            "pickup": pickup,
            "drop": drop,
            "distance": distance
        ])
    }

    func rideRequested(pickup: String, drop: String, fare: Double) {
        log("ride_requested", params: [
            "pickup": pickup,
            "drop": drop,
            "fare_estimate": fare
        ])
    }

    func rideAccepted() {
        log("ride_accepted")
    }

    func rideStarted() {
        log("ride_started")
    }

    func rideCompleted(fare: Double, distance: Double, duration: Double) {
        log("ride_completed", params: [
            "fare_amount": fare,
            "distance": distance,
            "duration": duration
        ])
    }

    func paymentSuccess(mode: String, amount: Double) {
        log("payment_success", params: [
            "payment_mode": mode,
            "amount": amount
        ])
    }

    func rideCancelled(reason: String) {
        log("ride_cancelled", params: [
            "reason": reason,
            "user_type": "passenger"
        ])
    }

    func rateDriver(rating: Int) {
        log("rate_driver", params: [
            "rating_value": rating
        ])
    }

    func appShare() {
        log("app_share")
    }

    func supportClick() {
        log("support_click")
    }
}
