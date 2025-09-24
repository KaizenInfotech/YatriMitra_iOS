//
//  AppDelegate.swift
//  yatriMitra
//
//  Created by Kaizen Infotech Solutions Private Limited. on 04/06/24.
//

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces
import Alamofire
import Firebase
import FirebaseMessaging
import FirebaseInAppMessaging
import UserNotifications
import FirebaseCore
import FirebaseAuth
import FirebaseRemoteConfig
import CoreData
import FacebookCore
import AppTrackingTransparency
import AdSupport

@main

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    let locationManager = CLLocationManager()
    let googleAPIKey = "AIzaSyDce_Ybso83w6ay7NoKCuA5y33udrxGhmk"
    let mapMyIndiaKay = "9c2c3540616bedfaf261461beeb24c6f"
    weak var window: UIWindow?
    weak var notifyDict:NSDictionary!
    let gcmMessageIDKey = "gcm.message_id"
    var mainUserInfo:[AnyHashable: Any] = [:]
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Thread.sleep(forTimeInterval: 1.0)
        print("imeiiii : \(UIDevice.current.identifierForVendor?.uuidString)")
//        NetworkMonitor.shared
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        //        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        //           UNUserNotificationCenter.current().requestAuthorization(
        //               options: authOptions,
        //               completionHandler: { _, _ in }
        //           )
        //        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        //               print("Called Notification Delegates")
        //           }
        //        UNUserNotificationCenter.current().delegate = self
        //        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        //            if granted {
        //                print("Notification permission granted")
        //                Messaging.messaging().delegate = self
        //
        //                DispatchQueue.main.async {
        //                    UIApplication.shared.registerForRemoteNotifications()
        //                }
        //            } else if let error = error {
        //                print("Error requesting notification permission: \(error.localizedDescription)")
        //            }
        //        }
        getRemoteConfig_ComingSoon()
        registerPushNotifications()
        
        GMSServices.provideAPIKey(googleAPIKey)
        GMSPlacesClient.provideAPIKey(googleAPIKey)
        TimerManager.shared.stopAllTimers()
        NetworkMonitor.shared.startMonitoring()
        locationManager.requestAlwaysAuthorization()
        //        self.splashScreen()
//                deviceToken()
        
        //MARK: FACEBOOK INTEGRATION
        
        // 1. Initialize Facebook SDK
           ApplicationDelegate.shared.application(
               application,
               didFinishLaunchingWithOptions: launchOptions
           )

           // 2. Debug SDK version
           print("Facebook SDK Version: \(Settings.shared.sdkVersion)")

           // 3. Optional: Explicitly activate app (not needed in SDK 14+)
           AppEvents.shared.activateApp()

           // 4. Facebook SDK configuration
           Settings.shared.isAutoLogAppEventsEnabled = true
           Settings.shared.isAdvertiserIDCollectionEnabled = true
           Settings.shared.isEventDataUsageLimited = false

           // 5. Request ATT permission (iOS 14+)
//           DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//               self.requestTrackingPermission()
//           }
        
        NotificationCenter.default.addObserver(self,
                                                   selector: #selector(deviceToken),
                                                   name: .forceDeviceToken,
                                                   object: nil)

         return true
    }
    
    func requestTrackingPermission() {
        if #available(iOS 14, *) {
            let currentStatus = ATTrackingManager.trackingAuthorizationStatus

            guard currentStatus == .notDetermined else {
                print("ATT already determined: \(currentStatus.rawValue)")
                return
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    switch status {
                    case .authorized:
                        Settings.shared.isAdvertiserTrackingEnabled = true
                        print("ATT authorized")

                    case .denied, .restricted:
                        Settings.shared.isAdvertiserTrackingEnabled = false
                        print("ATT denied/restricted")

                    case .notDetermined:
                        Settings.shared.isAdvertiserTrackingEnabled = false
                        print("ATT not determined")

                    @unknown default:
                        Settings.shared.isAdvertiserTrackingEnabled = false
                        print("ATT unknown")
                    }

                    let idfa = ASIdentifierManager.shared().advertisingIdentifier
                    print("IDFA: \(idfa.uuidString)")
                }
            }
        } else {
            Settings.shared.isAdvertiserTrackingEnabled = true
        }
    }

    
    func application(
            _ app: UIApplication,
            open url: URL,
            options: [UIApplication.OpenURLOptionsKey : Any] = [:]
        ) -> Bool {
            return ApplicationDelegate.shared.application(app, open: url, options: options)
        }
    
    
    func getRemoteConfig_ComingSoon() {
        print("getRemoteConfig_ComingSoon: ")

        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0 // Set a higher value in production
        remoteConfig.configSettings = settings

        // Fetch and activate values
        remoteConfig.fetchAndActivate { status, error in
            if status != .error {
                print("getRemoteConfig_ComingSoon: isSuccessful")

                let showBanner = remoteConfig.configValue(forKey: "show_banner").stringValue
                print("getRemoteConfig_ComingSoon: isSuccessful showBanner \(showBanner)")
                UserDefaults.standard.set(showBanner, forKey: "showBanner")
                
                let bannerURL = remoteConfig.configValue(forKey: "iOS_banner_Img").stringValue
                print("getRemoteConfig_ComingSoon: isSuccessful BannerURL \(bannerURL)")
                UserDefaults.standard.set(bannerURL, forKey: "banner_URL")
                
                NotificationCenter.default.post(name: .bannerImgShow, object: nil)
                NotificationCenter.default.post(name: .bannerImgURL, object: nil)
                
                if showBanner == "true" {
                    print("getRemoteConfig_ComingSoon: isSuccessful if true showBanner \(showBanner)")
                    NotificationCenter.default.post(name: .bannerImgShow, object: nil)

                    // Load image or perform action
//                    self.showImagePopup_ComingSoon()
                    
                } else {
                    print("getRemoteConfig_ComingSoon: isSuccessful if false showBanner \(showBanner)")

//                    if let dialog = self.dialog, dialog.isShowing {
//                        dialog.dismiss()
//                    }
                }
            } else {
                print("getRemoteConfig_ComingSoon: Failed to fetch remote config: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    private func registerPushNotifications() {
        print("Registered of UN User notification")
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert], completionHandler: { granted, error in
            if granted {
                DispatchQueue.main.async{
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    switch settings.authorizationStatus {
                    case .authorized:
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    case .denied:
                        print("Notifications are denied.")
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                            DispatchQueue.main.async {
                                UIApplication.shared.registerForRemoteNotifications()
                            }
                            
                        }
                    case .notDetermined:
                        // Request authorization
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                            if granted {
                                DispatchQueue.main.async {
                                    UIApplication.shared.registerForRemoteNotifications()
                                }
                            } else {
                                print("User denied notification permission.")
                            }
                        }
                    default:
                        break
                    }
                }
            }
        })
        
    }
    
    
    
    //
    //        func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    //            let userInfo = response.notification.request.content.userInfo
    //            handleNotification(userInfo: userInfo) // Handle message keys here
    //            completionHandler()
    //        }
    //
    //
    func handleNotification(userInfo: [AnyHashable: Any]) {
        if let messageKey = userInfo["message_key"] as? String {
            print("Message Key: \(messageKey)")
            // Handle the message key accordingly
        }
    }
//    private func splashScreen() {
//        let launchScreen = UIStoryboard.init(name: "LaunchScreen", bundle: nil)
//        let rootVC = launchScreen.instantiateViewController(withIdentifier: "splashScreen")
//        self.window?.rootViewController = rootVC
//        self.window?.makeKeyAndVisible()
//        Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(dismissSplashController), userInfo: nil, repeats: true)
//    }
//    
//    @objc func dismissSplashController() {
//        let mainVC = UIStoryboard.init(name: "Main", bundle: nil)
//        let rootVC = mainVC.instantiateViewController(withIdentifier: "ViewController")
//        self.window?.rootViewController = rootVC
//        self.window?.makeKeyAndVisible()
//    }
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    @objc func deviceToken()  {
        let url = AppConfig.baseURL+"authtoken/authentication"
        var params: [String: String] = ["username": "YatriMitra", "Password": "YatriMitra@987654#$"]
        let headers: HTTPHeaders = [
              "Content-Type": "application/json"
            ]
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil, interceptor: nil).response { response in
            
            print("response Status Code: \(response.response?.statusCode ?? 0)")
            var statusCode = response.response?.statusCode ?? 0
            print("response authtoken1: \(response.result)")
                switch response.result {
                case .success(let data):
                    do{
                      guard let jsonData = data else {
                          print("Error: Data is nil")
                          return
                      }
                      let responseData = try JSONDecoder().decode(ResponseData.self, from: jsonData)
                      print("auth jsonData : ", responseData)
                        var deviceToken = responseData.result.token
                            print("deviceToken : \(deviceToken)")
                            UserDefaults.standard.setValue(deviceToken, forKey: "auth_deviceToken")
                    
                   } catch {
                       print("catch error: ",error.localizedDescription)
//                       let alertController = UIAlertController(title: "Network Error", message: "", preferredStyle: .alert)
//                           let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//                           alertController.addAction(okAction)
//                           self.present(alertController, animated: true, completion: nil)
                   }
                    //                    let dd = response as? NSDictionary
                    //                    let status = ((dd?.value(forKey: "result") as! AnyObject).value(forKey: "status"))
                    //                    let message = ((dd?.value(forKey: "result") as! AnyObject).value(forKey: "message"))
                    //                    let token = ((dd?.value(forKey: "result") as! AnyObject).value(forKey: "token"))
                    ////                    let status = loginResult?["status"] as? String
                    //                    print("status : \(status)")
                    ////                    let message = loginResult?["message"] as? String
                    //                    print("message : \(message)")
                    ////                    let token = loginResult?["token"] as? String
                    //                    print("token : \(token)")
                case .failure(let error):
                    print("Error : ",error.localizedDescription)
                }
            }
        
    }
    
    func networkCheck() {
        do {
            try Network.reachability = Reachability(hostname: "www.google.com")
        }
        catch {
            switch error as? Network.Error {
            case let .failedToCreateWith(hostname)?:
                print("Network error:\nFailed to create reachability object With host name d:", hostname)
            case let .failedToInitializeWith(address)?:
                print("Network error:\nFailed to initialize reachability object With address:", address)
            case .failedToSetCallout?:
                print("Network error:\nFailed to set callout")
            case .failedToSetDispatchQueue?:
                print("Network error:\nFailed to set DispatchQueue")
            case .none:
                print(error)
            }
        }
    }
    func storeNotificationLocally(userInfo:NSDictionary) {
//        [AnyHashable("pin"): 4895,
//         AnyHashable("vehicle_image_url"): https://yatrimitra.com/Styles\images\rickshaw.png,
//         AnyHashable("Drivername"): satish,
//         AnyHashable("driver_current_latitude"): 19.1952752,
//         AnyHashable("pickup_longitude"): 72.95602988451719,
//         AnyHashable("destination_longitude"): 72.95629149999999,
//         AnyHashable("google.c.fid"): e3QWlqPwQU8JrHfIGeF7iP,
//         AnyHashable("sourcePlaceName"): B-23, Neheru Nagar, Wagle Industrial Estate, Thane West, Mumbai, Thane, Maharashtra 400604, India, AnyHashable("google.c.sender.id"): 890698644180,
//         AnyHashable("fk_bookride_id"): 436,
//         AnyHashable("destinationPlaceName"): Mulund Railway Station, Pandit Jawaharlal Nehru Rd, station, Mulund West, Mumbai, Maharashtra 400080, India, AnyHashable("pickup_latitude"): 19.195776455550178,
//         AnyHashable("destination_latitude"): 19.1720555,
//         AnyHashable("aps"): {
//            "content-available" = 1;
//        }, AnyHashable("fk_member_master_profile_id"): 22,
//         AnyHashable("gcm.message_id"): 1733910604140606,
//         AnyHashable("driver_current_longitude"): 72.954886,
//         AnyHashable("MobileNumber"): 9686348862,
//         AnyHashable("Message"): Please share the Pin with the Driver to start the ride,
//         AnyHashable("Vehicle_no"): MH04LC9665,
//         AnyHashable("Vehicle_Brand_Model"): ACTIVA 6G DLX,
//         AnyHashable("driver_image_url"): https://yatrimitra.com/Documents/ProfilePhoto/Photo_107102024053924PM.png, AnyHashable("Title"): Your Driver has reached your location]
         
         
        var messageID:String=""
        var title:String=""
        var mDetails:String=""
        var currentDate:String=""
        var expiryDate:String=""
        let date=Date()
        print("userInfo : \(userInfo)")
        //1578904672967993
        
        if let messageIDs = userInfo["gcm.message_id"] as? String {
                   print("Message ID: \(messageIDs)")
            messageID=messageIDs
               }
//        
////        if let titles = userInfo["gcm.message_id"] as? String {
////                   print("Message ID: \(messageIDs)")
////            title=titles
////               }
//        
//        if let description = userInfo["gcm.notification.description"] as? String {
//                   print("description: \(description)")
//            mDetails=description
//               }
//        
//        
//        if let aps=userInfo["aps"] as? NSDictionary
//        {
//            if let alert = aps.value(forKey: "alert") as? String
//            {
////                if let titles=alert.value(forKey: "title") as? String
////                {
//                    title=alert
//                print(title)
////                }
////                if let body=alert.value(forKey: "body") as? String
////                {
////                    mDetails=body
////                }
//
//
//                let df:DateFormatter=DateFormatter()
//                df.dateFormat="dd/MM/YYYY hh:mm a"
//                currentDate=df.string(from: date)
//
//                let now = Calendar.current.dateComponents(in: .current, from: Date())
//
//                let tomorrow = DateComponents(year: now.year, month: now.month, day: now.day! + 3)
//                if  let expiryDates = Calendar.current.date(from: tomorrow)
//                {
//                df.dateFormat="dd/MM/YYYY"
//                expiryDate = df.string(from: expiryDates)
//                }
//            }
//        }
     
        let appDelegates = UIApplication.shared.delegate as! AppDelegate

         let nscontext = appDelegates.persistentContainer.viewContext

        let entity = NSEntityDescription.entity(forEntityName: "Entity", in: nscontext)
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
                         request.entity = entity
                 let pred = NSPredicate(format: "id = %@", messageID as CVarArg)
                         request.predicate = pred
                         do
                         {
                             let result = try nscontext.fetch(request)
                             
                             if result.count > 0
                             {
                                 let manage = result[0] as! NSManagedObject
                                 nscontext.delete(manage)
                                 try nscontext.save()
                                 print("Record Deleted")
                             }
                             else
                             {
                                 print("Record Not Found")
                             }
                          
                         }
                         catch {}
        
        
        
           let newUser = NSManagedObject(entity: entity!, insertInto: nscontext)
            newUser.setValue(messageID, forKey: "id")
//            newUser.setValue(title, forKey:"title")
//            newUser.setValue(mDetails, forKey: "details")
//            newUser.setValue(currentDate, forKey: "notify_date")
//            newUser.setValue(expiryDate, forKey: "expiry_date")
//            newUser.setValue(date, forKey: "sort_date")
//            newUser.setValue("Unread", forKey: "flag")
        
            do
            {
                try nscontext.save()
            }
            catch
            {
                
            }
            print("Record Inserted")
    }
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "yatriMitra")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func applicationWillTerminate(_ application: UIApplication) {
        let memberprofileid = Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "")
        print("memberprofileid : \(memberprofileid)")
        UserDefaults.standard.setValue(memberprofileid, forKey: "fk_member_master_profile_id")
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        print("applicationDidReceiveMemoryWarning")
    }
}

extension Notification.Name {
    static let forceUpdate = Notification.Name("FORCEUPDATE")
    static let bannerImgShow = Notification.Name("Banner_Img_Show")
    static let bannerImgURL = Notification.Name("Banner_Img_URL")
    static let forceDeviceToken = Notification.Name("Force_Device_Token")
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNS token: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
        
        Messaging.messaging().token { token, error in
            //            if let error = error {
            //                print("Error fetching FCM registration token1: \(error)")
            //            } else if let token = token {
            print("didRegisterForRemoteNotificationsWithDeviceToken : FCM registration token: \(token)")
            UserDefaults.standard.setValue(token, forKey: "fcm_token")
            //            }
        }
    }
    
    //    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
    ////        let userInfo = notification.request.content.userInfo
    ////        print("userInfo : \(userInfo)")
    //        print("willPresent notification: UNNotification) async -> UNNotificationPresentationOptions")
    ////        if #available(iOS 14.0, *) {
    ////            return [.badge, .sound, .banner]
    ////        } else {
    ////            return [.badge, .sound, .alert]
    ////        }
    //        return [.badge, .sound, .alert]
    //    }
    
    
    //    func userNotificationCenter(_ center: UNUserNotificationCenter,
    //                                willPresent notification: UNNotification,
    //                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    //        let userInfo = notification.request.content.userInfo
    //
    //        print("userNotificationCenter will present userinfo \(userInfo)")
    //        storeNotificationLocally(userInfo: userInfo as NSDictionary)
    //        // With swizzling disabled you must let Messaging know about the message, for Analytics
    //        // Messaging.messagidng().appDidReceiveMessage(userInfo)
    //
    //        // Print message ID.//NotifyList
    //        NotificationCenter.default.post(name: Notification.Name("NotifyDashboard"), object: nil)
    //        NotificationCenter.default.post(name: Notification.Name("NotifyList"), object: nil)
    //
    //        completionHandler([UNNotificationPresentationOptions.alert,
    //                           UNNotificationPresentationOptions.sound,
    //                           UNNotificationPresentationOptions.badge])
    //    }
    
    //    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
    
    
    //    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult {
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let messageID = userInfo["gcm.message_id"], let title = userInfo["Title"] as? String, let message = userInfo["Message"] as? String {
            print("messageID : \(messageID)")
            //            let notificationData: [String: Any] = [
            //                        "Message": message,
            //                    ]
            print("message from notification : \(message)")
            print("title from notification : \(title)")
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = message
            content.sound = UNNotificationSound(named: UNNotificationSoundName("NotiTone.caf"))
            //            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//            let request = UNNotificationRequest(identifier: "fred", content: content, trigger: nil)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error adding notification: \(error)")
                } else {
                    print("Notification scheduled")
                    
                    // Remove the notification after it appears (for example, 2 seconds later)
                    //                                        DispatchQueue.main.asyncAfter(deadline: .now() + 15) { // 7 seconds total: 5 to show, 2 to stay
                    //                                            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["fred"])
                    //                                            print("Notification removed")
                    //                                        }
                }
            }
            //            UserDefaults.standard.set(notificationData, forKey: "latestNotificationData")
            //                    print("Notification data stored: \(notificationData)")
        }
        print("userInfo2 : \(userInfo)")
                guard let title = userInfo["Title"] as? String else {
                completionHandler(.failed)
                return
            }
//        if title.contains("Ride Started") {
//                // Titles to be removed
//                let titlesToRemove = [
//                    "Your ride pin is",
//                    "Ride Accepted",
//                    "Get ready for your driver",
//                    "Your Driver has reached your location"
//                ]
//                
//                let notificationCenter = UNUserNotificationCenter.current()
//                notificationCenter.getDeliveredNotifications { notifications in
//                    // Identify notifications to remove by title
//                    let identifiersToRemove = notifications.compactMap { notification -> String? in
//                        let notificationTitle = notification.request.content.title
//                        return titlesToRemove.contains(where: { notificationTitle.contains($0) }) ? notification.request.identifier : nil
//                    }
//                    
//                    // Remove notifications with these identifiers
//                    notificationCenter.removeDeliveredNotifications(withIdentifiers: identifiersToRemove)
//                }
//            }
        
//        if title.contains("Ride Ended") {
//                // Titles to be removed
//                let titlesToRemove = [
//                    "Ride Started"
//                ]
//                
//                let notificationCenter = UNUserNotificationCenter.current()
//                notificationCenter.getDeliveredNotifications { notifications in
//                    // Identify notifications to remove by title
//                    let identifiersToRemove = notifications.compactMap { notification -> String? in
//                        let notificationTitle = notification.request.content.title
//                        return titlesToRemove.contains(where: { notificationTitle.contains($0) }) ? notification.request.identifier : nil
//                    }
//                    
//                    // Remove notifications with these identifiers
//                    notificationCenter.removeDeliveredNotifications(withIdentifiers: identifiersToRemove)
//                }
//            }
        mainUserInfo = userInfo
        //        return UIBackgroundFetchResult.newData
        completionHandler(.newData)
        
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void) {
            //            let userInfo = notification.request.content.userInfo
            let userInfo = mainUserInfo
            print("userInfo : \(userInfo)")
            print("willPresent notification: UNNotification) async -> UNNotificationPresentationOptions")
            completionHandler([.alert, .sound, .badge])
        }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = mainUserInfo
        //        let userInfo = response.notification.request.content.userInfo
        print("userInfo1 : \(userInfo)")
        var target = userInfo["Title"] as? String
        print("target : \(target)")
        storeNotificationLocally(userInfo: userInfo as NSDictionary)
        if ((target?.contains("Your ride pin is")) == true) || ((target?.contains("Ride Accepted")) == true) || ((target?.contains("Get ready for your driver")) == true) || ((target?.contains("Your Driver has reached your location")) == true)  {
            print("abba jabba dabba")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "BookACabViewController") as! BookACabViewController
            initialViewController.member_master_profile_id = userInfo["fk_member_master_profile_id"] as? Int
            initialViewController.rideStatus = "tappedNotifcationBanner"
            initialViewController.otpInt = userInfo["pin"] as? Int
            initialViewController.pickup_latitude = userInfo["pickup_latitude"] as? String
            initialViewController.pickup_longitude = userInfo["pickup_longitude"] as? String
            initialViewController.destination_latitude = userInfo["destination_latitude"] as? String
            initialViewController.destination_longitude = userInfo["destination_longitude"] as? String
            initialViewController.driver_current_latitude = userInfo["driver_current_latitude"] as? String
            initialViewController.driver_current_longitude = userInfo["driver_current_longitude"] as? String
            initialViewController.pk_bookride_id = userInfo["fk_bookride_id"] as? Int
            initialViewController.vehicle_Photo_afterAppTermination = userInfo["vehicle_image_url"] as? String
            initialViewController.driver_Photo_afterAppTermination = userInfo["driver_image_url"] as? String
            initialViewController.minutesFromAPI = userInfo["pickupDuration"] as? Int
            if let vehicleNumber = userInfo["Vehicle_no"] as? String {
                initialViewController.vehicleNumberString = vehicleNumber
            } else {
                print("vehicleNumber is nil")
            }
            //Vehicle Model
            if let vehicleModel = userInfo["Vehicle_Brand_Model"] as? String {
                initialViewController.vehicleModelString = vehicleModel
            } else {
                print("vehicleModel is nil")
            }
            //Driver Name
            if let driverName = userInfo["Drivername"] as? String {
                initialViewController.driverNameString = driverName
            } else {
                print("driverName is nil")
            }

            if let driverMobileNumber = userInfo["MobileNumber"] as? String {
                initialViewController.driverMobileNumberString = driverMobileNumber
            } else {
                print("driverMobileNumber is nil")
            }
            let navigationController = UINavigationController(rootViewController: initialViewController)
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
        } else if ((target?.contains("Ride Started")) == true) {
            print("-----------Ride Started-------------------")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "RideStartedViewController") as! RideStartedViewController
            initialViewController.member_master_profile_id = userInfo["fk_member_master_profile_id"] as? Int
            initialViewController.rideStatus = "tappedNotifcationBanner"
            initialViewController.latitudes_destination = userInfo["destination_latitude"] as? String
            initialViewController.longitudes_destination = userInfo["destination_longitude"] as? String
            initialViewController.driver_current_latitude = userInfo["driver_current_latitude"] as? String
            initialViewController.driver_current_longitude = userInfo["driver_current_longitude"] as? String
            initialViewController.pk_bookride_id = userInfo["fk_bookride_id"] as? Int
            initialViewController.vehiclePhotoString = userInfo["vehicle_image_url"] as? String
            initialViewController.driverPhotoString = userInfo["driver_image_url"] as? String
            if let vehicleNumber = userInfo["Vehicle_no"] as? String {
                initialViewController.vehicleNumberString = vehicleNumber
            } else {
                print("vehicleNumber is nil")
            }
            //Vehicle Model
            if let vehicleModel = userInfo["Vehicle_Brand_Model"] as? String {
                initialViewController.vehicleModelString = vehicleModel
            } else {
                print("vehicleModel is nil")
            }
            //Driver Name
            if let driverName = userInfo["Driver_Name"] as? String {
                initialViewController.driverNameString = driverName
            } else {
                print("driverName is nil")
            }

            if let driverMobileNumber = userInfo["Driver_Mob_No"] as? String {
                initialViewController.driverMobileNumberString = driverMobileNumber
            } else {
                print("driverMobileNumber is nil")
            }
            let navigationController = UINavigationController(rootViewController: initialViewController)
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
        } else if ((target?.contains("Ride Ended")) == true) {
            print("----------------Ride Ended------------------")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "EndTripViewController") as! EndTripViewController
            initialViewController.member_master_profile_id = userInfo["fk_member_master_profile_id"] as? Int
            initialViewController.rideStatus = "tappedNotificationBanner"
            var ride = "tappedNotificationBanner"
            UserDefaults.standard.set(ride, forKey: "ride")
            initialViewController.pickupamout = userInfo["pickupAmount"] as? Int
            initialViewController.fareAmount = userInfo["amount"] as? Int
            initialViewController.totalAmout = userInfo["TotalAmount"] as? Int
            initialViewController.vehicle_type_id = userInfo["vehicleType_id"] as? Int
            let navigationController = UINavigationController(rootViewController: initialViewController)
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
        }
    }
    //    func storeNotificationLocally(userInfo:NSDictionary){
    //        var messageID:String=""
    //        var messages:String=""
    //        var title:String=""
    //        var mDetails:String=""
    //        var currentDate:String=""
    //        var expiryDate:String=""
    //        let date=Date()
    //        print("userInfo from storeNotificationLocally : \(userInfo)")
    //        //1578904672967993
    //
    //        if let messageIDs = userInfo["gcm.message_id"] as? String {
    //                   print("Message ID: \(messageIDs)")
    //            messageID=messageIDs
    //               }
    //        if let message = userInfo["Message"] as? String {
    //                   print("Message : \(message)")
    //            messages=message
    //               }
    //
    ////        if let titles = userInfo["gcm.message_id"] as? String {
    ////                   print("Message ID: \(messageIDs)")
    ////            title=titles
    ////               }
    //
    //        if let description = userInfo["gcm.notification.description"] as? String {
    //                   print("description: \(description)")
    //            mDetails=description
    //               }
    //
    //
    //        if let aps=userInfo["aps"] as? NSDictionary
    //        {
    //            if let alert = aps.value(forKey: "alert") as? String
    //            {
    ////                if let titles=alert.value(forKey: "title") as? String
    ////                {
    //                    title=alert
    //                print("title : \(title)")
    ////                }
    ////                if let body=alert.value(forKey: "body") as? String
    ////                {
    ////                    mDetails=body
    ////                }
    //
    //
    //                let df:DateFormatter=DateFormatter()
    //                df.dateFormat="dd/MM/YYYY hh:mm a"
    //                currentDate=df.string(from: date)
    //
    //                let now = Calendar.current.dateComponents(in: .current, from: Date())
    //
    //                let tomorrow = DateComponents(year: now.year, month: now.month, day: now.day! + 3)
    //                if  let expiryDates = Calendar.current.date(from: tomorrow)
    //                {
    //                df.dateFormat="dd/MM/YYYY"
    //                expiryDate = df.string(from: expiryDates)
    //                }
    //            }
    //        }
    //
    //        let appDelegates = UIApplication.shared.delegate as! AppDelegate
    //
    //         let nscontext = appDelegates.persistentContainer.viewContext
    //
    //        let entity = NSEntityDescription.entity(forEntityName: "Entity", in: nscontext)
    //
    //        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
    //                         request.entity = entity
    //                 let pred = NSPredicate(format: "id = %@", messageID as CVarArg)
    //                         request.predicate = pred
    //                         do
    //                         {
    //                             print("110")
    //                             let result = try nscontext.fetch(request)
    //
    //                             if result.count > 0
    //                             {
    //                                 print("111")
    //                                 let manage = result[0] as! NSManagedObject
    //                                 nscontext.delete(manage)
    //                                 try nscontext.save()
    //                                 print("Record Deleted")
    //                             }
    //                             else
    //                             {
    //                                 print("Record Not Found")
    //                             }
    //
    //                         }
    //                         catch {}
    //
    //
    //
    //           let newUser = NSManagedObject(entity: entity!, insertInto: nscontext)
    //            newUser.setValue(messageID, forKey: "id")
    //            newUser.setValue(messages, forKey:"message")
    ////            newUser.setValue(title, forKey:"title")
    ////            newUser.setValue(mDetails, forKey: "details")
    ////            newUser.setValue(currentDate, forKey: "notify_date")
    ////            newUser.setValue(expiryDate, forKey: "expiry_date")
    ////            newUser.setValue(date, forKey: "sort_date")
    ////            newUser.setValue("Unread", forKey: "flag")
    //
    //            do
    //            {
    //                try nscontext.save()
    //            }
    //            catch
    //            {
    //
    //            }
    //            print("Record Inserted")
    //    }
    
    
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        UserDefaults.standard.setValue(fcmToken, forKey: "fcm_token")
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        print("dataDict : \(dataDict)")
    }
}
