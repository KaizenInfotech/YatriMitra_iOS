//
//  RideConfirmViewController.swift
//  yatriMitra
//
//  Created by IOS 2 on 18/06/24.
//

import UIKit
import MapKit
import GoogleMaps
import Alamofire

protocol CancelRide: AnyObject {
    func rideCancel()
}

class RideConfirmViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var otpLbl: UILabel!
    @IBOutlet weak var vehicleNo: UILabel!
    @IBOutlet weak var vehicleName: UILabel!
    @IBOutlet weak var driverName: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var callView: UIView!
    @IBOutlet weak var callImg: UIImageView!
    @IBOutlet weak var mobLBL: UILabel!
    @IBOutlet weak var otpView: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var cancelReasonViewOne: UIView!
    @IBOutlet weak var cancelReasonViewTwo: UIView!
    @IBOutlet weak var cancelReasonViewThree: UIView!
    @IBOutlet weak var driverTakingTooLongLbl: UILabel!
    @IBOutlet weak var rideAmtTooHighLbl: UILabel!
    @IBOutlet weak var bookedMyMistake: UILabel!
    @IBOutlet weak var cancelReasonBGView: UIView!
    @IBOutlet weak var rideCancelImg: UIImageView!
    @IBOutlet weak var rideCnfrmMainView: UIView!
    @IBOutlet weak var shareBGView: UIView!
    @IBOutlet weak var rideTypeImg: UIImageView!
    @IBOutlet weak var driverPic: UIImageView!
    @IBOutlet weak var shareCancelBtn: UIButton!
    
    var current:String?
    var destination:String?
    var currentLocationCoordinate: CLLocationCoordinate2D?
    var destinationLocationCoordinate: CLLocationCoordinate2D?
    var blurVision = BlurView()
    var blurVisible = false
    var pk_bookride_id : Int?
    
    weak var cancelRideDelegate: CancelRide?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        createNavigationBar()
        NetworkMonitor.shared
        cancelReasonBGView.isHidden = true
        shareBGView.isHidden = true
        rideCancelImg.isHidden = true
        otpView.layer.cornerRadius=10
        otpView.layer.shadowOpacity = 0.5
        otpView.layer.shadowOffset = CGSize(width: 5, height: 5)
        otpView.layer.shadowRadius = 5
        otpView.layer.borderColor = UIColor.gray.cgColor
        otpView.layer.borderWidth = 1
        callView.layer.cornerRadius=10
        callView.layer.shadowOpacity = 0.3
        callView.layer.shadowOffset = CGSize(width: 5, height: 5)
        callView.layer.shadowRadius = 5
        callView.layer.borderColor = UIColor.systemGray4.cgColor
        callView.layer.borderWidth = 1
        mobLBL.isUserInteractionEnabled = true
        cancelBtn.layer.cornerRadius = 15
        shareBtn.layer.cornerRadius = 15
        submitBtn.layer.cornerRadius = 15
        shareCancelBtn.layer.cornerRadius = 15
        cancelReasonViewOne.layer.cornerRadius = 15
        cancelReasonViewTwo.layer.cornerRadius = 15
        cancelReasonViewThree.layer.cornerRadius = 15
        let tapLblGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        mobLBL.addGestureRecognizer(tapLblGesture)
        callImg.isUserInteractionEnabled = true  // Important for enabling interaction
        let tapImgGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        callImg.addGestureRecognizer(tapImgGesture)
        callView.isUserInteractionEnabled = true  // Important for enabling interaction
        let tapViewGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        callView.addGestureRecognizer(tapViewGesture)
        mapView.delegate=self
        locationTxts()
        driverDetailsAPI()
    }
    
    private func setupLoaderView() {
        // Set up loader view
        blurVision.removeFromSuperview()
        blurVision.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurVision)
        if blurVisible {
            NSLayoutConstraint.activate([
                blurVision.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                blurVision.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                blurVision.topAnchor.constraint(equalTo: view.topAnchor),
                blurVision.bottomAnchor.constraint(equalTo: cancelReasonBGView.topAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                blurVision.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                blurVision.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                blurVision.topAnchor.constraint(equalTo: view.topAnchor),
                blurVision.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])

        }
    }
    
    @objc func viewTapped() {
        print("View tapped")
        let phoneNumber = "9876543210"
        print(phoneNumber)
        if let encodedPhoneNumber = phoneNumber.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
           let phoneURL = URL(string: "tel://\(encodedPhoneNumber)"), UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        } else {
            print("Unable to initiate a phone call.")
        }
    }
    
    @objc func imageViewTapped() {
            print("ImageView tapped")
        let phoneNumber = "9876543210"
        print(phoneNumber)
        if let encodedPhoneNumber = phoneNumber.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
           let phoneURL = URL(string: "tel://\(encodedPhoneNumber)"), UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        } else {
            print("Unable to initiate a phone call.")
        }
    }
    
    @objc func labelTapped() {
            print("Label tapped")
        let phoneNumber = "9876543210"
        print(phoneNumber)
        if let encodedPhoneNumber = phoneNumber.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
           let phoneURL = URL(string: "tel://\(encodedPhoneNumber)"), UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        } else {
            print("Unable to initiate a phone call.")
        }
    }
    
    func createNavigationBar() {
        let customBackButton = UIButton()
        customBackButton.setImage(UIImage(named: "back"), for: .normal)
        customBackButton.addTarget(self, action: #selector(customBackButtonTapped), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customBackButton)
    }
    
    @objc func customBackButtonTapped() {
        self.navigationController?.popViewController(animated: true)
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
    
    func locationTxts() {
        guard let address = current, !address.isEmpty else { return }
        geocodeAddress(address) { coordinate in
            guard let coordinate = coordinate else { return }
            self.addAnnotation(at: coordinate, for: address)
            self.updateMapRegion()
            self.calculateRoute()
        }
        guard let address = destination, !address.isEmpty else { return }
        geocodeAddress(address) { coordinate in
            guard let coordinate = coordinate else { return }
            self.addAnnotation(at: coordinate, for: address)
            self.updateMapRegion()
            self.calculateRoute()
        }
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
            if annotation.title == "Yours Location" {
                
                annotationView?.image = UIImage(named: "startpoint")
                let desiredSize = CGSize(width: 25, height: 25)
                if let image = annotationView?.image {
                    annotationView?.image = image.scaled(to: desiredSize)
                }
                annotationView?.centerOffset = CGPoint(x: 0, y: -desiredSize.height / 2)
                
            } else if annotation.title == "Drivers Location" {
                
                annotationView?.image = UIImage(named: "endpoint")
                let desiredSize = CGSize(width: 25, height: 25)
                if let image = annotationView?.image {
                    annotationView?.image = image.scaled(to: desiredSize)
                }
                annotationView?.centerOffset = CGPoint(x: 0, y: -desiredSize.height / 2)
            }
            
            return annotationView
       }
    
    func updateMapRegion() {
        
        guard let currentCoordinate = currentLocationCoordinate,
              let destinationCoordinate = destinationLocationCoordinate else {
            return
        }
        
        var zoomRect = MKMapRect.null
        let currentPoint = MKMapPoint(currentCoordinate)
        let destinationPoint = MKMapPoint(destinationCoordinate)
        
        zoomRect = zoomRect.union(MKMapRect(x: currentPoint.x, y: currentPoint.y, width: 0, height: 0))
        zoomRect = zoomRect.union(MKMapRect(x: destinationPoint.x, y: destinationPoint.y, width: 0, height: 0))
        
        mapView.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
    }
    
    func calculateRoute() {
        guard let currentCoordinate = currentLocationCoordinate,
              let destinationCoordinate = destinationLocationCoordinate else {
            return
        }
        
        let sourcePlacemark = MKPlacemark(coordinate: currentCoordinate)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlacemark)
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { response, error in
            guard let response = response, error == nil else {
                print("Error calculating route: \(String(describing: error?.localizedDescription))")
                return
            }
            
            let route = response.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 4.0
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func addAnnotation(at coordinate: CLLocationCoordinate2D, for textField: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        if textField == current {
            annotation.title = "Yours Location"
            print("coordinate1 : \(coordinate)")
            currentLocationCoordinate = coordinate
        } else if textField == destination {
            annotation.title = "Drivers Location"
            print("coordinate2 : \(coordinate)")
            destinationLocationCoordinate = coordinate
        }
        mapView.addAnnotation(annotation)
        
        // Optionally, center the map around the annotation
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func cancelRideAction(_ sender: Any) {
        blurVisible = true
        self.rideCnfrmMainView.backgroundColor = UIColor(rgb: 0x000000)
        self.cancelReasonBGView.roundCorners([.topLeft, .topRight], radius: 30)
        setupLoaderView()
        cancelReasonBGView.isHidden = false
    }
    
    @IBAction func shareAction(_ sender: Any) {
        blurVisible = true
        self.rideCnfrmMainView.backgroundColor = UIColor(rgb: 0x000000)
        self.shareBGView.roundCorners([.topLeft, .topRight], radius: 30)
        setupLoaderView()
        shareBGView.isHidden = false
    }
    
    @IBAction func cancelSubmitAction(_ sender: Any) {
        cancelReasonBGView.isHidden = true
        blurVisible = false
        setupLoaderView()
        rideCancelImg.layer.cornerRadius = 15
        rideCancelImg.isHidden = false
        view.addSubview(rideCancelImg)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            let backToLocationVC = self.storyboard?.instantiateViewController(identifier: "MapViewController") as! MapViewController
            self.navigationController?.pushViewController(backToLocationVC, animated: true)
//        }
    }
    
    @IBAction func whatsappAction(_ sender: Any) {
        print("SHARE TO WHATSAPP")
    }
    
    @IBAction func gmainAction(_ sender: Any) {
        print("SHARE TO GMAIL")
    }
    
    @IBAction func fbAction(_ sender: Any) {
        print("SHARE TO FACEBOOK")
    }
    
    @IBAction func linksAction(_ sender: Any) {
        print("SHARE TO LINKS")
    }
    
    @IBAction func shareCancelAction(_ sender: Any) {
        print("SHARE CANCELLED")
        self.blurVision.removeFromSuperview()
        self.rideCnfrmMainView.backgroundColor = UIColor(rgb: 0xDFF0FF)
        cancelReasonBGView.isHidden = true
        shareBGView.isHidden = true
    }
}


extension RideConfirmViewController{
    func driverDetailsAPI() {
        let url = AppConfig.baseURL+"Book/After_driveraccept_ride_passanger_will_get_driver_details"
        let params :  [String : Any] = [
            "fk_bookride_id": 1
//            "fk_bookride_id": pk_bookride_id
      ]
        print("bookARide() -> parameters : \(params)")
        let token = UserDefaults.standard.string(forKey: "auth_deviceToken") ?? ""

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers, interceptor: nil).response { response in
            print("response : \(response)")
            print("response.result : \(response.result)")
            
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
                            print("JSON -------\(json)")
                            let status = loginResult["status"] as? String ?? ""
                            let message = loginResult["message"] as? String ?? ""
                            if let driverDetails = loginResult["driverDetails"] as? [[String: Any]] {
                                print("driverDetails : \(driverDetails)")
                                for allDriverDetails in driverDetails{
                                    self.vehicleNo.text = allDriverDetails["vehicleNumber"] as? String
                                    self.vehicleName.text = allDriverDetails["vehicleBrand_model"] as? String
                                    self.driverName.text = allDriverDetails["drivername"] as? String
                                    if let driverProfilePic = allDriverDetails["profilephoto"] as? String {
                                        if let url = URL(string: driverProfilePic), let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) {
                                            self.driverPic.image = image
                                            self.driverPic.contentMode = .scaleAspectFill
                                            print("Image loaded successfully.")
                                        } else {
                                            print("Failed to load image named \(driverProfilePic).")
                                        }
                                    } else {
                                        self.driverPic.image = UIImage(named: "Mask group")
                                    }
                                    if let otp = allDriverDetails["pin"] as? Int {
                                        self.otpLbl.text = String(otp)
                                    }
                                    
                                    self.mobLBL.text = allDriverDetails["drivermobilenumber"] as? String
                                    var vehicleType = allDriverDetails["vehicletype"] as? Int
                                    if vehicleType == 1 {
                                        self.rideTypeImg.image = UIImage(named: "autoRickshaw")
                                    } else if vehicleType == 2 {
                                        self.rideTypeImg.image = UIImage(named: "non-ac-taxi")
                                    }else if vehicleType == 3 {
                                        self.rideTypeImg.image = UIImage(named: "ac-Taxi")
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
}
extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        if #available(iOS 11, *) {
            var cornerMask = CACornerMask()
            if(corners.contains(.topLeft)){
                cornerMask.insert(.layerMinXMinYCorner)
            }
            if(corners.contains(.topRight)){
                cornerMask.insert(.layerMaxXMinYCorner)
            }
            if(corners.contains(.bottomLeft)){
                cornerMask.insert(.layerMinXMaxYCorner)
            }
            if(corners.contains(.bottomRight)){
                cornerMask.insert(.layerMaxXMaxYCorner)
            }
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = cornerMask
            
        } else {
            let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }
}

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}
