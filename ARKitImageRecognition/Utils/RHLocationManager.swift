//
//  RHLocationManager.swift
//  ARKitImageRecognition
//
//  Created by Vlad Bonta on 17/11/2018.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation
import CoreLocation

class RHCLocationHandler: NSObject, CLLocationManagerDelegate {
    
    static let sharedInstance = RHCLocationHandler()
    
    private(set) var lastKnownLocation: CLLocation?
    let locationName: String = ""
    private(set) var address: String?
    private let locationManager: CLLocationManager = CLLocationManager()
    private let geocoder: CLGeocoder = CLGeocoder()
    private(set) var isLocationPermissionGranted: Bool = false
    
    private override init() {
        super.init()
        self.initLocation()
    }
    
    private func initLocation() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        
        self.startLocationUpdate()
    }
    
    func canAccessLocation() -> Bool {
        return self.isLocationPermissionGranted && CLLocationManager.locationServicesEnabled()
    }
    
    func startLocationUpdate() {
        if CLLocationManager.locationServicesEnabled() && self.isLocationPermissionGranted {
            locationManager.startUpdatingLocation()
        }
    }
    
  
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.lastKnownLocation = locations[0] as CLLocation
        manager.stopUpdatingLocation()
        self.addressReverseGeocde()
        debugPrint("user latitude = \(self.lastKnownLocation?.coordinate.latitude ?? 0.0)")
        debugPrint("user longitude = \(self.lastKnownLocation?.coordinate.longitude ?? 0.0)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .notDetermined || status == .denied {
            self.isLocationPermissionGranted = false
            debugPrint("locationAuthorization not granted")
        } else {
            self.isLocationPermissionGranted = true
            self.startLocationUpdate()
            debugPrint("locationAuthorization granted")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.lastKnownLocation = nil
        self.address = nil
        debugPrint("Location Error \(error)")
    }
    
    private func addressReverseGeocde() {
        guard let location = self.lastKnownLocation else {
            return
        }
        self.geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
            var addressString = ""
            if error == nil {
                debugPrint("reverseGeocodeLocation success: ")
                let firstLocationPlacemark = placemarks?[0]
                guard let adressesDictionary = firstLocationPlacemark?.addressDictionary else { return }
                guard let addressesArray: [String] = adressesDictionary["FormattedAddressLines"] as? [String] else { return }
                for value in addressesArray {
                    addressString += String(format: "%@ ", value)
                }
                addressString = String(addressString.dropLast())
            } else {
                debugPrint("reverseGeocodeLocation error: ", error ?? "")
            }
        })
    }
    
}
