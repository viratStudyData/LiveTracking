//
//  ViewController.swift
//  LiveTracking
//
//  Created by Apple on 04/12/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import GooglePlacePicker
import EZSwiftExtensions

class HomeVC: UIViewController {

    //MARK: -----> Outlets
    @IBOutlet weak var txtFieldPickup: UITextField!
    @IBOutlet weak var txtFieldDropOff: UITextField!
    
    //MARK: Properties
    var isPickUp: Bool = true
    var locationData = LocationDataModel()
    
    //MARK: -----> Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}


//MARK: -----> Custom Methods
extension HomeVC {
    @IBAction func btnActionGo(_ sender: Any) {
        
        if txtFieldPickup.text == "" {
            Alerts.shared.showAlert(type: AlertsType.alert, message: AlertsMessage.pickUp)
            
        }else if txtFieldDropOff.text == "" {
            Alerts.shared.showAlert(type: AlertsType.alert, message: AlertsMessage.dropOff)
            
        }else {
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: StoryboardId.mapVC.rawValue) as? MapVC else {return}
            vc.locationData = locationData
            pushVC(vc)
        }
        
    }
    
    func placePickerConfigure() {
        self.view.endEditing(true)
        
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        self.present(placePicker, animated: true, completion: nil)
        
        return
    }
}


//MARK: -----> Delegates
extension HomeVC: UITextFieldDelegate, GMSPlacePickerViewControllerDelegate {
    
    //GMSPlacePickerViewController Delegate
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        viewController.dismiss(animated: true, completion: nil)
        
        let lat = place.coordinate.latitude.description
        let long = place.coordinate.longitude.description
        let address = place.formattedAddress ?? ""
        
        if isPickUp{
           txtFieldPickup.text = address
            locationData.pickupLat = lat
            locationData.pickupLong = long
            
        }else{
            txtFieldDropOff.text = address
            locationData.dropOffLat = lat
            locationData.dropOffLong = long
            
        }
        print(locationData.pickupLong)
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        viewController.dismissVC(completion: nil)
    }
    
    func placePicker(_ viewController: GMSPlacePickerViewController, didFailWithError error: Error) {
        print(error)
    }
    
    //TextField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == txtFieldPickup {
            isPickUp = true
            placePickerConfigure()
        }else {
            isPickUp = false
            placePickerConfigure()
        }
    }
    
}
