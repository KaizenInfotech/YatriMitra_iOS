//
//  CurrenttoDestinationViewController.swift
//  yatriMitra
//
//  Created by Kaizen Infotech Solutions Private Limited. on 12/06/24.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import GooglePlaces
import MapKit
import CoreLocation

protocol PopBackViewControllerProtocol: AnyObject{
    func dataPassBack(memberID: Int?)
}

class CurrenttoDestinationViewController: UIViewController,UITextFieldDelegate, PopBack, PopBackTo {
    
    
    @IBOutlet weak var seearchRideBtn: UIButton!
    @IBOutlet weak var recentSearchesTableView: UITableView!
    @IBOutlet weak var destinationLocationTxtField: UITextField!
    @IBOutlet weak var autoSuggestPlaces: UIView!
    @IBOutlet weak var buttonOpticity: UIButton!
    @IBOutlet weak var locationUnservicableImg: UIImageView!
    @IBOutlet weak var locationUnservicableBtn: UIButton!
    @IBOutlet weak var currentLocationTxtField: UITextField!
    @IBOutlet weak var currentDestinationView: UIView!
    @IBOutlet weak var recentSearchesTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var autoSuggestPlacesHeight: NSLayoutConstraint!
    @IBOutlet weak var noResultsFoundImg: UIImageView!
    @IBOutlet weak var noResultsFoundLbl: UILabel!
    @IBOutlet weak var currentLocationTxtFieldCrossBtn: UIButton!
    @IBOutlet weak var currentLocationTxtFieldCrossImg: UIImageView!
    @IBOutlet weak var destinationLocationTxtFieldCrossImg: UIImageView!
    @IBOutlet weak var autoCompleteRecentSearchesActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var destinationLocationTxtFieldCrossBtn: UIButton!
    @IBOutlet weak var noResultsFoundView: UIView!
    
    
    //MARK: PROTOCOL VARIABLES ------
    
    weak var popBackViewControllerProtocolDelegate: PopBackViewControllerProtocol?
    
    var currentAppVersion: String?
    var member_master_profile_id : Int?
    var isCurrentTFTouched = false
    var currentLocation : String?
    var destinationLocation : String?
    var textFieldCalledFrom : String?
    var autoSuggestPlacestableView = UITableView()
    var placesClient: GMSPlacesClient!
    var autocompleteResults: [GMSAutocompletePrediction] = []
    var currentLocationautocompleteResults: [GMSAutocompletePrediction] = []
    var destinationLocationautocompleteResults: [GMSAutocompletePrediction] = []
    var recentSearches: [String] = []
    private var autocompleteController: GMSAutocompleteResultsViewController?
    var sessionToken: GMSAutocompleteSessionToken?
    var totalTime : String?
    var firstTime : String?
    var locationUnServiceable : String?
    var currentlocationcooordination: CLLocationCoordinate2D?
    var destinationlocationcooordination: CLLocationCoordinate2D?
    let geoCoder = CLGeocoder()
    var mainLat : CLLocationDegrees?
    var mainLong : CLLocationDegrees?
    var dash : String?
    var newValueCurrentLocation: GMSAutocompletePrediction?
    var LocTextFieldTapped : String?
    var activeTextField: UITextField?
    var lastClickTime: CFTimeInterval = 0
    var iOSversion: String?
    var apiTimer : Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        print("currentlocationcooordination : \(currentlocationcooordination)")
        print("recentSearches : \(recentSearches)")
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleForceUpdate),
                                               name: .forceUpdate,
                                               object: nil)
        if let apiTimer = apiTimer {
            TimerManager.shared.registerTimer(apiTimer)
        }
        placesClient = GMSPlacesClient.shared()
        createNavigationBar()
        NetworkMonitor.shared
        currentDestinationView.layer.cornerRadius=10
        currentDestinationView.layer.shadowOpacity = 0.5 // Adjust opacity to your preference
        currentDestinationView.layer.shadowOffset = CGSize(width: 5, height: 5) // Bottom and right offset
        currentDestinationView.layer.shadowRadius = 5 // Adjust radius to your preference
        currentLocationTxtField.text = currentLocation
        if currentLocationTxtField.text != "" {
            currentLocationTxtFieldCrossImg.isHidden = false
            currentLocationTxtFieldCrossBtn.isHidden = false
        } else if currentLocationTxtField.text == "" {
            currentLocationTxtFieldCrossImg.isHidden = true
            currentLocationTxtFieldCrossBtn.isHidden = true
        }
        if destinationLocationTxtField.text != "" {
            destinationLocationTxtFieldCrossImg.isHidden = false
            destinationLocationTxtFieldCrossBtn.isHidden = false
        } else if destinationLocationTxtField.text == "" {
            destinationLocationTxtFieldCrossImg.isHidden = true
            destinationLocationTxtFieldCrossBtn.isHidden = true
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        addDoneButtonOnNumpad(textField: destinationLocationTxtField)
        addDoneButtonOnNumpad(textField: currentLocationTxtField)
        currentLocationTxtField.delegate=self
        currentLocationTxtField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        destinationLocationTxtField.delegate=self
        destinationLocationTxtField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        //        tableView.frame = CGRect(x: 20, y: 300, width: self.view.frame.width - 40, height: 300)
        //        tableView.layer.cornerRadius = 10
        autoSuggestPlacestableView.dataSource = self
        autoSuggestPlacestableView.delegate = self
        recentSearchesTableView.delegate = self
        recentSearchesTableView.dataSource = self
        seearchRideBtn.layer.cornerRadius = 15
        //                self.view.addSubview(tableView)
        recentSearchesTableView.separatorStyle = .none
        self.autoSuggestPlaces.addSubview(autoSuggestPlacestableView)
        autoSuggestPlacestableView.translatesAutoresizingMaskIntoConstraints = false
        autoSuggestPlaces.layer.cornerRadius = 10
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
        locationUnservicableImg.isUserInteractionEnabled = true
        var dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissImg))
        locationUnservicableImg.addGestureRecognizer(dismissTap)
        buttonOpticity.isUserInteractionEnabled = true
        var dismissTap1 = UITapGestureRecognizer(target: self, action: #selector(dismissImg))
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(navigatetoMapVConTappingCurrentLocationTF))
        //        currentLocationTxtField.addGestureRecognizer(tapGesture1)
        buttonOpticity.addGestureRecognizer(dismissTap1)
        autoSuggestPlacestableView.isHidden = true
        locationUnservicableImg.isHidden = true
        locationUnservicableBtn.isHidden = true
        currentLocationTxtFieldCrossImg.isHidden = false
        currentLocationTxtFieldCrossBtn.isHidden = false
        destinationLocationTxtFieldCrossImg.isHidden = false
        destinationLocationTxtFieldCrossBtn.isHidden = false
        buttonOpticity.isHidden = true
        //        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        noResultsFoundView.addGestureRecognizer(tapGesture)
        noResultsFoundView.isUserInteractionEnabled = true
        //        setupClearButtonForTextField()
        crossBtnAtTxtFields()
        getAppVersion()
        startAPITimer()
        if let apiTimer = apiTimer {
            TimerManager.shared.registerTimer(apiTimer)
        }
    }
    
    func getAppVersion() {
        
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            print("App Version: \(appVersion)")
            self.currentAppVersion = appVersion
        }
    }
    
    func goToBack(current: String?, dest: String?, curreCoordinate: CLLocationCoordinate2D?, destCoordinate: CLLocationCoordinate2D?, profileID: Int?) {
        self.currentLocation = current
        self.destinationLocation = dest
        self.currentlocationcooordination = curreCoordinate
        self.destinationlocationcooordination = destCoordinate
        self.member_master_profile_id = profileID
    }
    
    func goToBackDest(current: String?, dest: String?, curreCoordinate: CLLocationCoordinate2D?, destCoordinate: CLLocationCoordinate2D?, profileID: Int?, locUnservice: String?) {
        self.currentLocation = current
        self.destinationLocation = dest
        self.member_master_profile_id = profileID
        self.currentlocationcooordination = curreCoordinate
        self.destinationlocationcooordination = destCoordinate
        self.locationUnServiceable = locUnservice
    }
    
    func startAPITimer() {
        apiTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(sessionTimeOut), userInfo: nil, repeats: true)
        
    }
    @objc func dismissImg() {
        locationUnservicableImg.isHidden = true
        buttonOpticity.isHidden = true
        locationUnservicableBtn.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        placesClient = nil
        autoSuggestPlacestableView.removeFromSuperview()
        activeTextField = nil
        apiTimer?.invalidate()
        apiTimer = nil
        popBackViewControllerProtocolDelegate = nil
        autoSuggestPlacestableView.delegate = nil
        autoSuggestPlacestableView.dataSource = nil
    }
    

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        if locationUnServiceable == "locationIsNotAvailable" {
            print("currentLocation : \(currentLocation)")
            print("destinationLocation : \(destinationLocation)")
            locationUnservicableImg.isHidden = false
            buttonOpticity.isHidden = false
            locationUnservicableBtn.isHidden = false
            currentLocationTxtField.text = currentLocation
            destinationLocationTxtField.text = destinationLocation
            if currentLocationTxtField.text != "" {
                currentLocationTxtFieldCrossImg.isHidden = false
                currentLocationTxtFieldCrossBtn.isHidden = false
            } else if currentLocationTxtField.text == "" {
                currentLocationTxtFieldCrossImg.isHidden = true
                currentLocationTxtFieldCrossBtn.isHidden = true
            }
            if destinationLocationTxtField.text != "" {
                destinationLocationTxtFieldCrossImg.isHidden = false
                destinationLocationTxtFieldCrossBtn.isHidden = false
            } else if destinationLocationTxtField.text == "" {
                destinationLocationTxtFieldCrossImg.isHidden = true
                destinationLocationTxtFieldCrossBtn.isHidden = true
            }
            //            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) { [self] in
            //                let otpVC = storyboard?.instantiateViewController(identifier: "MapViewController") as! MapViewController
            //                //        otpVC.recentSearches = recentSearches
            //                //        otpVC.currentLocation = currentLoc
            //                //        otpVC.destinationLocation = destinationLoc
            //                otpVC.currentlocationcooordination = currentlocationcooordination
            //                otpVC.destinationlocationcooordination = destinationlocationcooordination
            //                self.navigationController?.pushViewController(otpVC, animated: true)
            //            }
        } else if locationUnServiceable == "comingFromDestinationTextField" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.destinationLocationTxtField.becomeFirstResponder()
            }
            seearchRideBtn.isHidden = false
        } else if locationUnServiceable == "comingFromCurrentTextField" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.currentLocationTxtField.becomeFirstResponder()
            }
            seearchRideBtn.isHidden = false
        }
        
        if currentLocation != nil && destinationLocation != nil {
            currentLocationTxtField.text = currentLocation
            destinationLocationTxtField.text = destinationLocation
            seearchRideBtn.isHidden = false
        }
        recentSearchList()
        //        recentSearchesTableView.reloadData()
        
    }
    func setupClearButtonForTextField() {
        // Create the button with an "X" symbol
        if LocTextFieldTapped == "destinationLocTextFieldTapped" {
            let clearButton1 = UIButton(type: .custom)
            clearButton1.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
            clearButton1.frame = CGRect(x: 0, y: 0, width: 20, height: 20) // Adjust size as needed
            clearButton1.tintColor = .gray // Adjust color if needed
            clearButton1.addTarget(self, action: #selector(clearTextField1), for: .touchUpInside)
            
            // Set it as the right view of the text field
            destinationLocationTxtField.rightView = clearButton1
            destinationLocationTxtField.rightViewMode = .whileEditing // Only show the button when editing
        } else {
            let clearButton = UIButton(type: .custom)
            clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
            clearButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20) // Adjust size as needed
            clearButton.tintColor = .gray // Adjust color if needed
            clearButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
            
            // Set it as the right view of the text field
            currentLocationTxtField.rightView = clearButton
            currentLocationTxtField.rightViewMode = .whileEditing
        }
    }
    @objc func clearTextField() {
        currentLocationTxtField.text = ""
        currentlocationcooordination = nil
        currentLocationTxtField.becomeFirstResponder()
    }
    @objc func clearTextField1() {
        destinationLocationTxtField.text = ""
        destinationlocationcooordination = nil
        destinationLocationTxtField.becomeFirstResponder()
    }
    
    // Optional: You can implement the UITextFieldDelegate method to hide/show the clear button if needed
    
    
    func convertStringsToPredictions(strings: [String]) -> [CustomAutocompletePrediction] {
        return strings.map { string in
            // Create attributed text versions of the string
            let attributedPrimaryText = NSAttributedString(string: string)
            let attributedFullText = NSAttributedString(string: string)
            
            // Create a custom prediction
            return CustomAutocompletePrediction(
                placeID: UUID().uuidString, // Using a random ID for example
                attributedPrimaryText: attributedPrimaryText,
                attributedFullText: attributedFullText
            )
        }
    }
    
    @objc func navigatetoMapVConTappingCurrentLocationTF() {
//        let otpVC = self.storyboard?.instantiateViewController(identifier: "MapViewController") as! MapViewController
        apiTimer = nil
        apiTimer?.invalidate()
//        otpVC.member_master_profile_id = member_master_profile_id
        self.popBackViewControllerProtocolDelegate?.dataPassBack(memberID: self.member_master_profile_id)
//        self.navigationController?.pushViewController(otpVC, animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    
    func crossBtnAtTxtFields() {
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        clearButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20) // Adjust size as needed
        clearButton.tintColor = .gray // Adjust color if needed
        clearButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        
        // Set it as the right view of the text field
        currentLocationTxtField.rightView = clearButton
        currentLocationTxtField.rightViewMode = .always
        let clearButton1 = UIButton(type: .custom)
        clearButton1.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        clearButton1.frame = CGRect(x: 0, y: 0, width: 20, height: 20) // Adjust size as needed
        clearButton1.tintColor = .gray // Adjust color if needed
        clearButton1.addTarget(self, action: #selector(clearTextField1), for: .touchUpInside)
        
        // Set it as the right view of the text field
        destinationLocationTxtField.rightView = clearButton1
        destinationLocationTxtField.rightViewMode = .always
    }
    var visibilityTimer: Timer?
    @objc func textFieldDidChange(_ textField: UITextField) {
        //        if textField.text?.isEmpty ?? true {
        //            autoSuggestPlaces.isHidden=true
        //            autoSuggestPlacestableView.isHidden = true
        //        } else {
        if let textCount = textField.text?.count, textCount > 0 {
            // Cancel any existing timer
            visibilityTimer?.invalidate()
            autoCompleteRecentSearchesActivityIndicator.isHidden = false
            autoCompleteRecentSearchesActivityIndicator.startAnimating()
            autoSuggestPlaces.isHidden = false
            autoSuggestPlacestableView.isHidden = false
            noResultsFoundView.isHidden = true
            // Schedule a new timer to make the view visible after 5 seconds of no input
            visibilityTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
                guard let self = self else { return }
                print("No new input for 5 seconds, showing autoSuggestPlaces")
                if textField == currentLocationTxtField {
                    LocTextFieldTapped = "currentLocTextFieldTapped"
                    
                    print("currentLocationTxtField.text?.count : \(textField.text?.count)")
                    if textField.text?.isEmpty ?? true || textField.text?.count == 0 {
                        autoSuggestPlaces.isHidden=true
                        autoSuggestPlacestableView.isHidden = true
                        currentLocationTxtField.text = ""
                        currentlocationcooordination = nil
                        print("currentlocationcooordination.text?.count : \(currentlocationcooordination)")
                        currentLocationTxtField.delegate = self
                        currentLocationTxtField.becomeFirstResponder()
                    }
                    currentLocationTxtFieldCrossImg.isHidden = false
                    currentLocationTxtFieldCrossBtn.isHidden = false
                    isCurrentTFTouched = true
                    guard let query = textField.text, !query.isEmpty else {
                        autocompleteResults = []
                        autoSuggestPlacestableView.reloadData()
                        return
                    }
                    let filter = GMSAutocompleteFilter()
                    filter.country = "IN"
                    //                    filter.type = .noFilter
                    // Define the geographical bounds
                    let southwestCorner = CLLocationCoordinate2D(latitude: 18.901133, longitude: 72.658744) // Southwest corner (Mumbai)
                    let northeastCorner = CLLocationCoordinate2D(latitude: 19.324753, longitude: 73.096050) // Northeast corner (Sasunavghar, Maharashtra 401208)
                    let bounds = GMSCoordinateBounds(coordinate: southwestCorner, coordinate: northeastCorner)
                    autocompleteController?.autocompleteFilter = filter
                    //                    filter.type = .noFilter
                    
                    placesClient?.findAutocompletePredictions(fromQuery: query, filter: filter, sessionToken: nil, callback: { (results, error) in
                        if let error = error {
                            print("Error: \(error.localizedDescription)")
                            return
                        }
                        
                        if let results = results {
                            self.autocompleteResults = results
                            self.autoSuggestPlacestableView.reloadData()
                        }
                        //                        if let results = results {
                        //                                   // Filter results to stay within bounds
                        //                                   self.autocompleteResults = []
                        //                                   let dispatchGroup = DispatchGroup()
                        //
                        //                                   for prediction in results {
                        //                                       dispatchGroup.enter()
                        //                                       let placeID = prediction.placeID // No need for 'if let', placeID is non-optional
                        //                                       self.placesClient?.fetchPlace(fromPlaceID: placeID, placeFields: [.coordinate], sessionToken: self.sessionToken) { place, error in
                        //                                           if let error = error {
                        //                                               print("Error fetching place details: \(error.localizedDescription)")
                        //                                           } else if let place = place {
                        //                                               let coordinate = place.coordinate
                        //                                               if bounds.contains(coordinate) {
                        //                                                   self.autocompleteResults.append(prediction)
                        //                                               }
                        //                                           }
                        //                                           dispatchGroup.leave()
                        //                                       }
                        //                                   }
                        //
                        //                                   dispatchGroup.notify(queue: .main) {
                        //                                       self.autoSuggestPlacestableView.reloadData()
                        //                                   }
                        //                               }
                    })
                } else if textField == destinationLocationTxtField {
                    print("destinationLocationTxtField.text?.count : \(textField.text?.count)")
                    LocTextFieldTapped = "destinationLocTextFieldTapped"
                    
                    if textField.text?.isEmpty ?? true || textField.text?.count == 0 {
                        autoSuggestPlaces.isHidden=true
                        autoSuggestPlacestableView.isHidden = true
                        destinationLocationTxtField.text = ""
                        destinationlocationcooordination = nil
                        print("destinationlocationcooordination.text?.count : \(destinationlocationcooordination)")
                        destinationLocationTxtField.delegate = self
                        destinationLocationTxtField.becomeFirstResponder()
                    } else {
                        destinationLocationTxtFieldCrossImg.isHidden = false
                        destinationLocationTxtFieldCrossBtn.isHidden = false
                        isCurrentTFTouched = false
                        guard let query = textField.text, !query.isEmpty else {
                            autocompleteResults = []
                            autoSuggestPlacestableView.reloadData()
                            return
                        }
                        let filter = GMSAutocompleteFilter()
                        filter.country = "IN"
                        //                        filter.type = .noFilter
                        // Define the geographical bounds
                        let southwestCorner = CLLocationCoordinate2D(latitude: 18.901133, longitude: 72.658744) // Southwest corner (Mumbai)
                        let northeastCorner = CLLocationCoordinate2D(latitude: 19.324753, longitude: 73.096050) // Northeast corner (Sasunavghar, Maharashtra 401208)
                        let bounds = GMSCoordinateBounds(coordinate: southwestCorner, coordinate: northeastCorner)
                        autocompleteController?.autocompleteFilter = filter
                        //                        filter.type = .noFilter
                        
                        placesClient?.findAutocompletePredictions(fromQuery: query, filter: filter, sessionToken: nil, callback: { (results, error) in
                            if let error = error {
                                print("Error: \(error.localizedDescription)")
                                return
                            }
                            
                            if let results = results {
                                self.autocompleteResults = results
                                self.autoSuggestPlacestableView.reloadData()
                            }
                            //                            if let results = results {
                            //                                       // Filter results to stay within bounds
                            //                                       self.autocompleteResults = []
                            //                                       let dispatchGroup = DispatchGroup()
                            //
                            //                                       for prediction in results {
                            //                                           dispatchGroup.enter()
                            //                                           let placeID = prediction.placeID // No need for 'if let', placeID is non-optional
                            //                                           self.placesClient?.fetchPlace(fromPlaceID: placeID, placeFields: [.coordinate], sessionToken: self.sessionToken) { place, error in
                            //                                               if let error = error {
                            //                                                   print("Error fetching place details: \(error.localizedDescription)")
                            //                                               } else if let place = place {
                            //                                                   let coordinate = place.coordinate
                            //                                                   if bounds.contains(coordinate) {
                            //                                                       self.autocompleteResults.append(prediction)
                            //                                                   }
                            //                                               }
                            //                                               dispatchGroup.leave()
                            //                                           }
                            //                                       }
                            //
                            //                                       dispatchGroup.notify(queue: .main) {
                            //                                           self.autoSuggestPlacestableView.reloadData()
                            //                                       }
                            //                                   }
                        })
                    }
                }
                //    }
            }
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
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        print ("activeTextField : \(activeTextField)")
    }
    //    @objc func textFieldDidChange1(_ textField: UITextField){
    //        if textField.text?.isEmpty ?? true || textField.text?.count == 0 {
    //            autoSuggestPlaces.isHidden=true
    //            autoSuggestPlacestableView.isHidden = true
    //            destinationLocationTxtField.text = ""
    //            destinationlocationcooordination = nil
    //        } else {
    //        destinationLocationTxtFieldCrossImg.isHidden = false
    //        destinationLocationTxtFieldCrossBtn.isHidden = false
    //        isCurrentTFTouched = false
    //        guard let query = textField.text, !query.isEmpty else {
    //            autocompleteResults = []
    //            autoSuggestPlacestableView.reloadData()
    //            return
    //        }
    //        let filter = GMSAutocompleteFilter()
    //        filter.country = "IN"
    //        autocompleteController?.autocompleteFilter = filter
    //        filter.type = .noFilter
    //
    //        placesClient?.findAutocompletePredictions(fromQuery: query, filter: filter, sessionToken: nil, callback: { (results, error) in
    //            if let error = error {
    //                print("Error: \(error.localizedDescription)")
    //                return
    //            }
    //
    //            if let results = results {
    //                self.autocompleteResults = results
    //                self.autoSuggestPlacestableView.reloadData()
    //            }
    //        })
    //    }
    //    }
    
    
    @objc func dismissKeyboard() {
        autoSuggestPlaces.isHidden = true
        view.endEditing(true) // This will dismiss the keyboard
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.isEmpty ?? true || textField.text?.count == 0 {
            autoSuggestPlaces.isHidden=true
            autoSuggestPlacestableView.isHidden = true
        }
    }
    
    
    func geocodeAddress(_ address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            //            if let error = error {
            //                print("Geocoding error: \(error.localizedDescription)")
            //                self.autoSuggestPlaces.isHidden = true
            //                self.buttonOpticity.isHidden = false
            //                let alertController = UIAlertController(title: "", message: "Invalid Location", preferredStyle: .alert)
            //
            //                // Present the alert controller
            //                self.present(alertController, animated: true) {
            //                    // Dismiss the alert after 5 seconds
            //                    DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) { [self] in
            //                        alertController.dismiss(animated: true, completion: nil)
            //                    }
            //                }
            ////                completion(nil)
            ////                return
            //            }
            if let error = error as NSError? {
                print("Geocoding failed: \(error.localizedDescription)")
                print("Error code: \(error.code)")
                print("Error details: \(error.userInfo)")
                completion(nil)
                return
            }
            if let placemark = placemarks?.first, let location = placemark.location {
                print("location.coordinate : \(location.coordinate)")
                completion(location.coordinate)
            } else {
                completion(nil)
            }
            //            let placemark = placemarks?.first
            //            let location = placemark?.location
            //            print("location.coordinate : \(location?.coordinate)")
            //            completion(location?.coordinate)
        }
    }
    func createNavigationBar() {
        let customBackButton = UIButton()
        customBackButton.setImage(UIImage(named: "back"), for: .normal)
        customBackButton.addTarget(self, action: #selector(customBackButtonTapped), for: .touchUpInside)
        
        // Set custom back button as left bar button item
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customBackButton)
        
        self.title = "Destination"
        
        // Optional: Customize the title appearance
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 20, weight: .bold)
        ]
        self.navigationController?.navigationBar.titleTextAttributes = titleAttributes
    }
    @objc func customBackButtonTapped() {
        // Perform the custom back button action
        //        self.navigationController?.popViewController(animated: true)
        apiTimer = nil
        apiTimer?.invalidate()
        TimerManager.shared.stopAllTimers()
//        let otpVC = storyboard?.instantiateViewController(identifier: "MapViewController") as! MapViewController
//        otpVC.member_master_profile_id = member_master_profile_id
//        self.navigationController?.pushViewController(otpVC, animated: true)
        self.popBackViewControllerProtocolDelegate?.dataPassBack(memberID: self.member_master_profile_id)
        self.navigationController?.popViewController(animated: true)
    }
    func addDoneButtonOnNumpad(textField: UITextField) {
        let keypadToolbar: UIToolbar = UIToolbar()
        keypadToolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // Done button
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        
        // Add flexible space and done button to the toolbar
        keypadToolbar.items = [flexibleSpace, doneButton]
        textField.inputAccessoryView = keypadToolbar
    }
    
    @IBAction func searchRideBtnAction(_ sender: Any) {
        let currentTime = CACurrentMediaTime()
        
        if currentTime - lastClickTime < 1 { // Ignore multiple clicks within 1 second
            return
        }
        
        lastClickTime = currentTime
        
        // Handle button click action
        print("Button clicked")
        if NetworkMonitor.shared.isConnected{
            navigateToBookACabVC()
            //            locationUnServiceables()
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
        
        //        else if currentLocationautocompleteResults.count == 0 && isCurrentTFTouched == false{
        //            let alertController = UIAlertController(title: nil, message: "Invalid Location", preferredStyle: .alert)
        //            let okAction = UIAlertAction(title: "OK", style: .default) { [self]_ in
        //                autoSuggestPlaces.isHidden = true
        //                currentLocationTxtField.text = ""
        //                currentLocationTxtField.becomeFirstResponder()
        //            }
        //            alertController.addAction(okAction)
        //            present(alertController, animated: true, completion: nil)
        //        } else if destinationLocationautocompleteResults.count == 0 && isCurrentTFTouched == true{
        //            let alertController = UIAlertController(title: nil, message: "Invalid Location", preferredStyle: .alert)
        //            let okAction = UIAlertAction(title: "OK", style: .default) { [self]_ in
        //                autoSuggestPlaces.isHidden = true
        //                destinationLocationTxtField.text = ""
        //                destinationLocationTxtField.becomeFirstResponder()
        //            }
        //            alertController.addAction(okAction)
        //            present(alertController, animated: true, completion: nil)
        //        }
        
    }
    
    @IBAction func locationUnservicableBtnAction(_ sender: Any) {
        locationUnservicableImg.isHidden = true
        buttonOpticity.isHidden = true
        locationUnservicableBtn.isHidden = true
    }
    
    @IBAction func currentLocationTxtFieldCrossBtnAction(_ sender: Any) {
        print("currentLocationTxtFieldCrossBtnAction trigerred")
        currentLocationTxtField.text = ""
        currentLocationTxtFieldCrossImg.isHidden = true
        currentLocationTxtFieldCrossBtn.isHidden = true
        autoSuggestPlaces.isHidden = true
        autoSuggestPlacestableView.isHidden = true
        currentlocationcooordination = nil
        currentLocationTxtField.becomeFirstResponder()
        isCurrentTFTouched = true
    }
    
    
    @IBAction func destinationLocationTxtFieldCrossBtnAction(_ sender: Any) {
        print("destinationLocationTxtFieldCrossBtnAction trigerred")
        destinationLocationTxtField.text = ""
        destinationLocationTxtFieldCrossImg.isHidden = true
        destinationLocationTxtFieldCrossBtn.isHidden = true
        autoSuggestPlaces.isHidden = true
        autoSuggestPlacestableView.isHidden = true
        destinationlocationcooordination = nil
        destinationLocationTxtField.becomeFirstResponder()
        isCurrentTFTouched = true
    }
    
    func locationUnServiceables() {
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
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default,headers: headers, interceptor: nil).response { [self] response in
            
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
                                view.endEditing(true)
                                locationUnservicableImg.isHidden = false
                                buttonOpticity.isHidden = false
                                locationUnservicableBtn.isHidden = false
                                self.view.backgroundColor = UIColor(red: 210, green: 234, blue: 255)
                                if textFieldCalledFrom == "currentLocationTextField" {
                                    currentLocationTxtField.text = ""
                                } else if textFieldCalledFrom == "destinationLocationTextField" {
                                    destinationLocationTxtField.text = ""
                                }
                            } else if message == "OK" {
//                                navigateToBookACabVC()
                                //                                view.endEditing(true)
                                //                                locationUnservicableImg.isHidden = false
                                //                                buttonOpticity.isHidden = false
                                //                                locationUnservicableBtn.isHidden = false
                                //                                self.view.backgroundColor = UIColor(red: 210, green: 234, blue: 255)
                                //                                if textFieldCalledFrom == "currentLocationTextField" {
                                //                                    currentLocationTxtField.text = ""
                                //                                    currentLocationTxtField.becomeFirstResponder()
                                //                                } else if textFieldCalledFrom == "destinationLocationTextField" {
                                //                                    destinationLocationTxtField.text = ""
                                //                                    destinationLocationTxtField.becomeFirstResponder()
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
    func recentSearchList() {
        let url = AppConfig.baseURL+"Book/Getlatest_three_rides_Foruser"
        let params :  [String : Any] = [
            "fk_member_master_profile_id":member_master_profile_id ?? 0,
            "currentAppVersion": self.currentAppVersion ?? ""
        ]
        let token = UserDefaults.standard.string(forKey: "auth_deviceToken") ?? ""

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        print("recentSearchList() -> url : \(url)")
        print("recentSearchList() -> params : \(params)")
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default,headers: headers, interceptor: nil).response { [self] response in
            print("recentSearchList() -> response : \(response.result)")
            switch response.result {
                
            case .success (let data) :
                if let data = data {
                    do {
                        recentSearches.removeAll()
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let loginResult = json["result"] as? [String: Any] {
                            print("recentSearchList() -> JSON -------\(json)")
                            let status = loginResult["status"] as? String ?? ""
                            let message = loginResult["message"] as? String ?? ""
                            let output = loginResult["output"] as! [[String: Any]]
                            print("recentSearchList() -> output : \(output)")
                            for output in output {
                                let distinationaddress = output["distinationaddress"] as? String ?? ""
                                print("recentSearchList() -> : \(distinationaddress)")
                                recentSearches.append(distinationaddress)
                            }
                            //                                let distinationaddress = output["distinationaddress"] as? String ?? ""
                            DispatchQueue.main.async {
                                self.recentSearchesTableView.reloadData()
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
            print("CurrenttoDestinationViewController() -> sessionTimeOut() -> url : \(url)")
            print("CurrenttoDestinationViewController() -> sessionTimeOut() -> params : \(params)")
            AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { [self] response in
                
                print("recentSearchList() -> response : \(response.result)")
                switch response.result {
                    
                case .success (let data) :
                    if let data = data {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                               let loginResult = json["result"] as? [String: Any] {
                                print("CurrenttoDestinationViewController() -> sessionTimeOut() -> JSON -------\(json)")
                                let status = loginResult["status"] as? String ?? ""
                                let message = loginResult["message"] as? String ?? ""
                                let version = loginResult["version"] as? [[String: Any]]
                                
                                if status == "0" {
                                    if let version = version {
                                        print("CurrenttoDestinationViewController() -> sessionTimeOut() -> version : \(version)")
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
                                    if Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "") != 0 && UserDefaults.standard.string(forKey: "fk_member_master_profile_id") != nil && member_master_profile_id != nil  {
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
                                        
                                        let okAction = UIAlertAction(title: "OK", style: .default) { [self] _ in
//                                            let otpVC = storyboard?.instantiateViewController(identifier: "LoginRegisterViewController") as! LoginRegisterViewController
                                            print("-----pop2-----LoginVC")
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
                                        
                                        let okAction = UIAlertAction(title: "OK", style: .default) { [self] _ in
//                                            let otpVC = storyboard?.instantiateViewController(identifier: "LoginRegisterViewController") as! LoginRegisterViewController
                                            print("-----pop1-----LoginVC")
                                            member_master_profile_id = nil
                                            UserDefaults.standard.setValue(member_master_profile_id, forKey: "fk_member_master_profile_id")
//                                            self.navigationController?.pushViewController(otpVC, animated: true)
                                            
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
        
    func navigateToBookACabVC() {
        print(":navigateToBookACabVC() -> currentLocationTxtField.text : \(currentLocationTxtField.text)")
        print(":navigateToBookACabVC() -> destinationLocationTxtField.text : \(destinationLocationTxtField.text)")
        print(":navigateToBookACabVC() -> currentlocationcooordination : \(currentlocationcooordination)")
        print(":navigateToBookACabVC() -> destinationlocationcooordination : \(destinationlocationcooordination)")
        if let currentText = currentLocationTxtField.text, currentText.isEmpty, currentText.count == 0 {
            //            let alertController = UIAlertController(title: nil, message: "Please Enter Source Location", preferredStyle: .alert)
//            let alertController = UIAlertController(title: nil, message: "Please Enter Location", preferredStyle: .alert)
//            let okAction = UIAlertAction(title: "OK", style: .default) { [self] _ in
//                currentLocationTxtField.delegate = self
//                if destinationLocationTxtField.text != nil {
//                    destinationLocationTxtField.text = ""
//                }
//                currentLocationTxtField.text = ""
//                currentLocationTxtField.becomeFirstResponder()
//            }
//            alertController.addAction(okAction)
//            present(alertController, animated: true, completion: nil)
            
            let alertController = UIAlertController(title: nil, message: "Please Enter Source Location", preferredStyle: .alert)
            
            // Present the alert controller
            self.present(alertController, animated: true) {
                // Dismiss the alert after 5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    alertController.dismiss(animated: true, completion: nil)
                }
            }
            
        } else if currentlocationcooordination == nil {
            //            let alertController = UIAlertController(title: nil, message: "Please Enter valid Source Location", preferredStyle: .alert)
//            let alertController = UIAlertController(title: nil, message: "Please Enter valid Location", preferredStyle: .alert)
//            let okAction = UIAlertAction(title: "OK", style: .default) { [self] _ in
//                currentLocationTxtField.delegate = self
//                currentLocationTxtField.text = ""
//                currentLocationTxtField.becomeFirstResponder()
//            }
//            alertController.addAction(okAction)
//            present(alertController, animated: true, completion: nil)
            
            let alertController = UIAlertController(title: nil, message: "Please Enter Valid Source Location", preferredStyle: .alert)
            
            // Present the alert controller
            self.present(alertController, animated: true) {
                // Dismiss the alert after 5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    alertController.dismiss(animated: true, completion: nil)
                }
            }
            
        }else if let destinationText = destinationLocationTxtField.text, destinationText.isEmpty, destinationText.count == 0 {
            //            let alertController = UIAlertController(title: nil, message: "Please Enter Destination Location", preferredStyle: .alert)
//            let alertController = UIAlertController(title: nil, message: "Please Enter Location", preferredStyle: .alert)
//            let okAction = UIAlertAction(title: "OK", style: .default) { [self] _ in
//                destinationLocationTxtField.delegate = self
//                destinationLocationTxtField.text = ""
//                destinationLocationTxtField.becomeFirstResponder()
//            }
//            alertController.addAction(okAction)
//            present(alertController, animated: true, completion: nil)
            
            let alertController = UIAlertController(title: nil, message: "Please Enter Destination Location", preferredStyle: .alert)
            
            // Present the alert controller
            self.present(alertController, animated: true) {
                // Dismiss the alert after 5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    alertController.dismiss(animated: true, completion: nil)
                }
            }
        } else if destinationlocationcooordination == nil {
            //            let alertController = UIAlertController(title: nil, message: "Please Enter valid Destination Location", preferredStyle: .alert)
//            let alertController = UIAlertController(title: nil, message: "Please Enter valid Location", preferredStyle: .alert)
//            let okAction = UIAlertAction(title: "OK", style: .default) { [self] _ in
//                currentLocationTxtField.delegate = self
//                destinationLocationTxtField.text = ""
//                currentLocationTxtField.becomeFirstResponder()
//            }
//            alertController.addAction(okAction)
//            present(alertController, animated: true, completion: nil)
            
            let alertController = UIAlertController(title: nil, message: "Please Enter Valid Destination Location", preferredStyle: .alert)
            
            // Present the alert controller
            self.present(alertController, animated: true) {
                // Dismiss the alert after 5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    alertController.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            autoSuggestPlaces.isHidden = true
            //        tableView.isHidden = true
            let otpVC = storyboard?.instantiateViewController(identifier: "BookACabViewController") as! BookACabViewController
            apiTimer = nil
            apiTimer?.invalidate()
            otpVC.recentSearches = recentSearches
            otpVC.currentLoc = currentLocationTxtField.text
            otpVC.destinationLoc = destinationLocationTxtField.text
            otpVC.currentlocationcooordination = currentlocationcooordination
            otpVC.destinationlocationcooordination = destinationlocationcooordination
            otpVC.member_master_profile_id = member_master_profile_id
            //            otpVC.totalTime = totalTime
            otpVC.textFieldResponderDelegate = self
            otpVC.PopBackDelegate = self
            otpVC.PopBackToDelegate = self
            //            otpVC.firstTime = firstTime
            self.navigationController?.pushViewController(otpVC, animated: true)
        }
    }
    
    deinit {
        apiTimer?.invalidate()
        apiTimer = nil
        popBackViewControllerProtocolDelegate = nil
        autoSuggestPlacestableView.delegate = nil
        autoSuggestPlacestableView.dataSource = nil
        NotificationCenter.default.removeObserver(self)
        print("******************** DEINIT CurrenttodestinationViewController REMOVED FROM MEMORY*********************")
    }
}


extension CurrenttoDestinationViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        destinationLocationTxtField.text = place.name
    }
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
        print("Error1: ", error.localizedDescription)
    }
    
}

//MARK: TABLEVIEW PROTOCOLS
extension CurrenttoDestinationViewController: UITableViewDataSource, UITableViewDelegate, TextFieldResponder {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == autoSuggestPlacestableView{
            print("autocompleteResults.count : \(autocompleteResults.count)")
            if autocompleteResults.count == 0 {
                print("autocompleteResults count is zero")
                if LocTextFieldTapped == "currentLocTextFieldTapped" {
                    autoSuggestPlacestableView.isHidden = true
                    noResultsFoundImg.isHidden = false
                    noResultsFoundLbl.isHidden = false
                    noResultsFoundView.isHidden = false
                    noResultsFoundLbl.text = "No results found for \(currentLocationTxtField.text ?? "")"
                } else if LocTextFieldTapped == "destinationLocTextFieldTapped" {
                    autoSuggestPlacestableView.isHidden = true
                    noResultsFoundImg.isHidden = false
                    noResultsFoundLbl.isHidden = false
                    noResultsFoundView.isHidden = false
                    noResultsFoundLbl.text = "No results found for \(destinationLocationTxtField.text ?? "")"
                }
                return autocompleteResults.count
            } else {
                return  autocompleteResults.count
            }
        } else if tableView == recentSearchesTableView{
            print("recentSearches.count : \(recentSearches.count)")
            return recentSearches.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result: GMSAutocompletePrediction!
        if tableView == autoSuggestPlacestableView && autocompleteResults.count > 0 {
            autoSuggestPlaces.isHidden = false
            tableView.isHidden = false
            noResultsFoundImg.isHidden = true
            autoCompleteRecentSearchesActivityIndicator.stopAnimating()
            autoCompleteRecentSearchesActivityIndicator.isHidden = true
            noResultsFoundLbl.isHidden = true
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
            let result = autocompleteResults[indexPath.row]
            cell.textLabel?.text = result.attributedFullText.string
            return cell
        } else if tableView == recentSearchesTableView {
            if recentSearches.count == 0 {
                recentSearchesTableViewHeight.constant = 0
            } else if recentSearches.count == 1 {
                recentSearchesTableViewHeight.constant = 70
            } else if recentSearches.count == 2 {
                recentSearchesTableViewHeight.constant = 140
            } else if recentSearches.count == 3 {
                recentSearchesTableViewHeight.constant = 210
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecentSearchesTableViewCell") as! RecentSearchesTableViewCell
            let data = recentSearches[indexPath.row]
            if let commaIndex = data.firstIndex(of: ",") {
                let mainText = String(data[..<commaIndex])
                let subText = String(data[data.index(after: commaIndex)...])
                cell.mainLabel.text = mainText
                cell.subLabel.text = subText
            } else {
                // If there's no comma, display the entire string in mainLabel
                cell.mainLabel.text = data
                cell.subLabel.text = ""
            }
            return cell
        }
        return UITableViewCell(style: .default, reuseIdentifier: "defaultCell")
    }
    func getCoordinatesFromGooglePlaces(address: String) {
        let urlStr = "https://maps.googleapis.com/maps/api/geocode/json?address=\(address)&key=AIzaSyDce_Ybso83w6ay7NoKCuA5y33udrxGhmk"
        guard let url = URL(string: urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else { return }
        
        URLSession.shared.dataTask(with: url) { [self] (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else { return }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let firstResult = results.first,
                   let geometry = firstResult["geometry"] as? [String: Any],
                   let location = geometry["location"] as? [String: Any],
                   let lat = location["lat"] as? Double,
                   let lng = location["lng"] as? Double {
                    destinationlocationcooordination = CLLocationCoordinate2D(latitude:  CLLocationDegrees(lat), longitude:  CLLocationDegrees(lng))
                    print("Coordinates from Google Places: \(lat), \(lng)")
                    
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
                let alertController = UIAlertController(title: "Network Error", message: "", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }.resume()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let result = autocompleteResults[indexPath.row]
        
        if NetworkMonitor.shared.isConnected{
            visibilityTimer?.invalidate()
            if activeTextField == currentLocationTxtField {
                textFieldCalledFrom = "currentLocationTextField"
                //            if autocompleteResults.count == 0 {
                //               currentLocationautocompleteResults = autocompleteResults
                //                currentLocationTxtField.delegate = self
                //            }
                if autoSuggestPlacestableView.isHidden == false {
                    let result = autocompleteResults[indexPath.row]
                    print("Selected place: \(result.attributedFullText.string)")
                    newValueCurrentLocation = result
                    print("newValueCurrentLocation : \(newValueCurrentLocation)")
                    //                currentLocationTxtField.text = result.attributedFullText.string
                    let placeID = result.placeID
                    
                    // Use GMSPlacesClient to fetch place details
                    let placesClient = GMSPlacesClient.shared()
                    placesClient.fetchPlace(fromPlaceID: placeID, placeFields: .coordinate, sessionToken: nil) { [self] (place, error) in
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
                        //                self.autoSuggestPlaces.isHidden = true
                        
                        currentlocationcooordination = CLLocationCoordinate2D(latitude: CLLocationDegrees(mainLat ?? 0.0), longitude: CLLocationDegrees(mainLong ?? 0.0))
                        isCurrentTFTouched = false
                        print("didselectrow() -> currentlocationcooordination(autocompleteResults) : \(currentlocationcooordination)")
                        //                    if currentLocationTxtField.text == "" || destinationLocationTxtField.text == "" {
                        //
                        //                    }
                        //                    else {
                        //                        navigateToBookACabVC()
                        locationUnServiceables()
                        //                    }
                        
                        
                    }
                    //                if currentLocationTxtField.text == "" || destinationLocationTxtField.text == "" {
                    //
                    //                                        } else {
                    //                                            navigateToBookACabVC()
                    //                                        }
                    //                DispatchQueue.main.async { [self] in
                    //                    guard let currentLocationText = currentLocationTxtField.text, !currentLocationText.isEmpty else { return }
                    //                    if currentlocationcooordination != nil {
                    //                        print("currentlocationcooordination is not nil")
                    //                        currentlocationcooordination = nil
                    //                    }
                    //                    geocodeAddress(currentLocationText) { coordinate in
                    //                        guard let coordinate1 = coordinate else { return }
                    //
                    //                        print("--------coordinate1(autoSuggestPlacestableView) : \(coordinate1)")
                    //
                    //                        currentlocationcooordination = CLLocationCoordinate2D(latitude: CLLocationDegrees(coordinate?.latitude ?? 0.0), longitude: CLLocationDegrees(coordinate?.longitude ?? 0.0))
                    //                        print("didSelectRowAt() -> currentLocationTxtField.text(autoSuggestPlacestableView) -> currentlocationcooordination : \(currentlocationcooordination)")
                    //                    }
                    //                    autoSuggestPlaces.isHidden = true
                    //                    tableView.isHidden = true
                    //                    if currentLocationTxtField.text == "" || destinationLocationTxtField.text == "" {
                    //
                    //                    } else {
                    //                        navigateToBookACabVC()
                    //                    }
                    //                }
                    
                    
                } else if !recentSearches.isEmpty {
                    if currentLocationTxtFieldCrossImg.isHidden == true && currentLocationTxtFieldCrossBtn.isHidden == true {
                        currentLocationTxtFieldCrossImg.isHidden = false
                        currentLocationTxtFieldCrossBtn.isHidden = false
                    }
                    //                currentLocationTxtField.text = recentSearches[indexPath.row]
                    dash = recentSearches[indexPath.row]
                    print("Dash value: \(String(describing: dash))")
                    fetchAutocompletePredictions(query: dash ?? "") { predictions in
                        guard let predictions = predictions else {
                            print("No predictions found.")
                            return
                        }
                        //                    for prediction in predictions {
                        let firstPrediction = predictions.first
                        print("Place ID: \(firstPrediction?.placeID ?? "No ID")")
                        print("Primary Text: \(firstPrediction?.attributedPrimaryText.string)")
                        print("Full Text: \(firstPrediction?.attributedFullText.string)")
                        let placeID = firstPrediction?.placeID
                        
                        // Use GMSPlacesClient to fetch place details
                        let placesClient = GMSPlacesClient.shared()
                        placesClient.fetchPlace(fromPlaceID: placeID!, placeFields: .coordinate, sessionToken: nil) { [self] (place, error) in
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
                            currentLocationTxtField.text = firstPrediction?.attributedFullText.string
                            mainLat = latitude
                            mainLong = longitude
                            //                                tableView.isHidden = true
                            //                                autoSuggestPlaces.isHidden = true
                            //                                locationUnServiceable()
                            //                self.autoSuggestPlaces.isHidden = true
                            isCurrentTFTouched = false
                            currentlocationcooordination = CLLocationCoordinate2D(latitude: CLLocationDegrees(mainLat ?? 0.0), longitude: CLLocationDegrees(mainLong ?? 0.0))
                            print("didselectrow() -> currentlocationcooordination(dash) : \(currentlocationcooordination)")
                            
                            //                            if currentLocationTxtField.text == "" || destinationLocationTxtField.text == "" {
                            //
                            //                            } else {
                            //                            navigateToBookACabVC()
                            locationUnServiceables()
                            //                            }
                            
                        }
                        //                        }
                        
                    }
                    //                DispatchQueue.main.async { [self] in
                    //                    guard let currentLocationText = currentLocationTxtField.text, !currentLocationText.isEmpty else { return }
                    //                    if currentlocationcooordination != nil {
                    //                        print("currentlocationcooordination(1) is not nil")
                    //                        currentlocationcooordination = nil
                    //                    }
                    //                    geocodeAddress(currentLocationText) { coordinate in
                    //                        guard let coordinate1 = coordinate else { return }
                    //
                    //                        print("--------coordinate1 : \(coordinate1)")
                    //                        currentlocationcooordination = CLLocationCoordinate2D(latitude: CLLocationDegrees(coordinate?.latitude ?? 0.0), longitude: CLLocationDegrees(coordinate?.longitude ?? 0.0))
                    //                        print("didSelectRowAt() -> currentLocationTxtField.text(1) -> currentlocationcooordination : \(currentlocationcooordination)")
                    //                        autoSuggestPlaces.isHidden = true
                    //                        tableView.isHidden = true
                    //                        if currentLocationTxtField.text == "" || destinationLocationTxtField.text == "" {
                    //
                    //                        } else {
                    //                            navigateToBookACabVC()
                    //                        }
                    //                    }
                    //                }
                    
                }
            } else {
                //            if autocompleteResults.count == 0 {
                //               destinationLocationautocompleteResults = autocompleteResults
                //            }
                textFieldCalledFrom = "destinationLocationTextField"
                if autoSuggestPlacestableView.isHidden == false {
                    let result = autocompleteResults[indexPath.row]
                    print("Selected place (destinationLocationTxtField.text): \(result.attributedFullText.string)")
                    destinationLocationTxtField.text = result.attributedFullText.string
                    //                getCoordinatesFromGooglePlaces(address: destinationLocationTxtField.text!)
                    let placeID = result.placeID
                    
                    // Use GMSPlacesClient to fetch place details
                    let placesClient = GMSPlacesClient.shared()
                    placesClient.fetchPlace(fromPlaceID: placeID, placeFields: .coordinate, sessionToken: nil) { [self] (place, error) in
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
                        self.destinationLocationTxtField.text = result.attributedFullText.string
                        mainLat = latitude
                        mainLong = longitude
                        tableView.isHidden = true
                        autoSuggestPlaces.isHidden = true
                        //                self.autoSuggestPlaces.isHidden = true
                        isCurrentTFTouched = true
                        destinationlocationcooordination = CLLocationCoordinate2D(latitude: CLLocationDegrees(mainLat ?? 0.0), longitude: CLLocationDegrees(mainLong ?? 0.0))
                        print("didselectrow() -> destinationlocationcooordination : \(currentlocationcooordination)")
                        //                    if currentLocationTxtField.text == "" || destinationLocationTxtField.text == "" {
                        //
                        //                    } else {
                        //                        navigateToBookACabVC()
                        locationUnServiceables()
                        //                    }
                        
                    }
                    
                    //                DispatchQueue.main.async { [self] in
                    //                    guard let destinationLocationText = destinationLocationTxtField.text, !destinationLocationText.isEmpty else { return }
                    //
                    //                    if destinationlocationcooordination != nil {
                    //                        print("destinationlocationcooordination is not nil")
                    //                        destinationlocationcooordination = nil
                    //                    }
                    //                    geocodeAddress(destinationLocationText) { coordinate in
                    //                        guard let coordinate1 = coordinate else { return }
                    //
                    //                        print("--------coordinate1 : \(coordinate1)")
                    //
                    //                        destinationlocationcooordination = CLLocationCoordinate2D(latitude: CLLocationDegrees(coordinate?.latitude ?? 0.0), longitude: CLLocationDegrees(coordinate?.longitude ?? 0.0))
                    //                        print("didSelectRowAt() -> destinationLocationText.text -> destinationlocationcooordination(autoSuggestPlacestableView) : \(destinationlocationcooordination)")
                    //
                    //                        autoSuggestPlaces.isHidden = true
                    //                        tableView.isHidden = true
                    //                        if currentLocationTxtField.text == "" || destinationLocationTxtField.text == "" {
                    //
                    //                        } else {
                    //                            navigateToBookACabVC()
                    //                        }
                    //                    }
                    //                }
                    
                } else if !recentSearches.isEmpty {
                    //                if destinationLocationTxtFieldCrossImg.isHidden == true && destinationLocationTxtFieldCrossBtn.isHidden == true {
                    //                    destinationLocationTxtFieldCrossImg.isHidden = false
                    //                    destinationLocationTxtFieldCrossBtn.isHidden = false
                    //                }
                    dash = recentSearches[indexPath.row]
                    print("Dash value: \(String(describing: dash))")
                    fetchAutocompletePredictions(query: dash ?? "") { predictions in
                        guard let predictions = predictions else {
                            print("No predictions found.")
                            return
                        }
                        //                    for prediction in predictions {
                        let firstPrediction = predictions.first
                        print("Place ID: \(firstPrediction?.placeID ?? "No ID")")
                        print("Primary Text: \(firstPrediction?.attributedPrimaryText.string)")
                        print("Full Text: \(firstPrediction?.attributedFullText.string)")
                        let placeID = firstPrediction?.placeID
                        
                        // Use GMSPlacesClient to fetch place details
                        let placesClient = GMSPlacesClient.shared()
                        placesClient.fetchPlace(fromPlaceID: placeID!, placeFields: .coordinate, sessionToken: nil) { [self] (place, error) in
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
                            destinationLocationTxtField.text = firstPrediction?.attributedFullText.string
                            mainLat = latitude
                            mainLong = longitude
                            //                                tableView.isHidden = true
                            //                                autoSuggestPlaces.isHidden = true
                            //                                locationUnServiceable()
                            //                self.autoSuggestPlaces.isHidden = true
                            isCurrentTFTouched = true
                            destinationlocationcooordination = CLLocationCoordinate2D(latitude: CLLocationDegrees(mainLat ?? 0.0), longitude: CLLocationDegrees(mainLong ?? 0.0))
                            print("didselectrow() -> destinationlocationcooordination(dash) : \(destinationlocationcooordination)")
                            
                            //                        if currentLocationTxtField.text == "" || destinationLocationTxtField.text == "" {
                            //
                            //                        } else {
                            //                            navigateToBookACabVC()
                            locationUnServiceables()
                            //                        }
                            
                        }
                        //                        }
                        
                    }
                    //                destinationLocationTxtField.text = recentSearches[indexPath.row]
                    //                DispatchQueue.main.async { [self] in
                    //                    guard let destinationLocationText = destinationLocationTxtField.text, !destinationLocationText.isEmpty else { return }
                    //                    if destinationlocationcooordination != nil {
                    //                        print("destinationlocationcooordination(1) is not nil")
                    //                        destinationlocationcooordination = nil
                    //                    }
                    //                    geocodeAddress(destinationLocationText) { coordinate in
                    //                        guard let coordinate1 = coordinate else { return }
                    //
                    //                        print("--------coordinate1 : \(coordinate1)")
                    //
                    //                        destinationlocationcooordination = CLLocationCoordinate2D(latitude: CLLocationDegrees(coordinate?.latitude ?? 0.0), longitude: CLLocationDegrees(coordinate?.longitude ?? 0.0))
                    //                        print("didSelectRowAt() -> destinationLocationText.text(1) -> destinationlocationcooordination : \(destinationlocationcooordination)")
                    //                        autoSuggestPlaces.isHidden = true
                    //                        tableView.isHidden = true
                    //                        if currentLocationTxtField.text == "" || destinationLocationTxtField.text == "" {
                    //
                    //                        } else {
                    //                            navigateToBookACabVC()
                    //                        }
                    //                    }
                    //                }
                    
                }
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
    
    
    func currentTFResponder() {
        DispatchQueue.main.async {
            self.currentLocationTxtField.becomeFirstResponder()
        }
    }
    
    func destinationTFResponder() {
        DispatchQueue.main.async {
            self.destinationLocationTxtField.becomeFirstResponder()
        }
    }
    
    func fetchAutocompletePredictions(query: String, completion: @escaping ([GMSAutocompletePrediction]?) -> Void) {
        // Get the shared GMSPlacesClient instance
        let placesClient = GMSPlacesClient.shared()
        
        // Set up bounds and filters if necessary (optional)
        //        let bounds = GMSCoordinateBounds()
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
}

struct CustomAutocompletePrediction {
    var placeID: String
    var attributedPrimaryText: NSAttributedString
    var attributedFullText: NSAttributedString
}
