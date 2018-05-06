//
//  ViewController.swift
//  TrainingMaps
//
//  Created by Isaías on 5/5/18.
//  Copyright © 2018 Isaías. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import PKHUD


class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager!
    var startDateUpdatedLocation: Date? = nil{
        willSet{
            // Solo cuando comience a obtener ubicaciones se mostrará el HUD.
            HUD.show(.systemActivity)
        }
    }
    
    let ZOOM_LEVEL: Int = 15 // Zoom una vez obtenido las ubicaciones
    let MAX_SECONDS_WATING: Double = 4 // Cantidad de tiempo maximo para obtener las ubicaciones
    let RANDOM_LOCATION = CLLocationCoordinate2DMake(35.671048, 139.709510)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HUD.dimsBackground = false
        HUD.allowsInteraction = false
        
        self.configLocationManager()
        self.configMap()
    }
    
    func configMap() {
        self.mapView.mapType = .standard
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self
    }
    
    func configLocationManager() {
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func openLocationSettings() {
        let urlSettings = URL(string: UIApplicationOpenSettingsURLString)
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(urlSettings!, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(urlSettings!)
        }
    }
    

    //MARK: CLLocationManager Delegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        print("didChangeAuthorization")
        
        HUD.hide(animated: true)
        
        if status == .denied {
            print("Denied")
        }
        else if status == .notDetermined{
            print("Not Determined")
        }
        else if status == .restricted{
            print("Restricted")
        }
        else if status == .authorizedAlways{
            print("authorizedAlways")
        }
        else if status == .authorizedWhenInUse{
            print("authorizedWhenInUse")
        }
        
        if status != .authorizedWhenInUse {
            let alert = UIAlertController(title: "Location is not enabled", message: "Press OK to open Settings", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.openLocationSettings()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                NSLog("The \"Cancel\" alert occured.")
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        print("Error getting Location: \(error.localizedDescription)")
        let alert = UIAlertController(title: "Error", message: "There's was a problem trying to get your Location \n Trying again later.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        if startDateUpdatedLocation == nil {
            startDateUpdatedLocation = Date()
        }
        
        let elapsed = locations.last?.timestamp.timeIntervalSince(startDateUpdatedLocation!)
        // Despues de 5 segundos
        if Double(elapsed!) >= MAX_SECONDS_WATING {
            self.locationManager.stopUpdatingLocation()
            
            HUD.hide(animated: true)
            
            let centerLocation = locations.last!.coordinate
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = centerLocation
            annotation.title = nil
            annotation.subtitle = nil
            
            self.mapView.addAnnotation(annotation)
            
            self.mapView.setCenterCoordinate(centerLocation, withZoomLevel: ZOOM_LEVEL, animated: true)
        }
        
    }

    //MARK: MKMapView Delegate

    //TODO: Cambiar color al Pin
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
//        if annotation.isKind(of: MKUserLocation.self) { // Ubicacion usuario
//            return nil  // Por defecto
//        }
//        else{
//            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "id")
//
//            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "id")
//            annotationView!.canShowCallout = false
//            annotationView!.tintColor = UIColor.blue
//
//            return annotationView
//        }
//    }

    
}

