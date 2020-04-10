//
//  SecondViewController.swift
//  MapViewEx
//
//  Created by Pradeep on 10/04/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class SecondViewController: UIViewController, CLLocationManagerDelegate,MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var txtView: UITextView!
    
    let manager = CLLocationManager()
    var userCoordinate:CLLocationCoordinate2D?
    let userPin = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        manager.delegate = self
        manager.requestLocation()
        txtView.text = "Map is loading..."
        // Do any additional setup after loading the view.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            print("Found user location = \(location)")
            print("Lat: \(location.coordinate.latitude)")
            print("Long: \(location.coordinate.longitude)")
            userCoordinate = location.coordinate
            
            let region = MKCoordinateRegion(center: userCoordinate!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            mapView.setRegion(region, animated: true)
            
            
            userPin.coordinate = userCoordinate!
            userPin.title = "Current Location"
            mapView.addAnnotation(userPin)
            
            retreiveCityName(lattitude: userCoordinate?.latitude ?? 0.0, longitude: userCoordinate?.longitude ?? 0.0) { (response) in
    
                DispatchQueue.main.async {
                    self.userPin.title = response?.address
                    self.txtView.text = "Location = \(response?.locationName ?? "") \n"
                    self.txtView.text.append(contentsOf: "Street = \(response?.street ?? "") \n")
                    self.txtView.text.append(contentsOf: "City = \(response?.city ?? "") \n")
                    self.txtView.text.append(contentsOf: "Zip = \(response?.zip ?? "") \n")
                    self.txtView.text.append(contentsOf: "Country = \(response?.country ?? "") \n")
                }
                
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user location = \(error.localizedDescription)")
        
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard annotation is MKPointAnnotation else {
            return nil
        }
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        
        if annotationView == nil {
            
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.isDraggable = true
        }
        else{
            annotationView?.annotation = annotation
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        if newState == MKAnnotationView.DragState.ending {
            let droppedAt = view.annotation?.coordinate
            userCoordinate = view.annotation?.coordinate
            
            print(droppedAt.debugDescription)
            retreiveCityName(lattitude: userCoordinate?.latitude ?? 0.0, longitude: userCoordinate?.longitude ?? 0.0) { (response) in
                print("response = \(response)")
                
                DispatchQueue.main.async {
                    self.userPin.title = response?.address
                    self.txtView.text = "Location = \(response?.locationName ?? "") \n"
                    self.txtView.text.append(contentsOf: "Street = \(response?.street ?? "") \n")
                    self.txtView.text.append(contentsOf: "City = \(response?.city ?? "") \n")
                    self.txtView.text.append(contentsOf: "Zip = \(response?.zip ?? "") \n")
                    self.txtView.text.append(contentsOf: "Country = \(response?.country ?? "") \n")
                }
                
            }
        }
    }
    
    func retreiveCityName(lattitude: Double, longitude: Double, completionHandler: @escaping (UserData?) -> Void)
    {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: lattitude, longitude: longitude), completionHandler:
        {
            placeMarks, error in
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placeMarks?[0]

            
            
            // Address dictionary
            let description =  placeMark.description
            let address = description.components(separatedBy: "@")[0]
            print("Address: =\(address)")
            print("description = \(placeMark.description)")
            print(placeMark.addressDictionary!)
            var locationName = ""
            var street = ""
            var city = ""
            var zip = ""
            var country = ""
            
            // Location name
            if let locationName1 = placeMark.addressDictionary?["Name"] as? NSString
            {
                locationName = locationName1 as String
            }

            // Street address
            if let street1 = placeMark.addressDictionary?["Thoroughfare"] as? NSString
            {
                street = street1 as String
            }

            // City
            if let city1 = placeMark.addressDictionary?["City"] as? NSString
            {
                city = city1 as String
            }

            // Zip code
            if let zip1 = placeMark.addressDictionary?["ZIP"] as? NSString
            {
                zip = zip1 as String
            }

            // Country
            if let country1 = placeMark.addressDictionary?["Country"] as? NSString
            {
                country = country1 as String
            }
            let userData = UserData(locationName: locationName,street: street, city: city, zip: zip, country: country, address: address)
            
            completionHandler(userData)
         })
    }
}
