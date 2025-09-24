//
//  RideStartedViewController.swift
//  yatriMitra
//
//  Created by Kaizen Infotech Solutions Private Limited. on 19/06/24.
//

import UIKit
import MapKit
import Alamofire
import GoogleMaps
import CoreLocation


class RideStartedViewController: UIViewController, MKMapViewDelegate, GMSMapViewDelegate, CLLocationManagerDelegate  {
    
    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet weak var driverDetails: UIView!
    @IBOutlet weak var myMapBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var callView: UIView!
    @IBOutlet weak var vehicleNumber: UILabel!
    @IBOutlet weak var vehicleModel: UILabel!
    @IBOutlet weak var driverName: UILabel!
    @IBOutlet weak var vehicleImage: UIImageView!
    @IBOutlet weak var driverPhoto: UIImageView!
    @IBOutlet weak var rideCancelledSuccessfullyImg: UIImageView!
    @IBOutlet weak var cancelRideReasonMandatoryLBL: UILabel!
    @IBOutlet weak var cancelRideReasonTxtField: UITextField!
    @IBOutlet weak var driverMobileNumber: UILabel!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var shareViewOptions: UIView!
    @IBOutlet weak var cancelRideView: UIView!
    @IBOutlet weak var cancelRideViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonOpticity: UIButton!
    
    
    var member_master_profile_id : Int?
    var mapView: GMSMapView!
    let locationManager = CLLocationManager()
    var vehicleNumberString:String?
    var vehicleModelString:String?
    var driverNameString:String?
    var vehicleImageUI:UIImage?
    var driverPhotoUI:UIImage?
    var driverMobileNumberString:String?
    var current:String?
    var destination:String?
    var currentLocationCoordinate: CLLocationCoordinate2D?
    var destinationLocationCoordinate: CLLocationCoordinate2D?
    var route: MKRoute?
    var currentAnnotation: MKPointAnnotation?
    var arrowMarker: UIImageView?
    var startimer: Timer?
    var pk_bookride_id: Int?
    var mainLat : CLLocationDegrees?
    var mainLong : CLLocationDegrees?
    var boolAutoComplete = true
    let geoCoder = CLGeocoder()
    var isRequestInProgress = false
    var roadPolyline : GMSPolyline?
    var currentMarker: GMSMarker?
    var destinationMarker: GMSMarker?
    var moveCamera : Bool = false
    var rideStatus : String?
    var currentToRoadDottedPolyline : GMSPolyline?
    var destinationDottedPolyline : GMSPolyline?
    let dottedPathFromCurrentLocation = GMSMutablePath()
    let dottedPathToDestination = GMSMutablePath()
    var latitudes_destination: String?
    var longitudes_destination: String?
    var driver_current_latitude : String?
    var driver_current_longitude : String?
    var driverPhotoString: String?
    var vehiclePhotoString: String?
    var lastClickTime: CFTimeInterval = 0
    var iOSversion: String?
    var apiTimer : Timer?
    var sd_poliline_points : String?
    var polylinecoordinates : [CLLocationCoordinate2D] = []
    var isdpPolylinePointsobtainedfromDriverlocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Landed in RideStartedViewController")
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleForceUpdate),
                                               name: .forceUpdate,
                                               object: nil)
        if let apiTimer = apiTimer {
            TimerManager.shared.registerTimer(apiTimer)
        }
        if let startimer = startimer {
            TimerManager.shared.registerTimer(startimer)
        }
        cancelRideReasonTxtField.delegate = self
        rideCancelledSuccessfullyImg.isHidden = true
        cancelRideView.isHidden = true
        apiTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(sessionTimeOut), userInfo: nil, repeats: true)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        if rideStatus == "active" || rideStatus == "tappedNotifcationBanner" {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            //            pendingRide()
            if let latString = latitudes_destination,
               let lonString = longitudes_destination,
               let driverlatString = driver_current_latitude,
               let driverlonString = driver_current_longitude,
               let latitude = Double(latString),
               let longitude = Double(lonString),
               let driverlatitude = Double(driverlatString),
               let driverlongitude = Double(driverlonString) {
                currentLocationCoordinate = CLLocationCoordinate2D(latitude: driverlatitude, longitude: driverlongitude)
                // Set the destinationLocationCoordinate using CLLocationCoordinate2D
                destinationLocationCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                if let driverProfilePic = driverPhotoString {
                    
                    // Trim any extra spaces and replace backslashes with forward slashes
                    let correctedDriverProfilePic = driverProfilePic.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "//", with: "/")
                    
                    print("Corrected Driver Profile Pic URL after the app is terminated : \(correctedDriverProfilePic)")  // Debugging line
                    
                    if let url = URL(string: correctedDriverProfilePic) {
                        if let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) {
                            DispatchQueue.main.async {
                                self.driverPhoto.image = image  // Or rotateImageBy270Degrees(image: image) if needed
                                
                                print("Image loaded successfully after the app is terminated.")
                            }
                        } else {
                            print("Failed to load image data from URL after the app is terminated : \(url).")
                        }
                    }
                }
                if let imageUrlString = vehiclePhotoString,
                   let imageUrl = URL(string: imageUrlString) {
                    print("Attempting to load image from URL: \(imageUrlString)")
                    DispatchQueue.global().async {
                        do {
                            let imageData = try Data(contentsOf: imageUrl)
                            if let image = UIImage(data: imageData) {
                                DispatchQueue.main.async {
                                    print("Image loaded successfully, updating UIImageView.")
                                    self.vehicleImage.image = image
                                }
                            } else {
                                print("Failed to create UIImage from data.")
                            }
                        } catch {
                            print("Error loading image data: \(error)")
                            let alertController = UIAlertController(title: "Network Error", message: "", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            } else {
                print("Invalid latitude or longitude values.")
            }
        } else {
            driverPhoto.image = driverPhotoUI
            self.vehicleImage.image = vehicleImageUI
        }
        print("destinationLocationCoordinate : \(destinationLocationCoordinate)")
        cancelRideReasonTxtField.layer.borderColor = UIColor.black.cgColor // Set border color
        cancelRideReasonTxtField.layer.borderWidth = 2.0                 // Set border width
        cancelRideReasonTxtField.layer.cornerRadius = 5.0               // Optional: Add rounded corners
        cancelRideReasonTxtField.clipsToBounds = true
        cancelRideReasonMandatoryLBL.isHidden = true
        rideStatusStarted()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            
            // Adjust the bottom constraint of cancelRideView
            cancelRideViewBottomConstraint.constant = keyboardHeight
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        // Reset the bottom constraint to original
        cancelRideViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // Dismiss keyboard when tapping outside the text field
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func clear_GmapsAndTimer_Memory() {
        locationManager.delegate = nil
        currentMarker = nil
        destinationMarker = nil
        roadPolyline = nil
        currentToRoadDottedPolyline = nil
        destinationDottedPolyline = nil
        myMap.delegate = nil
        dottedPathFromCurrentLocation.removeAllCoordinates()
        dottedPathToDestination.removeAllCoordinates()
        startimer?.invalidate()
        apiTimer?.invalidate()
        startimer = nil
        apiTimer = nil
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    deinit {
        clear_GmapsAndTimer_Memory()
        print("******************** DEINIT RideStartedViewcontroller REMOVED FROM MEMORY*********************")
    }
    
    func rideStatusStarted() {
        
        shareView.isHidden = true
        shareViewOptions.isHidden = true
        buttonOpticity.isHidden = true
        print("RideStartedViewController() -> currentLocationCoordinate : \(currentLocationCoordinate)")
        print("RideStartedViewController() -> destinationLocationCoordinate : \(destinationLocationCoordinate)")
        print("current : \(current)")
        print("destination : \(destination)")
        print("pk_bookride_id : \(pk_bookride_id)")
        print("vehicleNumberString : \(vehicleNumberString)")
        print("vehicleModelString : \(vehicleModelString)")
        print("driverNameString : \(driverNameString)")
        print("driverMobileNumberString : \(driverMobileNumberString)")
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        NetworkMonitor.shared
        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 8)
        mapView = GMSMapView.map(withFrame: self.myMap.bounds, camera: camera)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.myMap.addSubview(mapView)
        mapView.isMyLocationEnabled = false
        vehicleNumber.text = vehicleNumberString
        vehicleModel.text = vehicleModelString
        driverName.text = driverNameString
        self.driverPhoto.layer.cornerRadius = self.driverPhoto.frame.size.width / 2
        self.driverPhoto.clipsToBounds = true
        driverMobileNumber.text = driverMobileNumberString
        myMapBottomConstraint.constant = 250
        callView.layer.cornerRadius=10
        callView.layer.shadowOpacity = 0.3
        callView.layer.shadowOffset = CGSize(width: 5, height: 5)
        callView.layer.shadowRadius = 5
        callView.layer.borderColor = UIColor.systemGray4.cgColor
        callView.layer.borderWidth = 1
        shareView.roundCorners([.topLeft, .topRight], radius: 20)
        mapView.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(callViewTapped))
        callView.addGestureRecognizer(tapGesture)
        callView.isUserInteractionEnabled = true
        //        locationTxts()
        
        self.addCustomMarkers()
        showPath(polyStr: sd_poliline_points ?? "")
        self.updateMapRegion()
        //        self.calculateRoute()
        startRideConfirmTimer()
    }
    
    
    @objc func callViewTapped() {
        placePhoneCall(phoneNumber: driverMobileNumber.text ?? "") // Replace with the phone number you want to call
    }
    
    // Function to place the phone call
    func placePhoneCall(phoneNumber: String) {
        if let phoneCallURL = URL(string: "tel://\(phoneNumber)"),
           UIApplication.shared.canOpenURL(phoneCallURL) {
            UIApplication.shared.open(phoneCallURL, options: [:], completionHandler: nil)
        } else {
            print("Phone call not possible on this device.")
        }
    }
    var elapsedTime: TimeInterval = 0.0
    let totalDuration: TimeInterval = 5 * 60 * 60
    func startRideConfirmTimer() {
        //        elapsedTime = 0.0
        // Create and start the timer to call rideConfirm() every 5 seconds
        startimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(rideCnfirm), userInfo: nil, repeats: true)
        //        RunLoop.current.add(startimer!, forMode: .common)
        
    }
    
    
    
    @objc func rideCnfirm() {
        
        
        //        if startimer != nil {
        //            guard !isRequestInProgress else { return }
        //                isRequestInProgress = true
        //            getUpdatedLatLongFromDriver()
        //            endRide()
        //        } else {
        //
        //        }
        if NetworkMonitor.shared.isConnected {
            elapsedTime += 5.0
            
            print("Timer fired: Elapsed time: \(elapsedTime) seconds")
            
            // Your ride confirmation logic here
            getUpdatedLatLongFromDriver()
            endRide()
            // Check if total duration has been reached (5 hours)
            if elapsedTime >= totalDuration {
                startimer?.invalidate()
                startimer = nil
                elapsedTime = 0.0
                print("Timer stopped after 5 hours")
            }
        } else {
            print("you are not connected")
            let alert = UIAlertController(title: "No Internet Connection",
                                          message: "It looks like you're offline. Please check your internet connection.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default,handler: { [self] _ in
                
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    func locationTxts() {
        guard let currentLocationText = current, !currentLocationText.isEmpty else { return }
        geocodeAddress(currentLocationText) { coordinate in
            guard let coordinate = coordinate else { return }
            self.addAnnotation(at: coordinate, for: self.current!)
            self.addCustomMarkers()
            self.updateMapRegion()
            self.calculateRoute()
        }
        guard let destinationLocationText = destination, !destinationLocationText.isEmpty else { return }
        geocodeAddress(destinationLocationText) { coordinate in
            guard let coordinate = coordinate else { return }
            self.addAnnotation(at: coordinate, for: self.destination!)
            self.addCustomMarkers()
            self.updateMapRegion()
            self.calculateRoute()
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //        myMap.camera = GMSCameraPosition(target: CLLocationCoordinate2D(latitude: locationManager.location?.coordinate.longitude ?? 0.0, longitude: locationManager.location?.coordinate.latitude ?? 0.0), zoom: 8, bearing: 0, viewingAngle: 0)
        //        let marker = GMSMarker()
        //        marker.position = CLLocationCoordinate2D(latitude: locationManager.location?.coordinate.latitude ?? 0.0, longitude: locationManager.location?.coordinate.longitude ?? 0.0)
        //        marker.map = myMap
        
        //        guard let location = locations.last else { return }
        locationManager.stopUpdatingLocation()
        print("latitude : ", locationManager.location?.coordinate.latitude ?? 0.0)
        print("longitude : ", locationManager.location?.coordinate.longitude ?? 0.0)
        let latitude = locationManager.location?.coordinate.latitude
        let longitude = locationManager.location?.coordinate.longitude
        let camera = GMSCameraPosition.camera(withLatitude: latitude!, longitude: longitude!, zoom: 15.0)
        mapView.animate(to: camera)
        
        let marker = GMSMarker()
        //        marker.position = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        marker.map = mapView
        mainLat = latitude
        mainLong = longitude
        let locationString = "Lat: \(latitude), Lon: \(longitude)"
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
                }
            }
        }
        let center = CLLocationCoordinate2D(latitude: locationManager.location?.coordinate.latitude ?? 0.0, longitude: locationManager.location?.coordinate.longitude ?? 0.0)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
        // Set the region on the map view
        myMap.setRegion(region, animated: true)
        
        //        pickupLocation.text = " \(latitude), \(longitude)"
        
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
                completion(location.coordinate)
            } else {
                completion(nil)
            }
        }
    }
    
    // Function to add annotation to map
    func addAnnotation(at coordinate: CLLocationCoordinate2D, for textField: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        if textField == current {
            annotation.title = "Current Location"
            print("coordinate1 : \(coordinate)")
            currentLocationCoordinate = coordinate
        } else if textField == destination {
            annotation.title = "Destination"
            print("coordinate2 : \(coordinate)")
            destinationLocationCoordinate = coordinate
        }
        myMap.addAnnotation(annotation)
        
        // Optionally, center the map around the annotation
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        myMap.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "CustomAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        if annotation.title == "Current Location" {
            annotationView?.pinTintColor = .systemGreen
        } else if annotation.title == "Destination" {
            annotationView?.pinTintColor = .red
        }
        
        // Customize the annotation view's image or symbol if needed
        // Example: annotationView?.image = UIImage(named: "customImage")
        
        return annotationView
    }
    
    func calculateBearing(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> CLLocationDegrees {
        let lat1 = start.latitude.radians
           let lon1 = start.longitude.radians
           let lat2 = end.latitude.radians
           let lon2 = end.longitude.radians

        let deltaLon = lon2 - lon1

        let y = sin(deltaLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon)
        let bearing = atan2(y, x).degrees

        return (bearing + 360).truncatingRemainder(dividingBy: 360) // Normalize to 0-360
    }
    func addCustomMarkers() {
        guard let currentCoordinate = currentLocationCoordinate,
              let destinationCoordinate = destinationLocationCoordinate else {
            return
        }
        
        print("addCustomMarkers() -> currentCoordinate : \(currentCoordinate)")
        print("addCustomMarkers() -> destinationCoordinate : \(destinationCoordinate)")
        // Add current location marker
        currentMarker = GMSMarker(position: currentCoordinate)
        currentMarker?.title = "Current Location"
        //        currentMarker?.icon = resizeImage(image: UIImage(named: "driverMarkerPoint")!, targetSize: CGSize(width: 25, height: 25))
        currentMarker?.icon = resizeImage(image: UIImage(named: "Blue_Arrow_Up_Darker")!, targetSize: CGSize(width: 25, height: 25))
        if polylinecoordinates.count > 1 {
            let bearing = calculateBearing(from: polylinecoordinates[0], to: polylinecoordinates[1])
            currentMarker?.rotation = bearing // Set the calculated bearing
            
            // Ensure the marker icon rotates correctly
            currentMarker?.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        }
        currentMarker?.map = mapView
        
        // Add destination marker
        destinationMarker = GMSMarker(position: destinationCoordinate)
        destinationMarker?.title = "Destination"
        destinationMarker?.icon = resizeImage(image: UIImage(named: "endpoint")!, targetSize: CGSize(width: 25, height: 25))
        destinationMarker?.map = mapView
        //        calculateDistance()
    }
    
    func calculateDistance(latZero: Double, longZero: Double, lat: Double, long: Double) -> Double {
        let earthRadius = 6371000.0 // Earth's radius in meters
        
        let dLat = (lat - latZero) * .pi / 180
        let dLong = (long - longZero) * .pi / 180
        
        let a = sin(dLat / 2) * sin(dLat / 2) +
        cos(latZero * .pi / 180) * cos(lat * .pi / 180) *
        sin(dLong / 2) * sin(dLong / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        return earthRadius * c
    }
    
    func clearRecordsBeforeMinimum(
        distanceList: [Double],
        polylineCoordinates: [CLLocationCoordinate2D]
    ) -> ([Double], [CLLocationCoordinate2D]) {
        guard let minValue = distanceList.min(),
              let minIndex = distanceList.firstIndex(of: minValue) else {
            return (distanceList, polylineCoordinates) // Return the original arrays if empty
        }
        
        // Remove all elements before the minimum index
        let updatedDistanceList = Array(distanceList[minIndex...])
        let updatedPolylineCoordinates = Array(polylineCoordinates[minIndex...])
        
        return (updatedDistanceList, updatedPolylineCoordinates)
    }
    
    func findMinIndex(list: [Double]) throws -> Int {
        // Ensure the list has at least two elements
//        guard list.count > 1 else {
//            throw NSError(domain: "InvalidInput", code: 1, userInfo: [NSLocalizedDescriptionKey: "Array must have at least two elements"])
//        }
        
        // Initialize minIndex and minValue with the 1st element
//        var minIndex = 0
//        var minValue = list[0]
//        
//        // Start checking from the 2nd position
//        for i in 1..<list.count {
//            if list[i] < minValue {
//                minValue = list[i]
//                minIndex = i
//            }
//        }
//        
//        return minIndex
        var minIndex : Int?
        if list.count > 1 {
            minIndex = 0
            var minValue = list[0]
            
            // Start checking from the 2nd position
            for i in 1..<list.count {
                if list[i] < minValue {
                    minValue = list[i]
                    minIndex = i
                }
            }
            
            
        }
        return minIndex ?? 0
    }
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Determine what scale factor to use
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // Resize the image
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    func updateMapRegion() {
        print("currentLocationCoordinate : \(currentLocationCoordinate)")
        print("destinationLocationCoordinate : \(destinationLocationCoordinate)")
        
        guard let currentCoordinate = currentLocationCoordinate,
              let destinationCoordinate = destinationLocationCoordinate else {
            return
        }
        
        //        var zoomRect = MKMapRect.null
        //        let currentPoint = MKMapPoint(currentCoordinate)
        //        let destinationPoint = MKMapPoint(destinationCoordinate)
        //
        //        zoomRect = zoomRect.union(MKMapRect(x: currentPoint.x, y: currentPoint.y, width: 0, height: 0))
        //        zoomRect = zoomRect.union(MKMapRect(x: destinationPoint.x, y: destinationPoint.y, width: 0, height: 0))
        //
        //        myMap.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
        let bounds = GMSCoordinateBounds(coordinate: currentCoordinate, coordinate: destinationCoordinate)
        // Create a camera update that fits the bounds with padding
        let update = GMSCameraUpdate.fit(bounds, withPadding: 80.0)
        
        // Move the camera to the updated position
        mapView.moveCamera(update)
        moveCamera = true
        
    }
    
    //    func calculateRoute() {
    //        guard let currentCoordinate = currentLocationCoordinate,
    //              let destinationCoordinate = destinationLocationCoordinate else {
    //            return
    //        }
    //
    //        let sourcePlacemark = MKPlacemark(coordinate: currentCoordinate)
    //        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
    //
    //        let directionRequest = MKDirections.Request()
    //        directionRequest.source = MKMapItem(placemark: sourcePlacemark)
    //        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
    //        directionRequest.transportType = .automobile
    //
    //        let directions = MKDirections(request: directionRequest)
    //        directions.calculate { response, error in
    //            guard let response = response, error == nil else {
    //                print("Error calculating route: \(String(describing: error?.localizedDescription))")
    //                return
    //            }
    //
    //            self.route = response.routes[0]
    //            self.myMap.addOverlay(self.route!.polyline, level: .aboveRoads)
    //
    //            // Start moving the marker
    ////            self.addArrowMarker()
    ////            self.moveArrowMarker()
    //        }
    //        startRideConfirmTimer()
    //    }
    func calculateRoute() {
        guard let currentCoordinate = currentLocationCoordinate,
              let destinationCoordinate = destinationLocationCoordinate else {
            return
        }
        
        let origin = "\(currentCoordinate.latitude),\(currentCoordinate.longitude)"
        let destination = "\(destinationCoordinate.latitude),\(destinationCoordinate.longitude)"
        
        print("origin : \(origin)")
        print("destination : \(destination)")
        let urlStr = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyDce_Ybso83w6ay7NoKCuA5y33udrxGhmk"
        
        print("url of route : \(urlStr)")
        
        guard let url = URL(string: urlStr) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("Received JSON: \(json)")
                    if let routes = json["routes"] as? [[String: Any]], let route = routes.first {
                        if let overviewPolyline = route["overview_polyline"] as? [String: Any], let points = overviewPolyline["points"] as? String {
                            DispatchQueue.main.async { [weak self] in
                                guard let self = self else { return }
                                roadPolyline?.map = nil
                                currentToRoadDottedPolyline?.map = nil
                                destinationDottedPolyline?.map = nil
                                dottedPathFromCurrentLocation.removeAllCoordinates()
                                dottedPathToDestination.removeAllCoordinates()
                                showPath(polyStr: points)
                            }
                        }
                    }
                }
            } catch let error {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }.resume()
        //        startRideConfirmTimer()
    }
    
    //    func showPath(polyStr: String) {
    //        let path = GMSPath(fromEncodedPath: polyStr)
    //        let polyline = GMSPolyline(path: path)
    //        polyline.strokeWidth = 5.0
    //        polyline.strokeColor = .blue
    //        polyline.map = mapView
    //    }
    func decodePolyline(_ encodedPath: String) -> [CLLocationCoordinate2D] {
        var coordinates: [CLLocationCoordinate2D] = []
        let length = encodedPath.count
        var index = encodedPath.startIndex
        var lat = 0
        var lng = 0
        
        while index < encodedPath.endIndex {
            var result = 1
            var shift = 0
            var b: Int
            
            repeat {
                let char = encodedPath[index]
                index = encodedPath.index(after: index)
                b = Int(char.asciiValue!) - 63 - 1
                result += b << shift
                shift += 5
            } while b >= 0x1f
            
            lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1)
            
            result = 1
            shift = 0
            
            repeat {
                let char = encodedPath[index]
                index = encodedPath.index(after: index)
                b = Int(char.asciiValue!) - 63 - 1
                result += b << shift
                shift += 5
            } while b >= 0x1f
            
            lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1)
            
            let coordinate = CLLocationCoordinate2D(latitude: Double(lat) * 1e-5, longitude: Double(lng) * 1e-5)
            coordinates.append(coordinate)
        }
        
        print("Decoded path: \(coordinates)")
        return coordinates
    }
    var path = GMSMutablePath()
    func showPath(polyStr: String) {
        guard let currentCoordinate = currentLocationCoordinate,
              let destinationCoordinate = destinationLocationCoordinate else {
            return
        }
        if let existingPolyline = roadPolyline {
            existingPolyline.map = nil // Remove the old polyline from the map
            
        }
        currentToRoadDottedPolyline?.map = nil
        destinationDottedPolyline?.map = nil
        dottedPathFromCurrentLocation.removeAllCoordinates()
        dottedPathToDestination.removeAllCoordinates()
        roadPolyline?.map = nil
        roadPolyline = nil
        
        let path = GMSPath(fromEncodedPath: polyStr)
        roadPolyline = GMSPolyline(path: path)
        //        roadPolyline.strokeColor = UIColor.blue // Color for the road path
        roadPolyline?.strokeColor = UIColor(red: 95, green: 102, blue: 118)
        roadPolyline?.strokeWidth = 5.0
        roadPolyline?.map = mapView // Your GMSMapView instance
        guard let paths = path else { return }
        let firstRoadCoordinate = paths.coordinate(at: 0)
        dottedPathFromCurrentLocation.add(currentCoordinate)
        dottedPathFromCurrentLocation.add(firstRoadCoordinate)
        currentToRoadDottedPolyline = GMSPolyline(path: dottedPathFromCurrentLocation)
        currentToRoadDottedPolyline?.strokeColor = UIColor(red: 95, green: 102, blue: 118)
        currentToRoadDottedPolyline?.strokeWidth = 5.0
        let dotStyle = GMSStrokeStyle.solidColor(.clear)
        //        let gapStyle = GMSStrokeStyle.solidColor(UIColor(red: 95, green: 102, blue: 118))
        let gapStyle = GMSStrokeStyle.solidColor(.clear)
        let pattern = [gapStyle, dotStyle]
        currentToRoadDottedPolyline?.spans = GMSStyleSpans((currentToRoadDottedPolyline?.path)!, pattern, [2, 2], .geodesic)
        currentToRoadDottedPolyline?.map = mapView
        let lastRoadCoordinate = paths.coordinate(at: (paths.count() - 1))
        dottedPathToDestination.add(lastRoadCoordinate) // Start from the last point on the road
        dottedPathToDestination.add(destinationCoordinate) // Exact building location
        destinationDottedPolyline = GMSPolyline(path: dottedPathToDestination)
        destinationDottedPolyline?.strokeColor = UIColor(red: 95, green: 102, blue: 118)
        destinationDottedPolyline?.strokeWidth = 5.0
        destinationDottedPolyline?.spans = GMSStyleSpans((destinationDottedPolyline?.path)!, pattern, [2, 2], .geodesic)
        destinationDottedPolyline?.map = mapView
    }
    func showPath1(polylineCoordinates: [CLLocationCoordinate2D]) {
        guard let currentCoordinate = currentLocationCoordinate,
              let destinationCoordinate = destinationLocationCoordinate else {
            return
        }
        // Create the polyline without hidden views logic
        currentToRoadDottedPolyline?.map = nil
        destinationDottedPolyline?.map = nil
        dottedPathFromCurrentLocation.removeAllCoordinates()
        dottedPathToDestination.removeAllCoordinates()
        roadPolyline?.map = nil
        roadPolyline = nil
        
        path = GMSMutablePath()
        polylineCoordinates.forEach { path.add($0) }
        
        
        roadPolyline = GMSPolyline(path: path)
        roadPolyline?.strokeColor = UIColor(red: 95/255, green: 102/255, blue: 118/255, alpha: 1)
        roadPolyline?.strokeWidth = 5.0
        roadPolyline?.map = mapView
        
        
        if let firstRoadCoordinate = polylineCoordinates.first {
            let dottedPathFromCurrentLocation = GMSMutablePath()
            //                dottedPathFromCurrentLocation.add(currentCoordinate)
            dottedPathFromCurrentLocation.add(firstRoadCoordinate)
            
            currentToRoadDottedPolyline = GMSPolyline(path: dottedPathFromCurrentLocation)
            currentToRoadDottedPolyline?.map = mapView
        }
        
        if let lastRoadCoordinate = polylineCoordinates.last {
            let dottedPathToDestination = GMSMutablePath()
            //                dottedPathToDestination.add(lastRoadCoordinate)
            dottedPathToDestination.add(destinationCoordinate)
            
            destinationDottedPolyline = GMSPolyline(path: dottedPathToDestination)
            destinationDottedPolyline?.map = mapView
        }
    }
    func addArrowMarker() {
        guard let currentCoordinate = currentLocationCoordinate else { return }
        let arrowImage = UIImage(named: "Vector 9") // Ensure you have an arrow image in your assets
        arrowMarker = UIImageView(image: arrowImage)
        arrowMarker?.frame.size = CGSize(width: 40, height: 40)
        arrowMarker?.center = myMap.convert(currentCoordinate, toPointTo: myMap)
        if let arrowMarker = arrowMarker {
            myMap.addSubview(arrowMarker)
        }
    }
    
    func moveArrowMarker() {
        guard let route = route, let arrowMarker = arrowMarker else { return }
        
        var pointIndex = 0
        let points = route.polyline.points()
        let totalPoints = route.polyline.pointCount
        
        startimer?.invalidate() // Invalidate any existing timer
        startimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if pointIndex < totalPoints {
                let point = points[pointIndex]
                let coord = point.coordinate
                let newCenter = self.myMap.convert(coord, toPointTo: self.myMap)
                
                UIView.animate(withDuration: 0.1) {
                    arrowMarker.center = newCenter
                }
                
                if pointIndex > 0 {
                    let previousCoord = points[pointIndex - 1].coordinate
                    let angle = self.angleBetweenCoordinates(from: previousCoord, to: coord)
                    arrowMarker.transform = CGAffineTransform(rotationAngle: angle)
                }
                
                pointIndex += 1
            } else {
                timer.invalidate()
            }
        }
    }
    
    func angleBetweenCoordinates(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> CGFloat {
        let deltaX = end.longitude - start.longitude
        let deltaY = end.latitude - start.latitude
        let angle = atan2(deltaY, deltaX)
        return CGFloat(angle)
    }
    
    // MKMapViewDelegate method to render polyline
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 4.0
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    @IBAction func shareBtnAction(_ sender: Any) {
        driverDetails.isHidden = true
        if shareView.isHidden == true {
            buttonOpticity.isHidden = false
            shareView.isHidden = false
            myMapBottomConstraint.constant = 84
        }
    }
    
    @IBAction func closeShareView(_ sender: Any) {
        if shareView.isHidden == false {
            shareView.isHidden = true
            
        }
        if driverDetails.isHidden == true {
            buttonOpticity.isHidden = true
            driverDetails.isHidden = false
            myMapBottomConstraint.constant = 250
        }
    }
    
    @IBAction func shareDriverDetails(_ sender: Any) {
        //        if shareView.isHidden == false {
        //            shareView.isHidden = true
        //        }
        //        if shareViewOptions.isHidden == true {
        //            shareViewOptions.isHidden = false
        //            myMapBottomConstraint.constant = 333
        //        }
        
        let driverName = driverName.text ?? ""
        let driverPhone = driverMobileNumber.text ?? ""
        let vehicleModel = vehicleModel.text ?? ""
        let vehicleNumber = vehicleNumber.text ?? ""
        let pickupLocation = current
        let destinationLocation = destination
        
        // Construct the message
        let message = """
            RIDE DETAILS
            ---------------------------
            Driver Details:
            \(driverName)
            \(driverPhone)
            
            Vehicle Details:
            \(vehicleNumber)
            
            Pickup Location:
            \(pickupLocation ?? "")
            
            Destination Location:
            \(destinationLocation ?? "")
            """
        // Create an array with the items to share
        let itemsToShare: [Any] = [message]
        
        // Initialize the UIActivityViewController
        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        
        // Exclude some activity types if necessary
        activityViewController.excludedActivityTypes = [.assignToContact, .saveToCameraRoll, .print]
        
        // Present the share sheet
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    @IBAction func shareNcancelRideViewCancelBtnAction(_ sender: Any) {
        let currentTime = CACurrentMediaTime()
        
        if currentTime - lastClickTime < 1 { // Ignore multiple clicks within 1 second
            return
        }
        
        lastClickTime = currentTime
        
        // Handle button click action
        print("Button clicked")
        print("opened cancel ride reasons view after driver details view is appeared")
        if buttonOpticity.isHidden == true {
            buttonOpticity.isHidden = false
        }
        if cancelRideView.isHidden == true {
            cancelRideView.isHidden = false
            cancelRideReasonMandatoryLBL.isHidden = true
            myMapBottomConstraint.constant = 281
            cancelRideView.roundCorners([.topLeft, .topRight], radius: 30)
        }
        
    }
    
    @IBAction func submitActionForRideCancel(_ sender: Any) {
        //        let currentTime = CACurrentMediaTime()
        //        if currentTime - lastClickTime < 1 { // Ignore multiple clicks within 1 second
        //            return
        //        }
        //        lastClickTime = currentTime
        //
        // Handle button click action
        print("Button clicked")
        view.endEditing(true)
        if cancelRideReasonTxtField.text == "" {
            // Show error: No option selected
            cancelRideReasonTxtField.layer.borderColor = UIColor.red.cgColor // Set border color
            cancelRideReasonTxtField.layer.borderWidth = 2.0                 // Set border width
            cancelRideReasonTxtField.layer.cornerRadius = 5.0               // Optional: Add rounded corners
            cancelRideReasonTxtField.clipsToBounds = true
            cancelRideReasonMandatoryLBL.isHidden = false
            return
        } else {
            if NetworkMonitor.shared.isConnected{
                print("you are connected")
                cancelRide()
            } else {
                print("you are not connected")
                let alert = UIAlertController(title: "No Internet Connection",
                                              message: "It looks like you're offline. Please check your internet connection.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default,handler: { [self] _ in
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }))
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func hideShareOptions(_ sender: Any) {
        if shareViewOptions.isHidden == false {
            shareViewOptions.isHidden = true
        }
        if driverDetails.isHidden == true {
            buttonOpticity.isHidden = true
            driverDetails.isHidden = false
            myMapBottomConstraint.constant = 250
        }
    }
    
    @IBAction func disablecancelReasonView(_ sender: Any) {
        let currentTime = CACurrentMediaTime()
        
        if currentTime - lastClickTime < 1 { // Ignore multiple clicks within 1 second
            return
        }
        
        lastClickTime = currentTime
        
        // Handle button click action
        print("Button clicked")
        cancelRideReasonTxtField.text = ""
        view.endEditing(true)
        cancelRideReasonTxtField.layer.borderColor = UIColor.black.cgColor // Set border color
        cancelRideReasonTxtField.layer.borderWidth = 2.0                 // Set border width
        cancelRideReasonTxtField.layer.cornerRadius = 5.0               // Optional: Add rounded corners
        cancelRideReasonTxtField.clipsToBounds = true
        shareViewOptions.isHidden = true
        cancelRideView.isHidden=true
        buttonOpticity.isHidden = true
        cancelRideReasonMandatoryLBL.isHidden = true
        shareView.isHidden = true
        driverDetails.isHidden = false
        self.myMapBottomConstraint.constant = 250
        //        if cancelBtnIsCalledFrom == "Before Driver Accepted the Ride" {
        //            currentToDestinationMainView.isHidden = false
        //            progressBGView.isHidden = false
        //            cancelRideView.isHidden = true
        //            buttonOpticity.isHidden = true
        //            self.myMapBottomConstraint.constant = 425
        //
        //        }
        //
        //        else if cancelBtnIsCalledFrom == "After Driver Accepted the Ride" {
        //            driverDetailsView.isHidden = false
        //            buttonOpticity.isHidden = true
        //            buttonOpticity1.isHidden = true
        //            self.myMapBottomConstraint.constant = 349
        //        }
        
    }
    
    @IBAction func whatsAppBtnAction(_ sender: Any) {
        let driverName = driverName.text ?? ""
        let driverPhone = driverMobileNumber.text ?? ""
        let vehicleModel = vehicleModelString ?? ""
        let vehicleNumber = vehicleNumberString ?? ""
        let pickupLocation = current ?? ""
        let destinationLocation = destination ?? ""
        
        // Construct the message
        let message = """
            RIDE DETAILS
            ---------------------------
            Driver Details:
            \(driverName)
            \(driverPhone)
            
            Vehicle Details:
            \(vehicleNumber)
            
            Pickup Location:
            \(pickupLocation)
            
            Destination Location:
            \(destinationLocation)
            """
        
        // Encode the message for URL
        let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // Create WhatsApp URL
        let whatsappURL = "https://wa.me/?text=\(encodedMessage)"
        
        // Open WhatsApp if available
        if let url = URL(string: whatsappURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("WhatsApp is not installed on this device.")
        }
    }
    @IBAction func gmailBtnAction(_ sender: Any) {
        let driverName = driverName.text ?? ""
        let driverPhone = driverMobileNumber.text ?? ""
        let vehicleModel = vehicleModelString ?? ""
        let vehicleNumber = vehicleNumberString ?? ""
        let pickupLocation = current ?? ""
        let destinationLocation = destination ?? ""
        
        // Construct the message body
        let messageBody = """
        RIDE DETAILS
        ---------------------------
        Driver Details:
        \(driverName)
        \(driverPhone)
        
        Vehicle Details:
        \(vehicleModel)
        \(vehicleNumber)
        
        Pickup Location:
        \(pickupLocation)
        
        Destination Location:
        \(destinationLocation)
        """
        
        // Encode the message for URL
        let encodedMessageBody = messageBody.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // Create the mailto URL
        let email = "recipient@example.com" // Replace with the actual recipient email if needed
        let subject = "Driver and Vehicle Details"
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let gmailURL = "mailto:\(email)?subject=\(encodedSubject)&body=\(encodedMessageBody)"
        
        // Open Gmail or the default email app if available
        if let url = URL(string: gmailURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("No email client is available on this device.")
        }
    }
    @IBAction func facebookBtnAction(_ sender: Any) {
        let driverName = driverName.text ?? ""
        let driverPhone = driverMobileNumber.text ?? ""
        let vehicleModel = vehicleModelString ?? ""
        let vehicleNumber = vehicleNumberString ?? ""
        let pickupLocation = current ?? ""
        let destinationLocation = destination ?? ""
        
        // Construct the message body
        let messageBody = """
        RIDE DETAILS
        ---------------------------
        Driver Details:
        \(driverName)
        \(driverPhone)
        
        Vehicle Details:
        \(vehicleModel)
        \(vehicleNumber)
        
        Pickup Location:
        \(pickupLocation)
        
        Destination Location:
        \(destinationLocation)
        """
        
        // Encode the message for URL
        let encodedMessageBody = messageBody.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // Create Facebook Share URL
        let facebookURL = "https://www.facebook.com/sharer/sharer.php?u=\(encodedMessageBody)"
        
        // Open Facebook Share Dialog
        if let url = URL(string: facebookURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("No Facebook app is available on this device.")
        }
    }
    @IBAction func linksBtnAction(_ sender: Any) {
    }
    
    
    @IBAction func recenterBtnAction(_ sender: Any) {
        updateMapRegion()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        clear_GmapsAndTimer_Memory()
        stopAllTimers()
    }
    
    func stopAllTimers() {
        
        [apiTimer,
         startimer].forEach {
            $0?.invalidate()
            print("Timers-------- \($0?.timeInterval ?? 101)")
        }

        apiTimer = nil
        startimer = nil
    }
    
}



//MARK: API IMPLEMENTATION
extension RideStartedViewController {
    func getUpdatedLatLongFromDriver() {
        let url = AppConfig.baseURL+"Book/get_passanger_updated_latlong_of_drivers_while_riding"
        let params :  [String : Any] = [
            //            "fk_bookride_id": 169
            "fk_bookride_id": Int(UserDefaults.standard.string(forKey: "bookride_id") ?? "")
        ]
        print("getUpdatedLatLongFromDriver() -> url : \(url)")
        print("getUpdatedLatLongFromDriver() -> parameters : \(params)")
        let token = UserDefaults.standard.string(forKey: "auth_deviceToken") ?? ""

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        DispatchQueue.global(qos: .background).async {
            // Heavy processing here
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { [weak self] response in
                    guard let self = self else { return }
                    print("getUpdatedLatLongFromDriver() -> response : \(response)")
                    print("getUpdatedLatLongFromDriver  () -> response.result : \(response.result)")
                    self.isRequestInProgress = false
                    let statusCode = response.response?.statusCode
                    print("statusCode : \(statusCode)")
                    
                    switch response.result {
                        
                    case .success (let data) :
                        if let data = data {
                            do {
                                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                                   let loginResult = json["result"] as? [String: Any] {
                                    print("getUpdatedLatLongFromDriver() -> JSON -------\(json)")
                                    let status = loginResult["status"] as? String ?? ""
                                    let message = loginResult["message"] as? String ?? ""
                                    let ridelatlong = loginResult["ridelatlong"] as? [[String:Any]]
                                    
                                    print("getUpdatedLatLongFromDriver() -> STATUSSSS---- : \(status)")
                                    print("getUpdatedLatLongFromDriver() -> ridelatlong---- : \(ridelatlong)")
                                    if let ridelatlong = ridelatlong {
                                        for dict in ridelatlong {
                                            let fk_bookride_id = dict["fk_bookride_id"] as? Int
                                            let latitude = dict["latitude"] as? String
                                            let longitude = dict["longitude"] as? String
                                            var updated_sd_poliline_points = dict["sd_poliline_points"] as? String
                                            //                                            var doublelatitude = Double(latitude ?? "")
                                            //                                            var doublelongitude = Double(longitude ?? "")
                                            if isdpPolylinePointsobtainedfromDriverlocation == false {
                                                //                                                showPath(polyStr: dp_poliline_points ?? "")
                                                let coordinates = decodePolyline(sd_poliline_points ?? "")
                                                
                                                // Print the decoded coordinates
                                                for coordinate in coordinates {
                                                    print("driverapp : coordinates ::: Latitude: \(coordinate.latitude), Longitude: \(coordinate.longitude)")
                                                    //                                            let coordinateString = "\(coordinate.latitude),\(coordinate.longitude)"
                                                    polylinecoordinates.append(coordinate)
                                                }
                                                isdpPolylinePointsobtainedfromDriverlocation = true
                                            }
                                            if let latitudeStr = latitude, let longitudeStr = longitude,
                                               let doublelatitude = Double(latitudeStr), let doublelongitude = Double(longitudeStr) {
                                                currentLocationCoordinate = nil
                                                currentLocationCoordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
                                                //                                            mapView.clear()
                                                myMap.removeAnnotations(myMap.annotations)
                                                currentLocationCoordinate = CLLocationCoordinate2D(latitude: doublelatitude, longitude: doublelongitude)
                                                
                                                var distanceList = [Double]() // List to store distances for current iteration
                                                var allDistanceList = [Double]() // Master list to store all distance lists
                                                
                                                for i in 0..<polylinecoordinates.count {
                                                    let point = polylinecoordinates[i]
                                                    let distance = calculateDistance(latZero: doublelatitude, longZero: doublelongitude, lat: point.latitude, long: point.longitude)
                                                    print("List- Distance inside calculated: \(distance) m")
                                                    
                                                    distanceList.append(distance)
                                                }
                                                allDistanceList.append(contentsOf: distanceList)
                                                //                                        let distanceList1 = [23.0, 56.0, 12.0, 45.0, 67.0] // Example distances
                                                //                                        var polylineCoordinates = [
                                                //                                            CLLocationCoordinate2D(latitude: 37.7740, longitude: -122.4190),
                                                //                                            CLLocationCoordinate2D(latitude: 37.7745, longitude: -122.4192),
                                                //                                            CLLocationCoordinate2D(latitude: 37.7750, longitude: -122.4196),
                                                //                                            CLLocationCoordinate2D(latitude: 37.7755, longitude: -122.4198),
                                                //                                            CLLocationCoordinate2D(latitude: 37.7760, longitude: -122.4200)
                                                //                                        ]
                                                let result = clearRecordsBeforeMinimum(distanceList: allDistanceList, polylineCoordinates: polylinecoordinates)
                                                print("Updated Distance List: \(result.0)")
                                                print("Updated Polyline Coordinates: \(result.1)")
                                                polylinecoordinates = result.1
//                                                DispatchQueue.global(qos: .background).async {
                                                DispatchQueue.main.async { [weak self] in
                                                    guard let self = self else { return }
                                                    do {
                                                        if self.polylinecoordinates.count >= 2 {
                                                            // Find the minimum value and its index
                                                            let minIndex = try findMinIndex(list: allDistanceList)
                                                            let minDistanceValue = allDistanceList[minIndex]
                                                            
                                                            // Check if the minimum distance value is less than or equal to 15
                                                            if minDistanceValue <= 15.0 {
                                                                polylinecoordinates.remove(at: 0)
                                                                currentToRoadDottedPolyline?.map = nil
                                                                destinationDottedPolyline?.map = nil
                                                                dottedPathFromCurrentLocation.removeAllCoordinates()
                                                                dottedPathToDestination.removeAllCoordinates()
                                                                roadPolyline = nil
                                                                roadPolyline?.map = nil
                                                                mapView.clear()
                                                                //                                                removeElementsBeforeIndex(coordinatesList: &polylinecoordinates, index: minIndex)
                                                                //                                                encodePolyline(polylinecoordinates)
                                                                //                                                showPath1(polylineCoordinates: polylinecoordinates)
                                                                //                                                for coordinate in polylinecoordinates {
                                                                //                                                    print("path : \(path)")
                                                                //                                                    path.add(coordinate)
                                                                //                                                }
                                                                //                                                roadPolyline = GMSPolyline(path: path)
                                                                //                                                roadPolyline?.strokeColor = UIColor(red: 95/255, green: 102/255, blue: 118/255, alpha: 1)
                                                                //                                                roadPolyline?.strokeWidth = 5.0
                                                                //                                                roadPolyline?.map = mapView
                                                                showPath1(polylineCoordinates: polylinecoordinates)
                                                            }
                                                            
                                                            if rideStatus == "driverApproachingTowardsPassengerPending" || rideStatus == "tappedNotifcationBanner" {
                                                                destinationLocationCoordinate = destinationLocationCoordinate
                                                            }
                                                            else {
                                                                //                                                        destinationLocationCoordinate = passengercooordinates
                                                            }
                                                            DispatchQueue.main.async { [weak self] in
                                                                guard let self = self else { return }
                                                                currentMarker?.map = nil
                                                                print("locationManager.location?.speed : \(locationManager.location?.speed)")
                                                                print("locationManager.location?.speedAccuracy : \(locationManager.location?.speedAccuracy)")
                                                                self.addCustomMarkers()
                                                                if moveCamera == false {
                                                                    print("kdnfkdngkjdsnfnkdnvjkf=========")
                                                                    self.updateMapRegion()
                                                                }
                                                            }
                                                        } else {
                                                            DispatchQueue.main.async { [weak self] in
                                                                guard let self = self else { return }
                                                                currentMarker?.map = nil
                                                                    self.addCustomMarkers()
                                                                    if moveCamera == false {
                                                                        print("kdnfkdngkjdsnfnkdnvjkf=========")
                                                                        self.updateMapRegion()
                                                                }
                                                            }
                                                        }
                                                    } catch {
                                                        let alertController = UIAlertController(title: "Network Error", message: "", preferredStyle: .alert)
                                                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                                        alertController.addAction(okAction)
                                                        self.present(alertController, animated: true, completion: nil)
                                                    }
                                                }
                                                
                                                //                                            var speed = locationManager.location?.speed as? String
                                                //                                            let alertController = UIAlertController(title: speed, message: "", preferredStyle: .alert)
                                                //
                                                //                                            // Present the alert controller
                                                //                                            self.present(alertController, animated: true) {
                                                //                                                // Dismiss the alert after 5 seconds
                                                //                                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                                //                                                    alertController.dismiss(animated: true, completion: nil)
                                                //                                                }
                                                //                                            }
                                                //                                            if let speed = locationManager.location?.speed {
                                                //                                                let speedString = String(format: "%.2f", speed) // Format the speed as a string with 2 decimal places
                                                //                                                if speedString > "0.0" {
                                                //                                                    let alertController = UIAlertController(title: "Speed: \(speedString) m/s", message: "", preferredStyle: .alert)
                                                //
                                                //                                                    // Present the alert controller
                                                //                                                    self.present(alertController, animated: true) {
                                                //                                                        // Dismiss the alert after 2 seconds
                                                //                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                                //                                                            alertController.dismiss(animated: true, completion: nil)
                                                //                                                        }
                                                //                                                    }
                                                //                                                }
                                                //                                            }
                                                
                                                //                                            self.addCustomMarkers()
                                                //                                            if moveCamera == false {
                                                //                                                self.updateMapRegion()
                                                //                                                //                                                self.calculateRoute()
                                                ////                                                showPath(polyStr: sd_poliline_points ?? "")
                                                //                                            }
                                                //                                    locationTxts()
                                            }
                                        }
                                    }
                                } else {
                                }
                            } catch {
                                let alertController = UIAlertController(title: "Network Error", message: "", preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alertController.addAction(okAction)
                                self.present(alertController, animated: true, completion: nil)
                            }
                        }
                    case .failure(let error):
                        print("Request failed with error: \(error)")
                    }
                }
            }
        }
    }
    
    func cancelRide() {
        let url = AppConfig.baseURL+"Book/Cancel_ride_driver"
        let params :  [String : Any] = [
            //            "fk_bookride_id": 6
            "fk_bookride_id": pk_bookride_id,
            "reason_for_cancle": cancelRideReasonTxtField.text
        ]
        print("cancelRide() -> url : \(url)")
        print("cancelRide() -> parameters : \(params)")
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
                            //                        if status == "-1" {
                            //                            self.currentToDestinationMainView.isHidden=true
                            //                            self.progressBGView.isHidden = true
                            //                            self.driverDetailsView.isHidden = true
                            //                            self.noDriverFound.isHidden = false
                            //                            NSLayoutConstraint.activate([self.mapView.bottomAnchor.constraint(equalTo: self.noDriverFound.topAnchor, constant: 0)])
                            //                        } else {
                            if status == "0" {
                                TimerManager.shared.stopAllTimers()
                                UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
                                    DispatchQueue.main.async { [weak self] in
                                        guard let self = self else { return }
                                        //                                                                loaderActivity1.stopAnimating()
                                        //                                                                loaderActivity1.isHidden = true
                                        buttonOpticity.isHidden = true
                                        shareView.isHidden = true
                                        self.cancelRideView.isHidden = true
                                        myMapBottomConstraint.constant = 0
                                        self.buttonOpticity.isHidden = false
                                        self.rideCancelledSuccessfullyImg.isHidden = false
                                        
                                        
                                        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { [weak self] _ in
//                                                if let enabledVC = self?.storyboard?.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController {
//                                                    apiTimer = nil
//                                                    apiTimer?.invalidate()
//                                                    enabledVC.member_master_profile_id = Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "")
//                                                    self?.navigationController?.pushViewController(enabledVC, animated: true)
//                                                }
                                                var memberID = Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "")
                                            
                                            
                                            let mapVC = self?.storyboard?.instantiateViewController(identifier: "MapViewController") as! MapViewController
                                            mapVC.member_master_profile_id = self?.member_master_profile_id
                                            self?.navigationController?.pushViewController(mapVC, animated: true)
//                                                DispatchQueue.main.async { [weak self] in
//                                                    guard let self = self else { return }
//                                                    if let viewControllers = self.navigationController?.viewControllers {
//                                                        for vc in viewControllers {
//                                                            if vc is MapViewController {
//                                                                self.apiTimer = nil
//                                                                self.apiTimer?.invalidate()
//                                                                self.PopBackViewControllerDelegate?.dataPassBack(memberID: memberID)
//                                                                self.navigationController?.popToViewController(vc, animated: true)
//                                                                break
//                                                            }
//                                                        }
//                                                    }
//                                                }
                                        }
                                    }
                                }
                                
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
                    
                }
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    func endRide() {
        let url = AppConfig.baseURL+"Book/Trip_end_flag_from_driver"
        let params :  [String : Any] = [
            //            "fk_bookride_id": 169
            "fk_bookride_id": Int(UserDefaults.standard.string(forKey: "bookride_id") ?? "")
        ]
        print("endRide() -> url : \(url)")
        print("endRide() -> parameters : \(params)")
        let token = UserDefaults.standard.string(forKey: "auth_deviceToken") ?? ""

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { [weak self] response in
            guard let self = self else { return }
            print("endRide() -> response : \(response)")
            print("endRide() -> response.result : \(response.result)")
            let statusCode = response.response?.statusCode
            print("statusCode : \(statusCode)")
            
            switch response.result {
                
            case .success (let data) :
                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let loginResult = json["result"] as? [String: Any] {
                            print("endRide() -> JSON -------\(json)")
                            let status = loginResult["status"] as? String ?? ""
                            let message = loginResult["message"] as? String ?? ""
                            let ride = loginResult["ride"] as? String ?? ""
                            let pickupamout = loginResult["pickupamout"] as? Int
                            let fareAmount = loginResult["fareAmount"] as? Int
                            let totalAmout = loginResult["totalAmout"] as? Int
                            let vehicleTypeID = loginResult["vehicle_type_id"] as? Int
                            print("endRide() -> STATUSSSS---- : \(status)")
                            //                            if ride == "End" || status == "0" {
                            //                                if let currentTimer = startimer {
                            //                                            print("Timer exists. Invalidating timer and stopping the ride confirmation.")
                            //                                            currentTimer.invalidate()
                            //                                    startimer?.invalidate()
                            //                                    startimer = nil
                            //
                            //                                            // Navigate to EndTripViewController after invalidating the timer
                            //                                            if let enabledVC = self.storyboard?.instantiateViewController(withIdentifier: "EndTripViewController") as? EndTripViewController {
                            //                                                enabledVC.startimer = startimer
                            //                                                self.navigationController?.pushViewController(enabledVC, animated: true)
                            //                                            }
                            //                                        } else {
                            //
                            //                                            startimer?.invalidate()
                            //                                            startimer = nil
                            //                                            print("Timer is already invalidated.")
                            //                                        }
                            //                            }
                            if (ride == "End" || status == "0") {
                                var hasNavigatedToEndTrip = false
                                if let currentTimer = startimer {
                                    print("Timer exists. Invalidating timer and stopping the ride confirmation.")
                                    currentTimer.invalidate()
                                    startimer?.invalidate()
                                    startimer = nil
                                    
                                    // Navigate to EndTripViewController only if not already navigated
                                    if !hasNavigatedToEndTrip {
                                        hasNavigatedToEndTrip = true // Set flag to true to prevent multiple navigations
                                        TimerManager.shared.stopAllTimers()
                                        if let enabledVC = self.storyboard?.instantiateViewController(withIdentifier: "EndTripViewController") as? EndTripViewController {
                                            apiTimer = nil
                                            apiTimer?.invalidate()
                                            enabledVC.startimer = startimer
                                            enabledVC.pickupamout = pickupamout
                                            enabledVC.fareAmount = fareAmount
                                            enabledVC.totalAmout = totalAmout
                                            enabledVC.vehicle_type_id = vehicleTypeID
                                            enabledVC.member_master_profile_id = member_master_profile_id
                                            self.navigationController?.pushViewController(enabledVC, animated: true)
                                        }
                                    }
                                    
                                } else {
                                    startimer?.invalidate()
                                    startimer = nil
                                    print("Timer is already invalidated.")
                                    
                                    // Check for navigation if timer is already invalidated
                                    //                                    if !hasNavigatedToEndTrip {
                                    //                                        hasNavigatedToEndTrip = true
                                    //                                        if let enabledVC = self.storyboard?.instantiateViewController(withIdentifier: "EndTripViewController") as? EndTripViewController {
                                    //                                            enabledVC.startimer = startimer
                                    //                                            self.navigationController?.pushViewController(enabledVC, animated: true)
                                    //                                        }
                                    //                                    }
                                }
                            }else {
                                
                            }
                        } else {
                        }
                    } catch {
                        let alertController = UIAlertController(title: "Network Error", message: "", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    func pendingRide() {
        let url = AppConfig.baseURL+"Book/get_PendingRide"
        let params :  [String : Any] = [
            //            "fk_bookride_id": 169
            "fk_member_master_profile_id": member_master_profile_id
        ]
        print("pendingRide() -> url : \(url)")
        print("pendingRide() -> parameters : \(params)")
        let token = UserDefaults.standard.string(forKey: "auth_deviceToken") ?? ""

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { [weak self] response in
            guard let self = self else { return }
            print("pendingRide() -> response : \(response)")
            print("pendingRide() -> response.result : \(response.result)")
            let statusCode = response.response?.statusCode
            print("statusCode : \(statusCode)")
            
            switch response.result {
                
            case .success (let data) :
                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let loginResult = json["result"] as? [String: Any] {
                            print("pendingRide() -> JSON -------\(json)")
                            let status = loginResult["status"] as? String ?? ""
                            let message = loginResult["message"] as? String ?? ""
                            if status == "0" && message == "OK"{
                                let output = loginResult["output"] as? [[String: Any]]
                                print("pendingRide() -> output---- : \(output)")
                                if let output = output as? [String: Any] {
                                    pk_bookride_id = output["bookingid"] as? Int
                                    var destLAT = output["latitudes_destination"] as? String ?? ""
                                    var destLong = output["longitudes_destination"] as? String ?? ""
                                    destinationLocationCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(destLAT) ?? 0.0, longitude: CLLocationDegrees(destLong) ?? 0.0)
                                    vehicleNumberString = output["vehicle_Number"] as? String ?? ""
                                    vehicleModelString = output["vehicle_Model"] as? String ?? ""
                                    driverNameString = output["driverName"] as? String ?? ""
                                    driverMobileNumberString = output["driver_Mobile_Number"] as? String ?? ""
                                    rideStatusStarted()
                                }
                                
                            }
                        } else {
                        }
                    } catch {
                        let alertController = UIAlertController(title: "Network Error", message: "", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
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
            print("RideStartedViewController() -> sessionTimeOut() -> url : \(url)")
            print("RideStartedViewController() -> sessionTimeOut() -> params : \(params)")
            AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { [weak self] response in
                guard let self = self else { return }
                print("recentSearchList() -> response : \(response.result)")
                switch response.result {
                case .success (let data) :
                    if let data = data {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                               let loginResult = json["result"] as? [String: Any] {
                                print("RideStartedViewController() -> sessionTimeOut() -> JSON -------\(json)")
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
                                        
                                        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                                            guard let self = self else { return }
//                                            let otpVC = storyboard?.instantiateViewController(identifier: "LoginRegisterViewController") as! LoginRegisterViewController
                                            member_master_profile_id = nil
                                            UserDefaults.standard.setValue(member_master_profile_id, forKey: "fk_member_master_profile_id")
//                                            self.navigationController?.pushViewController(otpVC, animated: false)
                                            
                                            let otpVC = self.storyboard?.instantiateViewController(identifier: "LoginRegisterViewController") as! LoginRegisterViewController
                                            let navController = UINavigationController(rootViewController: otpVC)

                                            DispatchQueue.main.async {

                                                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                                                    sceneDelegate.window?.rootViewController = navController
                                                    sceneDelegate.window?.makeKeyAndVisible()
                                                }
                                            }
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
                                        
                                        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                                            guard let self = self else { return }
//                                            let otpVC = storyboard?.instantiateViewController(identifier: "LoginRegisterViewController") as! LoginRegisterViewController
                                            member_master_profile_id = nil
                                            UserDefaults.standard.setValue(member_master_profile_id, forKey: "fk_member_master_profile_id")
//                                            self.navigationController?.pushViewController(otpVC, animated: false)
                                            
                                            let otpVC = self.storyboard?.instantiateViewController(identifier: "LoginRegisterViewController") as! LoginRegisterViewController
                                            let navController = UINavigationController(rootViewController: otpVC)

                                            DispatchQueue.main.async {

                                                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                                                    sceneDelegate.window?.rootViewController = navController
                                                    sceneDelegate.window?.makeKeyAndVisible()
                                                }
                                            }
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
}


extension RideStartedViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text?.count ?? 0 > 0 {
            cancelRideReasonTxtField.layer.borderColor = UIColor.black.cgColor // Set border color
            cancelRideReasonTxtField.layer.borderWidth = 2.0                 // Set border width
            cancelRideReasonTxtField.layer.cornerRadius = 5.0               // Optional: Add rounded corners
            cancelRideReasonTxtField.clipsToBounds = true
            cancelRideReasonMandatoryLBL.isHidden = true
        }
        return true
    }
}

