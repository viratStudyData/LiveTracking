//
//  LocationManager.swift
//  BusinessDirectory
//
//  Created by Aseem 13 on 18/01/17.
//  Copyright © 2017 Taran. All rights reserved.
//

import UIKit
import CoreLocation
import EZSwiftExtensions

protocol LocationUpdatedDelegate  : class{
    func fetchNewLocation()
}

class LocationManager: NSObject {
    
    //MARK: -----> Properties
    var locationManager : CLLocationManager?
    var currentLoc : CLLocation?
    var heading : CLLocationDirection?
    weak var delegateLocationUpdate : LocationUpdatedDelegate?
    
    static let shared = LocationManager()
    
    
    //MARK: -----> Initial Method
    override init() {
        super.init()
        locationInitializer()
        updateLocation()
    }
    
}

//MARK: -----> Custom Methods
extension LocationManager {
    func updateLocation(){
        if CLLocationManager.authorizationStatus() == .denied{
            settingsAlert()
            return
        }
        locationManager?.delegate = self
        locationManager?.startUpdatingLocation()
    }
    
    func stopUpdateLocation(){
        locationManager?.delegate = nil
        locationManager?.stopUpdatingLocation()
    }
    
    func locationInitializer(){
        locationManager?.delegate = nil
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager?.requestAlwaysAuthorization()
        locationManager?.distanceFilter = 1
        
    }
    
    func settingsAlert(){
        let alert = UIAlertController.init(title: "Allow Permission", message: "We need your location to serve you better,Please turn on location services in settings", preferredStyle: .alert)
        
        let deny = UIAlertAction.init(title: "Deny", style: .default, handler: nil)
        let allow = UIAlertAction.init(title: "Allow", style: .default, handler: {(action) in
            UIApplication.shared.open(NSURL(string:UIApplicationOpenSettingsURLString)! as URL, options: [:], completionHandler: nil)
        })
        alert.addAction(deny)
        alert.addAction(allow)
        
        ez.topMostVC?.presentVC(alert)
        
    }
    
}


//MARK: -----> Delegates
extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse,.authorizedAlways:
            locationManager?.startUpdatingLocation()
        case .notDetermined:
            locationManager?.requestAlwaysAuthorization()
        case .restricted,.denied:
            self.settingsAlert()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLoc = locations.last
        heading = currentLoc?.course
        delegateLocationUpdate?.fetchNewLocation()
    }
}
