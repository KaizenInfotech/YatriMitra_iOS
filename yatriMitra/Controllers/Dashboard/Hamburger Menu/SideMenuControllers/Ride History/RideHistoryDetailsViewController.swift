//
//  RideHistoryDetailsViewController.swift
//  yatriMitra
//
//  Created by Kaizen Infotech Solutions Private Limited. on 25/06/24.
//

import UIKit

class RideHistoryDetailsViewController: UIViewController {
    
    @IBOutlet weak var mainScrollView: UIView!
    @IBOutlet weak var sourceToDestinationView: UIView!
    @IBOutlet weak var driverDetailsView: UIView!
    @IBOutlet weak var vehicleDetailsView: UIView!
    @IBOutlet weak var paymentDetailsView: UIView!
    @IBOutlet weak var currentToDestinationView: UIView!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var source: UILabel!
    @IBOutlet weak var destination: UILabel!
    @IBOutlet weak var destinationLocationLbl: UITextField!
    @IBOutlet weak var navigationRouteMapImg: UIImageView!
    @IBOutlet weak var currentLocationLbl: UITextField!
    @IBOutlet weak var dateTimeLbl: UILabel!
    @IBOutlet weak var TimeLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var vehicleNumber: UILabel!
    @IBOutlet weak var vehicleImage: UIImageView!
    @IBOutlet weak var driverName: UILabel!
    @IBOutlet weak var vehicleBrand: UILabel!
    @IBOutlet weak var pickupamount: UILabel!
    @IBOutlet weak var fareamount: UILabel!
    @IBOutlet weak var totalamount: UILabel!
    @IBOutlet weak var pickupChargesLbl: UILabel!
    @IBOutlet weak var fareTitleLbl: UILabel!
    @IBOutlet weak var estimatedRideChargesLbl: UILabel!
    @IBOutlet weak var driverImage: UIImageView!
    
    
    //Created UI ON 18th March 2025
    @IBOutlet weak var mainScrollView_18_03_25: UIView!
    @IBOutlet weak var dateTimeView_18_03_25: UIView!
    @IBOutlet weak var statusLbl_18_03_25: UILabel!
    @IBOutlet weak var sourceToDestinationView_18_03_25: UIView!
    @IBOutlet weak var driverDetailsView_18_03_25: UIView!
    @IBOutlet weak var navigationRouteMapImg_18_03_25 : UIImageView!
    @IBOutlet weak var TimeLbl_18_03_25: UILabel!
    @IBOutlet weak var dateLbl_18_03_25: UILabel!
    @IBOutlet weak var source_18_03_25: UILabel!
    @IBOutlet weak var destination_18_03_25: UILabel!
    @IBOutlet weak var driverImage_18_03_25: UIImageView!
    @IBOutlet weak var driverName_18_03_25: UILabel!
    @IBOutlet weak var vehicleBrand_18_03_25: UILabel!
    @IBOutlet weak var vehicleNumber_18_03_25: UILabel!
    
    var pkBookrideId: Int?
    var bookedDate: String?
    var vehicleType: String?
    var vehicleTypeId: Int?
    var vehicleImage1: String?
    var driverImage1: String?
    var sourceAddress: String?
    var destinationAddress: String?
    var fkDriverId: Int?
    var rideStatus: String?
    var ride_history_status: String?
    var bookedtime: String?
    var bookeddate: String?
    var pickupamout: String?
    var fareAmount: String?
    var totalAmout: String?
    var vehicle_brand: String?
    var vehicle_number: String?
    var routMap_photo: String?
    var driver_first_name: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createNavigationBar()
        sourceToDestinationView.roundCorners([.bottomLeft, .bottomRight], radius: 10)
        driverDetailsView.roundCorners(.allCorners, radius: 10)
        vehicleDetailsView.roundCorners(.allCorners, radius: 10)
        paymentDetailsView.roundCorners(.allCorners, radius: 10)
        self.driverImage.layer.cornerRadius = self.driverImage.frame.size.width / 2
        self.driverImage_18_03_25.layer.cornerRadius = 40
        driverImage_18_03_25.clipsToBounds = true
        currentToDestinationView.layer.cornerRadius = 10
        currentToDestinationView.layer.shadowOpacity = 0.5 // Adjust opacity to your preference
        currentToDestinationView.layer.shadowOffset = CGSize(width: 5, height: 5) // Bottom and right offset
        currentToDestinationView.layer.shadowRadius = 5 // Adjust radius to your preference
        //        statusLbl.layer.borderColor = UIColor.systemGreen.cgColor
        //        statusLbl.layer.borderWidth = 2.0
        //        statusLbl.layer.cornerRadius = 10.0
        //        statusLbl.layer.masksToBounds = true // Ensures the corner radius is applied
        //        statusLbl.textColor = UIColor.systemGreen
        print("ridestatus : \(rideStatus)")
        rideHistoryDetails()
    }
    func createNavigationBar() {
        let customBackButton = UIButton()
        customBackButton.setImage(UIImage(named: "back"), for: .normal)
        customBackButton.addTarget(self, action: #selector(customBackButtonTapped), for: .touchUpInside)
        
        // Set custom back button as left bar button item
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customBackButton)
        
        self.title = "Ride History Details"
        
        // Optional: Customize the title appearance
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 20, weight: .bold)
        ]
        self.navigationController?.navigationBar.titleTextAttributes = titleAttributes
    }
    @objc func customBackButtonTapped() {
        // Perform the custom back button action
        self.navigationController?.popViewController(animated: true)
    }
    
    //Created on 18th March 2025
    func rideHistoryDetails() {
        currentLocationLbl.text = sourceAddress
        destinationLocationLbl.text = destinationAddress
        source_18_03_25.text = sourceAddress
        destination_18_03_25.text = destinationAddress
        dateLbl_18_03_25.text = bookeddate
        TimeLbl_18_03_25.text = bookedtime
        
        //        if vehicle_brand == "" || vehicle_number == "" {
        if rideStatus == "Cancelled" && ride_history_status == "" {
            driverDetailsView_18_03_25.isHidden = true
            statusLbl_18_03_25.text = "Cancelled"
            statusLbl_18_03_25.backgroundColor = UIColor.systemRed
            //            statusLbl.layer.borderColor = UIColor.systemRed.cgColor
            //            statusLbl.layer.borderWidth = 2.0
            //            statusLbl.layer.cornerRadius = 10.0
            statusLbl_18_03_25.layer.masksToBounds = true // Ensures the corner radius is applied
            //            statusLbl.font = UIFont.systemFont(ofSize: 16.0)
            sourceToDestinationView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                sourceToDestinationView_18_03_25.topAnchor.constraint(equalTo: dateTimeView_18_03_25.bottomAnchor, constant: 20)
            ])
        } else if rideStatus == "Cancelled" && ride_history_status == "while searching" {
            driverDetailsView_18_03_25.isHidden = true
            statusLbl_18_03_25.text = "Cancelled"
            statusLbl_18_03_25.backgroundColor = UIColor.systemRed
            //            statusLbl.layer.borderColor = UIColor.systemRed.cgColor
            //            statusLbl.layer.borderWidth = 2.0
            //            statusLbl.layer.cornerRadius = 10.0
            statusLbl_18_03_25.layer.masksToBounds = true // Ensures the corner radius is applied
            //            statusLbl.font = UIFont.systemFont(ofSize: 16.0)
            sourceToDestinationView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                sourceToDestinationView_18_03_25.topAnchor.constraint(equalTo: dateTimeView_18_03_25.bottomAnchor, constant: 20)
            ])
        }
        else if rideStatus == "Cancelled" && ride_history_status == "Cancel by driver" {
            driverDetailsView_18_03_25.isHidden = false
            vehicleBrand_18_03_25.text = vehicle_brand
            vehicleNumber_18_03_25.text = vehicle_number
            driverName_18_03_25.text = driver_first_name
            statusLbl_18_03_25.text = "Cancelled by Driver"
            //            statusLbl.layer.borderColor = UIColor.systemRed.cgColor
            //            statusLbl.layer.borderWidth = 2.0
            //            statusLbl.layer.cornerRadius = 10.0
            statusLbl_18_03_25.layer.masksToBounds = true // Ensures the corner radius is applied
            //            statusLbl.font = UIFont.systemFont(ofSize: 15.0)
            statusLbl_18_03_25.font = UIFont.boldSystemFont(ofSize: 18.0)
            statusLbl_18_03_25.backgroundColor = UIColor.systemRed
            vehicleDetailsView.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                vehicleDetailsView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor, constant: 20)
//            ])

        }
        else if rideStatus == "Cancelled" && ride_history_status == "after accepted driver ride" {
            driverDetailsView_18_03_25.isHidden = false
            vehicleBrand_18_03_25.text = vehicle_brand
            vehicleNumber_18_03_25.text = vehicle_number
            driverName_18_03_25.text = driver_first_name
            statusLbl_18_03_25.text = "Cancelled by Passenger"
            //            statusLbl.layer.borderColor = UIColor.systemRed.cgColor
            //            statusLbl.layer.borderWidth = 2.0
            //            statusLbl.layer.cornerRadius = 10.0
            statusLbl_18_03_25.layer.masksToBounds = true // Ensures the corner radius is applied
            //            statusLbl.font = UIFont.systemFont(ofSize: 15.0)
            statusLbl_18_03_25.font = UIFont.boldSystemFont(ofSize: 18.0)
            statusLbl.backgroundColor = UIColor.systemRed
//            vehicleDetailsView.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                vehicleDetailsView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor, constant: 20)
//            ])
        } else if rideStatus == "Cancelled" && ride_history_status == "After ride started"{
            driverDetailsView_18_03_25.isHidden = false
            vehicleBrand_18_03_25.text = vehicle_brand
            vehicleNumber_18_03_25.text = vehicle_number
            driverName_18_03_25.text = driver_first_name
            statusLbl_18_03_25.text = "Cancelled by Passenger"
            //            statusLbl.layer.borderColor = UIColor.systemRed.cgColor
            //            statusLbl.layer.borderWidth = 2.0
            //            statusLbl.layer.cornerRadius = 10.0
            statusLbl_18_03_25.layer.masksToBounds = true // Ensures the corner radius is applied
            //            statusLbl.font = UIFont.systemFont(ofSize: 15.0)
            statusLbl.font = UIFont.boldSystemFont(ofSize: 18.0)
            statusLbl.backgroundColor = UIColor.systemRed
//            vehicleDetailsView.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                vehicleDetailsView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor, constant: 20)
//            ])
        } else {
            driverDetailsView_18_03_25.isHidden = false
            vehicleBrand_18_03_25.text = vehicle_brand
            vehicleNumber_18_03_25.text = vehicle_number
            driverName_18_03_25.text = driver_first_name
            statusLbl_18_03_25.text = "Completed"
            //            statusLbl.layer.borderColor = UIColor.systemGreen.cgColor
            //            statusLbl.layer.borderWidth = 2.0
            //            statusLbl.layer.cornerRadius = 10.0
            statusLbl_18_03_25.layer.masksToBounds = true // Ensures the corner radius is applied
            statusLbl_18_03_25.backgroundColor = UIColor.systemGreen
        }
        if let driverImageString = driverImage1?.trimmingCharacters(in: .whitespacesAndNewlines),
           !driverImageString.isEmpty {
            
            // Replace backslashes with forward slashes
            let correctedDriverImageString = driverImageString.replacingOccurrences(of: "\\", with: "/")
            
            print("Corrected Driver Image String: \(correctedDriverImageString)")  // Debugging line
            
            if let url = URL(string: correctedDriverImageString) {
                DispatchQueue.global().async {
                    if let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) {
                        DispatchQueue.main.async { [self] in
                            driverImage_18_03_25.image = image  // Or rotateImageBy270Degrees(image: image) if needed
                            driverImage_18_03_25.contentMode = .scaleAspectFill
                        }
                    } else {
                        DispatchQueue.main.async { [self] in
                            driverImage_18_03_25.image = UIImage(named: "placeholderImage")
                            driverImage_18_03_25.contentMode = .scaleAspectFill // Use a placeholder image
                        }
                    }
                }
            } else {
                print("Invalid Driver Image URL format: \(correctedDriverImageString)")  // Invalid URL
                driverImage_18_03_25.image = UIImage(named: "placeholderImage")
            }
        } else {
            print("Driver Image String is nil or empty")  // Debugging line
            driverImage_18_03_25.image = UIImage(named: "placeholderImage")
        }
        
        if let navigationRouteImgString = routMap_photo?.trimmingCharacters(in: .whitespacesAndNewlines),
           !navigationRouteImgString.isEmpty {
            
            // Replace backslashes with forward slashes
            let correctedVehicleImageString = navigationRouteImgString.replacingOccurrences(of: "\\", with: "/")
            
            print("Corrected navigation Route Image String: \(correctedVehicleImageString)")  // Debugging
            
            if let url = URL(string: correctedVehicleImageString) {
                print("Valid URL: \(url)")  // Debugging line
                DispatchQueue.global().async {
                    do {
                        let imageData = try Data(contentsOf: url)
                        if let image = UIImage(data: imageData) {
                            DispatchQueue.main.async { [self] in
                                //                                if let rotatedImage = rotateImageBy270Degrees(image: image) {
                                //                                            navigationRouteMapImg.image = rotatedImage
                                //                                        } else {
                                //                                            // In case rotation fails, use the original image
                                //                                            navigationRouteMapImg.image = image
                                //                                        }
                                navigationRouteMapImg_18_03_25.image = image
                                navigationRouteMapImg_18_03_25.contentMode = .scaleToFill
                            }
                        } else {
                            DispatchQueue.main.async { [self] in
                                navigationRouteMapImg_18_03_25.image = UIImage(named: "placeholderImage")
                                vehicleImage.contentMode = .scaleAspectFit // Use a placeholder image
                            }
                        }
                    } catch {
                        print("navigationRouteImgString -> Error fetching image data: \(error)")  // Handle error properly
                        DispatchQueue.main.async { [self] in
                            navigationRouteMapImg_18_03_25.image = UIImage(named: "")
                            navigationRouteMapImg.contentMode = .scaleAspectFit // Use a placeholder image
                        }
                    }
                }
            } else {
                print("Invalid URL format after correction: \(correctedVehicleImageString)")  // Invalid URL
                vehicleImage.image = UIImage(named: "placeholderImage")
            }
        } else {
            print("Vehicle Image String is nil or empty")
            vehicleImage.image = UIImage(named: "placeholderImage")
        }
    }
    
    
    
//    func rideHistoryDetails() {
//        dateLbl.text = bookedDate
//        currentLocationLbl.text = sourceAddress
//        destinationLocationLbl.text = destinationAddress
//        source.text = sourceAddress
//        destination.text = destinationAddress
//        dateLbl.text = bookeddate
//        TimeLbl.text = bookedtime
//        
//        //        if vehicle_brand == "" || vehicle_number == "" {
//        if rideStatus == "Cancelled" && ride_history_status == "while searching" {
//            driverDetailsView.isHidden = true
//            vehicleDetailsView.isHidden = true
//            paymentDetailsView.isHidden = true
//            statusLbl.text = "Cancelled"
//            //            statusLbl.layer.borderColor = UIColor.systemRed.cgColor
//            //            statusLbl.layer.borderWidth = 2.0
//            //            statusLbl.layer.cornerRadius = 10.0
//            statusLbl.layer.masksToBounds = true // Ensures the corner radius is applied
//            //            statusLbl.font = UIFont.systemFont(ofSize: 16.0)
//            statusLbl.textColor = UIColor.systemRed
//            sourceToDestinationView.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                sourceToDestinationView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor, constant: 20)
//            ])
//        }
//        else if rideStatus == "Cancelled" && ride_history_status == "Cancel by driver" {
//            driverDetailsView.isHidden = false
//            vehicleDetailsView.isHidden = false
//            paymentDetailsView.isHidden = true
//            vehicleBrand.text = vehicle_brand
//            vehicleNumber.text = vehicle_number
//            driverName.text = driver_first_name
//            statusLbl.text = "Cancelled by Driver"
//            //            statusLbl.layer.borderColor = UIColor.systemRed.cgColor
//            //            statusLbl.layer.borderWidth = 2.0
//            //            statusLbl.layer.cornerRadius = 10.0
//            statusLbl.layer.masksToBounds = true // Ensures the corner radius is applied
//            //            statusLbl.font = UIFont.systemFont(ofSize: 15.0)
//            statusLbl.font = UIFont.boldSystemFont(ofSize: 18.0)
//            statusLbl.textColor = UIColor.systemRed
//            vehicleDetailsView.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                vehicleDetailsView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor, constant: 20)
//            ])
//
//        }
//        else if rideStatus == "Cancelled" && ride_history_status == "after accepted driver ride" {
//            driverDetailsView.isHidden = false
//            vehicleDetailsView.isHidden = false
//            paymentDetailsView.isHidden = true
//            vehicleBrand.text = vehicle_brand
//            vehicleNumber.text = vehicle_number
//            driverName.text = driver_first_name
//            statusLbl.text = "Cancelled by Passenger"
//            //            statusLbl.layer.borderColor = UIColor.systemRed.cgColor
//            //            statusLbl.layer.borderWidth = 2.0
//            //            statusLbl.layer.cornerRadius = 10.0
//            statusLbl.layer.masksToBounds = true // Ensures the corner radius is applied
//            //            statusLbl.font = UIFont.systemFont(ofSize: 15.0)
//            statusLbl.font = UIFont.boldSystemFont(ofSize: 18.0)
//            statusLbl.textColor = UIColor.systemRed
//            vehicleDetailsView.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                vehicleDetailsView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor, constant: 20)
//            ])
//        } else if rideStatus == "Cancelled" && ride_history_status == "After ride started"{
//            driverDetailsView.isHidden = false
//            vehicleDetailsView.isHidden = false
//            paymentDetailsView.isHidden = true
//            vehicleBrand.text = vehicle_brand
//            vehicleNumber.text = vehicle_number
//            driverName.text = driver_first_name
//            statusLbl.text = "Cancelled by Passenger"
//            //            statusLbl.layer.borderColor = UIColor.systemRed.cgColor
//            //            statusLbl.layer.borderWidth = 2.0
//            //            statusLbl.layer.cornerRadius = 10.0
//            statusLbl.layer.masksToBounds = true // Ensures the corner radius is applied
//            //            statusLbl.font = UIFont.systemFont(ofSize: 15.0)
//            statusLbl.font = UIFont.boldSystemFont(ofSize: 18.0)
//            statusLbl.textColor = UIColor.systemRed
//            vehicleDetailsView.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                vehicleDetailsView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor, constant: 20)
//            ])
//        } else {
//            driverDetailsView.isHidden = false
//            vehicleDetailsView.isHidden = false
//            paymentDetailsView.isHidden = false
//            vehicleBrand.text = vehicle_brand
//            vehicleNumber.text = vehicle_number
//            driverName.text = driver_first_name
//            statusLbl.text = "Completed"
//            //            statusLbl.layer.borderColor = UIColor.systemGreen.cgColor
//            //            statusLbl.layer.borderWidth = 2.0
//            //            statusLbl.layer.cornerRadius = 10.0
//            statusLbl.layer.masksToBounds = true // Ensures the corner radius is applied
//            statusLbl.textColor = UIColor.systemGreen
//            if pickupamout == "0" {
//                pickupChargesLbl.isHidden = true
//                pickupamount.isHidden = true
//                NSLayoutConstraint.activate([
//                    estimatedRideChargesLbl.topAnchor.constraint(equalTo: self.fareTitleLbl.bottomAnchor, constant: 10)
//                    //                    fareTitleLbl.bottomAnchor.constraint(equalTo: self.estimatedRideChargesLbl.topAnchor, constant: 10)
//                ])
//            } else {
//                pickupamount.text = "Rs. " + (pickupamout ?? "")
//            }
//            fareamount.text = "Rs. " + (fareAmount ?? "")
//            totalamount.text = "Rs. " + (totalAmout ?? "")
//        }
//        //        if rideStatus == "cancel"{
//        //            statusLbl.text = "Cancelled"
//        ////            statusLbl.layer.borderColor = UIColor.systemRed.cgColor
//        ////            statusLbl.layer.borderWidth = 2.0
//        ////            statusLbl.layer.cornerRadius = 10.0
//        //            statusLbl.layer.masksToBounds = true // Ensures the corner radius is applied
//        //            statusLbl.textColor = UIColor.systemRed
//        //        } else {
//        //            statusLbl.text = "Completed"
//        ////            statusLbl.layer.borderColor = UIColor.systemGreen.cgColor
//        ////            statusLbl.layer.borderWidth = 2.0
//        ////            statusLbl.layer.cornerRadius = 10.0
//        //            statusLbl.layer.masksToBounds = true // Ensures the corner radius is applied
//        //            statusLbl.textColor = UIColor.systemGreen
//        //        }
//        //        if let vehicleImageString = vehicleImage1, let url = URL(string: vehicleImageString) {
//        //        if let vehicleImageString = vehicleImage1?.trimmingCharacters(in: .whitespacesAndNewlines), !vehicleImageString.isEmpty, let url = URL(string: vehicleImageString) {
//        //            DispatchQueue.global().async {
//        //                if let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) {
//        //                    DispatchQueue.main.async { [self] in
//        //                        vehicleImage.image = image
//        //                        vehicleImage.contentMode = .scaleAspectFit
//        //                    }
//        //                } else {
//        //                    DispatchQueue.main.async { [self] in
//        //                        vehicleImage.image = UIImage(named: "placeholderImage")
//        //                        vehicleImage.contentMode = .scaleAspectFit// Use a placeholder image
//        //                    }
//        //                }
//        //            }
//        //        } else {
//        //            vehicleImage.image = UIImage(named: "placeholderImage")
//        //        }
//        if let vehicleImageString = vehicleImage1?.trimmingCharacters(in: .whitespacesAndNewlines),
//           !vehicleImageString.isEmpty {
//            
//            // Replace backslashes with forward slashes
//            let correctedVehicleImageString = vehicleImageString.replacingOccurrences(of: "\\", with: "/")
//            
//            print("Corrected Vehicle Image String: \(correctedVehicleImageString)")  // Debugging
//            
//            if let url = URL(string: correctedVehicleImageString) {
//                print("Valid URL: \(url)")  // Debugging line
//                DispatchQueue.global().async {
//                    do {
//                        let imageData = try Data(contentsOf: url)
//                        if let image = UIImage(data: imageData) {
//                            DispatchQueue.main.async { [self] in
//                                vehicleImage.image = image
//                                vehicleImage.contentMode = .scaleAspectFit
//                            }
//                        } else {
//                            DispatchQueue.main.async { [self] in
//                                vehicleImage.image = UIImage(named: "placeholderImage")
//                                vehicleImage.contentMode = .scaleAspectFit // Use a placeholder image
//                            }
//                        }
//                    } catch {
//                        print("Vehicle Image -> Error fetching image data: \(error)")  // Handle error properly
//                        DispatchQueue.main.async { [self] in
//                            vehicleImage.image = UIImage(named: "placeholderImage")
//                            vehicleImage.contentMode = .scaleAspectFit // Use a placeholder image
//                        }
//                    }
//                }
//            } else {
//                print("Invalid Vehicle Image URL format after correction: \(correctedVehicleImageString)")  // Invalid URL
//                vehicleImage.image = UIImage(named: "placeholderImage")
//            }
//        } else {
//            print("Vehicle Image String is nil or empty")
//            vehicleImage.image = UIImage(named: "placeholderImage")
//        }
//        
//        //        if let driverImageString = driverImage1, let url = URL(string: driverImageString) {
//        //            DispatchQueue.global().async {
//        //                if let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) {
//        //                    DispatchQueue.main.async { [self] in
//        ////                        driverImage.image = rotateImageBy270Degrees(image: image)
//        //                        driverImage.image = image
//        //                        driverImage.contentMode = .scaleToFill
//        //                    }
//        //                } else {
//        //                    DispatchQueue.main.async { [self] in
//        //                        driverImage.image = UIImage(named: "placeholderImage")
//        //                        driverImage.contentMode = .scaleToFill // Use a placeholder image
//        //                    }
//        //                }
//        //            }
//        //        } else {
//        //            vehicleImage.image = UIImage(named: "placeholderImage")
//        //        }
//        //        driverImage.image = rotateImageBy270Degrees(image: driverImage1!)
//        if let driverImageString = driverImage1?.trimmingCharacters(in: .whitespacesAndNewlines),
//           !driverImageString.isEmpty {
//            
//            // Replace backslashes with forward slashes
//            let correctedDriverImageString = driverImageString.replacingOccurrences(of: "\\", with: "/")
//            
//            print("Corrected Driver Image String: \(correctedDriverImageString)")  // Debugging line
//            
//            if let url = URL(string: correctedDriverImageString) {
//                DispatchQueue.global().async {
//                    if let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) {
//                        DispatchQueue.main.async { [self] in
//                            driverImage.image = image  // Or rotateImageBy270Degrees(image: image) if needed
//                            driverImage.contentMode = .scaleAspectFill
//                        }
//                    } else {
//                        DispatchQueue.main.async { [self] in
//                            driverImage.image = UIImage(named: "placeholderImage")
//                            driverImage.contentMode = .scaleAspectFill // Use a placeholder image
//                        }
//                    }
//                }
//            } else {
//                print("Invalid Driver Image URL format: \(correctedDriverImageString)")  // Invalid URL
//                driverImage.image = UIImage(named: "placeholderImage")
//            }
//        } else {
//            print("Driver Image String is nil or empty")  // Debugging line
//            driverImage.image = UIImage(named: "placeholderImage")
//        }
//        
//        if let navigationRouteImgString = routMap_photo?.trimmingCharacters(in: .whitespacesAndNewlines),
//           !navigationRouteImgString.isEmpty {
//            
//            // Replace backslashes with forward slashes
//            let correctedVehicleImageString = navigationRouteImgString.replacingOccurrences(of: "\\", with: "/")
//            
//            print("Corrected navigation Route Image String: \(correctedVehicleImageString)")  // Debugging
//            
//            if let url = URL(string: correctedVehicleImageString) {
//                print("Valid URL: \(url)")  // Debugging line
//                DispatchQueue.global().async {
//                    do {
//                        let imageData = try Data(contentsOf: url)
//                        if let image = UIImage(data: imageData) {
//                            DispatchQueue.main.async { [self] in
//                                //                                if let rotatedImage = rotateImageBy270Degrees(image: image) {
//                                //                                            navigationRouteMapImg.image = rotatedImage
//                                //                                        } else {
//                                //                                            // In case rotation fails, use the original image
//                                //                                            navigationRouteMapImg.image = image
//                                //                                        }
//                                navigationRouteMapImg.image = image
//                                navigationRouteMapImg.contentMode = .scaleToFill
//                            }
//                        } else {
//                            DispatchQueue.main.async { [self] in
//                                navigationRouteMapImg.image = UIImage(named: "placeholderImage")
//                                vehicleImage.contentMode = .scaleAspectFit // Use a placeholder image
//                            }
//                        }
//                    } catch {
//                        print("navigationRouteImgString -> Error fetching image data: \(error)")  // Handle error properly
//                        DispatchQueue.main.async { [self] in
//                            navigationRouteMapImg.image = UIImage(named: "")
//                            navigationRouteMapImg.contentMode = .scaleAspectFit // Use a placeholder image
//                        }
//                    }
//                }
//            } else {
//                print("Invalid URL format after correction: \(correctedVehicleImageString)")  // Invalid URL
//                vehicleImage.image = UIImage(named: "placeholderImage")
//            }
//        } else {
//            print("Vehicle Image String is nil or empty")
//            vehicleImage.image = UIImage(named: "placeholderImage")
//        }
//    }
    
}

extension RideHistoryDetailsViewController{
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
    
    func rotateImage(image: UIImage, byDegrees degrees: CGFloat) -> UIImage? {
        let radians = degrees * CGFloat.pi / 180 // Convert degrees to radians
        
        // Create a new context of the correct size
        var newSize = CGRect(origin: CGPoint.zero, size: image.size)
            .applying(CGAffineTransform(rotationAngle: radians)).size
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContext(newSize)
        let context = UIGraphicsGetCurrentContext()!
        
        // Move origin to the middle of the image so we can rotate around the center
        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        
        // Rotate the image context
        context.rotate(by: radians)
        
        // Draw the image at its center
        image.draw(in: CGRect(x: -image.size.width / 2, y: -image.size.height / 2, width: image.size.width, height: image.size.height))
        
        // Get the new image from the context
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return rotatedImage
    }
}
