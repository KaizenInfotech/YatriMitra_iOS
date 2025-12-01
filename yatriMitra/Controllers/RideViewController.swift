//
//  RideViewController.swift
//  yatriMitra
//
//  Created by Kaizen Infotech Solutions Private Limited. on 27/08/24.
//

import UIKit
import MapKit
import GoogleMaps
import CoreLocation

class RideViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var myMap: MKMapView!
    
    var mapView: GMSMapView!
    var mainLat : CLLocationDegrees?
    var mainLong : CLLocationDegrees?
    let locationManager = CLLocationManager()
    let geoCoder = CLGeocoder()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myMap.delegate = self
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 8)
        mapView = GMSMapView.map(withFrame: self.myMap.bounds, camera: camera)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.myMap.addSubview(mapView)
        mapView.delegate = self
        
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
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
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
//                    if boolAutoComplete {
//                        currentLocationTxtField.text=address
//                        print("Address(MapVC) : \(address)")
//                        boolAutoComplete = false
//                    }
                }
            }
        }
        let center = CLLocationCoordinate2D(latitude: locationManager.location?.coordinate.latitude ?? 0.0, longitude: locationManager.location?.coordinate.longitude ?? 0.0)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
        // Set the region on the map view
        myMap.setRegion(region, animated: true)
        
        
        //        pickupLocation.text = " \(latitude), \(longitude)"
        
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
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 4.0
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }

}
