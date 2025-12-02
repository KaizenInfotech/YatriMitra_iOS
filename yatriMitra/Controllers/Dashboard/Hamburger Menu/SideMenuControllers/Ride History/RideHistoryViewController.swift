//
//  RideHistoryViewController.swift
//  yatriMitra
//
//  Created by Kaizen Infotech Solutions Private Limited. on 12/06/24.
//

import UIKit
import Alamofire

class RideHistoryViewController: UIViewController {

    @IBOutlet weak var loaderActivity: UIActivityIndicatorView!
    @IBOutlet weak var emptyRideImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyRideMessage: UIImageView!
    
    weak var profileBackVCDelegate: ProfileBackVC?
    
    
    //    var rideDate = ["Tue, May 07, 06:49 PM", "Tue, May 07, 06:49 PM", "Tue, May 07, 06:49 PM"]
    var rideDate : [String] = []
    //    var rideTypeLbl = ["Rickshaw", "Non-AC Taxi", "AC Taxi"]
    var rideTypeLbl : [String] = []
    //    var rideTypeImg = [UIImage(named: "autoRickshaw"),UIImage(named: "non-ac-taxi"),UIImage(named: "ac-Taxi")]
    var rideTypeImg : [UIImage] = []
    var driverImage : [UIImage] = []
    var sourceaddress : [String] = []
    var distinationaddress : [String] = []
    var output: [[String : Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        //        navigationController?.navigationBar.titleTextAttributes?[NSAttributedString.Key.foregroundColor: UIColor(named: "#DFF0FF")]
        createNavigationBar()
        emptyRideImage.isHidden = true
        emptyRideMessage.isHidden = true
        loaderActivity.startAnimating()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        rideHistoryApiCall()
    }
    
    
    func createNavigationBar() {
        
        let customBackButton = UIButton()
        customBackButton.setImage(UIImage(named: "back"), for: .normal)
        customBackButton.addTarget(self, action: #selector(customBackButtonTapped), for: .touchUpInside)
        
        // Set custom back button as left bar button item
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customBackButton)
        
        self.title = "Ride History"
        
        // Optional: Customize the title appearance
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 20, weight: .bold)
        ]
        self.navigationController?.navigationBar.titleTextAttributes = titleAttributes
    }
    @objc func customBackButtonTapped() {
        self.profileBackVCDelegate?.profileBackVC(memberID: Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? ""), banner: "false")
        self.navigationController?.popViewController(animated: true)
    }
}


extension RideHistoryViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("output.count : \(output.count)")
        return output.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RideHistoryTableViewCell") as! RideHistoryTableViewCell
        cell.selectionStyle = .none
        //        cell.rideDate.text = rideDate[indexPath.row]
        //        cell.rideTypeImg.image = rideTypeImg[indexPath.row]
        //        if indexPath.row < driverImage.count {
        //            cell.driverImage.image = driverImage[indexPath.row]
        //        } else {
        //            print("Index out of range for driverImage at row \(indexPath.row).")
        //            // Optionally, set a placeholder image or handle the missing image case
        //            cell.driverImage.image = UIImage(named: "Mask group")
        //        }
        //        cell.rideTypeLbl.text = rideTypeLbl[indexPath.row]
        
        cell.rideHistoryTblViewCell.roundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10)
        if let outputs = output[indexPath.row] as? [String:Any] {
            if let bookedDate = outputs["bookeddate"] as? String {
                cell.rideDate.text = bookedDate
                cell.dateLbl.text = bookedDate
            }
            
            if let bookedTime = outputs["bookedtime"] as? String {
                cell.timeLbl.text = bookedTime
            }
            
            if let vehicletype = outputs["vehicletype"] as? String {
                cell.rideTypeLbl.text = vehicletype
            }
            
            if let rideStatus = outputs["ride_status"] as? String {
                cell.rideStatusLbl.text = rideStatus
                if rideStatus == "Completed"{
                    //                    cell.rideStatusLbl.text = "Completed"
                    cell.rideStatusLbl.textColor = UIColor(hex: "#03DE73")
                } else {
                    //                    cell.rideStatusLbl.text = "Cancelled"
                    cell.rideStatusLbl.textColor = UIColor(hex: "#FD4744")
                }
            }
            if let vehicleimage = outputs["vehicleimage"] as? String,
               let url = URL(string: vehicleimage),
               let imageData = try? Data(contentsOf: url),
               let image = UIImage(data: imageData) {
                cell.rideTypeImg.image = image
                cell.rideTypeImg.contentMode = .scaleAspectFit
            }
            if let driverimage = outputs["driverimage"] as? String,
               let url = URL(string: driverimage),
               let imageData = try? Data(contentsOf: url),
               let image = UIImage(data: imageData) {
                let modifiedDriverImage = rotateImageBy270Degrees(image: image)
                cell.driverImage.image = modifiedDriverImage
                cell.driverImage.contentMode = .scaleAspectFit
            }
            if let distinationaddress = outputs["distinationaddress"] as? String {
                cell.distinationaddress.text = distinationaddress
            }
            if let sourceaddress = outputs["sourceaddress"] as? String {
                cell.sourceaddress.text = sourceaddress
            }
            if let amount = outputs["totalAmout"] as? String {
                cell.approx_Fare.text = "₹ "+amount
            }
            if let distance = outputs["distance"] as? String {
                cell.distance.text = distance + " KM"
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 185
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mapViewController = storyboard.instantiateViewController(withIdentifier: "RideHistoryDetailsViewController") as? RideHistoryDetailsViewController {
            let rideDetail = output[indexPath.row]
            
            
            if  let rideDetails = rideDetail as? [String:Any]
            {
                mapViewController.pkBookrideId = rideDetails["pk_bookride_id"] as? Int
                mapViewController.vehicleType = rideDetails["vehicletype"] as? String
                mapViewController.vehicleTypeId = rideDetails["vehicletypeid"] as? Int
                mapViewController.vehicleImage1 = rideDetails["vehicleimage"] as? String
                mapViewController.driverImage1 = rideDetails["driverimage"] as? String
                mapViewController.sourceAddress = rideDetails["sourceaddress"] as? String
                mapViewController.destinationAddress = rideDetails["distinationaddress"] as? String
                mapViewController.fkDriverId = rideDetails["fk_member_master_profile_driver_id"] as? Int
                mapViewController.rideStatus = rideDetails["ride_status"] as? String
                mapViewController.ride_history_status = rideDetails["ride_history_status"] as? String
                
                
                mapViewController.bookedtime = rideDetails["bookedtime"] as? String
                mapViewController.bookeddate = rideDetails["bookeddate"] as? String
                mapViewController.pickupamout = rideDetails["pickupamout"] as? String
                mapViewController.fareAmount = rideDetails["fareAmount"] as? String
                mapViewController.totalAmout = rideDetails["totalAmout"] as? String
                mapViewController.vehicle_brand = rideDetails["vehicle_brand"] as? String
                mapViewController.vehicle_number = rideDetails["vehicle_number"] as? String
                mapViewController.routMap_photo = rideDetails["routMap_photo"] as? String
                mapViewController.driver_first_name = rideDetails["first_name"] as? String
            }
            
            
            navigationController?.pushViewController(mapViewController, animated: true)
        }
    }
    
}

extension RideHistoryViewController {
    func rideHistoryApiCall() {
        let url = AppConfig.baseURL+"Book/RideHistoryList_DetailForUser"
        let params :  [String : Any] = [
            "fk_member_master_profile_id": Int(UserDefaults.standard.string(forKey: "fk_member_master_profile_id") ?? "")
        ]
        print("rideHistoryApiCall() -> url : \(url)")
        print("rideHistoryApiCall() -> params : \(params)")
        
        let token = UserDefaults.standard.string(forKey: "auth_deviceToken") ?? ""

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default,headers: headers, interceptor: nil).response { [self] response in
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
                            output = loginResult["output"] as! [[String: Any]]
                            
                            print("output : \(output)")
                            //                            for fare in output{
                            //                                let bookeddate = fare["bookeddate"] as? String ?? ""
                            //                                print("bookeddate : \(bookeddate)")
                            //                                self.rideDate.append(bookeddate)
                            //
                            //                                let vehicletype = fare["vehicletype"] as? String ?? ""
                            //                                print("vehicletype : \(vehicletype)")
                            //                                self.rideTypeLbl.append(vehicletype)
                            //
                            //                                if let vehicleImageString = fare["vehicleimage"] as? String,
                            //                                   let url = URL(string: vehicleImageString),
                            //                                   let imageData = try? Data(contentsOf: url),
                            //                                   let image = UIImage(data: imageData) {
                            //                                    print("Vehicle image loaded successfully.")
                            //                                    self.rideTypeImg.append(image)
                            //                                    print("rideTypeImg : \(self.rideTypeImg)")
                            //                                } else {
                            //                                    print("Failed to load vehicle image.")
                            //                                }
                            //                                if let driverimageString = fare["driverimage"] as? String,
                            //                                   let url = URL(string: driverimageString),
                            //                                   let imageData = try? Data(contentsOf: url),
                            //                                   let image = UIImage(data: imageData) {
                            //                                    print("Vehicle image loaded successfully.")
                            //                                    let modifiedImage = self.rotateImageBy270Degrees(image: image)
                            //                                    self.driverImage.append(modifiedImage!)
                            //                                    print("rideTypeImg : \(self.rideTypeImg)")
                            //                                } else {
                            //                                    print("Failed to load vehicle image.")
                            //                                }
                            //                                let sourceaddress = fare["sourceaddress"] as? String ?? ""
                            //                                print("sourceaddress : \(sourceaddress)")
                            //                                self.sourceaddress.append(sourceaddress)
                            //                                let distinationaddress = fare["distinationaddress"] as? String ?? ""
                            //                                print("distinationaddress : \(distinationaddress)")
                            //                                self.distinationaddress.append(distinationaddress)
                            //                            }
                            
                            DispatchQueue.main.async { [self] in
                                loaderActivity.stopAnimating()
                                loaderActivity.isHidden = true
                                if output.count == 0 {
                                    emptyRideImage.isHidden = false
                                    emptyRideMessage.isHidden = false
                                    tableView.isHidden = true
                                } else {
                                    emptyRideImage.isHidden = true
                                    emptyRideMessage.isHidden = true
                                    tableView.isHidden = false
                                    self.tableView.reloadData()
                                }
                            }
                        } else {
                        }
                    } catch {
                        //                                   self.showAlert(title: "Error", message: "Failed to parse JSON: \(error.localizedDescription)")
                        loaderActivity.stopAnimating()
                        loaderActivity.isHidden = true
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


extension RideHistoryViewController{
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
}
