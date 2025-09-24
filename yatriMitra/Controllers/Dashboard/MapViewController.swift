//
//  MapViewController.swift
//  yatriMitra
//
//  Created by Kaizen Infotech Solutions Private Limited. on 04/06/24.
//

import UIKit
import MapKit
import GoogleMaps
import Alamofire
import GooglePlaces
import Network
import CoreLocation



class MapViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate,  GMSMapViewDelegate, PopBackViewControllerProtocol, ProfileBackVC {
    
    
    
    @IBOutlet weak var currentLocationTxtField: UITextField!
    @IBOutlet weak var currentLocationView: UIView!
    @IBOutlet weak var buttonOpticity: UIButton!
    @IBOutlet weak var dashBoardRecentSearchesTableView: UITableView!
    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet weak var destinationView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var destinationLocationView: UIView!
    @IBOutlet weak var demoPNG: UIImageView!
    @IBOutlet weak var logoutNoBtn: UIButton!
    @IBOutlet weak var logoutYesBtn: UIButton!
    @IBOutlet weak var currentLocationTxtFieldCrossBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoutView: UIView!
    @IBOutlet weak var autoSuggestPlaces: UIView!
    @IBOutlet weak var noResultsFoundImg: UIImageView!
    @IBOutlet weak var noResultsFoundLbl: UILabel!
    @IBOutlet weak var noResultsFoundView: UIView!
    @IBOutlet weak var recenterBtn: UIButton!
    @IBOutlet weak var recenterBtnImg: UIImageView!
    @IBOutlet weak var destinationBtn: UIButton!
    @IBOutlet weak var dashBoardRecentSearchesTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var autoCompleteRecentSearchesActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var comingSoonImg: UIImageView!
    @IBOutlet weak var destinationBtnBottomConstraint: NSLayoutConstraint!
    
    var currentAppVersion: String?
    var member_master_profile_id : Int?
    var mapView: GMSMapView!
    let marker = GMSMarker()
    var mainLat : CLLocationDegrees?
    var mainLong : CLLocationDegrees?
    let locationManager = CLLocationManager()
    let geoCoder = CLGeocoder()
    private var autocompleteController: GMSAutocompleteResultsViewController?
    var sessionToken: GMSAutocompleteSessionToken?
    var labelNames = ["My Profile", "Ride History", "Emergency", "Support", "About", "Share App", "Logout", "Delete Account"]
    var viewOpen:Bool = true
    var autoSuggestPlacestableView = UITableView()
    var placesClient: GMSPlacesClient!
    var autocompleteResults: [GMSAutocompletePrediction] = []
    var monitor: NWPathMonitor?
    let queue = DispatchQueue.global(qos: .background)
    var boolAutoComplete = true
    var dashboardRecentSearches: [String] = []
    var iOSversion: String?
    var isCurrentTFTouched = false
    var currentLocationCoordinate: CLLocationCoordinate2D?
    var currentlocationcooordination: CLLocationCoordinate2D?
    var recentercurrentlocationcooordination: CLLocationCoordinate2D?
    var recentercurrentlocationcooordinationtext: String?
    var destinationlocationcooordination: CLLocationCoordinate2D?
    var dash : String?
    var apiTimer : Timer?
    var isSelectedFromTableView : String?
    var showBanner : String?
    var bannerURL : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        UserDefaults.standard.setValue(member_master_profile_id, forKey: "fk_member_master_profile_id")
        
//        NetworkMonitor.shared
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(statusManager),
                         name: .flagsChanged,
                         object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleForceUpdate),
                                               name: .forceUpdate,
                                               object: nil)
        placesClient = GMSPlacesClient.shared()
        tableView.delegate=self
        tableView.dataSource=self
        dashBoardRecentSearchesTableView.delegate = self
        dashBoardRecentSearchesTableView.dataSource = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        if !CLLocationManager.locationServicesEnabled() {
            let alertController = UIAlertController(title: "Location Services Disabled",
                                                    message: "Please enable location services in Settings to use this feature.",
                                                    preferredStyle: .alert)
            
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
                // Open app's settings
                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(appSettings) {
                        UIApplication.shared.open(appSettings)
                    }
                }
            }
            //            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (_) in
                let enabledVC = self.storyboard?.instantiateViewController(withIdentifier: "WelcomeViewController") as? WelcomeViewController
                enabledVC?.member_master_profile_id = self.member_master_profile_id
                self.navigationController?.pushViewController(enabledVC!, animated: true)
            }
            
            alertController.addAction(settingsAction)
            //            alertController.addAction(cancelAction)
            
            // Present the alert
            present(alertController, animated: true, completion: nil)
        }
        else if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
        //        myMap.showsUserLocation = true
        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 8)
        mapView = GMSMapView.map(withFrame: self.myMap.bounds, camera: camera)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        self.myMap.addSubview(mapView)
        mapView.isMyLocationEnabled = true
        currentLocationView.layer.cornerRadius=10
        destinationView.layer.cornerRadius = 10
        destinationBtn.layer.cornerRadius = 10
        destinationBtn.contentHorizontalAlignment = .left
        registerTableCells()
        demoPNG.isHidden = true
        self.containerView.isHidden=true
        self.logoutView.isHidden=true
        print("self.showBanner : \(self.showBanner)")
        print("self.bannerURL : \(self.bannerURL)")
        if showBanner == "true" {
            comingSoonImg.isHidden = false
            buttonOpticity.isHidden = false
        } else {
            buttonOpticity.isHidden = true
            comingSoonImg.isHidden = true
        }
        logoutNoBtn.layer.cornerRadius=10
        logoutNoBtn.layer.borderColor=UIColor.black.cgColor
        logoutNoBtn.layer.borderWidth=2.0
        logoutYesBtn.layer.cornerRadius=10
        viewOpen=false
        currentLocationTxtField.delegate=self
        currentLocationTxtField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        autoSuggestPlacestableView.dataSource = self
        autoSuggestPlacestableView.delegate = self
        self.autoSuggestPlaces.addSubview(autoSuggestPlacestableView)
        autoSuggestPlacestableView.translatesAutoresizingMaskIntoConstraints = false
        autoSuggestPlaces.layer.cornerRadius = 10
        addDoneButtonOnNumpad(textField: currentLocationTxtField)
        // Set up constraints to occupy the entire view
        NSLayoutConstraint.activate([
            autoSuggestPlacestableView.topAnchor.constraint(equalTo: autoSuggestPlaces.topAnchor),
            autoSuggestPlacestableView.bottomAnchor.constraint(equalTo: autoSuggestPlaces.bottomAnchor),
            autoSuggestPlacestableView.leadingAnchor.constraint(equalTo: autoSuggestPlaces.leadingAnchor),
            autoSuggestPlacestableView.trailingAnchor.constraint(equalTo: autoSuggestPlaces.trailingAnchor)
        ])
        autoSuggestPlacestableView.layer.cornerRadius = 10
        autoSuggestPlacestableView.clipsToBounds = true
        autoSuggestPlaces.isHidden=true
        autoSuggestPlacestableView.isHidden = true
        noResultsFoundView.isHidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        noResultsFoundView.addGestureRecognizer(tapGesture)
        noResultsFoundView.isUserInteractionEnabled = true
        setupNetworkMonitor()
        dashBoardRecentSearchesTableView.separatorStyle = .none
        //        marker.isDraggable = true
        //        marker.icon = UIImage(named: "map-pin")
        let originImage = UIImage(named:"yatri-mitra-pin")
        let resizeImage = originImage?.scaled(to: CGSize(width: 60, height: 60))
        let centerMarker = UIImageView(image: resizeImage)
        centerMarker.translatesAutoresizingMaskIntoConstraints = false
        mapView.addSubview(centerMarker)
        
        // Center the marker on the mapView
        NSLayoutConstraint.activate([
            centerMarker.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
            centerMarker.centerYAnchor.constraint(equalTo: mapView.centerYAnchor, constant: -30)
        ])
        var dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissImg))
        comingSoonImg.addGestureRecognizer(dismissTap)
        if let apiTimer = apiTimer {
            TimerManager.shared.registerTimer(apiTimer)
        }
        getAppVersion()
        startAPITimer()
        remoteConfi()
        //        recentSearch()
        
    }
    
    func profileBackVC(memberID: Int?, banner: String?) {
        print("*************PROTOCOL_CALLED_from_Profileviewcontroller*********************")
        self.showBanner = banner
        self.member_master_profile_id = memberID
    }
    
    func dataPassBack(memberID: Int?) {
        print("*************PROTOCOL_CALLED_MAPVIEWCONTROLLER*********************")
        print("&&---\(memberID)")
        
        self.member_master_profile_id = memberID
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        apiTimer?.invalidate()
        apiTimer = nil
        TimerManager.shared.stopAllTimers()
        monitor?.cancel()
        monitor = nil
        locationManager.delegate = nil
        mapView.delegate = nil
        print("******************** DEINIT MAPVIEWCONTROLLER REMOVED FROM MEMORY*********************")
    }
    
    func remoteConfi() {
        print("self.showBanner: \(self.bannerURL)")
        
        guard var urlString = bannerURL?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !urlString.isEmpty else {
                print("🚫 bannerURL is nil or empty")
                return
            }

            // 🔧 Remove leading/trailing quotes if present
            if urlString.hasPrefix("\"") && urlString.hasSuffix("\"") {
                urlString.removeFirst()
                urlString.removeLast()
            }

            // Optional: encode if needed
            urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? urlString

            // Try to form the URL
            guard let url = URL(string: urlString) else {
                print("🚫 Invalid URL string: \(urlString)")
                return
            }

            // Proceed with downloading the image
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    return
                }

                guard let data = data, let image = UIImage(data: data) else {
                    print("❌ Failed to decode image")
                    return
                }

                DispatchQueue.main.async {
                    self?.comingSoonImg.image = image
                }
            }.resume()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.destinationBtn.setTitle("Search Destination", for: .normal)
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
            demoPNG.isHidden = true
        }
        UserDefaults.standard.setValue(member_master_profile_id, forKey: "fk_member_master_profile_id")
        dashboardRecentSearches.removeAll()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        locationManager.delegate = self
        mapView.delegate = self
        containerView.isHidden=true
        if showBanner == "true" {
            comingSoonImg.isHidden = false
            buttonOpticity.isHidden = false
        } else {
            buttonOpticity.isHidden = true
            comingSoonImg.isHidden = true
        }
        recentSearch()
        
    }
    
    func getAppVersion() {
        
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            print("App Version: \(appVersion)")
            self.currentAppVersion = appVersion
        }
    }
    
    
    
    @objc func dismissImg() {
        comingSoonImg.isHidden = true
        buttonOpticity.isHidden = true
    }
    
    
    func registerTableCells() {
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "SideMenuTableViewCell", bundle: nil), forCellReuseIdentifier: "SideMenuTableViewCell")
    }
    
    
    @objc func dismissKeyboard() {
        // Dismiss the keyboard
        view.endEditing(true)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //        myMap.camera = GMSCameraPosition(target: CLLocationCoordinate2D(latitude: locationManager.location?.coordinate.longitude ?? 0.0, longitude: locationManager.location?.coordinate.latitude ?? 0.0), zoom: 8, bearing: 0, viewingAngle: 0)
        //        let marker = GMSMarker()
        //        marker.position = CLLocationCoordinate2D(latitude: locationManager.location?.coordinate.latitude ?? 0.0, longitude: locationManager.location?.coordinate.longitude ?? 0.0)
        //        marker.map = myMap
        
        //        guard let location = locations.last else { return }
        print("latitude : ", locationManager.location?.coordinate.latitude ?? 0.0)
        print("longitude : ", locationManager.location?.coordinate.longitude ?? 0.0)
        let latitude = locationManager.location?.coordinate.latitude
        let longitude = locationManager.location?.coordinate.longitude
        let camera = GMSCameraPosition.camera(withLatitude: latitude!, longitude: longitude!, zoom: 15.0)
        mapView.animate(to: camera)
        
        //        let marker = GMSMarker()
        
        marker.position = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        //        marker.icon = UIImage(named: "map-pin")
        //        marker.map = mapView
        //        marker.isDraggable = true
        mainLat = latitude
        mainLong = longitude
        let locationString = "Lat: \(latitude), Lon: \(longitude)"
        
        print("locationString : \(locationString)")
        print("mainLat : \(mainLat)")
        print("mainLong : \(mainLong)")
        recentercurrentlocationcooordination = CLLocationCoordinate2D(latitude: CLLocationDegrees(mainLat ?? 0.0), longitude: CLLocationDegrees(mainLong ?? 0.0))
        currentlocationcooordination = CLLocationCoordinate2D(latitude: CLLocationDegrees(mainLat ?? 0.0), longitude: CLLocationDegrees(mainLong ?? 0.0))
        print("locationManager() -> currentlocationcooordination : \(currentlocationcooordination)")
        if let location = locations.last {
            geoCoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
                guard let self = self else { return }
                if let error = error {
                    print("Error reverse geocoding location: \(error.localizedDescription)")
                } else if let placemark = placemarks?.first {
                    let address = """
                \(placemark.subThoroughfare ?? "") \(placemark.thoroughfare ?? ""),
                \(placemark.locality ?? ""), \(placemark.administrativeArea ?? "") \(placemark.postalCode ?? ""),
                \(placemark.country ?? "")
                """
                    if boolAutoComplete {
                        recentercurrentlocationcooordinationtext = address
                        currentLocationTxtField.text=address
                        print("Address(MapVC) : \(address)")
                        boolAutoComplete = false
                    }
                }
            }
        }
        let center = CLLocationCoordinate2D(latitude: locationManager.location?.coordinate.latitude ?? 0.0, longitude: locationManager.location?.coordinate.longitude ?? 0.0)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
        // Set the region on the map view
        locationUnServiceable()
        myMap.setRegion(region, animated: true)
        
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        locationManager.stopMonitoringSignificantLocationChanges()
        //        pickupLocation.text = " \(latitude), \(longitude)"
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        apiTimer?.invalidate()
        apiTimer = nil
        visibilityTimer?.invalidate()
        visibilityTimer = nil
        TimerManager.shared.stopAllTimers()
        monitor?.cancel()
        monitor = nil
        locationManager.delegate = nil
        mapView.delegate = nil
    }
    
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if currentLocationTxtFieldCrossBtn.isHidden == true {
            currentLocationTxtFieldCrossBtn.isHidden = false
        }
        let centerCoordinate = mapView.camera.target // The center coordinate of the map
        
        // Update the labels with the new coordinates
        
        //        if isSelectedFromTableView == "isSelectedFromTableView" {
        //            print("---------------------------------------------->")
        //            print("idleAt -> mainLat : \(mainLat)")
        //            print("idleAt -> mainLong : \(mainLong)")
        //            print("---------------------------------------------->")
        //            reverseGeocodeCoordinate(CLLocationCoordinate2D(latitude: mainLat!, longitude: mainLong!))
        //        } else {
        mainLat = centerCoordinate.latitude
        mainLong = centerCoordinate.longitude
        
        print("idleAt -> mainLat : \(mainLat)")
        print("idleAt -> mainLong : \(mainLong)")
        
        // Optional: perform reverse geocoding here to get the address if needed
        reverseGeocodeCoordinate(CLLocationCoordinate2D(latitude: mainLat!, longitude: mainLong!))
        currentlocationcooordination = CLLocationCoordinate2D(latitude: CLLocationDegrees(mainLat ?? 0.0), longitude: CLLocationDegrees(mainLong ?? 0.0))
        //        }
        boolAutoComplete = true
        self.view.endEditing(true)
        locationUnServiceable()
    }
    func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
        print("Started dragging marker")
    }
    
    // Delegate method called during dragging
    func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
        print("Dragging marker at \(marker.position.latitude), \(marker.position.longitude)")
        mainLat = marker.position.latitude
        mainLong = marker.position.longitude
        locationUnServiceable()
    }
    
    // Delegate method called when dragging ends
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        print("Finished dragging marker at \(marker.position.latitude), \(marker.position.longitude)")
        // Update the camera position to center on the new marker position
        let camera = GMSCameraPosition.camera(withLatitude: marker.position.latitude, longitude: marker.position.longitude, zoom: 15.0)
        mapView.animate(to: camera)
        
        // Update mainLat and mainLong with the new position
        mainLat = marker.position.latitude
        mainLong = marker.position.longitude
        let newLocationString = "Lat: \(mainLat), Long: \(mainLong)"
        reverseGeocodeCoordinate(CLLocationCoordinate2D(latitude: mainLat!, longitude: mainLong!))
        currentlocationcooordination = CLLocationCoordinate2D(latitude: CLLocationDegrees(mainLat ?? 0.0), longitude: CLLocationDegrees(mainLong ?? 0.0))
        print("Finished dragging marker at ::: -> currentlocationcooordination : \(currentlocationcooordination)")
        // Update the text field
    }
    
    func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult(), error == nil else {
                print("Error in reverse geocoding: \(String(describing: error))")
                return
            }
            
            // Combine the address lines into a single string
            let addressLines = address.lines ?? []
            let formattedAddress = addressLines.joined(separator: ", ")
            
            // Update the text field with the address
            self.currentLocationTxtField.text = formattedAddress
            // Optionally, print the address
            print("Address(reverseGeocodeCoordinate): \(formattedAddress)")
        }
    }
    func setupNetworkMonitor() {
        monitor?.pathUpdateHandler = { path in
            if path.status == .unsatisfied {
                DispatchQueue.main.async {
                    //                           self.showAlert(title: "No Internet Connection", message: "Please check your internet settings.")
                    let alert = UIAlertController(title: "No Internet Connection", message: "Please check your internet settings.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                        
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        monitor?.start(queue: queue)
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied || status == .restricted || status == .notDetermined {
            showAlert(title: "Location Services Disabled", message: "Please enable location services in Settings to use this feature.")
            
        }
    }
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
            // Open app's settings
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(appSettings) {
                    UIApplication.shared.open(appSettings)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        // Present the alert
        present(alertController, animated: true, completion: nil)
    }
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    
    func updateUserInterface() {
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
        if !Network.reachability.isReachable{
            showNetworkCheckAlert()
        } else {
            showNetworkBackAlert()
        }
    }
    
    func showNetworkCheckAlert() {
        let alertAction = UIAlertController(title: "Something Went Wrong", message: "Please ensure your mobile has an internet connection", preferredStyle: UIAlertController.Style.alert)
        let dismissAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel) { (action:UIAlertAction) in}
        alertAction.addAction(dismissAction)
        self.present(alertAction, animated: true, completion: nil)
    }
    
    func showNetworkBackAlert() {
        let toastViewWithImage = ToastView(message: "Connected to Internet", image: UIImage(named: ""))
        toastViewWithImage.show(in: self.view, constraint: -50)
    }
    
    @IBAction func setCurrentLocationAction(_ sender: Any) {
        print("Current Location")
        currentLocationTxtFieldCrossBtn.isHidden = true
        mapView.isUserInteractionEnabled = true
        autoSuggestPlaces.isHidden=true
        currentlocationcooordination = nil
        autoSuggestPlacestableView.isHidden = true
        recenterBtnImg.isHidden = false
        recenterBtn.isHidden = false
        currentLocationTxtField.text = ""
        currentLocationTxtField.becomeFirstResponder()
    }
    @IBAction func sideMenuVCAction(_ sender: Any) {
        view.endEditing(true)
        autoSuggestPlaces.isHidden = true
        buttonOpticity.isHidden = false
        containerView.isHidden = false
        if !viewOpen {
            viewOpen = true
            autoSuggestPlaces.isHidden = true
        }else {
            viewOpen = false
        }
    }
    
    @IBAction func closeSideMenu(_ sender: Any) {
        self.containerView.isHidden = true
        buttonOpticity.isHidden = true
    }
    
    
    @IBAction func destinationBtnAction(_ sender: Any) {
        if NetworkMonitor.shared.isConnected{
            if currentLocationTxtField.text == "" {
                //                let alertController = UIAlertController(title: nil, message: "Please Enter Source Location", preferredStyle: .alert)
                let alertController = UIAlertController(title: nil, message: "Please Enter Location", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
            } else if autoSuggestPlaces.isHidden == false && noResultsFoundView.isHidden == false {
                let alertController = UIAlertController(title: nil, message: "Invalid Location", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                    self.autoSuggestPlaces.isHidden = true
                    self.currentLocationTxtField.text = ""
                    self.currentLocationTxtField.becomeFirstResponder()
                }
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
            } else {
                apiTimer = nil
                apiTimer?.invalidate()
                TimerManager.shared.stopAllTimers()
                let otpVC = storyboard?.instantiateViewController(identifier: "CurrenttoDestinationViewController") as! CurrenttoDestinationViewController
                otpVC.currentLocation=currentLocationTxtField.text
                otpVC.currentlocationcooordination = currentlocationcooordination
                otpVC.member_master_profile_id = member_master_profile_id
                otpVC.locationUnServiceable = "comingFromDestinationTextField"
                otpVC.popBackViewControllerProtocolDelegate = self
                //        otpVC.recentSearches = dashboardRecentSearches
                self.navigationController?.pushViewController(otpVC, animated: true)
            }
        } else {
            print("you are not connected")
            let alert = UIAlertController(title: "No Internet Connection",
                                          message: "It looks like you're offline. Please check your internet connection.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default,handler: {  _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    func startAPITimer() {
        apiTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(sessionTimeOut), userInfo: nil, repeats: true)
        
    }
    func handleLogout() {
        print("User logged out")
        
        self.containerView.isHidden=true
        buttonOpticity.isHidden = false
        self.logoutView.isHidden=false
    }
    
    @IBAction func buttonOpticityAction(_ sender: Any) {
        containerView.isHidden = true
        logoutView.isHidden = true
        buttonOpticity.isHidden = true
    }
    
    @IBAction func logoutNoBtnAction(_ sender: Any) {
        buttonOpticity.isHidden = true
        logoutView.isHidden=true
    }
    
    @IBAction func logoutYesBtnAction(_ sender: Any) {
        apiTimer?.invalidate()
        apiTimer = nil
        TimerManager.shared.stopAllTimers()
        buttonOpticity.isHidden = true
        let url = AppConfig.baseURL+"login/logOut"
        let params :  [String : Any] = [
            "fk_member_master_profile_id": member_master_profile_id, // this is the passanger id
        ]
        print("logoutYesBtnAction() -> url : \(url)")
        print("logoutYesBtnAction() -> parameters : \(params)")
        
        let token = UserDefaults.standard.string(forKey: "auth_deviceToken") ?? ""

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { [weak self] response in
            
            guard let self = self else { return }
            
            print("response : \(response)")
            print("response.result : \(response.result)")
            
            switch response.result {
                
            case .success (let data) :
                
                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let loginResult = json["result"] as? [String: Any] {
                            print("JSON -------\(json)")
                            let status = loginResult["status"] as? String ?? ""
                            let message = loginResult["message"] as? String ?? ""
                            
                            if status == "0" {
                                UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                                UserDefaults.standard.set("", forKey: "loggedin")
                                apiTimer?.invalidate()
                                apiTimer = nil
                                TimerManager.shared.stopAllTimers()
                                member_master_profile_id = nil
                                UserDefaults.standard.setValue(member_master_profile_id, forKey: "fk_member_master_profile_id")
                                let otpVC = self.storyboard?.instantiateViewController(identifier: "LoginRegisterViewController") as! LoginRegisterViewController
                                let navController = UINavigationController(rootViewController: otpVC)

                                DispatchQueue.main.async {
                                    UserDefaults.standard.synchronize()

                                    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                                        sceneDelegate.window?.rootViewController = navController
                                        sceneDelegate.window?.makeKeyAndVisible()
                                    }
                                }
//                                let otpVC = self.storyboard?.instantiateViewController(identifier: "LoginRegisterViewController") as! LoginRegisterViewController
//                                DispatchQueue.main.async {
//                                    UserDefaults.standard.synchronize()
//                                    self.navigationController?.pushViewController(otpVC, animated: false)
//                                }
                            }
                        } else {
                        }
                    } catch {
                        //                                   self.showAlert(title: "Error", message: "Failed to parse JSON: \(error.localizedDescription)")
                        let alertController = UIAlertController(title: "Network Error", message: "", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                } else {
                    print("Data is nil")
                }
                
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
        
    let debouncer = Debouncer(delay: 0.5)
    var visibilityTimer: Timer?
    @objc func textFieldDidChange(_ textField: UITextField) {
        print("Character count: \(textField.text?.count)")
        if let textCount = textField.text?.count, textCount > 0 {
            // Cancel any existing timer
            visibilityTimer?.invalidate()
            recenterBtnImg.isHidden = true
            recenterBtn.isHidden = true
            autoCompleteRecentSearchesActivityIndicator.isHidden = false
            autoCompleteRecentSearchesActivityIndicator.startAnimating()
            mapView.isUserInteractionEnabled = false
            autoSuggestPlaces.isHidden = false
            autoSuggestPlacestableView.isHidden = false
            noResultsFoundView.isHidden = true
            // Schedule a new timer to make the view visible after 5 seconds of no input
            visibilityTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
                guard let self = self else { return }
                print("No new input for 5 seconds, showing autoSuggestPlaces")
                //                    self.autoSuggestPlaces.isHidden = false
                //                    self.autoSuggestPlacestableView.isHidden = false
                //                }
                if textField == currentLocationTxtField {
                    currentLocationTxtFieldCrossBtn.isHidden = false
                    isCurrentTFTouched = true
                    guard let query = textField.text, !query.isEmpty else {
                        autocompleteResults = []
                        autoSuggestPlacestableView.reloadData()
                        return
                    }            
                    sessionToken = GMSAutocompleteSessionToken.init()
                    print("Session Token Created: \(sessionToken)")
                    let filter = GMSAutocompleteFilter()
                    filter.country = "IN"
//                    filter.type = .address
                    //                                                filter.type = .noFilter
                    
                    // Define the geographical bounds
                    //                    let southwestCorner = CLLocationCoordinate2D(latitude: 18.901133, longitude: 72.658744) // Southwest corner (Mumbai)
                    //                    let northeastCorner = CLLocationCoordinate2D(latitude: 19.324753, longitude: 73.096050) // Northeast corner (Sasunavghar, Maharashtra 401208)
                    let southwestCorner = CLLocationCoordinate2DMake(18.901133, 72.658744) // Southwest corner (Mumbai)
                    let northeastCorner = CLLocationCoordinate2DMake(19.324753, 73.096050) // Northeast corner (Sasunavghar, Maharashtra 401208)
//                    filter.locationRestriction = GMSPlaceRectangularLocationOption(southwestCorner, northeastCorner)
                    let bounds = GMSCoordinateBounds(coordinate: southwestCorner, coordinate: northeastCorner)
                    
                    let bounds1 = GMSPlaceRectangularLocationOption(southwestCorner, northeastCorner)
                                        autocompleteController?.autocompleteFilter?.locationBias = bounds1
                    autocompleteController?.autocompleteFilter = filter
                    //                    autocompleteController?.placeFields = [.name, .placeID, .coordinate, .formattedAddress]
                    print("autocompleteController?.placeFields : \(autocompleteController)")
                    //                            filter.types = [kGMSPlaceTypeRestaurant]
                    //                            filter.locationBias = GMSPlaceRectangularLocationOption(southwestCorner, northeastCorner)
                    //                            let request = GMSAutocompleteRequest(query:currentLocationTxtField.text ?? "")
                    //                            request.filter = filter
                    //                            request.sessionToken = sessionToken
                    
                    //                            GMSPlacesClient.shared().fetchAutocompleteSuggestions(from: request, callback: { ( results, error ) in
                    //                                  if let error = error {
                    //                                    print("Autocomplete error: \(error)")
                    //                                    return
                    //                                  }
                    //                                  if let autocompleteResults = results {
                    //                                    for result in autocompleteResults {
                    //                                      print("Result \(String(describing: result.placeSuggestion?.placeID)) with \(String(describing: result.placeSuggestion?.attributedFullText))")
                    //                                    }
                    //                                  }
                    //                                })
                    
                    placesClient?.findAutocompletePredictions(fromQuery: query, filter: filter, sessionToken: nil, callback: { (results, error) in
                        if let error = error {
                            print("Error: \(error.localizedDescription)")
                            return
                        }
                        results?.forEach { prediction in
                               print("Result: \(prediction.attributedFullText.string)")
                           }
                        if let results = results {
                            self.autocompleteResults = results
                            self.autoSuggestPlacestableView.reloadData()
                        }
                        //                                                if let results = results {
                        //                                                    print("results : \(results)")
                        //                                                    // Filter results to stay within bounds
                        //                                                    self.autocompleteResults = []
                        //                                                    let dispatchGroup = DispatchGroup()
                        //
                        //                                                    for prediction in results {
                        //                                                        dispatchGroup.enter()
                        //                                                        let placeID = prediction.placeID // No need for 'if let', placeID is non-optional
                        //                                                        self.placesClient?.fetchPlace(fromPlaceID: placeID, placeFields: [.coordinate], sessionToken: self.sessionToken) { place, error in
                        //                                                            if let error = error {
                        //                                                                print("Error fetching place details: \(error.localizedDescription)")
                        //                                                            } else if let place = place {
                        //                                                                let coordinate = place.coordinate
                        //                                                                if bounds.contains(coordinate) {
                        //                                                                    self.autocompleteResults.append(prediction)
                        //                                                                }
                        //                                                            }
                        //                                                            dispatchGroup.leave()
                        //                                                        }
                        //                                                    }
                        //                                                    dispatchGroup.notify(queue: .main) {
                        ////                                                        self.autocompleteResults = results
                        //                                                        self.autoSuggestPlacestableView.reloadData()
                        //                                                    }
                        //                                                }
                    })
                }
            }
            // Hide the views while waiting for the timer to complete
            autoSuggestPlaces.isHidden = false
            autoSuggestPlacestableView.isHidden = true
        } else {
            // If text is empty, cancel the timer and hide the views immediately
            visibilityTimer?.invalidate()
            autoCompleteRecentSearchesActivityIndicator.isHidden = false
            autoCompleteRecentSearchesActivityIndicator.startAnimating()
            autoSuggestPlaces.isHidden = false
            autoSuggestPlacestableView.isHidden = false

        }
        //        if textField.text?.isEmpty ?? true || textField.text?.count == 0 {
        //            autoSuggestPlaces.isHidden = true
        //            autoSuggestPlacestableView.isHidden = true
        //        } else {
        //            if textField == currentLocationTxtField {
        //                currentLocationTxtFieldCrossBtn.isHidden = false
        //                isCurrentTFTouched = true
        //                guard let query = textField.text, !query.isEmpty else {
        //                    autocompleteResults = []
        //                    autoSuggestPlacestableView.reloadData()
        //                    return
        //                }
        //                sessionToken = GMSAutocompleteSessionToken.init()
        //                print("Session Token Created: \(sessionToken)")
        //                let filter = GMSAutocompleteFilter()
        //                filter.country = "IN"
        //                autocompleteController?.autocompleteFilter = filter
        //                autocompleteController?.placeFields = [.name, .placeID, .coordinate, .formattedAddress]
        //                print("autocompleteController?.placeFields :                                                                                   \(autocompleteController?.placeFields)")
        //                filter.type = .noFilter
        //
        //                placesClient?.findAutocompletePredictions(fromQuery: query, filter: filter, sessionToken: nil, callback: { (results, error) in
        //                    if let error = error {
        //                        print("Error: \(error.localizedDescription)")
        //                        return
        //                    }
        //
        //                    if let results = results {
        //                        self.autocompleteResults = results
        //                        self.autoSuggestPlacestableView.reloadData()
        //                    }
        //                })
        //            }
        //        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.isEmpty ?? true {
            autoSuggestPlaces.isHidden = true
            autoSuggestPlacestableView.isHidden = true
        }
    }
    
    func addDoneButtonOnNumpad(textField: UITextField) {
//        let keypadToolbar: UIToolbar = UIToolbar()
//        keypadToolbar.items=[
//            UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: textField, action: #selector(UITextField.resignFirstResponder)),
//            UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
//        ]
//        keypadToolbar.sizeToFit()
//        textField.inputAccessoryView = keypadToolbar
        let keypadToolbar: UIToolbar = UIToolbar()
        keypadToolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // Done button
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        
        // Add flexible space and done button to the toolbar
        keypadToolbar.items = [flexibleSpace, doneButton]
        textField.inputAccessoryView = keypadToolbar
    }
    
    func geocodeAddress(_ address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            if let placemark = placemarks?.first, let location = placemark.location {
                print("location.coordinate : \(location.coordinate)")
                completion(location.coordinate)
            } else {
                completion(nil)
            }
        }
    }
    
    
    @IBAction func recenterBtnAction(_ sender: Any) {
        if !NetworkMonitor.shared.isConnected {
            print("you are not connected")
            let alert = UIAlertController(title: "No Internet Connection",
                                          message: "It looks like you're offline. Please check your internet connection.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default,handler: { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }))
            present(alert, animated: true, completion: nil)
            
        }
        else if !CLLocationManager.locationServicesEnabled() {
            let alertController = UIAlertController(title: "Location Services Disabled",
                                                    message: "Please enable location services in Settings to use this feature.",
                                                    preferredStyle: .alert)
            
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
                // Open app's settings
                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(appSettings) {
                        UIApplication.shared.open(appSettings)
                    }
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(settingsAction)
            alertController.addAction(cancelAction)
            
            // Present the alert
            present(alertController, animated: true, completion: nil)
        } else if CLLocationManager.authorizationStatus() == .notDetermined ||  CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied {
            let alertController = UIAlertController(title: "Allow Permission to access your location while using this app",
                                                    message: "This will be used to manage your location.",
                                                    preferredStyle: .alert)
            
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
                if let url = URL.init(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!)
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(settingsAction)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
        }
        else {
            //            guard let recentercurrentlocationcooordination = recentercurrentlocationcooordination else {
            //                print("Error: recentercurrentlocationcooordination is nil")
            //                return
            //            }
            //            let bounds = GMSCoordinateBounds(coordinate: recentercurrentlocationcooordination, coordinate: recentercurrentlocationcooordination)
            //            mainLat = recentercurrentlocationcooordination.latitude
            //            mainLong = recentercurrentlocationcooordination.longitude
            //            // Create a camera update that fits the bounds with padding
            //            let camera = GMSCameraPosition.camera(withLatitude: recentercurrentlocationcooordination.latitude, longitude: recentercurrentlocationcooordination.longitude, zoom: 15.0)
            //            mapView.animate(to: camera)
            //            currentLocationTxtField.text = recentercurrentlocationcooordinationtext
            //            //        moveCamera = true
            //            locationUnServiceable()
            boolAutoComplete = true
            view.endEditing(true)
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            
            
        }
        
    }
    
    
}

//MARK: TABLEVIEW PROTOCOLS
extension MapViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == autoSuggestPlacestableView{
            if autoSuggestPlaces.isHidden == false && autocompleteResults.count == 0 {
                print("autocompleteResults count is zero")
                print(currentLocationTxtField.text)
                autoSuggestPlacestableView.isHidden = true
                noResultsFoundView.isHidden = false
                noResultsFoundLbl.text = "No results found for \(currentLocationTxtField.text ?? "")"
                return autocompleteResults.count
            } else {
                return  autocompleteResults.count
            }
        } else if tableView == dashBoardRecentSearchesTableView{
            print("dashboardRecentSearches.count : \(dashboardRecentSearches.count)")
            //            if dashboardRecentSearches.count == 0 && dashboardRecentSearches.count == nil{
            //                dashBoardRecentSearchesTableViewHeight.constant = 0
            //                    )
            //                return  dashboardRecentSearches.count
            //            } else {
            return  dashboardRecentSearches.count
            //            }
        } else {
            return labelNames.count
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView ==  autoSuggestPlacestableView && autocompleteResults.count > 0 {
            if NetworkMonitor.shared.isConnected {
                //             if autocompleteResults.count > 0 {
                recenterBtnImg.isHidden = true
                recenterBtn.isHidden = true
                autoSuggestPlaces.isHidden = false
                autoSuggestPlacestableView.isHidden = false
                autoCompleteRecentSearchesActivityIndicator.stopAnimating()
                autoCompleteRecentSearchesActivityIndicator.isHidden = true
                noResultsFoundView.isHidden = true
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
                let result = autocompleteResults[indexPath.row]
                cell.textLabel?.text = result.attributedFullText.string
                return cell
                
                //            }
            } else  {
                print("you are not connected")
                let alert = UIAlertController(title: "No Internet Connection",
                                              message: "It looks like you're offline. Please check your internet connection.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default,handler: { _ in
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }))
                present(alert, animated: true, completion: nil)
                let defaultCell = UITableViewCell(style: .default, reuseIdentifier: "cell")
                defaultCell.textLabel?.text = "No results"
                return defaultCell
            }
        } else if tableView == dashBoardRecentSearchesTableView {
            if dashboardRecentSearches.count == 0 || dashboardRecentSearches.count == nil {
                dashBoardRecentSearchesTableViewHeight.constant = 0
            }
            else if dashboardRecentSearches.count == 1 {
                dashBoardRecentSearchesTableViewHeight.constant = 40
            } else if dashboardRecentSearches.count == 2 {
                dashBoardRecentSearchesTableViewHeight.constant = 80
            } else if dashboardRecentSearches.count == 3 {
                dashBoardRecentSearchesTableViewHeight.constant = 120
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "dashBoardRecentSearchesTableViewCell") as! dashBoardRecentSearchesTableViewCell
            cell.selectionStyle = .none
            cell.destinationAddLbl.text = dashboardRecentSearches[indexPath.row]
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTableViewCell") as! SideMenuTableViewCell
            cell.selectionStyle = .none
            cell.label.text = labelNames[indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        visibilityTimer?.invalidate()
        mapView.isUserInteractionEnabled = true
        if currentLocationTxtField.text == "" && containerView.isHidden == true {
            //            let alertController = UIAlertController(title: nil, message: "Please Enter Source Location", preferredStyle: .alert)
            let alertController = UIAlertController(title: nil, message: "Please Enter Location", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        } else {
            if tableView == autoSuggestPlacestableView {
                if NetworkMonitor.shared.isConnected {
                    let result = autocompleteResults[indexPath.row]
                    print("Selected place (MapVC): \(result.attributedFullText.string)")
                    let placeID = result.placeID
                    
                    // Use GMSPlacesClient to fetch place details
                    let placesClient = GMSPlacesClient.shared()
                    placesClient.fetchPlace(fromPlaceID: placeID, placeFields: .coordinate, sessionToken: nil) { [weak self] (place, error) in
                        guard let self = self else { return }
                        
                        if let error = error {
                            print("Error fetching place details: \(error.localizedDescription)")
                            return
                        }
                        
                        guard let place = place else {
                            print("No place details found")
                            return
                        }
                        
                        let latitude = place.coordinate.latitude
                        let longitude = place.coordinate.longitude
                        
                        // Update the text field
                        self.currentLocationTxtField.text = result.attributedFullText.string
                        mainLat = latitude
                        mainLong = longitude
                        tableView.isHidden = true
                        autoSuggestPlaces.isHidden = true
                        locationUnServiceable()
                        //                self.autoSuggestPlaces.isHidden = true
                        
                        currentlocationcooordination = CLLocationCoordinate2D(latitude: CLLocationDegrees(mainLat ?? 0.0), longitude: CLLocationDegrees(mainLong ?? 0.0))
                        isSelectedFromTableView = "isSelectedFromTableView"
                        print("didselectrow() -> currentlocationcooordination(autocompleteResults) : \(currentlocationcooordination)")
                        
                        // Pin the selected location on the map
                        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15.0)
                        self.mapView.animate(to: camera)
                        
                        //                    let marker = GMSMarker()
                        //                    marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        //                    marker.map = self.mapView
                        //                    marker.isDraggable = true
                        //                    marker.icon = UIImage(named: "map-pin")
                        
                        // Stop location updates to prevent the text field from being overwritten
                        locationManager.stopUpdatingLocation()
                    }
                    autoSuggestPlacestableView.isHidden = true
                    autoSuggestPlaces.isHidden = true
                    recenterBtnImg.isHidden = false
                    recenterBtn.isHidden = false
                    view.endEditing(true)
                    //                locationManager.delegate = self
                } else {
                    print("you are not connected")
                    let alert = UIAlertController(title: "No Internet Connection",
                                                  message: "It looks like you're offline. Please check your internet connection.",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default,handler: { _ in
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                    }))
                    present(alert, animated: true, completion: nil)
                }
            } else if tableView == dashBoardRecentSearchesTableView {
                
                if NetworkMonitor.shared.isConnected {
                    //                if autoSuggestPlaces.isHidden == false && noResultsFoundView.isHidden == false {
                    //                    let alertController = UIAlertController(title: nil, message: "Invalid Location", preferredStyle: .alert)
                    //                    let okAction = UIAlertAction(title: "OK", style: .default) { [self]_ in
                    //                        autoSuggestPlaces.isHidden = true
                    //                    }
                    //                }
                    //                if let currentText = currentLocationTxtField.text, !currentText.isEmpty,
                    //                   let destinationText = destinationBtn.title(for: .normal), !destinationText.isEmpty, curre {
                    //                if currentLocationTxtField.text != "" || destinationBtn.title(for: .normal) != "" && currentlocationcooordination != nil{
                    if let currentText = currentLocationTxtField.text, !currentText.isEmpty, currentlocationcooordination != nil {
                        dash = dashboardRecentSearches[indexPath.row]
                        //                    destinationBtn.setTitle(dash, for: .normal)
                        
                        print("Dash value: \(String(describing: dash))")
                        fetchAutocompletePredictions(query: dash ?? "") { predictions in
                            guard let predictions = predictions else {
                                print("No predictions found.")
                                return
                            }
                            print("predictions.count : \(predictions.count)")
                            //                        for prediction in predictions {
                            let firstPrediction = predictions[0]
                            print("Place ID: \(firstPrediction.placeID)")
                            print("Primary Text: \(firstPrediction.attributedPrimaryText.string)")
                            print("Full Text: \(firstPrediction.attributedFullText.string)")
                            let placeID = firstPrediction.placeID
                            
                            // Use GMSPlacesClient to fetch place details
                            let placesClient = GMSPlacesClient.shared()
                            placesClient.fetchPlace(fromPlaceID: placeID, placeFields: .coordinate, sessionToken: nil) { [weak self] (place, error) in
                                guard let self = self else { return }
                                
                                if let error = error {
                                    print("Error fetching place details: \(error.localizedDescription)")
                                    return
                                }
                                
                                guard let place = place else {
                                    print("No place details found")
                                    return
                                }
                                
                                let latitude = place.coordinate.latitude
                                let longitude = place.coordinate.longitude
                                
                                // Update the text field
                                self.destinationBtn.setTitle(firstPrediction.attributedFullText.string, for: .normal)
                                mainLat = latitude
                                mainLong = longitude
                                //                                tableView.isHidden = true
                                //                                autoSuggestPlaces.isHidden = true
                                //                                locationUnServiceable()
                                //                self.autoSuggestPlaces.isHidden = true
                                
                                destinationlocationcooordination = CLLocationCoordinate2D(latitude: CLLocationDegrees(mainLat ?? 0.0), longitude: CLLocationDegrees(mainLong ?? 0.0))
                                print("didselectrow() -> destinationlocationcooordination(dashBoardRecentSearchesTableView) : \(destinationlocationcooordination)")
                                
                                //                                locationManager.stopUpdatingLocation()
                                print("currentlocationcooordination : \(currentlocationcooordination)")
                                print("currentLocationTxtField.text : \(currentLocationTxtField.text)")
                                //                                autoSuggestPlaces.isHidden = true
                                //                                tableView.isHidden = true
//                                TimerManager.shared.stopAllTimers()
//                                let otpVC = storyboard?.instantiateViewController(identifier: "BookACabViewController") as! BookACabViewController
//                                apiTimer = nil
//                                apiTimer?.invalidate()
//                                otpVC.currentLoc = currentLocationTxtField.text
//                                otpVC.currentlocationcooordination = currentlocationcooordination
//                                otpVC.destinationlocationcooordination = destinationlocationcooordination
//                                otpVC.destinationLoc = destinationBtn.title(for: .normal)
//                                otpVC.member_master_profile_id = member_master_profile_id
//                                otpVC.PopBackViewControllerDelegate = self
//                                self.navigationController?.pushViewController(otpVC, animated: true)
                                
                                apiTimer = nil
                                apiTimer?.invalidate()
                                TimerManager.shared.stopAllTimers()
                                let otpVC = storyboard?.instantiateViewController(identifier: "CurrenttoDestinationViewController") as! CurrenttoDestinationViewController
                                otpVC.currentLocation=currentLocationTxtField.text
                                otpVC.currentlocationcooordination = currentlocationcooordination
                                otpVC.destinationLocation=destinationBtn.title(for: .normal)
                                otpVC.destinationlocationcooordination=destinationlocationcooordination
                                otpVC.member_master_profile_id = member_master_profile_id
                                otpVC.locationUnServiceable = "comingFromDestinationTextField"
                                otpVC.popBackViewControllerProtocolDelegate = self
                                //        otpVC.recentSearches = dashboardRecentSearches
                                self.navigationController?.pushViewController(otpVC, animated: true)
                            }
                            //                            }
                            
                        }
                        //                    DispatchQueue.main.async { [self] in
                        //                        guard let destinationLocationText = dash else { return }
                        //                        geocodeAddress(destinationLocationText) { [self] coordinate in
                        //                            guard let coordinate2 = coordinate else {
                        //                                return
                        //                            }
                        //                            print("--------coordinate2 : \(coordinate2)")
                        //                            destinationlocationcooordination = coordinate2
                        //                            print("destinationlocationcooordination : \(destinationlocationcooordination)")
                        //                            print("currentLocationTxtField.text : \(currentLocationTxtField.text)")
                        //                            autoSuggestPlaces.isHidden = true
                        //                            tableView.isHidden = true
                        //                            let otpVC = storyboard?.instantiateViewController(identifier: "BookACabViewController") as! BookACabViewController
                        //                            otpVC.currentLoc = currentLocationTxtField.text
                        //                            otpVC.currentlocationcooordination = currentlocationcooordination
                        //                            otpVC.destinationlocationcooordination = destinationlocationcooordination
                        //                            otpVC.destinationLoc = destinationBtn.title(for: .normal)
                        //                            //            otpVC.totalTime = totalTime
                        //                            //            otpVC.textFieldResponderDelegate = self
                        //                            //            otpVC.firstTime = firstTime
                        //                            self.navigationController?.pushViewController(otpVC, animated: true)
                        //                        }
                        //                    }
                        
                    } else if noResultsFoundView.isHidden == false, autocompleteResults.count == 0 {
                        let alertController = UIAlertController(title: nil, message: "Invalid Location", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                            guard let self = self else { return }
                            autoSuggestPlaces.isHidden = true
                            currentLocationTxtField.text = ""
                            currentLocationTxtField.becomeFirstResponder()
                        }
                        alertController.addAction(okAction)
                        present(alertController, animated: true, completion: nil)
                    }
                } else {
                    print("you are not connected")
                    let alert = UIAlertController(title: "No Internet Connection",
                                                  message: "It looks like you're offline. Please check your internet connection.",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default,handler: { _ in
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                    }))
                    present(alert, animated: true, completion: nil)
                }
            }else {
                let selectedLabel = labelNames[indexPath.row]
                var storyboardID: String?
                
                switch selectedLabel {
                case "My Profile":
                    storyboardID = "ProfileViewController"
                case "Ride History":
                    storyboardID = "RideHistoryViewController"
                case "Emergency":
                    storyboardID = "EmergencyViewController"
                case "Support":
                    //                    if let phoneURL = URL(string: "tel://9004995751"),
                    //                       UIApplication.shared.canOpenURL(phoneURL) {
                    //                        UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
                    //                    } else {
                    //                        print("Error: Cannot make a call.")
                    //                    }
                    let recipientEmail = "support@yatrimitra.com"
                    
                    // Gmail URL scheme for composing an email
                    if let gmailURL = URL(string: "googlegmail://co?to=\(recipientEmail)") {
                        if UIApplication.shared.canOpenURL(gmailURL) {
                            // Open Gmail app
                            UIApplication.shared.open(gmailURL, options: [:], completionHandler: nil)
                        } else {
                            // Gmail app not installed, fallback to default mail app
                            //                                    if let mailURL = URL(string: "mailto:\(recipientEmail)") {
                            if let mailURL = URL(string: "googlegmail://co?to=\(recipientEmail)") {
                                UIApplication.shared.open(mailURL, options: [:], completionHandler: nil)
                            } else {
                                print("Cannot open email client.")
                            }
                        }
                    }
                    
                    //                    storyboardID = "SupportViewController"
                case "About":
                    storyboardID = "AboutViewController"
                case "Share App":
                    let otpVC = storyboard?.instantiateViewController(identifier: "ShareAppViewController") as! ShareAppViewController
                    otpVC.profileBackVCDelegate = self
                    self.navigationController?.pushViewController(otpVC, animated: true)
                case "Logout":
                    // Handle logout separately
                    handleLogout()
                case "Delete Account":
                    //                    let urlString = "https://zfrmz.com/lpdbgetU7VxhKpzAMvhY"
                    //
                    //                            // Check if URL is valid
                    //                            if let url = URL(string: urlString) {
                    //                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    //                            } else {
                    //                                print("Invalid URL")
                    //                            }
                    let otpVC = storyboard?.instantiateViewController(identifier: "DeleteAccountViewController") as! DeleteAccountViewController
                    otpVC.urlString = "https://zfrmz.com/lpdbgetU7VxhKpzAMvhY"
                    otpVC.profileBackVCDelegate = self
                    self.navigationController?.pushViewController(otpVC, animated: true)
                    //                    return
                default:
                    break
                }
                
                if let storyboardID = storyboardID {
                    switch storyboardID {
                    case "ProfileViewController":
                        if let profileVC = self.storyboard?.instantiateViewController(withIdentifier: storyboardID) as? ProfileViewController {
                            profileVC.profileBackVCDelegate = self
                            self.navigationController?.pushViewController(profileVC, animated: true)
                        }
                    case "RideHistoryViewController":
                        if let rideHistoryVC = self.storyboard?.instantiateViewController(withIdentifier: storyboardID) as? RideHistoryViewController {
                            rideHistoryVC.profileBackVCDelegate = self
                            self.navigationController?.pushViewController(rideHistoryVC, animated: true)
                        }
                    case "EmergencyViewController":
                        if let emergencyVC = self.storyboard?.instantiateViewController(withIdentifier: storyboardID) as? EmergencyViewController {
                            emergencyVC.profileBackVCDelegate = self
                            self.navigationController?.pushViewController(emergencyVC, animated: true)
                        }
                    case "AboutViewController":
                        if let aboutVC = self.storyboard?.instantiateViewController(withIdentifier: storyboardID) as? AboutViewController {
                            aboutVC.profileBackVCDelegate = self
                            self.navigationController?.pushViewController(aboutVC, animated: true)
                        }
                    default:
                        let viewController = self.storyboard?.instantiateViewController(withIdentifier: storyboardID)
                        self.navigationController?.pushViewController(viewController!, animated: true)
                    }
                }
            }
        }
        
        autoSuggestPlacestableView.isHidden = true
        autoSuggestPlaces.isHidden=true
    }
    
    
    func fetchAutocompletePredictions(query: String, completion: @escaping ([GMSAutocompletePrediction]?) -> Void) {
        // Get the shared GMSPlacesClient instance
        let placesClient = GMSPlacesClient.shared()
        
        // Set up bounds and filters if necessary (optional)
        let bounds = GMSCoordinateBounds()
        let filter = GMSAutocompleteFilter() // Customize this filter as needed
        
        // Fetch predictions from the query
        placesClient.findAutocompletePredictions(fromQuery: query, filter: filter, sessionToken: nil) { (results, error) in
            if let error = error {
                print("Error fetching autocomplete predictions: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            // Return the results
            completion(results)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == autoSuggestPlacestableView {
            return 50
        } else if tableView == dashBoardRecentSearchesTableView {
            return 38
        } else {
            return 76
        }
    }
    
}


extension MapViewController{
    func gpsdisableAlert() {
        if !CLLocationManager.locationServicesEnabled() {
            let alertController = UIAlertController(title: "Location Services Disabled",
                                                    message: "Please enable location services in Settings to use this feature.",
                                                    preferredStyle: .alert)
            
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
                // Open app's settings
                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(appSettings) {
                        UIApplication.shared.open(appSettings)
                    }
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(settingsAction)
            alertController.addAction(cancelAction)
            
            // Present the alert
            present(alertController, animated: true, completion: nil)
        }
    }
    @objc func handleForceUpdate(_ notification: Notification) {
        sessionTimeOut()
    }
    @objc func sessionTimeOut() {
        //        gpsdisableAlert()
        if Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "") != 0 || UserDefaults.standard.string(forKey: "fk_member_master_profile_id") !=  nil {
            let url = AppConfig.baseURL+"login/SessionTimeOut_VersionCheck"
            let params :  [String : Any] = [
                "imeI_No": UIDevice.current.identifierForVendor?.uuidString,
                "fk_member_master_profile_id": Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "")
            ]
            let token = UserDefaults.standard.string(forKey: "auth_deviceToken") ?? ""

            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]
            print("MapViewController() -> sessionTimeOut() -> url : \(url)")
            print("MapViewController() -> sessionTimeOut() -> params : \(params)")
            AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { [weak self] response in
                guard let self = self else { return }
                print("recentSearchList() -> response : \(response.result)")
                switch response.result {
                    
                case .success (let data) :
                    if let data = data {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                               let loginResult = json["result"] as? [String: Any] {
                                print("MapViewController() -> sessionTimeOut() -> JSON -------\(json)")
                                let status = loginResult["status"] as? String ?? ""
                                let message = loginResult["message"] as? String ?? ""
                                let version = loginResult["version"] as? [[String: Any]]
                                
                                if status == "0" {
                                    if let version = version {
                                        print("sessionTimeOut() -> version : \(version)")
                                        for dict in version {
                                            iOSversion = dict["ios"] as? String
                                        }
                                        
                                        if let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let apiVersion = iOSversion {
                                            print("APIVersion : \(apiVersion)")
                                            print("codeVersion : \(versionString)")
                                            
                                            if Int(versionString) ?? 0 < Int(apiVersion) ?? 0 {
                                                apiTimer?.invalidate()
                                                apiTimer = nil
                                                TimerManager.shared.stopAllTimers()
                                                
                                                let alert = UIAlertController(title:  "New Version Available", message: "There is a newer version avaliable for download! Please update the app by visiting the App Store", preferredStyle: UIAlertController.Style.alert)
                                                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler:{(action:UIAlertAction) in
                                                    AppConfig.gotoAppStore()
                                                }));
                                                self.present(alert, animated: true, completion: nil)
                                                
                                            }
                                            
                                        }
                                    }
                                }
                                else if status == "-1" {
                                    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                                    UserDefaults.standard.set("", forKey: "loggedin")
                                    if Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "") != 0 && UserDefaults.standard.string(forKey: "fk_member_master_profile_id") != nil && member_master_profile_id != nil {
                                        apiTimer?.invalidate()
                                        apiTimer = nil
                                        TimerManager.shared.stopAllTimers()
                                        member_master_profile_id = nil
                                        UserDefaults.standard.setValue(member_master_profile_id, forKey: "fk_member_master_profile_id")
                                        
                                        
                                        // Add an action (button)
                                        //                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                        //                                    if !(self is ViewController) && !(self is MobileNoViewController) && !(self is OTPViewController) && !(self is RegisterMobileNoViewController) && !(self is RegisterOTPViewController) && !(self is RegistrationViewController) {
                                        // Check if it's MapViewController or any other allowed view controller
                                        //                                    let alertController = UIAlertController(title: "", message: "Session Time out , Member is deleted!!", preferredStyle: .alert)
                                        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
                                        
                                        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                                            TimerManager.shared.stopAllTimers()
                                            self.member_master_profile_id = nil
                                            UserDefaults.standard.setValue(self.member_master_profile_id, forKey: "fk_member_master_profile_id")
                                            self.apiTimer?.invalidate()
                                            self.apiTimer = nil
                                            
                                            let otpVC = self.storyboard?.instantiateViewController(identifier: "LoginRegisterViewController") as! LoginRegisterViewController
                                            let navController = UINavigationController(rootViewController: otpVC)

                                            DispatchQueue.main.async {

                                                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                                                    sceneDelegate.window?.rootViewController = navController
                                                    sceneDelegate.window?.makeKeyAndVisible()
                                                }
                                            }
//                                            let otpVC = self.storyboard?.instantiateViewController(identifier: "LoginRegisterViewController") as! LoginRegisterViewController
//                                            self.navigationController?.pushViewController(otpVC, animated: false)
                                        }
                                        
                                        alertController.addAction(okAction)
                                        self.present(alertController, animated: true, completion: nil)
                                        //                                    }
                                    }
                                    
                                } else if status == "-2" {
                                    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                                    UserDefaults.standard.set("", forKey: "loggedin")
                                    if Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "") != 0 && UserDefaults.standard.string(forKey: "fk_member_master_profile_id") != nil && member_master_profile_id != nil {
                                        apiTimer?.invalidate()
                                        apiTimer = nil
                                        TimerManager.shared.stopAllTimers()
                                        member_master_profile_id = nil
                                        UserDefaults.standard.setValue(member_master_profile_id, forKey: "fk_member_master_profile_id")
                                        //                                    if !(self is ViewController) && !(self is MobileNoViewController) && !(self is OTPViewController) && !(self is RegisterMobileNoViewController) && !(self is RegisterOTPViewController) && !(self is RegistrationViewController) {
                                        //                                        if self.isKind(of: MapViewController.self) {
                                        //                                    let alertController = UIAlertController(title: "", message: "Session Timeout. Another user logged in with the same number!", preferredStyle: .alert)
                                        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
                                        
                                        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                                            TimerManager.shared.stopAllTimers()
                                            self.member_master_profile_id = nil
                                            UserDefaults.standard.setValue(self.member_master_profile_id, forKey: "fk_member_master_profile_id")
                                            self.apiTimer?.invalidate()
                                            self.apiTimer = nil
                                            
                                            let otpVC = self.storyboard?.instantiateViewController(identifier: "LoginRegisterViewController") as! LoginRegisterViewController
                                            let navController = UINavigationController(rootViewController: otpVC)

                                            DispatchQueue.main.async {
                                                UserDefaults.standard.synchronize()

                                                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                                                    sceneDelegate.window?.rootViewController = navController
                                                    sceneDelegate.window?.makeKeyAndVisible()
                                                }
                                            }
//                                            let otpVC = self.storyboard?.instantiateViewController(identifier: "LoginRegisterViewController") as! LoginRegisterViewController
//                                            self.navigationController?.pushViewController(otpVC, animated: false)
                                        }
                                        
                                        alertController.addAction(okAction)
                                        self.present(alertController, animated: true, completion: nil)
                                        //                                        }
                                        //                                    }
                                        
                                    }
                                    
                                }
                                //                                else if status == "1" {
                                //                                    let alertController = UIAlertController(title: "", message: "No Record Found!!", preferredStyle: .alert)
                                //
                                //                                    // Add an action (button)
                                //                                    //                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                //                                    let okAction = UIAlertAction(title: "OK", style: .default) { [self] _ in
                                //                                        member_master_profile_id = "0"
                                //                                        UserDefaults.standard.setValue(member_master_profile_id, forKey: "fk_member_master_profile_id")
                                //                                        let otpVC = storyboard?.instantiateViewController(identifier: "ViewController") as! ViewController
                                //
                                //                                        self.navigationController?.pushViewController(otpVC, animated: true)
                                //                                    }
                                //                                    alertController.addAction(okAction)
                                //
                                //                                    // Present the alert
                                //                                    self.present(alertController, animated: true, completion: nil)
                                //
                                //
                                //                                }
                                
                            }
                        } catch {
                            //                                   self.showAlert(title: "Error", message: "Failed to parse JSON: \(error.localizedDescription)")
                            let alertController = UIAlertController(title: "Network Error", message: "", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    } else {
                        print("Data is nil")
                    }
                    
                case .failure(let error):
                    print("Request failed with error: \(error)")
                }
            }
        }
    }
    
    func recentSearch() {
        let url = AppConfig.baseURL+"Book/Getlatest_three_rides_Foruser"
        let params :  [String : Any] = [
            "fk_member_master_profile_id": member_master_profile_id ?? 0,
            "currentAppVersion": self.currentAppVersion ?? ""
        ]
        let token = UserDefaults.standard.string(forKey: "auth_deviceToken") ?? ""

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        print("recentSearch() -> url : \(url)")
        print("recentSearch() -> params : \(params)")
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { [weak self] response in
            guard let self = self else { return }
            
            print("recentSearchList() -> response : \(response.result)")
            switch response.result {
                
            case .success (let data) :
                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let loginResult = json["result"] as? [String: Any] {
                            print("recentSearch() -> JSON -------\(json)")
                            let status = loginResult["status"] as? String ?? ""
                            let message = loginResult["message"] as? String ?? ""
                            let output = loginResult["output"] as! [[String: Any]]
                            print("recentSearch() -> output : \(output)")
                            for output in output {
                                let distinationaddress = output["distinationaddress"] as? String ?? ""
                                print("recentSearch() -> : \(distinationaddress)")
                                
                                dashboardRecentSearches.append(distinationaddress)
                            }
                            if dashboardRecentSearches.count == 0 || dashboardRecentSearches.count == nil{
                                dashBoardRecentSearchesTableViewHeight.constant = 0
                                dashBoardRecentSearchesTableView.isHidden = true
                                NSLayoutConstraint.activate([
                                    destinationBtn.bottomAnchor.constraint(equalTo: self.destinationView.bottomAnchor, constant: -10)
                                ])
                            }
                            //                                let distinationaddress = output["distinationaddress"] as? String ?? ""
                            DispatchQueue.main.async {
                                self.dashBoardRecentSearchesTableView.reloadData()
                            }
                            
                        } else {
                        }
                    } catch {
                        //                                   self.showAlert(title: "Error", message: "Failed to parse JSON: \(error.localizedDescription)")
                        let alertController = UIAlertController(title: "Network Error", message: "", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                } else {
                    print("Data is nil")
                }
                
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
        
    }
    
    func locationUnServiceable() {
        if currentLocationTxtFieldCrossBtn.isHidden == true {
            currentLocationTxtFieldCrossBtn.isHidden = false
        }
        let url = AppConfig.baseURL+"login/CheckCurrentLocationIn_BoundingBox"
        //        let params :  [String : Any] = [
        //            "currentLat": 12.95103,
        //              "currentLong": 77.57774
        //        ]
        let params :  [String : Any] = [
            "currentLat": mainLat,
            "currentLong": mainLong
        ]
        let token = UserDefaults.standard.string(forKey: "auth_deviceToken") ?? ""

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        print("locationUnServiceable() -> url : \(url)")
        print("locationUnServiceable() -> params : \(params)")
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { [weak self] response in
            
            guard let self = self else { return }
            
            print("locationUnServiceable() -> response : \(response.result)")
            switch response.result {
                
            case .success (let data) :
                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let loginResult = json["result"] as? [String: Any] {
                            print("locationUnServiceable() -> JSON -------\(json)")
                            let status = loginResult["status"] as? String ?? ""
                            let message = loginResult["message"] as? String ?? ""
                            if message == "NO" {
                                demoPNG.isHidden = false
                                //                                    if myMap.isHidden == false {
                                destinationLocationView.isHidden = true
                                myMap.isHidden = true
                                //                                    }
                                self.view.backgroundColor = UIColor(red: 210, green: 234, blue: 255)
                            } else if message == "OK" {
                                demoPNG.isHidden = true
                                destinationLocationView.isHidden = false
                                myMap.isHidden = false
                                self.view.backgroundColor = UIColor.white
                            }
                            
                        } else {
                        }
                    } catch {
                        //                                   self.showAlert(title: "Error", message: "Failed to parse JSON: \(error.localizedDescription)")
                        let alertController = UIAlertController(title: "Network Error", message: "", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                } else {
                    print("Data is nil")
                }
                
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
        
    }
}



