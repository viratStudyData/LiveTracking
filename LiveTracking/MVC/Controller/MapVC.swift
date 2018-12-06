//
//  MapVC.swift
//  LiveTracking
//
//  Created by Apple on 04/12/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import GoogleMaps

class MapVC: UIViewController {

    //MARK: -----> Outlets
    @IBOutlet weak var mapView: GMSMapView!
    
    //MARK: -----> Properties
    var locationData: LocationDataModel?
    var driverMarker = GMSMarker()
    var isDoneCurrentPolyline: Bool = true
    var fitBound:Bool = true
    var polyline: GMSPolyline?
    
    
    //MARK: -----> Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        onViewLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

//MARK: -----> Cuctom Methods
extension MapVC {
    
    func onViewLoad() {
        LocationManager.shared.delegateLocationUpdate = self
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: CLLocationDegrees((locationData?.pickupLat)?.toDouble() ?? 0.0), longitude: CLLocationDegrees((locationData?.pickupLong)?.toDouble() ?? 0.0), zoom: 8.0)
        mapView?.animate(to: camera)
        
        let source = CLLocationCoordinate2D(latitude: (locationData?.pickupLat)?.toDouble() ?? 0.0, longitude: (locationData?.pickupLong)?.toDouble() ?? 0.0)
        let destination = CLLocationCoordinate2D(latitude: (locationData?.dropOffLat)?.toDouble() ?? 0.0, longitude: (locationData?.dropOffLong)?.toDouble() ?? 0.0)
        
        getPolylineRoute(from: source, to:  destination)
    }
    
    //MARK: Create Pplyline
    func getPolylineRoute(from source: CLLocationCoordinate2D? , to destination: CLLocationCoordinate2D?){
        if isDoneCurrentPolyline{
            isDoneCurrentPolyline = false
            
            guard let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source?.latitude ?? 0.0),\(source?.longitude ?? 0.0)&destination=\(destination?.latitude ?? 0.0),\(destination?.longitude ?? 0.0)&sensor=true&mode=driving&key=\(Constants.googleKey.rawValue)") else {
                isDoneCurrentPolyline = true
                return
            }
            
            getPath(url: url, source: source, destination: destination)
        }
    }
    
    
    @IBAction func btnBackAction(_ sender: Any) {
        popVC()
    }
}

//MARK: -----> Delegates
extension MapVC: LocationUpdatedDelegate {
    
    func fetchNewLocation() {
        
        guard let source = LocationManager.shared.currentLoc?.coordinate, let destLat = (locationData?.dropOffLat)?.toDouble(), let destLong = (locationData?.dropOffLong)?.toDouble()  else {return}
        
        let destination = CLLocationCoordinate2D(latitude: destLat, longitude: destLong)
        
        getPolylineRoute(from: source, to:  destination)
    }
    
}


//MARK: -----> API
extension MapVC {
    
    func getPath(url: URL, source: CLLocationCoordinate2D?, destination: CLLocationCoordinate2D?) {
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
            if error != nil {
                print(error?.localizedDescription ?? "Error")
                self.isDoneCurrentPolyline = true
                
            }else {
                do {
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]{
                        
                        DispatchQueue.global(qos: .background).async { [weak self] () -> Void in
                            guard let routes = json["routes"] as? NSArray else {
                                self?.isDoneCurrentPolyline = true
                                return
                            }
                            if (routes.count > 0) {
                                let overview_polyline = routes[0] as? NSDictionary
                                let dictPolyline = overview_polyline?["overview_polyline"] as? NSDictionary
                                guard let points = dictPolyline?.object(forKey: "points") as? String else { return }
                                
                                
                                DispatchQueue.main.async { () -> Void in
                                    self?.updateDriverLoction(points: points, source: source!, destination: destination!)
                                }
                                
                            }else{
                                self?.isDoneCurrentPolyline = true
                            }
                        }
                    }
                    
                }catch {
                    print("error in JSONSerialization")
                    self.isDoneCurrentPolyline = true
                }
            }
        })
        task.resume()
    }
    
    func updateDriverLoction(points: String, source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        
        self.mapView?.clear()
        guard let path = GMSMutablePath(fromEncodedPath: points) else {
            self.isDoneCurrentPolyline = true
            return
        }
        
        driverMarker.isFlat = true
        driverMarker.icon = #imageLiteral(resourceName: "car")
        driverMarker.map = mapView
        CATransaction.begin()
        CATransaction.setAnimationDuration(3.0)
        if let heading = LocationManager.shared.heading {
            driverMarker.rotation = heading
        }
        driverMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        driverMarker.position = CLLocationCoordinate2D(latitude: source.latitude, longitude: source.longitude)
        CATransaction.commit()
        
        let bounds = GMSCoordinateBounds(path: path)
        if self.fitBound {
            self.fitBound = false
            self.fitToMap(bounds: bounds)
        }
        
        self.showPath(polyStr: points)
    }
    
    func fitToMap(bounds: GMSCoordinateBounds) {
        self.mapView?.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50.0))
    }
    
    func showPath(polyStr :String){
        self.isDoneCurrentPolyline = true
        let path = GMSMutablePath(fromEncodedPath: polyStr)
        polyline = GMSPolyline(path: path)
        polyline?.geodesic = true
        polyline?.strokeWidth = 3.0
        polyline?.strokeColor = UIColor.black.withAlphaComponent(0.8)
        polyline?.map = mapView
    }
    
}
