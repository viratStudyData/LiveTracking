//
//  Alerts.swift
//  LiveTracking
//
//  Created by Apple on 05/12/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import EZSwiftExtensions


enum AlertsMessage: String {
    case pickUp = "Please enter pickup location."
    case dropOff = "Please enter droopoff location."
    case error = "Something went wrong."
}

enum AlertsType: String {
    case error = "Error"
    case alert = "Alert"
}

class Alerts: NSObject {
    static let shared = Alerts()
    
    func showAlert(type: AlertsType, message: AlertsMessage) {
        
        let alert = UIAlertController.init(title: type.rawValue, message: message.rawValue, preferredStyle: .alert)
        let ok = UIAlertAction.init(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(ok)
        
        ez.topMostVC?.presentVC(alert)
    }
}
