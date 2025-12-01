//
//  BookACabViewController.swift
//  yatriMitra
//
//  Created by Kaizen Infotech Solutions Private Limited. on 14/06/24.
//

import UIKit
import MapKit
import GoogleMaps
import Alamofire
import CoreImage
import CoreLocation


protocol TextFieldResponder: AnyObject {
    func currentTFResponder()
    func destinationTFResponder()
}

protocol PopBack: AnyObject {
    func goToBack(current: String?, dest: String?, curreCoordinate: CLLocationCoordinate2D?, destCoordinate: CLLocationCoordinate2D?, profileID: Int?)
}

protocol PopBackTo: AnyObject {
    func goToBackDest(current: String?, dest: String?, curreCoordinate: CLLocationCoordinate2D?, destCoordinate: CLLocationCoordinate2D?, profileID: Int?, locUnservice: String?)
}


class BookACabViewController: UIViewController, MKMapViewDelegate, CancelRide, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var pleasePayAsPerMeterView: UIView!
    @IBOutlet weak var loaderActivity: UIActivityIndicatorView!
    @IBOutlet weak var loaderActivity1: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bookBtn: UIButton!
    @IBOutlet weak var currentToDestinationMainView: UIView!
    @IBOutlet weak var currentLocationTxtField: UITextField!
    @IBOutlet weak var destinationLocationTxtField: UITextField!
    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet weak var currentToDestinationMainViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var currentToDestinationView: UIView!
    @IBOutlet weak var myMapBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var yourRideConfirmLbl: UILabel!
    
    //MARK: Progress BG UIView
    @IBOutlet weak var progressBGView: UIView!
    @IBOutlet weak var cancelBtnWhileSearching: UIButton!
    @IBOutlet weak var whileSearchingRideOption: UIButton!
    @IBOutlet weak var labelTollandParking: UILabel!
    //    @IBOutlet weak var labelRequest: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    //MARK: CANCEL RIDE VIEW
    @IBOutlet weak var submitCancelRideBtn: UIButton!
    @IBOutlet weak var cancelRideView: UIView!
    
    @IBOutlet weak var cancelRidBtn: UIButton!
    //MARK: SHARE AND CANCEL RIDE VIEW
    @IBOutlet weak var shareNcancelRideView: UIView!
    @IBOutlet weak var driverCountLbl: UILabel!
    
    //MARK: RIDE CONFIRM OUTLETS
    @IBOutlet weak var driverDetailsView: UIView!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var mobLBL: UILabel!
    @IBOutlet weak var driverPic: UIImageView!
    @IBOutlet weak var driverName: UILabel!
    @IBOutlet weak var vehicleName: UILabel!
    @IBOutlet weak var vehicleNo: UILabel!
    @IBOutlet weak var otpView: UIView!
    @IBOutlet weak var automobileImg: UIImageView!
    @IBOutlet weak var shareBGView: UIView!
    @IBOutlet weak var cancelReasonView: UIView!
    @IBOutlet weak var shareCancelButton: UIButton!
    @IBOutlet weak var otpLbl: UILabel!
    @IBOutlet weak var callView: UIView!
    
    
    //MARK: CANCEL RIDE REASONS VIEW OUTLETS
    @IBOutlet weak var driverTakingTooLongView: UIView!
    @IBOutlet weak var rideAmountTooHigh: UIView!
    @IBOutlet weak var bookMyMistake: UIView!
    
    @IBOutlet weak var buttonOpticity: UIButton!
    @IBOutlet weak var rideCancelledSuccessfullyImg: UIImageView!
    @IBOutlet weak var noDriverFound: UIView!
    
    @IBOutlet weak var buttonOpticity1: UIButton!
    //MARK: NO DRIVER FOUND VIEW OUTLETS
    @IBOutlet weak var noDriverFoundOKbtn: UIButton!
    
    //MARK: PROTOCOL
    weak var PopBackDelegate: PopBack?
    weak var PopBackToDelegate: PopBackTo?
    
    var minutesFromAPI: Int?
    var driverApproachingUserTiming: String?
    var isshareNcancelRideBtnClicked = false
    var iOSversion: String?
    var apiTimer : Timer?
    var member_master_profile_id : Int?
    var mapView: GMSMapView!
    var mainLat : CLLocationDegrees?
    var mainLong : CLLocationDegrees?
    let locationManager = CLLocationManager()
    let geoCoder = CLGeocoder()
    weak var textFieldResponderDelegate: TextFieldResponder?
    var progressBarTimer: Timer?
    var rideConfirmTimer: Timer?
    var driverAPICallTimer: Timer?
    var pinRideCancelledDriverApproachingAPICallTimer: Timer?
    var bookRideAndTimeSloteWiseAPICallTimer: Timer?
    var currentLoc:String?
    var destinationLoc:String?
    var currentLocationSendToRideStartedVC:String?
    var destinationLocationSendToRideStartedVC:String?
    var currentLocationCoordinate: CLLocationCoordinate2D?
    var destinationLocationCoordinate: CLLocationCoordinate2D?
    var newCurrentLocationCoordinate: CLLocationCoordinate2D?
    var newDestinationLocationCoordinate: CLLocationCoordinate2D?
    var currentlocationcooordination: CLLocationCoordinate2D? = nil
    var destinationlocationcooordination: CLLocationCoordinate2D?
    var destinationlocationcooordinationafterGettingDriveDetails: CLLocationCoordinate2D?
    var drivercoordinates: CLLocationCoordinate2D?
    var passengercooordinates: CLLocationCoordinate2D?
    var passengercooordinatesafterSearchContinues: CLLocationCoordinate2D?
    var rideExpInMins = ["1 min", "1 min", "2 min"]
    var rideTypeLbl : [String] = []
    //    var rideTypeLbl : [String] = ["Rickshaw", "Non-AC Taxi", "AC Taxi"]
    var rideFareLbl : [Int] = []
    //    var rideFareLbl : [Int] = [354, 430, 433]
    var rideTypeImg = [UIImage(named: "autoRickshaw"),UIImage(named: "non-ac-taxi"),UIImage(named: "ac-Taxi")]
    var distance : Float?
    var distanceforsearchdriver : Int?
    var vehicleTypeID : Int?
    var totalTime : String?
    var firstTime : String?
    var startTime : [String] = []
    var distanceFromGetTimings : [Int] = []
    var pk_bookride_id : Int?
    var timeslot_pk_bookride_id : Int?
    var rideFare : Int?
    var analyticsRideFare : Int?
    var rideCancelReason : String?
    var hasNavigatedToRideStarted = false
    var cancelBtnIsCalledFrom : String = ""
    var recentSearches: [String] = []
    var address:String?
    var isDriverTakingTooLongSelected = false
    var isRideAmountTooHighSelected = false
    var isBookMyMistakeSelected = false
    var pinMatched: String?
    var arrowMarker: GMSMarker?
    var base64String: String? = nil
    var pkbookrideid : Int?
    var loader = UIActivityIndicatorView(style: .medium)
    var roadPolyline : GMSPolyline?
    var currentMarker: GMSMarker?
    var destinationMarker: GMSMarker?
    var moveCamera : Bool = false
    var isZoomForFirstTime : Bool = false
    var lastClickTime: CFTimeInterval = 0
    var currentToRoadDottedPolyline : GMSPolyline?
    var destinationDottedPolyline : GMSPolyline?
    let dottedPathFromCurrentLocation = GMSMutablePath()
    let dottedPathToDestination = GMSMutablePath()
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    var isRouteLoadedOnce = false
    var driver_profile_id : Int?
    var sd_poliline_points : String?
    var routMap_photo : String?
    var ascDIS : [Double] = []
    var isdpPolylinePointsobtainedfromDriverlocation = false
    var noDriverFoundViewBool = false
    var bookBtnTitle: String?
    
    
    // Opened application after termination
    var rideStatus : String?
    var vehicleNumberString:String?
    var vehicleModelString:String?
    var driverNameString:String?
    var driverMobileNumberString:String?
    var otpInt:Int?
    var driver_Photo_afterAppTermination: String?
    var vehicle_Photo_afterAppTermination: String?
    var pickup_latitude: String?
    var pickup_longitude: String?
    var destination_latitude: String?
    var destination_longitude: String?
    var driver_current_latitude: String?
    var driver_current_longitude: String?
    var dp_poliline_points: String?
    var sourcePlaceName: String?
    var destinationPlaceName: String?
    //    var currentLocationCoordinate: CLLocationCoordinate2D?
    //    var currentLocationCoordinate: CLLocationCoordinate2D?
    var currentPolyline: GMSPolyline?
    var farelist : [[String: Any]] = []
    var durationsreached2mins = false
    var durationsreached1min = false
    var polylinecoordinates : [CLLocationCoordinate2D] = []
    var secondsElapsed: Int = 0
    
    var isProgressCancelRide = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pleasePayAsPerMeterView.layer.cornerRadius = 12
        pleasePayAsPerMeterView.layer.masksToBounds = true
        pleasePayAsPerMeterView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        driverCountLbl.isHidden = true
        whileSearchingRideOption.isHidden = true
        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 10.0)
        mapView = GMSMapView.map(withFrame: self.myMap.bounds, camera: camera)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.myMap.addSubview(mapView)
        mapView.delegate = self
        myMap.delegate=self
        mapView.isMyLocationEnabled = true
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleForceUpdate),
                                               name: .forceUpdate,
                                               object: nil)
        self.driverPic.layer.cornerRadius = self.driverPic.frame.size.width / 2
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(callViewTapped))
        callView.addGestureRecognizer(tapGesture)
        callView.isUserInteractionEnabled = true
        mapView.isMyLocationEnabled = false
        callView.layer.cornerRadius = 10
        callView.layer.shadowOpacity = 0.3
        callView.layer.shadowOffset = CGSize(width: 5, height: 5)
        callView.layer.shadowRadius = 5
        callView.layer.borderColor = UIColor.systemGray4.cgColor
        callView.layer.borderWidth = 1
        cancelRidBtn.layer.cornerRadius = 10
        cancelRidBtn.isUserInteractionEnabled = true
        cancelRidBtn.superview?.isUserInteractionEnabled = true
        cancelRidBtn.translatesAutoresizingMaskIntoConstraints = false
        if let apiTimer = apiTimer {
            TimerManager.shared.registerTimer(apiTimer)
        }
        //        apiTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(sessionTimeOut), userInfo: nil, repeats: true)
        apiTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.sessionTimeOut()
        }
        if rideStatus == "searchingRideContinued"  {
            if let progressBarTimer = progressBarTimer {
                TimerManager.shared.registerTimer(progressBarTimer)
            }
            if let rideConfirmTimer = rideConfirmTimer {
                TimerManager.shared.registerTimer(rideConfirmTimer)
            }
            if let driverAPICallTimer = driverAPICallTimer {
                TimerManager.shared.registerTimer(driverAPICallTimer)
            }
            if let pinRideCancelledDriverApproachingAPICallTimer = pinRideCancelledDriverApproachingAPICallTimer {
                TimerManager.shared.registerTimer(pinRideCancelledDriverApproachingAPICallTimer)
            }
            if let bookRideAndTimeSloteWiseAPICallTimer = bookRideAndTimeSloteWiseAPICallTimer {
                TimerManager.shared.registerTimer(bookRideAndTimeSloteWiseAPICallTimer)
            }
            timeslot_pk_bookride_id = pkbookrideid
            totalTime = "0.0"
            getTimings()
            currentLoc = sourcePlaceName
            destinationLoc = destinationPlaceName
            currentLocationTxtField.text = sourcePlaceName
            destinationLocationTxtField.text = destinationPlaceName
            currentLocationCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(pickup_latitude!)!, longitude: CLLocationDegrees(pickup_longitude!)!)
            currentlocationcooordination = CLLocationCoordinate2D(latitude: CLLocationDegrees(pickup_latitude!)!, longitude: CLLocationDegrees(pickup_longitude!)!)
            destinationLocationCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(destination_latitude!)!, longitude: CLLocationDegrees(destination_longitude!)!)
            destinationlocationcooordination = CLLocationCoordinate2D(latitude: CLLocationDegrees(destination_latitude!)!, longitude: CLLocationDegrees(destination_longitude!)!)
            passengercooordinatesafterSearchContinues = currentLocationCoordinate
            driverDetailsView.isHidden = true
            noDriverFound.isHidden = true
            shareNcancelRideView.isHidden = true
            shareBGView.isHidden = true
            cancelReasonView.isHidden = true
            loaderActivity.startAnimating()
            loaderActivity1.isHidden = true
            cancelRideView.isHidden = true
            buttonOpticity.isHidden = true
            buttonOpticity1.isHidden = true
            NetworkMonitor.shared
            rideCancelledSuccessfullyImg.isHidden = true
            submitCancelRideBtn.layer.cornerRadius = 10
            currentToDestinationView.layer.cornerRadius=10
            currentToDestinationView.layer.shadowOpacity = 0.5 // Adjust opacity to your preference
            currentToDestinationView.layer.shadowOffset = CGSize(width: 3, height: 3) // Bottom and right offset
            currentToDestinationView.layer.shadowRadius = 5 // Adjust radius to your preference
            cancelRideView.roundCorners([.topLeft, .topRight], radius: 20)
            shareNcancelRideView.roundCorners([.topLeft, .topRight], radius: 20)
            cancelReasonView.roundCorners([.topLeft, .topRight], radius: 20)
            locationManager.delegate = self
            addCustomMarkers()
            if moveCamera == false {
                self.updateMapRegion()
                moveCamera = false
            }
            NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
            print("sp_poliline_points1 : \(sd_poliline_points)")
            showPath(polyStr: sd_poliline_points ?? "")
            showProgressView()
            startProgressView1()
        }
        else if rideStatus == "driverApproachingTowardsPassengerPending" || rideStatus == "tappedNotifcationBanner" {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            progressBGView = nil
            noDriverFound = nil
            if let rideConfirmTimer = rideConfirmTimer {
                TimerManager.shared.registerTimer(rideConfirmTimer)
            }
            if let driverAPICallTimer = driverAPICallTimer {
                TimerManager.shared.registerTimer(driverAPICallTimer)
            }
            if let pinRideCancelledDriverApproachingAPICallTimer = pinRideCancelledDriverApproachingAPICallTimer {
                TimerManager.shared.registerTimer(pinRideCancelledDriverApproachingAPICallTimer)
            }
            if let bookRideAndTimeSloteWiseAPICallTimer = bookRideAndTimeSloteWiseAPICallTimer {
                TimerManager.shared.registerTimer(bookRideAndTimeSloteWiseAPICallTimer)
            }
            cancelBtnIsCalledFrom = "After Driver Accepted the Ride"
            pkbookrideid = pk_bookride_id
            vehicleNo.text = vehicleNumberString
            vehicleName.text = vehicleModelString
            driverName.text = driverNameString
            mobLBL.text = driverMobileNumberString
            currentLocationTxtField.text = sourcePlaceName
            destinationLocationTxtField.text = destinationPlaceName
            //MARK: Not Yet Live API Done
            print("MINUTES FROM API : \(self.minutesFromAPI)")
            if let pickupDuration = self.minutesFromAPI {
                timeFormatChanging(approachTiming: pickupDuration)
            }
            if let driverProfilePic = driver_Photo_afterAppTermination {
                
                // Trim any extra spaces and replace backslashes with forward slashes
                let correctedDriverProfilePic = driverProfilePic.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\\", with: "/")
                
                print("Corrected Driver Profile Pic URL after the app is terminated : \(correctedDriverProfilePic)")  // Debugging line
                
                loadImage(from: correctedDriverProfilePic, into: driverPic)
            } else {
                print("Driver profile photo string is nil or not a valid string after the app is terminated.")
                self.driverPic.image = UIImage(named: "Mask group")
            }
            if let imageUrlString = vehicle_Photo_afterAppTermination{
                let correctedDriverProfilePic = imageUrlString.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\\", with: "/")
                
                print("Corrected Vehicle Pic URL after the app is terminated : \(correctedDriverProfilePic)")
                print("Attempting to load image from URL: \(imageUrlString)")
                loadImage(from: correctedDriverProfilePic, into: automobileImg)
            }else {
                print("Invalid image URL string after the app is terminated.")
            }
            if let otpInt = otpInt {
                otpLbl.text = String(otpInt)
            }
            
            
            currentLocationCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(driver_current_latitude!)!, longitude: CLLocationDegrees(driver_current_longitude!)!)
            destinationLocationCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(pickup_latitude!)!, longitude: CLLocationDegrees(pickup_longitude!)!)
            destinationlocationcooordination = CLLocationCoordinate2D(latitude: CLLocationDegrees(destination_latitude!)!, longitude: CLLocationDegrees(destination_longitude!)!)
            self.myMapBottomConstraint.constant = 300
            currentToDestinationMainView.isHidden  = true
            loaderActivity1.isHidden = true
            buttonOpticity.isHidden = true
            buttonOpticity1.isHidden = true
            cancelReasonView.isHidden = true
            cancelRideView.isHidden = true
            shareBGView.isHidden = true
            shareNcancelRideView.isHidden = true
            rideCancelledSuccessfullyImg.isHidden = true
            otpView.isHidden = false
            driverDetailsView.isHidden = false
            self.addCustomMarkers()
            self.calculateRoute()
            if moveCamera == false {
                self.updateMapRegion()
            }
            startProgressView2()
        } else {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            if let progressBarTimer = progressBarTimer {
                TimerManager.shared.registerTimer(progressBarTimer)
            }
            if let rideConfirmTimer = rideConfirmTimer {
                TimerManager.shared.registerTimer(rideConfirmTimer)
            }
            if let driverAPICallTimer = driverAPICallTimer {
                TimerManager.shared.registerTimer(driverAPICallTimer)
            }
            if let pinRideCancelledDriverApproachingAPICallTimer = pinRideCancelledDriverApproachingAPICallTimer {
                TimerManager.shared.registerTimer(pinRideCancelledDriverApproachingAPICallTimer)
            }
            if let bookRideAndTimeSloteWiseAPICallTimer = bookRideAndTimeSloteWiseAPICallTimer {
                TimerManager.shared.registerTimer(bookRideAndTimeSloteWiseAPICallTimer)
            }
            
            currentLocationTxtField.delegate = self
            destinationLocationTxtField.delegate = self
            locationManager.delegate = self
            createNavigationBar()
            base64String = ""
            base64String = nil
            print("currentlocationcooordination : \(currentlocationcooordination)")
            //        if let currloc = currentLoc, let commaIndex = currloc.firstIndex(of: ",") {
            //            currentLoc = String(currloc[..<commaIndex])
            //        } else {
            //            currentLoc = nil // or handle the case where there's no comma
            //        }
            //        if let destloc = destinationLoc, let commaIndex = destloc.firstIndex(of: ",") {
            //            destinationLoc = String(destloc[..<commaIndex])
            //        } else {
            //            destinationLoc = nil // or handle the case where there's no comma
            //        }
            print("currentLoc : \(currentLoc)")
            print("destinationLoc : \(destinationLoc)")
            currentLocationTxtField.text = currentLoc
            destinationLocationTxtField.text = destinationLoc
            currentLocationSendToRideStartedVC = currentLoc
            destinationLocationSendToRideStartedVC = destinationLoc
            driverDetailsView.isHidden = true
            noDriverFound.isHidden = true
            shareNcancelRideView.isHidden = true
            shareBGView.isHidden = true
            cancelReasonView.isHidden = true
            loaderActivity.startAnimating()
            loaderActivity1.isHidden = true
            cancelRideView.isHidden = true
            NetworkMonitor.shared
            submitCancelRideBtn.layer.cornerRadius = 10
            currentToDestinationView.layer.cornerRadius=10
            currentToDestinationView.layer.shadowOpacity = 0.5 // Adjust opacity to your preference
            currentToDestinationView.layer.shadowOffset = CGSize(width: 3, height: 3) // Bottom and right offset
            currentToDestinationView.layer.shadowRadius = 5 // Adjust radius to your preference
            cancelRideView.roundCorners([.topLeft, .topRight], radius: 20)
            shareNcancelRideView.roundCorners([.topLeft, .topRight], radius: 20)
            cancelReasonView.roundCorners([.topLeft, .topRight], radius: 20)
            
            currentLocationTxtField.text = currentLoc
            destinationLocationTxtField.text = destinationLoc
            print("BookACabViewController -> currentlocationcooordination : \(currentlocationcooordination)")
            print("BookACabViewController -> destinationlocationcooordination : \(destinationlocationcooordination)")
            currentLocationCoordinate = currentlocationcooordination
            destinationLocationCoordinate = destinationlocationcooordination
            print("currentLocationCoordinate : \(currentLocationCoordinate)")
            print("destinationLocationCoordinate : \(destinationLocationCoordinate)")
            destinationlocationcooordinationafterGettingDriveDetails = currentlocationcooordination
            newDestinationLocationCoordinate = destinationlocationcooordination
            print("BookACabViewController -> destinationlocationcooordinationafterGettingDriveDetails : \(destinationlocationcooordinationafterGettingDriveDetails)")
            self.progressBGView.isHidden = true
            tableView.delegate = self
            tableView.dataSource = self
            
            currentLocationTxtField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidBegin)
            destinationLocationTxtField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidBegin)
            //        locationTxts()
            self.calculateRoute()
            self.addCustomMarkers()
            //        self.updateMapRegion()
            tableView.separatorStyle = .none
            bookBtn.layer.cornerRadius = 15
            noDriverFoundOKbtn.layer.cornerRadius = 15
            bookBtn.isHidden=false
            bookBtn.setTitle("BOOK AUTO-RICKSHAW", for: .normal)
            self.myMapBottomConstraint.constant = 280
            print("currentLocationCoordinate1 : \(currentLocationCoordinate)")
            print("destinationLocationCoordinate1 : \(destinationLocationCoordinate)")
            //        progressBGViewUIModification()
            //        cancelRideViewUIModification()
            //MARK: Ride Confirm View UI
            otpView.layer.cornerRadius=10
            otpView.layer.shadowOpacity = 0.5
            otpView.layer.shadowOffset = CGSize(width: 5, height: 5)
            otpView.layer.shadowRadius = 5
            otpView.layer.borderColor = UIColor.gray.cgColor
            otpView.layer.borderWidth = 1
            mobLBL.isUserInteractionEnabled = true
            cancelBtn.layer.cornerRadius = 15
            shareBtn.layer.cornerRadius = 15
            //        submitBtn.layer.cornerRadius = 15
            //        shareCancelBtn.layer.cornerRadius = 15
            //        cancelReasonViewOne.layer.cornerRadius = 15
            //        cancelReasonViewTwo.layer.cornerRadius = 15
            //        cancelReasonViewThree.layer.cornerRadius = 15
            shareCancelButton.roundCorners(.allCorners, radius: 10.0)
            buttonOpticity.isHidden = true
            buttonOpticity1.isHidden = true
            rideCancelledSuccessfullyImg.isHidden = true
            loader.color = .white
            loader.translatesAutoresizingMaskIntoConstraints = false
            bookBtn.addSubview(loader)
            // Center the activity indicator within the button
            NSLayoutConstraint.activate([
                loader.centerXAnchor.constraint(equalTo: bookBtn.centerXAnchor),
                loader.centerYAnchor.constraint(equalTo: bookBtn.centerYAnchor)
            ])
            NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
            getTimings()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        base64String = ""
        base64String = nil
    }
    
    func clear_GmapsAndTimer_Memory() {
        locationManager.delegate = nil
        textFieldResponderDelegate = nil
        PopBackDelegate = nil
        PopBackToDelegate = nil
        currentMarker = nil
        destinationMarker = nil
        roadPolyline = nil
        currentToRoadDottedPolyline = nil
        destinationDottedPolyline = nil
        myMap.delegate = nil
        dottedPathFromCurrentLocation.removeAllCoordinates()
        dottedPathToDestination.removeAllCoordinates()
        apiTimer?.invalidate()
        progressBarTimer?.invalidate()
        rideConfirmTimer?.invalidate()
        driverAPICallTimer?.invalidate()
        pinRideCancelledDriverApproachingAPICallTimer?.invalidate()
        bookRideAndTimeSloteWiseAPICallTimer?.invalidate()
        apiTimer = nil
        progressBarTimer = nil
        rideConfirmTimer = nil
        driverAPICallTimer = nil
        pinRideCancelledDriverApproachingAPICallTimer = nil
        bookRideAndTimeSloteWiseAPICallTimer = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    
    deinit {
        clear_GmapsAndTimer_Memory()
        
        print("******************** DEINIT BOOKACABVIEWCONTROLLER REMOVED FROM MEMORY*********************")
    }
    
    func rideCancel() {
        showTableview()
    }
    
    
    @objc func appDidEnterBackground() {
        // Begin background task when app enters background
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "MyBackgroundTask") {
            // Clean up if the time allowed expires
            UIApplication.shared.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = .invalid
        }
    }
    
    @objc func appDidBecomeActive() {
        // End background task when app becomes active
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    func showTableview() {
        //        self.progressBarTimer.invalidate()
        progressBarTimer = nil
        self.progressBar.progress = 0.0
        self.progressBGView.isHidden = true
        self.bookBtn.isEnabled = false
        self.bookBtn.setTitle("BOOK", for: .normal)
        self.bookBtn.backgroundColor = hexStringToUIColor(hex: "#0B8039")
        self.tableView.isHidden = false
        self.tableView.reloadData()
    }
    
    
    @objc func callViewTapped() {
        placePhoneCall(phoneNumber: mobLBL.text ?? "") // Replace with the phone number you want to call
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
    
    func showProgressView() {
        //        self.cancelBtnWhileSearching.setTitle("Cancel ride", for: .normal)
        //        self.cancelBtnWhileSearching.backgroundColor = hexStringToUIColor(hex: "#DC0000")
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        tableView.isHidden = true
        self.progressBGView.isHidden = false
        myMapBottomConstraint.constant = 426
        currentToDestinationMainViewHeightConstraint.constant = 426
        progressBGView.transform = CGAffineTransform(translationX: self.view.bounds.width, y: 0)
        
        // Animate the view to slide in from the right
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
            self.progressBGView.transform = .identity
        }, completion: nil)
        if vehicleTypeID == 1 {
            labelTollandParking.text = "Please pay the driver as per the meter charge at the end of the ride."
        } else {
            labelTollandParking.text = "Toll and parking charges are not included; additional fees apply."
        }
        labelTollandParking.font = UIFont(name: "Lato", size: 16)
        labelTollandParking.textAlignment = .center
        labelTollandParking.textColor = UIColor(named: "#4D4D4D")
        self.customizeProgressBar()
    }
    
    func createNavigationBar() {
        let customBackButton = UIButton()
        customBackButton.setImage(UIImage(named: "back"), for: .normal)
        customBackButton.addTarget(self, action: #selector(customBackButtonTapped), for: .touchUpInside)
        
        // Set custom back button as left bar button item
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customBackButton)
        //        if driverDetailsView.isHidden == false {
        //            let customBackButton1 = UIButton()
        //            customBackButton1.setImage(UIImage(named: "ellipsis-v"), for: .normal)
        //            customBackButton1.addTarget(self, action: #selector(self.customBackButtonTapped1), for: .touchUpInside)
        //
        //            // Set custom back button as left bar button item
        //            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: customBackButton1)
        //        }
        
    }
    
    @objc func customBackButtonTapped() {
        // Perform the custom back button action
        //        self.navigationController?.popViewController(animated: true)
        TimerManager.shared.stopAllTimers()
        
        self.PopBackDelegate?.goToBack(current: self.currentLoc,
                                       dest: self.destinationLoc,
                                       curreCoordinate: self.currentlocationcooordination,
                                       destCoordinate: self.destinationlocationcooordination,
                                       profileID: self.member_master_profile_id)
        //        let otpVC = storyboard?.instantiateViewController(identifier: "CurrenttoDestinationViewController") as! CurrenttoDestinationViewController
        self.navigationController?.popViewController(animated: true)
        
        //        let otpVC = storyboard?.instantiateViewController(identifier: "CurrenttoDestinationViewController") as! CurrenttoDestinationViewController
        //        otpVC.recentSearches = recentSearches
        //        otpVC.currentLocation = currentLoc
        //        otpVC.destinationLocation = destinationLoc
        //        otpVC.currentlocationcooordination = currentlocationcooordination
        //        otpVC.destinationlocationcooordination = destinationlocationcooordination
        //        otpVC.member_master_profile_id = member_master_profile_id
        apiTimer = nil
        apiTimer?.invalidate()
        TimerManager.shared.stopAllTimers()
        //        self.navigationController?.pushViewController(otpVC, animated: true)
        
    }
    
    //    @objc func customBackButtonTapped1() {
    //        if shareNcancelView.isHidden == false {
    //            shareNcancelView.isHidden = true
    //        } else {
    //            shareNcancelView.isHidden = false
    //            shareNcancelView.layer.cornerRadius = 10
    //            shareNcancelView.clipsToBounds = true
    //        }
    //
    //    }
    
    
    func locationTxts() {
        if address != nil || ((address?.isEmpty) != nil) {
            print("driverApproachingTowardsPassenger() -> new Modified address : \(address)")
            let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 8)
            mapView = GMSMapView.map(withFrame: self.myMap.bounds, camera: camera)
            mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.myMap.addSubview(mapView)
            self.currentLocationTxtField.text = address
            self.destinationLocationTxtField.text = self.currentLoc
            myMap.delegate = self
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let group = DispatchGroup()
            
            guard let currentLocationText = self.currentLocationTxtField.text, !currentLocationText.isEmpty else { return }
            group.enter()
            self.geocodeAddress(currentLocationText) { coordinate in
                guard let coordinate1 = coordinate else {
                    group.leave()
                    return
                }
                print("--------coordinate1 : \(coordinate1)")
                self.addAnnotation(at: coordinate1, for: self.currentLocationTxtField)
                //                self.currentLocationCoordinate = coordinate1 // Assuming this property exists
                group.leave()
            }
            
            guard let destinationLocationText = self.destinationLocationTxtField.text, !destinationLocationText.isEmpty else { return }
            group.enter()
            self.geocodeAddress(destinationLocationText) { coordinate in
                guard let coordinate2 = coordinate else {
                    group.leave()
                    return
                }
                print("--------coordinate2 : \(coordinate2)")
                self.addAnnotation(at: coordinate2, for: self.destinationLocationTxtField)
                self.destinationLocationCoordinate = coordinate2 // Assuming this property exists
                group.leave()
            }
            
            group.notify(queue: .main) {
                print("group.notify -> currentlocationcooordination : \(self.currentlocationcooordination)")
                print("group.notify -> destinationlocationcooordination : \(self.destinationlocationcooordination)")
                self.currentLocationCoordinate = self.currentlocationcooordination
                self.destinationLocationCoordinate = self.destinationlocationcooordination
                self.calculateRoute()
                self.addCustomMarkers()
                self.updateMapRegion()
            }
        }
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
    
    // Function to add annotation to map
    func addAnnotation(at coordinate: CLLocationCoordinate2D, for textField: UITextField) {
        print("----currentLocationTxtField : \(currentLocationTxtField)")
        print("----destinationLocationTxtField : \(destinationLocationTxtField)")
        let formattedLatitude = Float(coordinate.latitude)
        let formattedLongitude = Float(coordinate.longitude)
        
        let updatedDoubleLatitude = String(format: "%.5f", coordinate.latitude)
        let updatedDoubleLongitude = String(format: "%.5f", coordinate.longitude)
        let formattedCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(updatedDoubleLatitude)!, longitude: CLLocationDegrees(updatedDoubleLongitude)!)
        print("----currentLocationTxtField : \(currentLocationTxtField)")
        print("----destinationLocationTxtField : \(destinationLocationTxtField)")
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = formattedCoordinate
        if textField == currentLocationTxtField{
            annotation.title = currentLoc
            print("coordinate1 : \(formattedCoordinate)")
            //            newCurrentLocationCoordinate = formattedCoordinate
            //            currentLocationCoordinate = currentlocationcooordination
            print("addAnnotation() -> currentLocationCoordinate?.latitude : \(currentLocationCoordinate?.latitude)")
            print("addAnnotation() -> currentLocationCoordinate?.longitude : \(currentLocationCoordinate?.longitude)")
        }
        if textField == destinationLocationTxtField {
            annotation.title = destinationLoc
            print("coordinate2 : \(formattedCoordinate)")
            //            newDestinationLocationCoordinate = formattedCoordinate
            //            destinationLocationCoordinate = destinationlocationcooordination
            print("addAnnotation() -> destinationLocationCoordinate?.latitude : \(destinationLocationCoordinate?.latitude)")
            print("addAnnotation() -> destinationLocationCoordinate?.longitude : \(destinationLocationCoordinate?.longitude)")
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
            
            annotationView?.image = UIImage(named: "startpoint")
            let desiredSize = CGSize(width: 25, height: 25)
            if let image = annotationView?.image {
                annotationView?.image = image.scaled(to: desiredSize)
            }
            annotationView?.centerOffset = CGPoint(x: 0, y: -desiredSize.height / 2)
            
        } else if annotation.title == "Destination" {
            
            annotationView?.image = UIImage(named: "endpoint")
            let desiredSize = CGSize(width: 25, height: 25)
            if let image = annotationView?.image {
                annotationView?.image = image.scaled(to: desiredSize)
            }
            annotationView?.centerOffset = CGPoint(x: 0, y: -desiredSize.height / 2)
        }
        
        return annotationView
    }
    
    //    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
    //        mapBearing = position.bearing
    //           driverMarker.rotation = lastDriverAngleFromNorth - mapBearing
    //    }
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
    let infoWindow = UILabel()
    func addCustomMarkers() {
        //        mapView.delegate = self
        
        if rideStatus == "searchingRideContinued" {
            guard let currentCoordinate = currentLocationCoordinate,
                  let destinationCoordinate = destinationLocationCoordinate else {
                let alertController = UIAlertController(title: "func addcustommarkers(if)", message: "", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            print("addCustomMarkers() -> currentCoordinate : \(currentCoordinate)")
            print("addCustomMarkers() -> destinationCoordinate : \(destinationCoordinate)")
            // Add current location marker
            
            
            if driverDetailsView.isHidden == false || shareNcancelRideView.isHidden == false || shareBGView.isHidden == false || cancelReasonView.isHidden == false || rideStatus == "driverApproachingTowardsPassengerPending"{
                currentMarker = GMSMarker(position: currentCoordinate)
                //            currentMarker?.title = "Current Location"
                //                currentMarker?.icon = resizeImage(image: UIImage(named: "driverMarkerPoint")!, targetSize: CGSize(width: 25, height: 25))
                currentMarker?.icon = resizeImage(image: UIImage(named: "Blue_Arrow_Up_Darker")!, targetSize: CGSize(width: 25, height: 25))
                if polylinecoordinates.count > 1 {
                    let bearing = calculateBearing(from: polylinecoordinates[0], to: polylinecoordinates[1])
                    currentMarker?.rotation = bearing // Set the calculated bearing
                    
                    // Ensure the marker icon rotates correctly
                    currentMarker?.groundAnchor = CGPoint(x: 0.5, y: 0.5)
                }
                let driverLatitude = currentCoordinate.latitude
                let driverLongitude = currentCoordinate.longitude
                //                   if let driverlatitude = Double(currentCoordinate.latitude), let driverlongitude = Double(currentCoordinate.longitude) {
                //                currentMarker?.rotation = CLLocationCoordinate2D(latitude: currentCoordinate.latitude, longitude: currentCoordinate.longitude)
                //                }
                currentMarker?.map = mapView
                destinationMarker = GMSMarker(position: destinationCoordinate)
                destinationMarker?.title = currentLoc
                destinationMarker?.icon = resizeImage(image: UIImage(named: "startpoint")!, targetSize: CGSize(width: 25, height: 25))
                destinationMarker?.map = mapView
            } else {
                currentMarker = GMSMarker(position: currentCoordinate)
                currentMarker?.title = currentLoc
                currentMarker?.icon = resizeImage(image: UIImage(named: "startpoint")!, targetSize: CGSize(width: 25, height: 25))
                currentMarker?.map = mapView
                destinationMarker = GMSMarker(position: destinationCoordinate)
                destinationMarker?.title = destinationLoc
                destinationMarker?.icon = resizeImage(image: UIImage(named: "endpoint")!, targetSize: CGSize(width: 25, height: 25))
                destinationMarker?.map = mapView
                //            addCustomInfoWindow(for: currentMarker, title: currentLoc)
                //            addCustomInfoWindow(for: destinationMarker, title: destinationLoc)
                calculateDistance(currentLocationCoordinate: currentCoordinate, destinationLocationCoordinate: destinationCoordinate) { [weak self] calculateDistance in
                    if let distances = calculateDistance {
                        print("The distance is: \(distances)")
                        let cleanedDistanceText = distances.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
                        
                        self?.distance = Float(cleanedDistanceText)
                        //                distance = Float(distances)
                        print("distance -------> : \(self?.distance)")
                    }
                    //            else {
                    //                    print("Failed to calculate the distance.")
                    //                }
                }
            }
            
            //        calculateDistance()
            
        } else if rideStatus == "driverApproachingTowardsPassengerPending" || rideStatus == "tappedNotifcationBanner" {
            destinationLocationCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(pickup_latitude!)!, longitude: CLLocationDegrees(pickup_longitude!)!)
            guard let currentCoordinate = currentLocationCoordinate,
                  let destinationCoordinate = destinationLocationCoordinate else {
                let alertController = UIAlertController(title: "func addcustomamrkers(else if)", message: "", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            print("addCustomMarkers() -> currentCoordinate : \(currentCoordinate)")
            print("addCustomMarkers() -> destinationCoordinate : \(destinationCoordinate)")
            // Add current location marker
            
            
            if driverDetailsView.isHidden == false || shareNcancelRideView.isHidden == false || shareBGView.isHidden == false || cancelReasonView.isHidden == false || rideStatus == "driverApproachingTowardsPassengerPending"{
                currentMarker = GMSMarker(position: currentCoordinate)
                //            currentMarker?.title = "Current Location"
                //                currentMarker?.icon = resizeImage(image: UIImage(named: "driverMarkerPoint")!, targetSize: CGSize(width: 25, height: 25))
                currentMarker?.icon = resizeImage(image: UIImage(named: "Blue_Arrow_Up_Darker")!, targetSize: CGSize(width: 25, height: 25))
                if polylinecoordinates.count > 1 {
                    let bearing = calculateBearing(from: polylinecoordinates[0], to: polylinecoordinates[1])
                    currentMarker?.rotation = bearing // Set the calculated bearing
                    
                    // Ensure the marker icon rotates correctly
                    currentMarker?.groundAnchor = CGPoint(x: 0.5, y: 0.5)
                }
                let driverLatitude = currentCoordinate.latitude
                let driverLongitude = currentCoordinate.longitude
                currentMarker?.map = mapView
                destinationMarker = GMSMarker(position: destinationCoordinate)
                destinationMarker?.title = currentLoc
                destinationMarker?.icon = resizeImage(image: UIImage(named: "startpoint")!, targetSize: CGSize(width: 25, height: 25))
                destinationMarker?.map = mapView
            } else {
                currentMarker = GMSMarker(position: currentCoordinate)
                currentMarker?.title = currentLoc
                currentMarker?.icon = resizeImage(image: UIImage(named: "startpoint")!, targetSize: CGSize(width: 25, height: 25))
                currentMarker?.map = mapView
                destinationMarker = GMSMarker(position: destinationCoordinate)
                destinationMarker?.title = destinationLoc
                destinationMarker?.icon = resizeImage(image: UIImage(named: "endpoint")!, targetSize: CGSize(width: 25, height: 25))
                destinationMarker?.map = mapView
                //            addCustomInfoWindow(for: currentMarker, title: currentLoc)
                //            addCustomInfoWindow(for: destinationMarker, title: destinationLoc)
                calculateDistance(currentLocationCoordinate: currentCoordinate, destinationLocationCoordinate: destinationCoordinate) { [weak self] calculateDistance in
                    if let distances = calculateDistance {
                        print("The distance is: \(distances)")
                        let cleanedDistanceText = distances.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
                        
                        self?.distance = Float(cleanedDistanceText)
                        //                distance = Float(distances)
                        print("distance -------> : \(self?.distance)")
                    }
                    //            else {
                    //                    print("Failed to calculate the distance.")
                    //                }
                }
            }
            
            //        calculateDistance()
            
        }
        else {
            guard let currentCoordinate = currentLocationCoordinate,
                  let destinationCoordinate = destinationLocationCoordinate else {
                let alertController = UIAlertController(title: "func addcustommarkers(else)", message: "", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            print("addCustomMarkers() -> currentCoordinate : \(currentCoordinate)")
            print("addCustomMarkers() -> destinationCoordinate : \(destinationCoordinate)")
            // Add current location marker
            
            
            if driverDetailsView.isHidden == false || shareNcancelRideView.isHidden == false || shareBGView.isHidden == false || cancelReasonView.isHidden == false || rideStatus == "driverApproachingTowardsPassengerPending"{
                currentMarker = GMSMarker(position: currentCoordinate)
                //            currentMarker?.title = "Current Location"
                //                currentMarker?.icon = resizeImage(image: UIImage(named: "driverMarkerPoint")!, targetSize: CGSize(width: 25, height: 25))
                currentMarker?.icon = resizeImage(image: UIImage(named: "Blue_Arrow_Up_Darker")!, targetSize: CGSize(width: 25, height: 25))
                if polylinecoordinates.count > 1 {
                    let bearing = calculateBearing(from: polylinecoordinates[0], to: polylinecoordinates[1])
                    currentMarker?.rotation = bearing // Set the calculated bearing
                    
                    // Ensure the marker icon rotates correctly
                    currentMarker?.groundAnchor = CGPoint(x: 0.5, y: 0.5)
                }
                currentMarker?.map = mapView
                destinationMarker = GMSMarker(position: destinationCoordinate)
                destinationMarker?.title = currentLoc
                destinationMarker?.icon = resizeImage(image: UIImage(named: "startpoint")!, targetSize: CGSize(width: 25, height: 25))
                destinationMarker?.map = mapView
            } else {
                currentMarker = GMSMarker(position: currentCoordinate)
                currentMarker?.title = currentLoc
                currentMarker?.icon = resizeImage(image: UIImage(named: "startpoint")!, targetSize: CGSize(width: 25, height: 25))
                currentMarker?.map = mapView
                destinationMarker = GMSMarker(position: destinationCoordinate)
                destinationMarker?.title = destinationLoc
                destinationMarker?.icon = resizeImage(image: UIImage(named: "endpoint")!, targetSize: CGSize(width: 25, height: 25))
                destinationMarker?.map = mapView
                //            addCustomInfoWindow(for: currentMarker, title: currentLoc)
                //            addCustomInfoWindow(for: destinationMarker, title: destinationLoc)
                calculateDistance(currentLocationCoordinate: currentCoordinate, destinationLocationCoordinate: destinationCoordinate) { [weak self] calculateDistance in
                    if let distances = calculateDistance {
                        print("The distance is: \(distances)")
                        let cleanedDistanceText = distances.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
                        
                        self?.distance = Float(cleanedDistanceText)
                        //                distance = Float(distances)
                        print("distance -------> : \(self?.distance)")
                    }
                    //            else {
                    //                    print("Failed to calculate the distance.")
                    //                }
                }
            }
            
            //        calculateDistance()
            
        }
        //GOOGLE ANALYTICS
        AnalyticsManager.shared.rideSearch(
            pickup: currentLoc ?? "",
            drop: destinationLoc ?? "",
            distance: Double(distance ?? 0)
        )
        
    }
    
    func addCustomInfoWindow(for marker: GMSMarker?, title: String?) {
        guard let marker = marker, let title = title else { return }
        //        let infoWindow = UILabel()
        infoWindow.text = title
        infoWindow.backgroundColor = UIColor.black
        infoWindow.textColor = UIColor.white
        infoWindow.textAlignment = .center
        infoWindow.font = UIFont.systemFont(ofSize: 14)
        infoWindow.sizeToFit()
        infoWindow.frame.size.width = CGFloat(280)
        infoWindow.frame.size.height = CGFloat(18)
        infoWindow.layer.cornerRadius = 8
        infoWindow.clipsToBounds = true
        infoWindow.center = mapView.projection.point(for: marker.position)
        infoWindow.center.y -= 30  // Adjust height above the marker
        
        mapView.addSubview(infoWindow)
        
        // Update the position of the info window when the map moves
        mapView.addObserver(self, forKeyPath: "camera", options: .new, context: nil)
    }
    
    // Observe camera changes to update info window positions
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "camera" {
            if let currentMarker = currentMarker {
                updateInfoWindowPosition(for: currentMarker)
            }
            if let destinationMarker = destinationMarker {
                updateInfoWindowPosition(for: destinationMarker)
            }
        }
    }
    
    func updateInfoWindowPosition(for marker: GMSMarker) {
        if let infoWindow = mapView.subviews.first(where: { ($0 as? UILabel)?.text == marker.title }) {
            infoWindow.center = mapView.projection.point(for: marker.position)
            infoWindow.center.y -= 35  // Adjust height above the marker
        }
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
    
    
    //    func updateMapRegion() {
    //        print("currentLocationCoordinate : \(currentLocationCoordinate)")
    //        print("destinationLocationCoordinate : \(destinationLocationCoordinate)")
    //
    //        guard let currentCoordinate = currentLocationCoordinate,
    //              let destinationCoordinate = destinationLocationCoordinate else {
    //            return
    //        }
    //
    //        var zoomRect = MKMapRect.null
    //        let currentPoint = MKMapPoint(currentCoordinate)
    //        let destinationPoint = MKMapPoint(destinationCoordinate)
    //
    //        zoomRect = zoomRect.union(MKMapRect(x: currentPoint.x, y: currentPoint.y, width: 0, height: 0))
    //        zoomRect = zoomRect.union(MKMapRect(x: destinationPoint.x, y: destinationPoint.y, width: 0, height: 0))
    //
    //        myMap.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
    //    }
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        print("Camera Zoom: \(position.zoom)")
        //            currentPosition = position
        // Check if both coordinates are available
        if let currentCoordinate = currentLocationCoordinate,
           let destinationCoordinate = destinationLocationCoordinate {
            
            // Create bounds that encompass both coordinates
            let bounds = GMSCoordinateBounds(coordinate: currentCoordinate, coordinate: destinationCoordinate)
            
            // Adjust the camera to fit both locations
            if isZoomForFirstTime == false {
                let update = GMSCameraUpdate.fit(bounds, withPadding: 100.0)
                mapView.moveCamera(update)
                isZoomForFirstTime = true
            }
        } else {
            print("One or both coordinates are nil")
        }
    }
    
    func updateMapRegion() {
        print("currentLocationCoordinate updateMapRegion() : \(String(describing: currentLocationCoordinate))")
        print("destinationLocationCoordinate updateMapRegion() : \(String(describing: destinationLocationCoordinate))")
        print("destinationlocationcooordination updateMapRegion() : \(String(describing: destinationlocationcooordination))")
        if rideStatus == "driverApproachingTowardsPassengerPending" || rideStatus == "tappedNotifcationBanner"{
            destinationLocationCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(pickup_latitude!)!, longitude: CLLocationDegrees(pickup_longitude!)!)
        }
        guard let currentCoordinate = currentLocationCoordinate,
              let destinationCoordinate = destinationLocationCoordinate else {
            let alertController = UIAlertController(title: "func updatemapregion()", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        if currentLocationCoordinate != nil && destinationLocationCoordinate != nil {
            print("Both coordinates are not nil")
            
            // Create a bounds object that includes both coordinates
            let bounds = GMSCoordinateBounds(coordinate: currentCoordinate, coordinate: destinationCoordinate)
            
            // Create a camera update that fits the bounds with padding
            let update = GMSCameraUpdate.fit(bounds, withPadding: 80.0)
            
            // Move the camera to the updated position
            mapView.moveCamera(update)
            moveCamera = true
        }
    }
    
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
                        print("calculateRoute() -> routes : \(routes)")
                        if let legs = route["legs"] as? [[String: Any]], let leg = legs.first {
                            if let distance = leg["distance"] as? [String: Any], let distanceText = distance["text"] as? String {
                                print("Distance(legs): \(distanceText)")
                            }
                            if let duration = leg["duration"] as? [String: Any], let durationsText = duration["text"] as? String {
                                print("durationsText: \(durationsText)")
                                if durationsreached2mins == false {
                                    if durationsText == "2 mins" {
                                        print("driver has reaching soon")
                                        durationsreached2mins = true
                                        //                                        driver_is_2_min_away_from_passenger_location()
                                    }
                                }
                                if durationsreached1min == false {
                                    if durationsText == "1 min" {
                                        print("driver has reached your location")
                                        durationsreached1min = true
                                        //                                        Driver_reached_your_location()
                                    }
                                }
                            }
                        }
                        
                        //                         let duration = route["duration"] as? String
                        //                        let durationText = duration["text"] as? String
                        //                        print("duration : \(durationText)")
                        if let overviewPolyline = route["overview_polyline"] as? [String: Any], let points = overviewPolyline["points"] as? String {
                            print("calculateRoute() -> overviewPolyline : \(overviewPolyline)")
                            print("calculateRoute() -> points : \(points)")
                            sd_poliline_points = points
                            let coordinates = decodePolyline(points)
                            
                            // Print the decoded coordinates
                            for coordinate in coordinates {
                                print("coordinates ::: Latitude: \(coordinate.latitude), Longitude: \(coordinate.longitude)")
                                let coordinateString = "\(coordinate.latitude),\(coordinate.longitude)"
                                //                                    polylinecoordinates.append(coordinate)
                            }
                            print("polylinecoordinates : \(polylinecoordinates)")
                            //                            let coords = decodePolyline(overviewPolyline["points"] as! String)!
                            DispatchQueue.main.async { [weak self] in
                                guard let self = self else { return }
                                self.roadPolyline?.map = nil
                                self.currentToRoadDottedPolyline?.map = nil
                                self.destinationDottedPolyline?.map = nil
                                self.dottedPathFromCurrentLocation.removeAllCoordinates()
                                self.dottedPathToDestination.removeAllCoordinates()
                                self.showPath(polyStr: points)
                            }
                            
                        }
                    }
                }
            } catch let error {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func drawRouteAndAdjustCamera() {
        guard let currentCoordinate = currentLocationCoordinate,
              let destinationCoordinate = destinationLocationCoordinate else {
            print("Coordinates not available.")
            return
        }
        
        // Construct the Google Directions API URL
        let origin = "\(currentCoordinate.latitude),\(currentCoordinate.longitude)"
        let destination = "\(destinationCoordinate.latitude),\(destinationCoordinate.longitude)"
        let urlStr = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=YOUR_API_KEY"
        
        // Fetch directions data
        guard let url = URL(string: urlStr) else {
            print("Invalid URL.")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching directions: \(error)")
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let routes = json["routes"] as? [[String: Any]],
                  let firstRoute = routes.first,
                  let overviewPolyline = firstRoute["overview_polyline"] as? [String: Any],
                  let points = overviewPolyline["points"] as? String else {
                print("Invalid directions data.")
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                // Decode the polyline points
                let path = GMSPath(fromEncodedPath: points)
                let polyline = GMSPolyline(path: path)
                //                polyline.strokeColor = .blue
                polyline.strokeWidth = 4.0
                polyline.map = self.mapView
                
                // Adjust the camera to fit the entire route
                var bounds = GMSCoordinateBounds()
                if let path = path {
                    for index in 0..<path.count() {
                        bounds = bounds.includingCoordinate(path.coordinate(at: index))
                    }
                }
                self.mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50.0))
                
                // Ensure the zoom logic only applies for the first time
                if self.isZoomForFirstTime {
                    self.isZoomForFirstTime = false
                }
            }
        }.resume()
    }
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
    
    func showPath(polyStr: String) {
        guard let currentCoordinate = currentLocationCoordinate,
              let destinationCoordinate = destinationLocationCoordinate else {
            return
        }
        
        if driverDetailsView.isHidden == false || shareNcancelRideView.isHidden == false || shareBGView.isHidden == false || driverDetailsView.isHidden == false {
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
            print("path1 : \(path)")
            roadPolyline = GMSPolyline(path: path)
            //        roadPolyline.strokeColor = UIColor.blue // Color for the road path
            roadPolyline?.strokeColor = UIColor(red: 95, green: 102, blue: 118) // Color for the road path
            roadPolyline?.strokeWidth = 5.0
            roadPolyline?.map = mapView // Your GMSMapView instance
            guard let paths = path else { return }
            let firstRoadCoordinate = paths.coordinate(at: 0)
            dottedPathFromCurrentLocation.add(currentCoordinate)
            dottedPathFromCurrentLocation.add(firstRoadCoordinate)
            currentToRoadDottedPolyline = GMSPolyline(path: dottedPathFromCurrentLocation)
            currentToRoadDottedPolyline?.strokeColor = UIColor(red: 108, green: 111, blue: 118)
            currentToRoadDottedPolyline?.strokeWidth = 5.0
            let dotStyle = GMSStrokeStyle.solidColor(.clear)
            //            let gapStyle = GMSStrokeStyle.solidColor(UIColor(red: 108, green: 111, blue: 118))
            let gapStyle = GMSStrokeStyle.solidColor(.clear)
            let pattern = [gapStyle, dotStyle]
            currentToRoadDottedPolyline?.spans = GMSStyleSpans((currentToRoadDottedPolyline?.path)!, pattern, [2, 2], .geodesic)
            currentToRoadDottedPolyline?.map = mapView
            let lastRoadCoordinate = paths.coordinate(at: (paths.count() - 1))
            dottedPathToDestination.add(lastRoadCoordinate) // Start from the last point on the road
            dottedPathToDestination.add(destinationCoordinate) // Exact building location
            destinationDottedPolyline = GMSPolyline(path: dottedPathToDestination)
            destinationDottedPolyline?.strokeColor = UIColor(red: 108, green: 111, blue: 118)
            destinationDottedPolyline?.strokeWidth = 5.0
            destinationDottedPolyline?.spans = GMSStyleSpans((destinationDottedPolyline?.path)!, pattern, [2, 2], .geodesic)
            destinationDottedPolyline?.map = mapView
            
        } else {
            currentToRoadDottedPolyline?.map = nil
            destinationDottedPolyline?.map = nil
            dottedPathFromCurrentLocation.removeAllCoordinates()
            dottedPathToDestination.removeAllCoordinates()
            roadPolyline?.map = nil
            roadPolyline = nil
            let path = GMSPath(fromEncodedPath: polyStr)
            print("path2 : \(path)")
            roadPolyline = GMSPolyline(path: path)
            //        roadPolyline.strokeColor = UIColor.blue // Color for the road path
            roadPolyline?.strokeColor = UIColor(red: 95, green: 102, blue: 118) // Color for the road path
            roadPolyline?.strokeWidth = 5.0
            roadPolyline?.map = mapView // Your GMSMapView instance
            guard let paths = path else { return }
            let firstRoadCoordinate = paths.coordinate(at: 0)
            dottedPathFromCurrentLocation.add(currentCoordinate)
            dottedPathFromCurrentLocation.add(firstRoadCoordinate)
            currentToRoadDottedPolyline = GMSPolyline(path: dottedPathFromCurrentLocation)
            currentToRoadDottedPolyline?.strokeColor = UIColor(red: 108, green: 111, blue: 118)
            currentToRoadDottedPolyline?.strokeWidth = 5.0
            let dotStyle = GMSStrokeStyle.solidColor(.clear)
            let gapStyle = GMSStrokeStyle.solidColor(UIColor(red: 108, green: 111, blue: 118))
            let pattern = [gapStyle, dotStyle]
            currentToRoadDottedPolyline?.spans = GMSStyleSpans((currentToRoadDottedPolyline?.path)!, pattern, [2, 2], .geodesic)
            currentToRoadDottedPolyline?.map = mapView
            let lastRoadCoordinate = paths.coordinate(at: (paths.count() - 1))
            dottedPathToDestination.add(lastRoadCoordinate) // Start from the last point on the road
            dottedPathToDestination.add(destinationCoordinate) // Exact building location
            destinationDottedPolyline = GMSPolyline(path: dottedPathToDestination)
            destinationDottedPolyline?.strokeColor = UIColor(red: 108, green: 111, blue: 118)
            destinationDottedPolyline?.strokeWidth = 5.0
            destinationDottedPolyline?.spans = GMSStyleSpans((destinationDottedPolyline?.path)!, pattern, [2, 2], .geodesic)
            destinationDottedPolyline?.map = mapView
        }
    }
    
    //    func encodePolyline(_ coordinates: [CLLocationCoordinate2D]) -> String {
    //        var encodedString = ""
    //        var previousLat: Int = 0
    //        var previousLng: Int = 0
    //
    //        for coordinate in coordinates {
    //            let lat = Int(coordinate.latitude * 1e5)
    //            let lng = Int(coordinate.longitude * 1e5)
    //
    //            let dLat = lat - previousLat
    //            let dLng = lng - previousLng
    //
    //            encodedString += encodeCoordinate(dLat)
    //            encodedString += encodeCoordinate(dLng)
    //
    //            previousLat = lat
    //            previousLng = lng
    //        }
    //        showPath(polyStr: encodedString)
    //        return encodedString
    //    }
    
    //    private func encodeCoordinate(_ value: Int) -> String {
    //        var encoded = ""
    //        var value = value << 1
    //        if value < 0 {
    //            value = ~value
    //        }
    //
    //        while value >= 0x20 {
    //            let nextValue = (0x20 | (value & 0x1f)) + 63
    //            encoded.append(Character(UnicodeScalar(nextValue)!))
    //            value >>= 5
    //        }
    //
    //        encoded.append(Character(UnicodeScalar(value + 63)!))
    //        return encoded
    //    }
    var path = GMSMutablePath()
    func showPath1(polylineCoordinates: [CLLocationCoordinate2D]) {
        guard let currentCoordinate = currentLocationCoordinate,
              let destinationCoordinate = destinationLocationCoordinate else {
            let alertController = UIAlertController(title: "func showpath1()", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        if driverDetailsView.isHidden == false || shareNcancelRideView.isHidden == false || shareBGView.isHidden == false || driverDetailsView.isHidden == false {
            // Remove the existing polyline
            currentToRoadDottedPolyline?.map = nil
            destinationDottedPolyline?.map = nil
            dottedPathFromCurrentLocation.removeAllCoordinates()
            dottedPathToDestination.removeAllCoordinates()
            roadPolyline?.map = nil
            roadPolyline = nil
            
            // Create a GMSMutablePath from the array of CLLocationCoordinate2D
            path = GMSMutablePath()
            polylineCoordinates.forEach { path.add($0) }
            
            // Create the road polyline
            roadPolyline = GMSPolyline(path: path)
            roadPolyline?.strokeColor = UIColor(red: 95/255, green: 102/255, blue: 118/255, alpha: 1)
            roadPolyline?.strokeWidth = 5.0
            roadPolyline?.map = mapView
            
            // Dotted line from current location to the first road coordinate
            if let firstRoadCoordinate = polylineCoordinates.first {
                let dottedPathFromCurrentLocation = GMSMutablePath()
                //                dottedPathFromCurrentLocation.add(currentCoordinate)
                dottedPathFromCurrentLocation.add(firstRoadCoordinate)
                
                currentToRoadDottedPolyline = GMSPolyline(path: dottedPathFromCurrentLocation)
                currentToRoadDottedPolyline?.map = mapView
            }
            
            // Dotted line from the last road coordinate to the destination
            if let lastRoadCoordinate = polylineCoordinates.last {
                let dottedPathToDestination = GMSMutablePath()
                //                dottedPathToDestination.add(lastRoadCoordinate)
                dottedPathToDestination.add(destinationCoordinate)
                
                destinationDottedPolyline = GMSPolyline(path: dottedPathToDestination)
                destinationDottedPolyline?.map = mapView
            }
        } else {
            // Create the polyline without hidden views logic
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
    }
    
    private func createDottedPolyline(path: GMSMutablePath) -> GMSPolyline {
        let dottedPolyline = GMSPolyline(path: path)
        dottedPolyline.strokeColor = UIColor(red: 108/255, green: 111/255, blue: 118/255, alpha: 1)
        dottedPolyline.strokeWidth = 5.0
        
        let dotStyle = GMSStrokeStyle.solidColor(.clear)
        let gapStyle = GMSStrokeStyle.solidColor(UIColor(red: 108/255, green: 111/255, blue: 118/255, alpha: 1))
        let pattern = [gapStyle, dotStyle]
        dottedPolyline.spans = GMSStyleSpans(path, pattern, [2, 2], .geodesic)
        
        return dottedPolyline
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
    func captureMapScreenshot() {
        // Ensure the map view is valid
        guard let map = mapView else { return }
        
        // Create an image renderer for the map view's bounds
        let renderer = UIGraphicsImageRenderer(size: map.bounds.size)
        
        // Render the map view as an image
        let image = renderer.image { context in
            map.layer.render(in: context.cgContext)
        }
        
        // Convert the image to Data (JPEG format in this example)
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            base64String = imageData.base64EncodedString()
            print("base64String : \(base64String)")
            // Save the image to a temporary file and get its URL
            let tempDirectory = FileManager.default.temporaryDirectory
            let fileURL = tempDirectory.appendingPathComponent("map_screenshot.jpg")
            
            do {
                // Write the image data to the file
                try imageData.write(to: fileURL)
                print("Screenshot saved at URL: \(fileURL)")
                
                // Now you can use `fileURL` as needed (e.g., share, upload, etc.)
                // For example, presenting a share sheet:
                //                    let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                //                    print("activityVC : \(activityVC)")
                //                    self.present(activityVC, animated: true, completion: nil)
                
            } catch {
                print("Error saving screenshot: \(error.localizedDescription)")
                let alertController = UIAlertController(title: "Network Error", message: "", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    //MARK: BOOK RIDE BUTTON
    @IBAction func bookBtnAction(_ sender: Any) {
        let currentTime = CACurrentMediaTime()
        
        if currentTime - lastClickTime < 1 { // Ignore multiple clicks within 1 second
            return
        }
        
        //GOOGLE ANALYTICS
        AnalyticsManager.shared.rideRequested(
            pickup: currentLoc ?? "",
            drop: destinationLoc ?? "",
            fare: Double(self.analyticsRideFare ?? 0)
        )
        
        
        lastClickTime = currentTime
        
        // Handle button click action
        print("Button clicked")
        bookBtn.isEnabled = false
        bookBtn.setTitle("", for: .normal)
        loader.startAnimating()
        //        drawRouteAndAdjustCamera()
        if let currentCoordinate = currentLocationCoordinate,
           let destinationCoordinate = destinationLocationCoordinate {
            
            // Create bounds that encompass both coordinates
            let bounds = GMSCoordinateBounds(coordinate: currentCoordinate, coordinate: destinationCoordinate)
            
            // Adjust the camera to fit both locations
            if isZoomForFirstTime == true {
                let update = GMSCameraUpdate.fit(bounds, withPadding: 50.0)
                mapView.moveCamera(update)
                isZoomForFirstTime = false
            }
        }
        if NetworkMonitor.shared.isConnected{
            if bookBtn.titleLabel?.text == "Cancel ride" {
                print("YOUR RIDE HAS BEEN CANCELED")
                showTableview()
            } else {
                print("Book A Cab")
                bookBtn.isEnabled = true
                bookBtn.isHidden = true
                //                bookBtn.setTitle("BOOK", for: .normal)
                loader.stopAnimating()
                showProgressView()
                startProgressView1()
            }
        }
        else {
            print("you are not connected")
            let alert = UIAlertController(title: "No Internet Connection",
                                          message: "It looks like you're offline. Please check your internet connection.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default,handler: { [weak self] _ in
                self?.bookBtn.isEnabled = true
                self?.bookBtn.setTitle("BOOK", for: .normal)
                self?.loader.stopAnimating()
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func customizeProgressBar() {
        progressBar.progress = 0.0
        progressBar.layer.cornerRadius = 7.5
        progressBar.clipsToBounds = true
        progressBar.layer.sublayers?[1].cornerRadius = 7.5
        progressBar.subviews[1].clipsToBounds = true
        startProgress()
    }
    
    func startProgressView1() {
        let stopInterval: Float = 15 * 60.0 // 15 minutes in seconds
        // Schedule the API call timer
        //        driverAPICallTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(differentAPICall), userInfo: nil, repeats: true)
        driverAPICallTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.differentAPICall()
        }
    }
    func startProgressView2() {
        let stopInterval: Float = 15 * 60.0 // 15 minutes in seconds
        // Schedule the API call timer
        //        pinRideCancelledDriverApproachingAPICallTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(differentAPICall2), userInfo: nil, repeats: true)
        pinRideCancelledDriverApproachingAPICallTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.differentAPICall2()
        }
    }
    
    @objc func differentAPICall() {
        //        if self.driverDetailsView.isHidden == false {
        //
        //            pinAPICall()
        //            rideCancelledByDriver()
        //            driverApproachingTowardsPassenger()
        //        } else if isshareNcancelRideBtnClicked == false {
        driverAPICall()
        //        }
    }
    @objc func differentAPICall2() {
        //        if self.driverDetailsView.isHidden == false {
        progressBGView = nil
        noDriverFound = nil
        pinAPICall()
        rideCancelledByDriver()
        driverApproachingTowardsPassenger()
        //        } else if isshareNcancelRideBtnClicked == false {
        //            driverAPICall()
        //        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let heading = newHeading.trueHeading // or use newHeading.magneticHeading
        rotateArrowMarker(to: heading)
    }
    func updateArrowMarkerPosition(at coordinate: CLLocationCoordinate2D) {
        if arrowMarker == nil {
            // Create the arrow marker
            arrowMarker = GMSMarker(position: coordinate)
            //            arrowMarker?.icon = UIImage(named: "arrow_marker") // Use your arrow image here
            arrowMarker?.icon = UIImage(named: "Blue_Arrow_Up_Darker") // Use your arrow image here
            arrowMarker?.map = mapView
        } else {
            // Update marker position
            arrowMarker?.position = coordinate
        }
    }
    
    // Function to rotate the arrow marker based on heading
    func rotateArrowMarker(to heading: CLLocationDirection) {
        arrowMarker?.rotation = heading // Rotate the arrow to match the heading direction
    }
    
    
    @objc func bookRideAndTimeSloteWiseAPICall() {
        for (index, timeString) in startTime.enumerated() {
            let timeValue = Int(Double(timeString) ?? 0.0)
            
            // Ensure that the current index appears when secondsElapsed reaches the corresponding startTime value
            if secondsElapsed == timeValue {
                print("index : \(index)")
                
                // Ensure the index exists in distanceFromGetTimings
                if index < distanceFromGetTimings.count {
                    distanceforsearchdriver = distanceFromGetTimings[index]
                    if index == 0 {
                        print("bookride")
                        print("distance: \(distance)")
                        print("distanceforsearchdriver: \(distanceforsearchdriver)")
                        bookRide()
                    } else {
                        print("anything")
                        print("distance: \(distance)")
                        print("distanceforsearchdriver: \(distanceforsearchdriver)")
                        timeSlotwise()
                    }
                    
                } else {
                    print("No corresponding distance for index \(index)")
                }
                
                break // Exit the loop once the correct index is found
            }
        }
        secondsElapsed += 1
    }
    func startProgress() {
        print("startProgress is started")
        //        bookRide()
        //        bookRideAndTimeSloteWiseAPICallTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(bookRideAndTimeSloteWiseAPICall), userInfo: nil, repeats: true)
        bookRideAndTimeSloteWiseAPICallTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.bookRideAndTimeSloteWiseAPICall()
        }
        currentLocationTxtField.isUserInteractionEnabled = false
        destinationLocationTxtField.isUserInteractionEnabled = false
        progressBar.progress = 0.0
        //        let totalTime: Float = 300.0 // 5 minutes in seconds
        let updateInterval: Float = 0.5 // Update every 0.5 seconds
        //        self.progressBarTimer = Timer.scheduledTimer(timeInterval: TimeInterval(updateInterval), target: self, selector: #selector(updateProgressView), userInfo: nil, repeats: true)
        progressBarTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(updateInterval), repeats: true) { [weak self] _ in
            self?.updateProgressView()
        }
        progressBar.progressTintColor = UIColor.blue
        progressBar.progressViewStyle = .default
    }
    @objc func updateProgressView() {
        //        if let firstStartTime = startTime.first {
        //                if firstStartTime == "0.0" {
        //                    bookRide()
        //                } else {
        //                    TimingSlotwise()
        //                }
        //            }
        //
        //            guard let totalTimeString = totalTime else {
        //                print("Error: totalTime is nil")
        //                return
        //            }
        //                let totalTimeString: Float = 300.0 // 5 minutes in seconds
        let totalTimeString = totalTime
        //                                if  let totalTimeInSeconds = convertTimeStringToSeconds(timeString: "00:00:05") {
        if  let totalTimeInSeconds = convertTimeStringToSeconds(timeString: totalTimeString!) {
            print("totalTime : \(totalTime)")
            print("totalTimeInSeconds : \(totalTimeInSeconds)")
            let updateInterval: Float = 0.5 // Update every 0.5 seconds
            let increment = updateInterval / totalTimeInSeconds
            var elapsedTime: Float = 0
            self.progressBar.progress += increment
            self.progressBar.setProgress(self.progressBar.progress, animated: true)
            print("progressBar: \(self.progressBar.progress)")
            Timer.scheduledTimer(withTimeInterval: TimeInterval(updateInterval), repeats: true) { [weak self] timer in
                elapsedTime += updateInterval
                if self?.noDriverFoundViewBool == false {
                    print("noDriverFoundViewBool is false")
                    if elapsedTime == totalTimeInSeconds {
                        timer.invalidate()
                        self?.rideConfirmTimer?.invalidate()
                        self?.rideConfirmTimer = nil
                        self?.progressBarTimer?.invalidate()
                        self?.progressBarTimer = nil
                        self?.driverAPICallTimer?.invalidate()
                        self?.driverAPICallTimer = nil
                        self?.tableView.isHidden = true
                        self?.bookRideAndTimeSloteWiseAPICallTimer?.invalidate()
                        self?.bookRideAndTimeSloteWiseAPICallTimer = nil
                        //                        self?.progressBGView.isHidden = true
                        //                        self?.noDriverFound.isHidden = false
                        self?.cancelRideAfterNoDriverFound()
                        //                    NSLayoutConstraint.activate([noDriverFound.topAnchor.constraint(equalTo: currentToDestinationView.bottomAnchor, constant: 20), currentToDestinationMainView.heightAnchor.constraint(equalToConstant: 325)])
                        self?.currentToDestinationMainViewHeightConstraint.constant = 325
                        self?.myMapBottomConstraint.constant = 325
                        // Ensure layout changes are animated
                        UIView.animate(withDuration: 0.3) {
                            self?.view.layoutIfNeeded()
                        }
                        print("Time exceeded. No driver found.")
                        self?.progressBarTimer = nil
                        self?.progressBarTimer?.invalidate()
                        self?.noDriverFoundViewBool = true
                    } else {
                        // Update progress bar
                        
                    }
                }
            }
            //            print("increment : \(increment)")
            //            progressBar.progress += increment
            //            print("progressBar : \(progressBar.progress)")
            //            progressBar.setProgress(progressBar.progress, animated: true)
            //            print("increment2 : \(increment)")
            
            //            if progressBar.progress >= 0.0 {
            //                //                progressBarTimer.invalidate()
            //                bookRide()
            //            }
            //            else if progressBar.progress >= 60.0 {
            //                //                progressBarTimer.invalidate()
            //                timeSlotwise()
            //            }else {
            //                self.currentToDestinationMainView.isHidden=true
            //                self.progressBGView.isHidden = true
            //                self.driverDetailsView.isHidden = true
            //                self.noDriverFound.isHidden = false
            //                NSLayoutConstraint.activate([self.mapView.bottomAnchor.constraint(equalTo: self.noDriverFound.topAnchor, constant: 0)])
            //            }
            //            for (index, time) in startTime.enumerated() {
            //                print("Index \(index): Time \(time)")
            //                if index == 0 || time == startTime[0] {
            //                    print("BookRide API Call")
            //                    bookRide()
            //                } else {
            //                    print("TimeSlotwise API Call")
            //                    timeSlotwise()
            //                }
            //            }
            //            if let firstTimeString = firstTime, let firstTimeInt = Int(firstTimeString){
            //                for i in 0...firstTimeInt{
            //                    print("i : \(i)")
            //                    if progressBar.progress >= 1.0 {
            //                        progressBarTimer.invalidate()
            //                        rideCnfirm()
            //                    }
            //                }
            //            }
        }
        
    }
    
    func startRideConfirmTimer() {
        // Create and start the timer to call rideConfirm() every 5 seconds
        //        rideConfirmTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(rideCnfirm), userInfo: nil, repeats: true)
        rideConfirmTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.rideCnfirm()
        }
        
    }
    
    
    @objc func rideCnfirm() {
        //        let rideCnfrm = storyboard?.instantiateViewController(identifier: "RideConfirmViewController") as! RideConfirmViewController
        //        rideCnfrm.current = self.current
        //        rideCnfrm.destination = self.destination
        //        rideCnfrm.cancelRideDelegate = self
        //        rideCnfrm.pk_bookride_id=pk_bookride_id
        //        self.navigationController?.pushViewController(rideCnfrm, animated: true)
        if self.driverDetailsView.isHidden == false {
            
            pinAPICall()
            rideCancelledByDriver()
            driverApproachingTowardsPassenger()
        } else if isshareNcancelRideBtnClicked == false {
            driverAPICall()
        }
    }
    
    
    //    func pinConfirmTimer() {
    //        // Create and start the timer to call rideConfirm() every 5 seconds
    //        rideConfirmTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(pinCnfirm), userInfo: nil, repeats: true)
    //
    //    }
    //    @objc func pinCnfirm() {
    //        pinAPICall()
    //    }
    
    
    
    
    @IBAction func disablecancelReasonView(_ sender: Any) {
        let currentTime = CACurrentMediaTime()
        
        if currentTime - lastClickTime < 1 { // Ignore multiple clicks within 1 second
            return
        }
        
        lastClickTime = currentTime
        
        // Handle button click action
        print("Button clicked")
        shareBGView.isHidden = true
        cancelReasonView.isHidden=true
        
        if cancelBtnIsCalledFrom == "Before Driver Accepted the Ride" {
            currentToDestinationMainView.isHidden = false
            progressBGView.isHidden = false
            cancelRideView.isHidden = true
            buttonOpticity.isHidden = true
            currentToDestinationMainViewHeightConstraint.constant = 426
            self.myMapBottomConstraint.constant = 426
            
        }
        
        else if cancelBtnIsCalledFrom == "After Driver Accepted the Ride" {
            driverDetailsView.isHidden = false
            buttonOpticity.isHidden = true
            buttonOpticity1.isHidden = true
            self.myMapBottomConstraint.constant = 300
        }
        
    }
    @IBAction func cancelRideAction(_ sender: Any) {
        let currentTime = CACurrentMediaTime()
        
        if currentTime - lastClickTime < 1 { // Ignore multiple clicks within 1 second
            return
        }
        
        lastClickTime = currentTime
        
        // Handle button click action
        print("Button clicked")
        cancelBtnIsCalledFrom = "Before Driver Accepted the Ride"
        
        shareBGView.isHidden = true
        currentToDestinationMainView.isHidden = true
        progressBGView.isHidden = true
        cancelReasonView.isHidden = false
        
        //        NSLayoutConstraint.activate([self.mapView.bottomAnchor.constraint(equalTo: self.cancelReasonView.topAnchor, constant: 30)])
        self.myMapBottomConstraint.constant = 350
        cancelReasonView.roundCorners([.topLeft, .topRight], radius: 30)
        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        
        // Add the tap gesture recognizer to the view
        driverTakingTooLongView.addGestureRecognizer(tapGestureRecognizer1)
        let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(handleRideAmountTooHighViewTap(_:)))
        
        // Add the tap gesture recognizer to the view
        rideAmountTooHigh.addGestureRecognizer(tapGestureRecognizer2)
        let tapGestureRecognizer3 = UITapGestureRecognizer(target: self, action: #selector(handlebookMyMistakeViewTap(_:)))
        
        // Add the tap gesture recognizer to the view
        bookMyMistake.addGestureRecognizer(tapGestureRecognizer3)
        
    }
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        print("Needed a shorter wait time")
        isDriverTakingTooLongSelected = true
        rideCancelReason = "Needed a shorter wait time"
        driverTakingTooLongView.backgroundColor = UIColor(red: 255/255, green: 250/255, blue: 141/255, alpha: 1.0)
        rideAmountTooHigh.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1.0)
        bookMyMistake.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1.0)
        
    }
    @objc func handleRideAmountTooHighViewTap(_ sender: UITapGestureRecognizer) {
        print("Ride amount too high")
        isRideAmountTooHighSelected = true
        rideAmountTooHigh.backgroundColor = UIColor(red: 255/255, green: 250/255, blue: 141/255, alpha: 1.0)
        driverTakingTooLongView.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1.0)
        bookMyMistake.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1.0)
        rideCancelReason = "Ride amount too high"
    }
    @objc func handlebookMyMistakeViewTap(_ sender: UITapGestureRecognizer) {
        print("Booked by mistake")
        isBookMyMistakeSelected = true
        bookMyMistake.backgroundColor = UIColor(red: 255/255, green: 250/255, blue: 141/255, alpha: 1.0)
        rideAmountTooHigh.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1.0)
        driverTakingTooLongView.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1.0)
        rideCancelReason = "Booked by mistake"
    }
    func navigateToMapViewController() {
        apiTimer?.invalidate()
        progressBarTimer?.invalidate()
        rideConfirmTimer?.invalidate()
        driverAPICallTimer?.invalidate()
        pinRideCancelledDriverApproachingAPICallTimer?.invalidate()
        bookRideAndTimeSloteWiseAPICallTimer?.invalidate()
        apiTimer = nil
        progressBarTimer = nil
        rideConfirmTimer = nil
        driverAPICallTimer = nil
        pinRideCancelledDriverApproachingAPICallTimer = nil
        bookRideAndTimeSloteWiseAPICallTimer = nil
        clear_GmapsAndTimer_Memory()
        TimerManager.shared.stopAllTimers()
        let mapVC = storyboard?.instantiateViewController(identifier: "MapViewController") as! MapViewController
        mapVC.member_master_profile_id = self.member_master_profile_id
        self.navigationController?.pushViewController(mapVC, animated: true)
        //        self.PopBackViewControllerDelegate?.dataPassBack(memberID: self.member_master_profile_id)
        //        DispatchQueue.main.async { [weak self] in
        //            guard let self = self else { return }
        //            if let viewControllers = self.navigationController?.viewControllers {
        //                for vc in viewControllers {
        //                    if vc is MapViewController {
        //                        self.navigationController?.popToViewController(vc, animated: true)
        //                        break
        //                    }
        //                }
        //            }
        //        }
    }
    //Mani
    @IBAction func submitActionForRideCancel(_ sender: Any) {
        let currentTime = CACurrentMediaTime()
        
        if currentTime - lastClickTime < 1 { // Ignore multiple clicks within 1 second
            return
        }
        
        lastClickTime = currentTime
        
        // Handle button click action
        print("Button clicked")
        if !isDriverTakingTooLongSelected && !isRideAmountTooHighSelected && !isBookMyMistakeSelected {
            // Show error: No option selected
            showError("Please select a reason for canceling the ride.")
            return
        } else {
            self.myMapBottomConstraint.constant = 0
            if self.currentToDestinationMainView.isHidden == false {
                self.currentToDestinationMainView.isHidden = true
            }
            if self.cancelRideView.isHidden == false {
                self.cancelRideView.isHidden = true
            }
            if self.cancelReasonView.isHidden == false {
                self.cancelReasonView.isHidden = true
            }
            if self.driverDetailsView.isHidden == false {
                self.driverDetailsView.isHidden = true
            }
            if self.shareNcancelRideView.isHidden == false {
                self.shareNcancelRideView.isHidden = true
            }
            self.noDriverFoundViewBool = true
            self.buttonOpticity1.isHidden = false
            self.loaderActivity1.isHidden = false
            self.loaderActivity1.startAnimating()
            //            DispatchQueue.main.asyncAfter(deadline: .now() + 20, execute: {
            if (cancelBtnIsCalledFrom == "After Driver Accepted the Ride") {
                self.cancelRideSecondTime()
            } else {
                self.cancelRide()
            }
            
            
            //            })
            
            
            
        }
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func shareCancelAction(_ sender: Any) {
        let currentTime = CACurrentMediaTime()
        
        if currentTime - lastClickTime < 1 { // Ignore multiple clicks within 1 second
            return
        }
        
        lastClickTime = currentTime
        
        // Handle button click action
        print("Button clicked")
        buttonOpticity.isHidden = true
        currentToDestinationMainView.isHidden=true
        progressBGView.isHidden=true
        shareBGView.isHidden = true
        driverDetailsView.isHidden = false
        self.myMapBottomConstraint.constant = 300
        //NSLayoutConstraint.activate([self.mapView.bottomAnchor.constraint(equalTo: self.driverDetailsView.topAnchor, constant: 30)])
        
    }
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func calculateDistance() {
        print("<------------------------------------------>")
        print("calculateDistance() -> currentLocationCoordinate : \(currentLocationCoordinate)")
        print("calculateDistance() -> destinationLocationCoordinate : \(destinationLocationCoordinate)")
        print("<------------------------------------------>")
        
        guard let currentCoordinate = currentLocationCoordinate,
              let destinationCoordinate = destinationLocationCoordinate else {
            print("returned from calculateDistance()")
            return
        }
        
        // Create CLLocation instances
        let currentLocation = CLLocation(latitude: currentCoordinate.latitude, longitude: currentCoordinate.longitude)
        let destinationLocation = CLLocation(latitude: destinationCoordinate.latitude, longitude: destinationCoordinate.longitude)
        
        // Calculate distance
        let distanceInMeters = currentLocation.distance(from: destinationLocation)
        let distanceInKilometers = distanceInMeters / 1000.0
        
        print("<------------------------------------------>")
        print("Distance: \(distanceInMeters) km")
        print("<------------------------------------------>")
        distance = Float(distanceInMeters)
        if rideStatus == "driverApproachingTowardsPassengerPending" || rideStatus == "tappedNotifcationBanner" {  } else {
            calculateFareApiCall()
        }
    }
    
    func calculateDistance(currentLocationCoordinate: CLLocationCoordinate2D, destinationLocationCoordinate: CLLocationCoordinate2D, completion: @escaping (String?) -> Void) {
        
        let apiKey = "AIzaSyDce_Ybso83w6ay7NoKCuA5y33udrxGhmk"
        
        // Construct the URL
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(currentLocationCoordinate.latitude),\(currentLocationCoordinate.longitude)&destination=\(destinationLocationCoordinate.latitude),\(destinationLocationCoordinate.longitude)&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        // Create a URL session to make the request
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            // Parse the JSON response
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    
                    if let routes = json["routes"] as? [[String: Any]], let firstRoute = routes.first {
                        print("routes : \(routes)")
                        if let legs = firstRoute["legs"] as? [[String: Any]], let firstLeg = legs.first {
                            print("legs : \(legs)")
                            if let distance = firstLeg["distance"] as? [String: Any], let distanceText = distance["text"] as? String {
                                print("firstLeg[ : \(distance)")
                                completion(distanceText)
                            } else {
                                completion(nil)
                            }
                        }
                    } else {
                        completion(nil)
                    }
                    
                }
                if self.rideStatus == "driverApproachingTowardsPassengerPending" || self.rideStatus == "tappedNotifcationBanner" {  } else {
                    self.calculateFareApiCall()
                }
            } catch {
                print("Failed to parse JSON: \(error)")
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    func haversineDistance(lat1: Float, lon1: Float, lat2: Float, lon2: Float) -> Float {
        let earthRadius: Float = 6371.0 // Earth's radius in kilometers
        
        let dLat = (lat2 - lat1).radians
        let dLon = (lon2 - lon1).radians
        
        let a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1.radians) * cos(lat2.radians) *
        sin(dLon / 2) * sin(dLon / 2)
        
        let c = 2 * atan2f(sqrt(a), sqrt(1 - a))
        
        return earthRadius * c
    }
    
    //    @IBAction func cancelBtn(_ sender: Any) {
    func cancelBtn1() {
        let currentTime = CACurrentMediaTime()
        
        if currentTime - lastClickTime < 1 { // Ignore multiple clicks within 1 second
            return
        }
        
        lastClickTime = currentTime
        
        // Handle button click action
        print("Button clicked")
        cancelBtnIsCalledFrom = "After Driver Accepted the Ride"
        currentToDestinationView.isHidden = true
        shareBGView.isHidden = true
        driverDetailsView.isHidden = true
        cancelReasonView.isHidden = false
        self.myMapBottomConstraint.constant = 340
        
        //        NSLayoutConstraint.activate([self.mapView.bottomAnchor.constraint(equalTo: self.cancelReasonView.topAnchor, constant: 30)])
        cancelReasonView.roundCorners([.topLeft, .topRight], radius: 30)
        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        
        // Add the tap gesture recognizer to the view
        driverTakingTooLongView.addGestureRecognizer(tapGestureRecognizer1)
        let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(handleRideAmountTooHighViewTap(_:)))
        
        // Add the tap gesture recognizer to the view
        rideAmountTooHigh.addGestureRecognizer(tapGestureRecognizer2)
        let tapGestureRecognizer3 = UITapGestureRecognizer(target: self, action: #selector(handlebookMyMistakeViewTap(_:)))
        
        // Add the tap gesture recognizer to the view
        bookMyMistake.addGestureRecognizer(tapGestureRecognizer3)
    }
    //Mani
    @IBAction func whileSearchingRideOptionAction(_ sender: Any) {
        let currentTime = CACurrentMediaTime()
        
        if currentTime - lastClickTime < 1 { // Ignore multiple clicks within 1 second
            return
        }
        
        lastClickTime = currentTime
        
        // Handle button click action
        print("Button clicked")
        cancelBtnIsCalledFrom = "Before Driver Accepted the Ride"
        if currentToDestinationMainView.isHidden == false {
            currentToDestinationMainView.isHidden = true
            myMapBottomConstraint.constant = 0
        }
        if cancelRideView.isHidden == true {
            cancelRideView.isHidden = false
        }
        if buttonOpticity.isHidden == true {
            buttonOpticity.isHidden = false
        }
    }
    //Mani
    @IBAction func hideCancelRideViewAction(_ sender: Any) {
        let currentTime = CACurrentMediaTime()
        
        if currentTime - lastClickTime < 1 { // Ignore multiple clicks within 1 second
            return
        }
        
        lastClickTime = currentTime
        
        // Handle button click action
        print("Button clicked")
        print("hide cancel ride view")
        
        if buttonOpticity.isHidden == false {
            buttonOpticity.isHidden = true
        }
        if cancelRideView.isHidden == false {
            cancelRideView.isHidden = true
        }
        if currentToDestinationMainView.isHidden == true {
            currentToDestinationMainView.isHidden = false
            currentToDestinationMainViewHeightConstraint.constant = 426
            myMapBottomConstraint.constant = 426
            
        }
    }
    //Mani
    @IBAction func openCancelRideReasonsView(_ sender: Any) {
        //        let currentTime = CACurrentMediaTime()
        //
        //        if currentTime - lastClickTime < 1 { // Ignore multiple clicks within 1 second
        //            return
        //        }
        //
        //        lastClickTime = currentTime
        
        // Handle button click action
        print("Button clicked")
        print("opened cancel ride reasons view")
        if buttonOpticity.isHidden == true {
            buttonOpticity.isHidden = false
        }
        if cancelReasonView.isHidden == true {
            cancelReasonView.isHidden = false
            myMapBottomConstraint.constant = 340
            cancelReasonView.roundCorners([.topLeft, .topRight], radius: 30)
            let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            
            // Add the tap gesture recognizer to the view
            driverTakingTooLongView.addGestureRecognizer(tapGestureRecognizer1)
            let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(handleRideAmountTooHighViewTap(_:)))
            
            // Add the tap gesture recognizer to the view
            rideAmountTooHigh.addGestureRecognizer(tapGestureRecognizer2)
            let tapGestureRecognizer3 = UITapGestureRecognizer(target: self, action: #selector(handlebookMyMistakeViewTap(_:)))
            
            // Add the tap gesture recognizer to the view
            bookMyMistake.addGestureRecognizer(tapGestureRecognizer3)
        }
        if currentToDestinationMainView.isHidden == false {
            currentToDestinationMainView.isHidden = true
        }
    }
    
    
    @IBAction func shareNcancelRideBtnAction(_ sender: Any) {
        //        let currentTime = CACurrentMediaTime()
        //
        //        if currentTime - lastClickTime < 1 { // Ignore multiple clicks within 1 second
        //            return
        //        }
        //
        //        lastClickTime = currentTime
        
        // Handle button click action
        print("Button clicked")
        cancelBtnIsCalledFrom = "After Driver Accepted the Ride"
        cancelRideView.isHidden = true
        isshareNcancelRideBtnClicked = true
        if shareNcancelRideView.isHidden == true {
            shareNcancelRideView.isHidden = false
        }
        if buttonOpticity.isHidden == true {
            buttonOpticity.isHidden = false
        }
        if driverDetailsView.isHidden == false {
            driverDetailsView.isHidden = true
            myMapBottomConstraint.constant = 0
        }
    }
    
    
    @IBAction func shareNcancelRideViewCancelBtnAction(_ sender: Any) {
        let currentTime = CACurrentMediaTime()
        
        if currentTime - lastClickTime < 1 { // Ignore multiple clicks within 1 second
            return
        }
        
        lastClickTime = currentTime
        
        // Handle button click action
        print("Button clicked")
        print("hide share and cancel ride view")
        if buttonOpticity.isHidden == false {
            buttonOpticity.isHidden = true
        }
        if shareNcancelRideView.isHidden == false {
            shareNcancelRideView.isHidden = true
        }
        if driverDetailsView.isHidden == true {
            driverDetailsView.isHidden = false
            myMapBottomConstraint.constant = 300
        }
    }
    
    @IBAction func shareNcancelRideViewShareRideBtnAction(_ sender: Any) {
        let currentTime = CACurrentMediaTime()
        
        if currentTime - lastClickTime < 1 { // Ignore multiple clicks within 1 second
            return
        }
        
        lastClickTime = currentTime
        
        // Handle button click action
        print("Button clicked")
        //        if shareBGView.isHidden == true {
        //            shareBGView.isHidden = false
        //            myMapBottomConstraint.constant = 333
        //        }
        let otp = otpLbl.text ?? "" // Example OTP, replace with actual OTP
        let driverName = driverName.text ?? ""
        let driverPhone = mobLBL.text ?? ""
        let vehicleModel = vehicleName.text ?? ""
        let vehicleNumber = vehicleNo.text ?? ""
        let pickupLocation = currentLocationTxtField.text ?? ""
        let destinationLocation = destinationLocationTxtField.text ?? ""
        
        // Construct the message
        let message = """
            RIDE DETAILS
            ---------------------------
            PIN:
            \(otp)
            
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
        // Create an array with the items to share
        let itemsToShare: [Any] = [message]
        
        // Initialize the UIActivityViewController
        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        
        // Exclude some activity types if necessary
        activityViewController.excludedActivityTypes = [.assignToContact, .saveToCameraRoll, .print]
        
        // Present the share sheet
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func shareNcancelRideViewCancelRideBtnAction(_ sender: Any) {
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
        if cancelReasonView.isHidden == true {
            cancelReasonView.isHidden = false
            myMapBottomConstraint.constant = 340
            cancelReasonView.roundCorners([.topLeft, .topRight], radius: 30)
            let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            
            // Add the tap gesture recognizer to the view
            driverTakingTooLongView.addGestureRecognizer(tapGestureRecognizer1)
            let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(handleRideAmountTooHighViewTap(_:)))
            
            // Add the tap gesture recognizer to the view
            rideAmountTooHigh.addGestureRecognizer(tapGestureRecognizer2)
            let tapGestureRecognizer3 = UITapGestureRecognizer(target: self, action: #selector(handlebookMyMistakeViewTap(_:)))
            
            // Add the tap gesture recognizer to the view
            bookMyMistake.addGestureRecognizer(tapGestureRecognizer3)
        }
        if currentToDestinationMainView.isHidden == false {
            currentToDestinationMainView.isHidden = true
        }
    }
    
    
    @IBAction func noDriverFoundOKbtnAction(_ sender: Any) {
        let currentTime = CACurrentMediaTime()
        
        if currentTime - lastClickTime < 1 { // Ignore multiple clicks within 1 second
            return
        }
        
        lastClickTime = currentTime
        
        // Handle button click action
        print("Button clicked")
        noDriverFoundViewBool = true
        rideConfirmTimer?.invalidate()
        rideConfirmTimer = nil
        progressBarTimer?.invalidate()
        progressBarTimer = nil
        driverAPICallTimer?.invalidate()
        driverAPICallTimer = nil
        apiTimer = nil
        apiTimer?.invalidate()
        tableView.isHidden = true
        bookRideAndTimeSloteWiseAPICallTimer?.invalidate()
        bookRideAndTimeSloteWiseAPICallTimer = nil
        navigateToMapViewController()
    }
    
    
    @IBAction func whatsAppBtnAction(_ sender: Any) {
        let otp = otpLbl.text ?? "" // Example OTP, replace with actual OTP
        let driverName = driverName.text ?? ""
        let driverPhone = mobLBL.text ?? ""
        let vehicleModel = vehicleName.text ?? ""
        let vehicleNumber = vehicleNo.text ?? ""
        let pickupLocation = currentLocationTxtField.text ?? ""
        let destinationLocation = destinationLocationTxtField.text ?? ""
        
        // Construct the message
        let message = """
            RIDE DETAILS
            ---------------------------
            PIN:
            \(otp)
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
        let currentTime = CACurrentMediaTime()
        
        if currentTime - lastClickTime < 1 { // Ignore multiple clicks within 1 second
            return
        }
        
        lastClickTime = currentTime
        
        // Handle button click action
        print("Button clicked")
        let otp = otpLbl.text ?? "" // Example OTP, replace with actual OTP
        let driverName = driverName.text ?? ""
        let driverPhone = mobLBL.text ?? ""
        let vehicleModel = vehicleName.text ?? ""
        let vehicleNumber = vehicleNo.text ?? ""
        let pickupLocation = currentLocationTxtField.text ?? ""
        let destinationLocation = destinationLocationTxtField.text ?? ""
        
        // Construct the message body
        let messageBody = """
        RIDE DETAILS
        ---------------------------
        PIN:
        \(otp)
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
        let currentTime = CACurrentMediaTime()
        
        if currentTime - lastClickTime < 1 { // Ignore multiple clicks within 1 second
            return
        }
        
        lastClickTime = currentTime
        
        // Handle button click action
        print("Button clicked")
        let otp = otpLbl.text ?? "" // Example OTP, replace with actual OTP
        let driverName = driverName.text ?? ""
        let driverPhone = mobLBL.text ?? ""
        let vehicleModel = vehicleName.text ?? ""
        let vehicleNumber = vehicleNo.text ?? ""
        let pickupLocation = currentLocationTxtField.text ?? ""
        let destinationLocation = destinationLocationTxtField.text ?? ""
        
        // Construct the message body
        let messageBody = """
        RIDE DETAILS
        ---------------------------
                PIN:
                \(otp)
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
        let currentTime = CACurrentMediaTime()
        
        if currentTime - lastClickTime < 1 { // Ignore multiple clicks within 1 second
            return
        }
        
        lastClickTime = currentTime
        
        // Handle button click action
        print("Button clicked")
    }
    
    
    @IBAction func recenterBtnAction(_ sender: Any) {
        updateMapRegion()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAllTimers()
        clear_GmapsAndTimer_Memory()
    }
    
    func stopAllTimers() {
        
        [apiTimer,
         progressBarTimer,
         rideConfirmTimer,
         driverAPICallTimer,
         pinRideCancelledDriverApproachingAPICallTimer,
         bookRideAndTimeSloteWiseAPICallTimer].forEach {
            $0?.invalidate()
            print("Timers-------- \($0?.timeInterval ?? 101)")
        }
        
        apiTimer = nil
        progressBarTimer = nil
        rideConfirmTimer = nil
        driverAPICallTimer = nil
        pinRideCancelledDriverApproachingAPICallTimer = nil
        bookRideAndTimeSloteWiseAPICallTimer = nil
    }
}

//MARK: API IMPLEMENTATION
extension BookACabViewController{
    
    func getTimings() {
        let url = AppConfig.baseURL+"Book/getTimingMasterlist"
        let token = UserDefaults.standard.string(forKey: "auth_deviceToken") ?? ""
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { [weak self] response in
            guard let self = self else { return }
            
            print("response : \(response.result)")
            switch response.result {
                
            case .success (let data) :
                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let loginResult = json["result"] as? [String: Any] {
                            print("JSON -------\(json)")
                            let status = loginResult["status"] as? String ?? ""
                            let message = loginResult["message"] as? String ?? ""
                            self.totalTime = loginResult["totalTime"] as? String ?? ""
                            let farelist = loginResult["farelist"] as! [[String: Any]]
                            
                            print("fareList : \(farelist)")
                            //                                let firstTimingFareList = farelist[0]
                            //                                print(firstTimingFareList)
                            //                                let firstTiming = firstTimingFareList["timings"]
                            //                                print("firstTiming : \(firstTiming)")
                            //                                self.firstTime = firstTiming as? String
                            for starttiming in farelist {
                                let startTiming  = starttiming["starttiming"]
                                print("startTiming : \(startTiming)")
                                //                                self.startTime.append(startTiming as! String)
                                var modifiedStartTime = convertTimeStringToSeconds(timeString: startTiming as! String)
                                if let modifiedStartTime = modifiedStartTime {
                                    self.startTime.append(String(describing: modifiedStartTime))
                                }
                                print("startTime : \(self.startTime)")
                                let distance  = starttiming["distance"]
                                distanceFromGetTimings.append(distance as! Int)
                                print("distanceFromGetTimings : \(distanceFromGetTimings)")
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
    func calculateFareApiCall() {
        let url = AppConfig.baseURL+"Passanger/calculateFare"
        let params :  [String : Any] = [
            "fk_member_master_profile_id": member_master_profile_id,
            //            "fk_member_master_profile_id": 7,
            "distance": distance,
            "sourceLat": currentLocationCoordinate?.latitude,
            "sourceLong": currentLocationCoordinate?.longitude,
            "destinationLat": destinationLocationCoordinate?.latitude,
            "destinationLong": destinationLocationCoordinate?.longitude
        ]
        print("calculateFareApiCall() -> url : \(url)")
        print("calculateFareApiCall() -> params : \(params)")
        
        let token = UserDefaults.standard.string(forKey: "auth_deviceToken") ?? ""
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { [weak self] response in
            guard let self = self else { return }
            print("calculateFareApiCall() -> response : \(response)")
            print("calculateFareApiCall() -> response.result : \(response.result)")
            
            switch response.result {
                
            case .success (let data) :
                
                //                let json = value as? [String : Any]
                //                let loginResult = json?["loginResult"] as? [String : Any]
                //                let status = loginResult?["status"] as? String ?? ""
                //                let message = loginResult?["message"] as? String ?? ""
                //
                //                if status == "-1"{
                //                    let alertController = UIAlertController(title: "", message: "Mobile Number not registered.", preferredStyle: .alert)
                //
                //                            // Add an action (button)
                //                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                //                            alertController.addAction(okAction)
                //
                //                            // Present the alert
                //                            self.present(alertController, animated: true, completion: nil)
                //                }
                
                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let loginResult = json["result"] as? [String: Any] {
                            print("calculateFareApiCall() -> JSON -------\(json)")
                            let status = loginResult["status"] as? String ?? ""
                            let message = loginResult["message"] as? String ?? ""
                            //                            if message == "NO"{
                            //                                let otpVC = self.storyboard?.instantiateViewController(identifier: "CurrenttoDestinationViewController") as! CurrenttoDestinationViewController
                            //                                otpVC.locationUnServiceable = "locationIsNotAvailable"
                            //                                otpVC.currentLocation = currentLoc
                            //                                otpVC.destinationLocation = destinationLoc
                            //                                otpVC.currentLocation = currentLoc
                            //                                otpVC.member_master_profile_id = member_master_profile_id
                            //                                otpVC.destinationLocation = destinationLoc
                            //                                otpVC.currentlocationcooordination = currentlocationcooordination
                            //                                otpVC.destinationlocationcooordination = destinationlocationcooordination
                            //                                //        otpVC.recentSearches = dashboardRecentSearches
                            //                                self.navigationController?.pushViewController(otpVC, animated: true)
                            //                            } else
                            if message == "OK" {
                                farelist = loginResult["farelist"] as! [[String: Any]]
                                
                                print("fareList : \(farelist)")
                                for fare in farelist{
                                    let vehicletypename = fare["vehicletypename"] as? String ?? ""
                                    print("vehicletypename : \(vehicletypename)")
                                    self.rideTypeLbl.append(vehicletypename)
                                }
                                for amount in farelist{
                                    if let amounts = amount["amount"] as? Int {
                                        print("amounts : \(amounts)")
                                        self.rideFareLbl.append(amounts)
                                        print("rideFareLbl : \(self.rideFareLbl)")
                                    }
                                    
                                }
                                for vehicleID in farelist {
                                    self.vehicleTypeID = vehicleID["vehicletypeid"] as? Int
                                    print("vehicleTypeID : \(self.vehicleTypeID)")
                                }
                                
                                DispatchQueue.main.async { [weak self] in
                                    guard let self = self else { return }
                                    self.loaderActivity.stopAnimating()
                                    self.loaderActivity.isHidden = true
                                    self.tableView.reloadData()
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
                    print("Data is nil")
                }
                
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
        
        
    }
    
    func bookRide() {
        
        if pk_bookride_id == nil || pk_bookride_id == 0 {
            pkbookrideid = 0
        } else {
            pkbookrideid = pk_bookride_id
        }
        var routeMapPhoto : String?
        if rideStatus == "searchingRideContinued" {
            pkbookrideid = pk_bookride_id
            routeMapPhoto = routMap_photo
            captureMapScreenshot()
        } else {
            pkbookrideid = 0
            routeMapPhoto = ""
            captureMapScreenshot()
        }
        let url = AppConfig.baseURL+"Book/bookride"
        let params :  [String : Any] = [
            //        "pk_bookride_id": 169,// if new booking then 0 other wise greate than 0
            "pk_bookride_id": pkbookrideid,// if new booking then 0 other wise greate than 0
            //            "pk_bookride_id": 0,// if new booking then 0 other wise greate than 0
            "fk_member_master_profile_id": member_master_profile_id, // this is the passanger id
            "sourceaddress": currentLoc,
            "distinationaddress": destinationLoc,
            "sourcelatitude": currentLocationCoordinate?.latitude,
            "sourcelongitude": currentLocationCoordinate?.longitude,
            "distinationlatitude": destinationLocationCoordinate?.latitude,
            "distinationlongitude": destinationLocationCoordinate?.longitude,
            //            "vehicletypeid": vehicleTypeID,
            "vehicletypeid": 1,
            "amount": rideFare,
            "distance": distance,
            "distanceforsearchdriver": distanceforsearchdriver,
            "RoutMap_photo":routeMapPhoto,
            "Base64_RoutMap_photo":base64String,
            "sd_poliline_points" : sd_poliline_points
        ]
        print("bookARide() -> currentLocationCoordinate?.latitude : \(currentLocationCoordinate?.latitude)")
        print("bookARide() -> rideFare : \(rideFare)")
        print("bookARide() -> currentLocationCoordinate?.longitude : \(currentLocationCoordinate?.longitude)")
        print("bookARide() -> destinationLocationCoordinate?.latitude : \(destinationLocationCoordinate?.latitude)")
        print("bookARide() -> destinationLocationCoordinate?.longitude : \(destinationLocationCoordinate?.longitude)")
        print("bookARide() -> url : \(url)")
        print("bookARide() -> parameters : \(params)")
        
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
                            print("JSON  bookRide API Response() -------\(json)")
                            let status = loginResult["status"] as? String ?? ""
                            let message = loginResult["message"] as? String ?? ""
                            var driverCount = loginResult["drivercount"] as? Int
                            if pkbookrideid == 0 {
                                self.pk_bookride_id = loginResult["pk_bookride_id"] as? Int
                                
                                pkbookrideid = pk_bookride_id
                                timeslot_pk_bookride_id = pk_bookride_id
                            }
                            print("bookARide() -> pk_bookride_id : \(pk_bookride_id)")
                            self.driverCountLbl.text = driverCount == 0 ? "Searching for Drivers" : driverCount == 1 ? "\(driverCount ?? 0) driver is currently checking your request" : "\(driverCount ?? 0) drivers are currently checking your request"
                            DispatchQueue.main.async { [weak self] in
                                guard let self = self else { return }
                                self.whileSearchingRideOption.isHidden = false
                                self.driverCountLbl.isHidden = false
                            }
                            
                            UserDefaults.standard.setValue(pkbookrideid, forKey: "bookride_id")
                            if status == "0" {
                                //                                self.rideCnfirm()
                                //                                self.startRideConfirmTimer()
                                //                                self.driverDetailsView.isHidden = false
                                //                                self.progressBarTimer.invalidate()
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
    
    func timeSlotwise() {
        
        let url = AppConfig.baseURL+"Book/SearchDriver_On_timeing_Slotwise"
        let params :  [String : Any] = [
            "fk_bookride_id": timeslot_pk_bookride_id,
            "vehicle_type": vehicleTypeID,
            "distanceforsearchdriver": distanceforsearchdriver
        ]
        print("timeSlotwise() -> parameters : \(params)")
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
                            print("JSON  timeSlotwise() -------\(json)")
                            let status = loginResult["status"] as? String ?? ""
                            let message = loginResult["message"] as? String ?? ""
                            self.pk_bookride_id = loginResult["pk_bookride_id"] as? Int
                            var driverCounts = loginResult["drivercount"] as? Int
                            
                            if status == "0" {
                                DispatchQueue.main.async {
                                    self.driverCountLbl.text = driverCounts == 0 ? "Searching for Drivers" : driverCounts == 1 ? "\(driverCounts ?? 0) driver is currently checking your request" : "\(driverCounts ?? 0) drivers are currently checking your request"
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
                    print("Data is nil")
                }
                
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    func driverAPICall() {
        if NetworkMonitor.shared.isConnected {
            print("driverAPICall() -> pkbookrideid : \(pkbookrideid)")
            
            let url = AppConfig.baseURL+"Book/After_driveraccept_ride_passanger_will_get_driver_details"
            let params :  [String : Any] = [
                "fk_bookride_id": pkbookrideid
            ]
            print("driverAPICall() -> parameters : \(params)")
            let token = UserDefaults.standard.string(forKey: "auth_deviceToken") ?? ""
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]
            
            AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { [weak self] response in
                guard let self = self else { return }
                print("response : \(response)")
                print("response.result : \(response.result)")
                let statusCode = response.response?.statusCode
                print("statusCode : \(statusCode)")
                
                switch response.result {
                    
                case .success (let data) :
                    if let data = data {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                               let loginResult = json["result"] as? [String: Any] {
                                print("JSON -------\(json)")
                                let status = loginResult["status"] as? String ?? ""
                                let message = loginResult["message"] as? String ?? ""
                                
                                print("STATUSSSS---- : \(status)")
                                if status == "0"{
                                    noDriverFoundViewBool = true
                                    mapView.delegate = nil
                                    rideConfirmTimer?.invalidate()
                                    rideConfirmTimer = nil
                                    progressBarTimer?.invalidate()
                                    progressBarTimer = nil
                                    driverAPICallTimer?.invalidate()
                                    driverAPICallTimer = nil
                                    bookRideAndTimeSloteWiseAPICallTimer?.invalidate()
                                    bookRideAndTimeSloteWiseAPICallTimer = nil
                                    self.currentToDestinationMainView.isHidden=true
                                    self.progressBGView.isHidden = true
                                    self.driverDetailsView.isHidden = false
                                    
                                    //                                    mapView.clear()
                                    //                                    mapView.delegate = nil
                                    myMap.removeAnnotations(myMap.annotations)
                                    
                                    let driverDetails = loginResult["driverDetails"] as? [[String: Any]]
                                    print("driverDetails : \(driverDetails)")
                                    guard let allDriverDetail = driverDetails else {
                                        print("driverDetails is nil")
                                        return
                                    }
                                    
                                    var profilePhotos: String?
                                    var otpPin: Int?
                                    var vehichleImg: String?
                                    var driMobNo: String?
                                    var vehType: Int?
                                    
                                    for allDriverDetails in allDriverDetail{
                                        
                                        self.vehicleNo.text = allDriverDetails["vehicleNumber"] as? String
                                        driver_profile_id = allDriverDetails["fk_member_master_profile_Driver_id"] as? Int
                                        self.vehicleName.text = allDriverDetails["vehicleBrand_model"] as? String
                                        self.driverName.text = allDriverDetails["drivername"] as? String
                                        self.minutesFromAPI = allDriverDetails["pickupDuration"] as? Int ?? 0
                                        profilePhotos = allDriverDetails["profilephoto"] as? String ?? ""
                                        otpPin = allDriverDetails["pin"] as? Int ?? 0
                                        vehichleImg = allDriverDetails["vehiclestaticImage"] as? String ?? ""
                                        driMobNo = allDriverDetails["drivermobilenumber"] as? String ?? ""
                                        vehType = allDriverDetails["vehicletype"] as? Int ?? 0
                                    }
                                    self.myMapBottomConstraint.constant = 300
                                    
                                    //MARK: Not Yet Live API Done
                                    timeFormatChanging(approachTiming: minutesFromAPI)
                                    
                                    print("Driver Approaching Time To User: \(self.driverApproachingUserTiming)")
                                    if let driverProfilePic = profilePhotos {
                                        
                                        let correctedDriverProfilePic = driverProfilePic.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\\", with: "/")
                                        print("Corrected Driver Profile Pic URL: \(correctedDriverProfilePic)")
                                        loadImage(from: correctedDriverProfilePic, into: driverPic)
                                        
                                    } else {
                                        print("Driver profile photo string is nil or not a valid string.")
                                        self.driverPic.image = UIImage(named: "Mask group")
                                    }
                                    
                                    if let otp = otpPin {
                                        self.otpLbl.text = String(otp)
                                    }
                                    
                                    if let imageUrlString = vehichleImg {
                                        let correctedDriverProfilePic = imageUrlString.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\\", with: "/")
                                        print("Corrected Driver Profile Pic URL: \(correctedDriverProfilePic)")
                                        print("Attempting to load image from URL: \(imageUrlString)")
                                        loadImage(from: correctedDriverProfilePic, into: automobileImg)
                                        
                                    }
                                    else {
                                        print("Invalid image URL string.")
                                    }
                                    self.mobLBL.text = driMobNo
                                    var vehicleType = vehType
                                    startProgressView2()
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
        } else {
            print("you are not connected")
            let alert = UIAlertController(title: "No Internet Connection",
                                          message: "It looks like you're offline. Please check your internet connection.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default,handler: { [weak self] _ in
                
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func timeFormatChanging(approachTiming: Int?) {
        if let pickUPDuration = approachTiming {
            let currentDate = Date()
            
            if let futureDate = Calendar.current.date(byAdding: .minute, value: pickUPDuration, to: currentDate) {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                let formattedTime = dateFormatter.string(from: futureDate)
                self.driverApproachingUserTiming = formattedTime
                
                print("Current time + \(minutesFromAPI) minutes = \(formattedTime)")
            }
        }
        
        nsAttributeText(boldText: self.driverApproachingUserTiming ?? "",normalText: "Your ride is confirmed.\nYour driver will reach your pickup location at")
        
        //GOOGLE ANALYTICS
        AnalyticsManager.shared.rideAccepted()
    }
    
    func nsAttributeText(boldText: String, normalText: String) {
        
        let attrs = [NSAttributedString.Key.font : UIFont(name: "Lato-Bold", size: 16)]
        let attributedString = NSMutableAttributedString(string:" \(boldText)", attributes:attrs as [NSAttributedString.Key : Any])
        let normalText = normalText
        let normalString = NSMutableAttributedString(string:normalText)
        normalString.append(attributedString)
        
        DispatchQueue.main.async {
            self.yourRideConfirmLbl.attributedText = normalString
        }
    }
    
    func cancelRideAfterNoDriverFound(){
        if NetworkMonitor.shared.isConnected {
            print("cancelRideAfterNoDriverFound() -> pkbookrideid : \(pkbookrideid)")
            let url = AppConfig.baseURL+"Book/Cancel_ride_after_progressbar"
            let params :  [String : Any] = [
                //            "fk_bookride_id": 169
                "fk_bookride_id": pkbookrideid
            ]
            print("cancelRideAfterNoDriverFound----\(url)")
            print("driverAPICall() -> parameters : \(params)")
            let token = UserDefaults.standard.string(forKey: "auth_deviceToken") ?? ""
            print("cancelRideAfterNoDriverFound----Token\(token)")
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]
            
            AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { [weak self] response in
                guard let self = self else { return }
                print("response : \(response)")
                print("response.result : \(response.result)")
                let statusCode = response.response?.statusCode
                print("statusCode : \(statusCode)")
                
                switch response.result {
                    
                case .success (let data) :
                    if let data = data {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                               let loginResult = json["result"] as? [String: Any] {
                                print("JSON -------cancelRideAfterNoDriverFound*********\(json)")
                                let status = loginResult["status"] as? String ?? ""
                                let message = loginResult["message"] as? String ?? ""
                                
                                if status == "0" {
                                    if isProgressCancelRide {
                                        isProgressCancelRide = false
                                        cancelRideAfterNoDriverFound()
                                    } else {
                                        progressBGView.isHidden = true
                                        noDriverFound.isHidden = false
                                    }
                                } else if status == "-1" {
                                    progressBGView.isHidden = true
                                    noDriverFound.isHidden = false
                                } else if status == "-2" {
                                    driverAPICall()
                                }
                            }
                            
                        } catch {
                            //                                                       self.showAlert(title: "Error", message: "Failed to parse JSON: \(error.localizedDescription)")
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
            //    }
        } else {
            print("you are not connected")
            let alert = UIAlertController(title: "No Internet Connection",
                                          message: "It looks like you're offline. Please check your internet connection.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default,handler: { [weak self] _ in
                
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func cancelRide() {
        
        var whenyoucancelled : String?
        
        if cancelBtnIsCalledFrom == "After Driver Accepted the Ride" {
            whenyoucancelled = "after accepted driver ride"
        } else {
            whenyoucancelled = "while searching"
        }
        let url = AppConfig.baseURL+"Book/Cancel_ride_from_passanger"
        let params :  [String : Any] = [
            
            "fk_bookride_id": pkbookrideid,
            "when_you_cancelled": whenyoucancelled, //while searching and after accepted driver ride
            "remark": rideCancelReason
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
                            print("JSON -------CANCELRIDE*********\(json)")
                            let status = loginResult["status"] as? String ?? ""
                            let message = loginResult["message"] as? String ?? ""
                            
                            if status == "0" || status == "-1"{
                                cancelRideSecondTime()
                            }  else if status == "-2" {
                                loaderActivity1.stopAnimating()
                                cancelRideView.isHidden = true
                                buttonOpticity.isHidden = true
                                buttonOpticity1.isHidden = true
                                loaderActivity1.isHidden = true
                                driverAPICall()
                            }
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
    
    func cancelRideSecondTime() {
        
        var whenyoucancelled : String?
        
        if cancelBtnIsCalledFrom == "After Driver Accepted the Ride" {
            whenyoucancelled = "after accepted driver ride"
        } else {
            whenyoucancelled = "while searching"
        }
        let url = AppConfig.baseURL+"Book/Cancel_ride_from_passanger"
        let params :  [String : Any] = [
            
            "fk_bookride_id": pkbookrideid,
            "when_you_cancelled": whenyoucancelled, //while searching and after accepted driver ride
            "remark": rideCancelReason
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
                            print("JSON -------CANCELRIDE*********\(json)")
                            let status = loginResult["status"] as? String ?? ""
                            let message = loginResult["message"] as? String ?? ""
                            
                            if status == "0" || status == "-1"{
                                
                                //GOOGLE ANALYTICS
                                AnalyticsManager.shared.rideCancelled(reason: rideCancelReason ?? "")
                                
                                
                                rideConfirmTimer?.invalidate()
                                rideConfirmTimer = nil
                                progressBarTimer?.invalidate()
                                progressBarTimer = nil
                                driverAPICallTimer?.invalidate()
                                driverAPICallTimer = nil
                                stopAllTimers()
                                DispatchQueue.main.async {
                                    self.loaderActivity1.stopAnimating()
                                    self.loaderActivity1.isHidden = true
                                    self.buttonOpticity1.isHidden = true
                                    self.buttonOpticity.isHidden = false
                                    self.rideCancelledSuccessfullyImg.isHidden = false
                                    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        self.navigateToMapViewController()
                                        
                                    }
                                }
                                
                                
                            }  else if status == "-2" {
                                loaderActivity1.stopAnimating()
                                cancelRideView.isHidden = true
                                buttonOpticity.isHidden = true
                                buttonOpticity1.isHidden = true
                                loaderActivity1.isHidden = true
                                driverAPICall()
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
    
    func pinAPICall() {
        if NetworkMonitor.shared.isConnected {
            let url = AppConfig.baseURL+"Book/Pin_matched_passanger_will_get_notification"
            let params :  [String : Any] = [
                //            "fk_bookride_id": 6
                "fk_bookride_id": pkbookrideid
            ]
            print("pinAPICall() ->  url : \(url)")
            print("pinAPICall() -> parameters : \(params)")
            let token = UserDefaults.standard.string(forKey: "auth_deviceToken") ?? ""
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]
            AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { [weak self] response in
                guard let self = self else { return }
                print("pinAPICall() -> response : \(response)")
                print("pinAPICall() -> response.result : \(response.result)")
                print("pinAPICall() -> response.error : \(response.error)")
                
                switch response.result {
                    
                case .success (let data) :
                    if let data = data {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                               let loginResult = json["result"] as? [String: Any] {
                                print("pinAPICall() -> JSON -------\(json)")
                                let status = loginResult["status"] as? String ?? ""
                                let message = loginResult["message"] as? String ?? ""
                                let ride = loginResult["ride"] as? String ?? ""
                                let sd_poliline_points_afterpinapicall = loginResult["sd_poliline_points"] as? String ?? ""
                                if ride == "Start" {
                                    print("vehicleNo : \(vehicleNo)")
                                    print("vehicleName : \(vehicleName)")
                                    print("driverName : \(driverName)")
                                    print("mobLBL : \(mobLBL)")
                                    print("pinAPICall() -> drivercoordinates : \(drivercoordinates)")
                                    print("pinAPICall() -> destinationlocationcooordination : \(destinationlocationcooordination)")
                                    if !self.hasNavigatedToRideStarted {
                                        mapView = nil
                                        driverDetailsView = nil
                                        self.hasNavigatedToRideStarted = true
                                        pinRideCancelledDriverApproachingAPICallTimer?.invalidate()
                                        pinRideCancelledDriverApproachingAPICallTimer = nil
                                        TimerManager.shared.stopAllTimers()
                                        //                                    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                                        let enabledVC = self.storyboard?.instantiateViewController(withIdentifier: "RideStartedViewController") as? RideStartedViewController
                                        apiTimer = nil
                                        apiTimer?.invalidate()
                                        //Vehicle Number
                                        if rideStatus == "driverApproachingTowardsPassengerPending" || rideStatus == "tappedNotifcationBanner" {
                                            enabledVC?.current = sourcePlaceName
                                            enabledVC?.destination = destinationPlaceName
                                        } else {
                                            enabledVC?.current = currentLocationSendToRideStartedVC
                                            enabledVC?.destination = destinationLocationSendToRideStartedVC
                                        }
                                        enabledVC?.currentLocationCoordinate = drivercoordinates
                                        enabledVC?.destinationLocationCoordinate = destinationlocationcooordination
                                        enabledVC?.member_master_profile_id = member_master_profile_id
                                        enabledVC?.pk_bookride_id = pkbookrideid
                                        if rideStatus == "searchingRideContinued" {
                                            enabledVC?.current = sourcePlaceName
                                            enabledVC?.destination = destinationPlaceName
                                            enabledVC?.sd_poliline_points = sd_poliline_points
                                        } else {
                                            enabledVC?.sd_poliline_points = sd_poliline_points_afterpinapicall
                                        }
                                        if let vehicleNumber = vehicleNo.text {
                                            enabledVC?.vehicleNumberString = vehicleNumber
                                        } else {
                                            print("vehicleNumber is nil")
                                        }
                                        //Vehicle Model
                                        if let vehicleModel = vehicleName.text {
                                            enabledVC?.vehicleModelString = vehicleModel
                                        } else {
                                            print("vehicleModel is nil")
                                        }
                                        //Driver Name
                                        if let driverName = driverName.text {
                                            enabledVC?.driverNameString = driverName
                                        } else {
                                            print("driverName is nil")
                                        }
                                        //Driver Photo
                                        if let driverPhoto = driverPic.image {
                                            enabledVC?.driverPhotoUI = driverPhoto
                                        } else {
                                            print("driverPhoto is nil")
                                        }
                                        //Vehicle Image
                                        if let vehicleImage = automobileImg.image {
                                            enabledVC?.vehicleImageUI = vehicleImage
                                        } else {
                                            print("vehicleImage is nil")
                                        }
                                        //Driver Mobile Number
                                        if let driverMobileNumber = mobLBL.text {
                                            enabledVC?.driverMobileNumberString = driverMobileNumber
                                        } else {
                                            print("driverMobileNumber is nil")
                                        }
                                        //                                enabledVC?.vehicleNumber.text = vehicleNo.text
                                        //                                enabledVC?.vehicleModel.text = vehicleName.text
                                        //                                enabledVC?.driverName.text = driverName.text
                                        //                                enabledVC?.driverPhoto.image = driverPic.image
                                        //                                enabledVC?.vehicleImage.image = automobileImg.image
                                        //                                enabledVC?.driverMobileNumber.text = mobLBL.text
                                        print("going to RideStartedViewController------------->")
                                        self.navigationController?.pushViewController(enabledVC!, animated: true)
                                    }
                                }
                            } else {
                                print("Something Went Wrong3------------->")
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
        } else {
            print("you are not connected")
            let alert = UIAlertController(title: "No Internet Connection",
                                          message: "It looks like you're offline. Please check your internet connection.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default,handler: { [weak self] _ in
                
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func loadImage(from urlString: String, into imageView: UIImageView) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
        }.resume()
    }
    
    func rideCancelledByDriver() {
        if NetworkMonitor.shared.isConnected {
            let url = AppConfig.baseURL+"Book/If_Cancel_ride_from_Driver_then_passengers_will_Recieve_Noti"
            let params :  [String : Any] = [
                //            "fk_bookride_id": 6
                "fk_bookride_id": pkbookrideid
            ]
            print("rideCancelledByDriver() ->  url : \(url)")
            print("rideCancelledByDriver() -> parameters : \(params)")
            let token = UserDefaults.standard.string(forKey: "auth_deviceToken") ?? ""
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]
            AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { [weak self] response in
                guard let self = self else { return }
                print("rideCancelledByDriver() -> response : \(response)")
                print("rideCancelledByDriver() -> response.result : \(response.result)")
                
                switch response.result {
                    
                case .success (let data) :
                    if let data = data {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                               let loginResult = json["result"] as? [String: Any] {
                                print("rideCancelledByDriver() -> JSON -------\(json)")
                                let status = loginResult["status"] as? String ?? ""
                                let message = loginResult["message"] as? String ?? ""
                                
                                if message == "Cancelled" {
                                    print("Ride Cancelled by Driver")
                                    stopAllTimers()
                                    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                                    
                                    //                                let alertController = UIAlertController(title: "", message: "Ride Cancelled by Driver", preferredStyle: .alert)
                                    let alertController = UIAlertController(title: "", message: "Driver has cancelled the Ride", preferredStyle: .alert)
                                    self.present(alertController, animated: true) {
                                        // Dismiss the alert after 5 seconds
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                                            guard let self = self else { return }
                                            alertController.dismiss(animated: true, completion: nil)
                                            navigateToMapViewController()
                                        }
                                    }
                                    //                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [self] in
                                    //                                    tableView.isHidden = true
                                    //                                    roadPolyline?.map = nil
                                    //                                    currentToRoadDottedPolyline?.map = nil
                                    //                                    destinationDottedPolyline?.map = nil
                                    //                                    dottedPathFromCurrentLocation.removeAllCoordinates()
                                    //                                    dottedPathToDestination.removeAllCoordinates()
                                    //                                    progressBGView.isHidden = false
                                    //                                    pk_bookride_id = 0
                                    //                                    pkbookrideid = 0
                                    //                                    timeslot_pk_bookride_id = 0
                                    //                                    driverDetailsView.isHidden = true
                                    //                                    self.buttonOpticity.isHidden = true
                                    //                                    self.rideCancelledSuccessfullyImg.isHidden = true
                                    //                                    currentToDestinationMainView.isHidden = false
                                    //                                    myMapBottomConstraint.constant = 425
                                    //                                    currentLocationCoordinate = nil
                                    //                                    currentLocationCoordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
                                    //                                    destinationLocationCoordinate = nil
                                    //                                    destinationLocationCoordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
                                    //                                    currentMarker?.map = nil
                                    //                                    destinationMarker?.map = nil
                                    //                                    mapView.clear()
                                    //                                    currentLocationCoordinate = currentlocationcooordination
                                    //                                    destinationLocationCoordinate = destinationlocationcooordination
                                    //                                    self.addCustomMarkers()
                                    //                                    self.calculateRoute()
                                    //                                    self.updateMapRegion()
                                    //                                    self.tableView.reloadData()
                                    //                                    getTimings()
                                    //                                    startProgress()
                                    //                                    startProgressView1()
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
                        
                    }
                case .failure(let error):
                    print("Request failed with error: \(error)")
                }
            }
        } else {
            print("you are not connected")
            let alert = UIAlertController(title: "No Internet Connection",
                                          message: "It looks like you're offline. Please check your internet connection.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default,handler: { [weak self] _ in
                
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func driver_is_2_min_away_from_passenger_location() {
        if NetworkMonitor.shared.isConnected {
            let url = AppConfig.baseURL+"Notification/Driver_is_2_min_away_from_passenger_location"
            let params :  [String : Any] = [
                //            "fk_bookride_id": 6
                "fk_book_id": pkbookrideid,
                //                 "fk_member_master_profile_Driver_id": Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "")
                "fk_member_master_profile_Driver_id": driver_profile_id
            ]
            print("driver_is_2_min_away_from_passenger_location() -> url : \(url)")
            print("driver_is_2_min_away_from_passenger_location() -> parameters : \(params)")
            let token = UserDefaults.standard.string(forKey: "auth_deviceToken") ?? ""
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]
            AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { [weak self] response in
                guard let self = self else { return }
                print("driver_is_2_min_away_from_passenger_location() -> response : \(response)")
                print("driver_is_2_min_away_from_passenger_location() -> response.result : \(response.result)")
                
                switch response.result {
                    
                case .success (let data) :
                    if let data = data {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                               let loginResult = json["result"] as? [String: Any] {
                                print("driver_is_2_min_away_from_passenger_location() -> JSON -------\(json)")
                                let status = loginResult["status"] as? String ?? ""
                                let message = loginResult["message"] as? String ?? ""
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
                    print("driver_is_2_min_away_from_passenger_location() -> Request failed with error: \(error)")
                }
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
    }
    
    func Driver_reached_your_location() {
        if NetworkMonitor.shared.isConnected {
            let url = AppConfig.baseURL+"Notification/Driver_reached_your_location"
            let params :  [String : Any] = [
                //            "fk_bookride_id": 6
                "fk_book_id": pkbookrideid,
                //                "fk_member_master_profile_Driver_id": Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "")
                "fk_member_master_profile_Driver_id": driver_profile_id
            ]
            print("Driver_reached_your_location() ->  url : \(url)")
            print("Driver_reached_your_location() -> parameters : \(params)")
            let token = UserDefaults.standard.string(forKey: "auth_deviceToken") ?? ""
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]
            AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { [weak self] response in
                guard let self = self else { return }
                print("Driver_reached_your_location() -> response : \(response)")
                print("Driver_reached_your_location() -> response.result : \(response.result)")
                
                switch response.result {
                    
                case .success (let data) :
                    if let data = data {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                               let loginResult = json["result"] as? [String: Any] {
                                print("Driver_reached_your_location() -> JSON -------\(json)")
                                let status = loginResult["status"] as? String ?? ""
                                let message = loginResult["message"] as? String ?? ""
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
                    print("Driver_reached_your_location() -> Request failed with error: \(error)")
                }
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
    }
    //    func stopAllTimers() {
    //        progressBarTimer?.invalidate()
    //        rideConfirmTimer?.invalidate()
    //        driverAPICallTimer?.invalidate()
    //        bookRideAndTimeSloteWiseAPICallTimer?.invalidate()
    //        pinRideCancelledDriverApproachingAPICallTimer?.invalidate()
    //
    //        progressBarTimer = nil
    //        rideConfirmTimer = nil
    //        driverAPICallTimer = nil
    //        bookRideAndTimeSloteWiseAPICallTimer = nil
    //        pinRideCancelledDriverApproachingAPICallTimer = nil
    //    }
    func updatePolyline() {
        guard let currentCoordinate = currentLocationCoordinate,
              let destinationCoordinate = destinationLocationCoordinate else {
            let alertController = UIAlertController(title: "func updatepolyline()", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        // Create a path for the polyline
        let path = GMSMutablePath()
        path.add(currentCoordinate)
        path.add(destinationCoordinate)
        
        // If a polyline already exists, update it instead of creating a new one
        if let existingPolyline = roadPolyline {
            existingPolyline.map = nil // Remove the old polyline
        }
        
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 5.0
        polyline.strokeColor = .blue
        polyline.map = mapView // Add the new polyline to the map
        
        roadPolyline = polyline // Keep a reference to the current polyline
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
    func removeElementsBeforeIndex(coordinatesList: inout [CLLocationCoordinate2D], index: Int) {
        guard index >= 0 && index < coordinatesList.count else { return }
        coordinatesList.removeSubrange(0...index)
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
    
    
    func driverApproachingTowardsPassenger() {
        if NetworkMonitor.shared.isConnected {
            let url = AppConfig.baseURL+"Book/get_pass_updated_latlong_when_driver_come_towords_passanger"
            let params :  [String : Any] = [
                //            "fk_bookride_id": 6
                "fk_bookride_id": pkbookrideid
            ]
            print("driverApproachingTowardsPassenger() -> url : \(url)")
            print("driverApproachingTowardsPassenger() -> parameters : \(params)")
            let token = UserDefaults.standard.string(forKey: "auth_deviceToken") ?? ""
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]
            AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { [weak self] response in
                guard let self = self else { return }
                print("driverApproachingTowardsPassenger() -> response : \(response)")
                print("driverApproachingTowardsPassenger() -> response.result : \(response.result)")
                
                switch response.result {
                    
                case .success (let data) :
                    if let data = data {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                               let loginResult = json["result"] as? [String: Any] {
                                print("driverApproachingTowardsPassenger() -> JSON -------\(json)")
                                let status = loginResult["status"] as? String ?? ""
                                let message = loginResult["message"] as? String ?? ""
                                let driverDetails = loginResult["driverDetails"] as? [[String:Any]]
                                print("driverApproachingTowardsPassenger() -> driverDetails : \(driverDetails)")
                                if let driverDetailsArray = driverDetails{
                                    for driverDetailDict in driverDetailsArray {
                                        let fk_bookride_id = driverDetailDict["fk_bookride_id"] as? Int
                                        let latitude = driverDetailDict["latitude"] as? String
                                        let longitude = driverDetailDict["longitude"] as? String
                                        
                                        //                                    let latitude = "19.19837347515327"
                                        //                                    let longitude = "72.95471291989088"
                                        
                                        
                                        dp_poliline_points = driverDetailDict["dp_poliline_points"] as? String
                                        
                                        
                                        print("dp_poliline_points-------- : \(dp_poliline_points)")
                                        print("isdpPolylinePointsobtainedfromDriverlocation-------- : \(isdpPolylinePointsobtainedfromDriverlocation)")
                                        
                                        
                                        print("driverDetailDict -> fk_bookride_id : \(fk_bookride_id)")
                                        print("driverDetailDict -> latitude : \(latitude)")
                                        print("driverDetailDict -> longitude : \(longitude)")
                                        if isdpPolylinePointsobtainedfromDriverlocation == false {
                                            print("dp_poliline_points : \(dp_poliline_points)")
                                            if dp_poliline_points != "" {
                                                if let dp_points = dp_poliline_points {
                                                    print("dp_poliline_points-------- inside if let: \(dp_poliline_points)")
                                                    showPath(polyStr: dp_points)
                                                    isdpPolylinePointsobtainedfromDriverlocation = true
                                                }
                                            }
                                            let coordinates = decodePolyline(dp_poliline_points ?? "")
                                            
                                            // Print the decoded coordinates
                                            for coordinate in coordinates {
                                                print("driverapp : coordinates ::: Latitude: \(coordinate.latitude), Longitude: \(coordinate.longitude)")
                                                //                                            let coordinateString = "\(coordinate.latitude),\(coordinate.longitude)"
                                                polylinecoordinates.append(coordinate)
                                            }
                                            //                                            isdpPolylinePointsobtainedfromDriverlocation = true
                                        }
                                        //                                        polylinecoordinates.removeAll()
                                        print("polylinecoordinates : \(polylinecoordinates)")
                                        if let latitudeStr = latitude, let longitudeStr = longitude,
                                           let driverlatitude = Double(latitudeStr), let driverlongitude = Double(longitudeStr) {
                                            //                                       if let driverlatitude = Double(latitude), let driverlongitude = Double(longitude) {
                                            
                                            let coordinate = CLLocationCoordinate2D(latitude: driverlatitude, longitude: driverlongitude)
                                            print("coordinate ::: \(coordinate)")
                                            //                                        polylinecoordinates.insert(coordinate, at: 0)
                                            print("dddddpolylinecoordinates : \(polylinecoordinates)")
                                            print("driverDetailDict -> fk_bookride_id : \(fk_bookride_id ?? 0)")
                                            print("driverDetailDict -> driverlatitude : \(driverlatitude)")
                                            print("driverDetailDict -> driverlongitude : \(driverlongitude)")
                                            currentLocationCoordinate = nil
                                            currentLocationCoordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
                                            destinationLocationCoordinate = nil
                                            destinationLocationCoordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
                                            
                                            myMap.removeAnnotations(myMap.annotations)
                                            //                                        myMap.removeOverlays(myMap.overlays)
                                            var distanceList = [Double]() // List to store distances for current iteration
                                            var allDistanceList = [Double]() // Master list to store all distance lists
                                            
                                            for i in 0..<polylinecoordinates.count {
                                                let point = polylinecoordinates[i]
                                                let distance = calculateDistance(latZero: driverlatitude, longZero: driverlongitude, lat: point.latitude, long: point.longitude)
                                                print("List- Distance inside calculated: \(distance) m")
                                                
                                                distanceList.append(distance)
                                            }
                                            
                                            // Add the current distance list to the master list
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
                                            //                                        DispatchQueue.global(qos: .background).async {
                                            DispatchQueue.main.async (execute: { [weak self] in
                                                guard let self = self else { return }
                                                //                                            guard !allDistanceList.isEmpty else {
                                                //                                                print("Error: allDistanceList is empty")
                                                //                                                let alertController = UIAlertController(title: "", message: "allDistanceList is empty", preferredStyle: .alert)
                                                //                                                                                                    self.present(alertController, animated: true) {
                                                //                                                                                                        // Dismiss the alert after 5 seconds
                                                //                                                                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                                //                                                                                                            alertController.dismiss(animated: true, completion: nil)
                                                //                                                                                                        }
                                                //                                                                                                    }
                                                //                                                return
                                                //                                            }
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
                                                            //                                                            mapView.clear()
                                                            
                                                            showPath1(polylineCoordinates: polylinecoordinates)
                                                        } else {
                                                            
                                                        }
                                                        drivercoordinates = coordinate
                                                        currentLocationCoordinate = drivercoordinates
                                                        passengercooordinates = currentlocationcooordination
                                                        
                                                        if rideStatus == "driverApproachingTowardsPassengerPending" || rideStatus == "tappedNotifcationBanner" {
                                                            destinationLocationCoordinate = destinationLocationCoordinate
                                                        }
                                                        else {
                                                            destinationLocationCoordinate = passengercooordinates
                                                        }
                                                        
                                                        DispatchQueue.main.async { [weak self] in
                                                            guard let self = self else { return }
                                                            
                                                            currentMarker?.map = nil
                                                            if mapView == nil {
                                                                print("mapView is nil") // Debugging log
                                                            } else {
                                                                self.addCustomMarkers()
                                                                if moveCamera == false {
                                                                    print("kdnfkdngkjdsnfnkdnvjkf=========")
                                                                    self.updateMapRegion()
                                                                }
                                                            }
                                                        }
                                                    } else {
                                                        currentToRoadDottedPolyline?.map = nil
                                                        destinationDottedPolyline?.map = nil
                                                        dottedPathFromCurrentLocation.removeAllCoordinates()
                                                        dottedPathToDestination.removeAllCoordinates()
                                                        roadPolyline = nil
                                                        roadPolyline?.map = nil
                                                        //                                                        mapView.clear()
                                                        drivercoordinates = coordinate
                                                        currentLocationCoordinate = drivercoordinates
                                                        passengercooordinates = currentlocationcooordination
                                                        
                                                        if rideStatus == "driverApproachingTowardsPassengerPending" || rideStatus == "tappedNotifcationBanner" {
                                                            destinationLocationCoordinate = destinationLocationCoordinate
                                                        }
                                                        else {
                                                            destinationLocationCoordinate = passengercooordinates
                                                        }
                                                        DispatchQueue.main.async { [weak self] in
                                                            guard let self = self else { return }
                                                            
                                                            //                                                            currentMarker?.map = nil
                                                            //                                                            self.addCustomMarkers()
                                                            if moveCamera == false {
                                                                print("kdnfkdngkjdsnfnkdnvjkf=========")
                                                                self.updateMapRegion()
                                                            }
                                                        }
                                                        
                                                    }
                                                }
                                                catch {
                                                    print("Error finding minimum index: \(error.localizedDescription)")
                                                    let alertController = UIAlertController(title: "Network Error", message: "", preferredStyle: .alert)
                                                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                                    alertController.addAction(okAction)
                                                    self.present(alertController, animated: true, completion: nil)
                                                }
                                            })
                                            
                                        } else {
                                            
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
                    print("driverApproachingTowardsPassenger() -> Request failed with error: \(error)")
                }
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
    
    @objc func handleForceUpdate(_ notification: Notification) {
        sessionTimeOut()
    }
    
    @objc func sessionTimeOut() {
        if Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "") != 0 || UserDefaults.standard.string(forKey: "fk_member_master_profile_id") !=  nil {
            //        gpsdisableAlert()
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
            print("BookACabViewController() -> sessionTimeOut() -> url : \(url)")
            print("BookACabViewController() -> sessionTimeOut() -> params : \(params)")
            AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { [weak self] response in
                guard let self = self else { return }
                
                print("recentSearchList() -> response : \(response.result)")
                switch response.result {
                    
                case .success (let data) :
                    if let data = data {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                               let loginResult = json["result"] as? [String: Any] {
                                print("BookACabViewController() -> sessionTimeOut() -> JSON -------\(json)")
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
                                        //                                            let alertController = UIAlertController(title: "", message: "Session Time out , Member is deleted!!", preferredStyle: .alert)
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
                                        //                                            let alertController = UIAlertController(title: "", message: "Session Timeout. Another user logged in with the same number!", preferredStyle: .alert)
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

//MARK: TABLEVIEW PROTOCOLS
extension BookACabViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("rideTypeLbl.count : \(rideTypeLbl.count)")
        //        if rideTypeLbl.count == 1{
        //            myMapBottomConstraint.constant = 280
        //            currentToDestinationMainViewHeightConstraint.constant = 280
        //        } else if rideTypeLbl.count == 2 {
        //            myMapBottomConstraint.constant = 284
        //            currentToDestinationMainViewHeightConstraint.constant = 284
        //        } else {
        //            myMapBottomConstraint.constant = 426
        //            currentToDestinationMainViewHeightConstraint.constant = 426
        //        }
        return rideTypeLbl.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookACabTableViewCell") as! BookACabTableViewCell
        cell.layer.cornerRadius = 12
        cell.selectionStyle = .none
        cell.bookACabCellView.layer.cornerRadius = 12
        cell.bookACabCellView.layer.masksToBounds = true
        cell.bookACabCellView.layer.borderWidth = 3.0
        cell.bookACabCellView.layer.borderColor = UIColor.clear.cgColor
        //        cell.bookACabCellView.layer.borderColor = UIColor(red: 252, green: 176, blue: 58).cgColor
        //        cell.layer.borderWidth = 5.0
        //        cell.layer.borderColor = UIColor(red: 252, green: 176, blue: 58).cgColor
        //        [UIImage(named: "autoRickshaw"),UIImage(named: "non-ac-taxi"),UIImage(named: "ac-Taxi")]
        let width = UIScreen.main.bounds.width
        print("width : \(width)")
        if width < 400 {
            cell.subTitle.font = UIFont.systemFont(ofSize: 9)
        }
        if indexPath.row < rideTypeLbl.count {
            cell.subTitle.textColor = UIColor(red: 72, green: 72, blue: 72)
            let rideFareCell = rideFareLbl[indexPath.row]
            // Use rideFare as needed
            print("rideFare: \(rideFare)")
            cell.rideFareLbl.text = "₹" + String(rideFareCell)
            self.analyticsRideFare = rideFareCell
            //            cell.rideTypeImg.image = rideTypeImg[indexPath.row]
            cell.rideTypeLbl.text = rideTypeLbl[indexPath.row]
            //            cell.rideExpInMins.text=rideExpInMins[indexPath.row]
            for fare in farelist {
                if vehicleTypeID == 1 {
                    rideFare = rideFareLbl[0]
                    cell.rideTypeLbl.text = fare["vehicletypename"] as? String ?? ""
                    bookBtnTitle = fare["vehicletypename"] as? String ?? ""
                    var randomNumGen = Int.random(in: 1...7)
                    cell.rideExpInMins.text=String(randomNumGen)+" mins"
                    cell.rideTypeImg.image = UIImage(named: "rickshaw_img")
                    cell.subTitle.text = "Final Fare is as per meter"
                    cell.fareCardBtn.addTarget(self, action: #selector(rickshawFareRateChart), for: .touchUpInside)
                } else if vehicleTypeID == 2 {
                    //                    cell.rideTypeLbl.text = "AC Taxi"
                    cell.rideTypeLbl.text = fare["vehicletypename"] as? String ?? ""
                    var randomNumGen = Int.random(in: 5...20)
                    cell.rideExpInMins.text=String(randomNumGen)+" mins"
                    cell.rideTypeImg.image = UIImage(named: "ac_taxi")
                    cell.subTitle.isHidden = true
                    cell.fareCardBtn.addTarget(self, action: #selector(acnNonACFareRateChart), for: .touchUpInside)
                } else if vehicleTypeID == 3 {
                    //                    cell.rideTypeLbl.text = "Non-AC Taxi"
                    cell.rideTypeLbl.text = fare["vehicletypename"] as? String ?? ""
                    var randomNumGen = Int.random(in: 10...20)
                    cell.rideExpInMins.text=String(randomNumGen)+" mins"
                    cell.rideTypeImg.image = UIImage(named: "non-ac-taxi")
                    cell.subTitle.text = "Final Fare is as per meter + Toll"
                    cell.fareCardBtn.addTarget(self, action: #selector(acnNonACFareRateChart), for: .touchUpInside)
                }
            }
        } else {
            print("Index out of range for rideFareLbl")
            // Handle the case where indexPath.row is out of range
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        rideFare = rideFareLbl[indexPath.row]
        let selectedRideType = rideTypeLbl[indexPath.row]
        //        if let currentCoordinate = currentLocationCoordinate,
        //           let destinationCoordinate = destinationLocationCoordinate {
        //
        //            // Create bounds that encompass both coordinates
        //            let bounds = GMSCoordinateBounds(coordinate: currentCoordinate, coordinate: destinationCoordinate)
        //
        //            // Adjust the camera to fit both locations
        //            if isZoomForFirstTime == true {
        //                let update = GMSCameraUpdate.fit(bounds, withPadding: 100.0)
        //                mapView.moveCamera(update)
        //                isZoomForFirstTime = false
        //                mapView.isUserInteractionEnabled = false
        //            }
        //        }
        switch vehicleTypeID {
        case 1:
            bookBtn.isHidden=false
            //            bookBtn.setTitle("BOOK AUTO-RICKSHAW", for: .normal)
            let title = "BOOK \(bookBtnTitle ?? "")".uppercased()
            bookBtn.setTitle(title, for: .normal)
            vehicleTypeID = 1
        case 3:
            bookBtn.isHidden=false
            //            bookBtn.setTitle("BOOK NON AC TAXI", for: .normal)
            let title = "BOOK \(bookBtnTitle ?? "")".uppercased()
            bookBtn.setTitle(title, for: .normal)
            vehicleTypeID = 3
        case 2:
            bookBtn.isHidden=false
            //            bookBtn.setTitle("BOOK AC TAXI", for: .normal)
            let title = "BOOK \(bookBtnTitle ?? "")".uppercased()
            bookBtn.setTitle(title, for: .normal)
            vehicleTypeID = 2
        default:
            bookBtn.setTitle("BOOK", for: .normal)
        }
    }
    @objc func rickshawFareRateChart() {
        //        var pdfURL = URL(string: "https://transport.maharashtra.gov.in/Site/Upload/GR/Auto%20English%201.pdf")
        var pdfURL = URL(string: "https://transport.maharashtra.gov.in/Site/Upload/GR/Auto%20Rickshaw%20Tariff%20Card.pdf")
        //        guard let url = pdfURL else { return }
        //        if UIApplication.shared.canOpenURL(url) {
        //            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        //        } else {
        //            print("Cannot open URL")
        //        }
        let otpVC = storyboard?.instantiateViewController(identifier: "FareCardViewController") as! FareCardViewController
        otpVC.urlString = "https://transport.maharashtra.gov.in/Site/Upload/GR/Auto%20Rickshaw%20Tariff%20Card.pdf"
        self.navigationController?.pushViewController(otpVC, animated: true)
    }
    @objc func acnNonACFareRateChart() {
        //        var pdfURL = URL(string: "https://transport.maharashtra.gov.in/Site/Upload/GR/YB%20Taxi%20English%201.pdf")
        var pdfURL = URL(string: "https://transport.maharashtra.gov.in/Site/Upload/GR/Black%20Yellow%20Taxi%20Tariff%20Card.pdf")
        //        guard let url = pdfURL else { return }
        //        if UIApplication.shared.canOpenURL(url) {
        //            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        //        } else {
        //            print("Cannot open URL")
        //        }
        let otpVC = storyboard?.instantiateViewController(identifier: "FareCardViewController") as! FareCardViewController
        otpVC.urlString = "https://transport.maharashtra.gov.in/Site/Upload/GR/Black%20Yellow%20Taxi%20Tariff%20Card.pdf"
        self.navigationController?.pushViewController(otpVC, animated: true)
    }
}

//MARK: TEXTFIELD DELEGATES
extension BookACabViewController: UITextFieldDelegate {
    @objc func textFieldDidChange(_ textField: UITextField) {
        print("TEXTFIELD TAPPED")
        if textField == currentLocationTxtField {
            //            textFieldResponderDelegate?.currentTFResponder()
            //            let otpVC = self.storyboard?.instantiateViewController(identifier: "MapViewController") as! MapViewController
            //            self.navigationController?.pushViewController(otpVC, animated: true)
            TimerManager.shared.stopAllTimers()
            PopBackToDelegate?.goToBackDest(current: self.currentLoc, dest: self.destinationLoc, curreCoordinate: self.currentlocationcooordination, destCoordinate: self.destinationlocationcooordination, profileID: self.member_master_profile_id, locUnservice: "comingFromCurrentTextField")
            //            let otpVC = self.storyboard?.instantiateViewController(identifier: "CurrenttoDestinationViewController") as! CurrenttoDestinationViewController
            apiTimer = nil
            apiTimer?.invalidate()
            //            otpVC.currentLocation = currentLoc
            //            otpVC.destinationLocation = destinationLoc
            //            otpVC.member_master_profile_id = member_master_profile_id
            //            otpVC.currentlocationcooordination = currentlocationcooordination
            //            otpVC.destinationlocationcooordination = destinationlocationcooordination
            //            otpVC.locationUnServiceable = "comingFromCurrentTextField"
            //            self.navigationController?.pushViewController(otpVC, animated: true)
            self.navigationController?.popViewController(animated: true)
        } else {
            //            textFieldResponderDelegate?.destinationTFResponder()
            TimerManager.shared.stopAllTimers()
            PopBackToDelegate?.goToBackDest(current: self.currentLoc, dest: self.destinationLoc, curreCoordinate: self.currentlocationcooordination, destCoordinate: self.destinationlocationcooordination, profileID: self.member_master_profile_id, locUnservice: "comingFromDestinationTextField")
            //            let otpVC = self.storyboard?.instantiateViewController(identifier: "CurrenttoDestinationViewController") as! CurrenttoDestinationViewController
            apiTimer = nil
            apiTimer?.invalidate()
            //            otpVC.currentLocation = currentLoc
            //            otpVC.destinationLocation = destinationLoc
            //            otpVC.currentlocationcooordination = currentlocationcooordination
            //            otpVC.member_master_profile_id = member_master_profile_id
            //            otpVC.destinationlocationcooordination = destinationlocationcooordination
            //            otpVC.locationUnServiceable = "comingFromDestinationTextField"
            //            self.navigationController?.pushViewController(otpVC, animated: true)
            self.navigationController?.popViewController(animated: true)
            
        }
        //        self.navigationController?.popViewController(animated: true)
    }
}

extension BookACabViewController {
    func convertTimeStringToSeconds(timeString: String) -> Float? {
        let components = timeString.split(separator: ":")
        guard components.count == 3,
              let hours = Float(components[0]),
              let minutes = Float(components[1]),
              let seconds = Float(components[2]) else {
            return nil
        }
        
        return hours * 3600 + minutes * 60 + seconds
    }
    
    func rotateImageBy180Degrees(image: UIImage) -> UIImage? {
        // Create a new context of the same size as the image
        UIGraphicsBeginImageContext(image.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        // Move the origin to the middle of the image to rotate around the center
        context.translateBy(x: image.size.width / 2, y: image.size.height / 2)
        
        // Rotate the context by 180 degrees (pi radians)
        context.rotate(by: .pi)
        
        // Draw the image in the context, offset by half the width and height to center it
        image.draw(in: CGRect(x: -image.size.width / 2, y: -image.size.height / 2, width: image.size.width, height: image.size.height))
        
        // Get the new image from the context
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // Clean up the context
        UIGraphicsEndImageContext()
        
        return rotatedImage
    }
    
    
    func rotateImageBy270Degrees(image: UIImage) -> UIImage? {
        // Create a new context of the same size as the image
        UIGraphicsBeginImageContext(image.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        // Move the origin to the middle of the image to rotate around the center
        context.translateBy(x: image.size.width / 2, y: image.size.height / 2)
        
        // Rotate the context by 270 degrees (3 * pi / 2 radians)
        context.rotate(by: 3 * .pi / 2)
        
        // Draw the image in the context, offset by half the width and height to center it
        image.draw(in: CGRect(x: -image.size.width / 2, y: -image.size.height / 2, width: image.size.width, height: image.size.height))
        
        // Get the new image from the context
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // Clean up the context
        UIGraphicsEndImageContext()
        
        return rotatedImage
    }
    
    
    func correctedImageOrientation(image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        
        // Use the appropriate method to handle the image orientation
        let orientedImage = ciImage.oriented(forExifOrientation: Int32(image.imageOrientation.rawValue))
        
        let context = CIContext(options: nil)
        guard let outputCGImage = context.createCGImage(orientedImage, from: orientedImage.extent) else { return nil }
        
        return UIImage(cgImage: outputCGImage)
    }
}

extension UIImage {
    static func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        let path = UIBezierPath(ovalIn: rect)
        color.setFill()
        path.fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func scaled(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
}

extension CLLocation {
    func distance(from location: CLLocation) -> Double {
        let earthRadiusKm: Double = 6371.0
        
        let dLat = (location.coordinate.latitude - self.coordinate.latitude).toRadians()
        let dLon = (location.coordinate.longitude - self.coordinate.longitude).toRadians()
        
        let lat1 = self.coordinate.latitude.toRadians()
        let lat2 = location.coordinate.latitude.toRadians()
        
        let a = sin(dLat/2) * sin(dLat/2) + sin(dLon/2) * sin(dLon/2) * cos(lat1) * cos(lat2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        
        return earthRadiusKm * c
    }
}

// Extension for Double to convert degrees to radians
extension Double {
    func toRadians() -> Double {
        return self * .pi / 180.0
    }
}

extension Float {
    var radians: Float { return self * .pi / 180.0 }
}


extension UIColor {
    convenience init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexString = hexString.replacingOccurrences(of: "#", with: "")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        let r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
extension Double {
    var radians: Double { return self * .pi / 180 }  // Converts degrees to radians
    var degrees: Double { return self * 180 / .pi }  // Converts radians to degrees
}
