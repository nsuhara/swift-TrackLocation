//
//  ViewController.swift
//  swift-TrackLocation
//
//  Created by nsuhara on 2018/11/22.
//  Copyright © 2018 nsuhara. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    struct UserDefaultsStandardStruct {
        let forKey = "com.nsuhara.swift-TrackLocation"
        let standard = UserDefaults.standard
        var data: [String: [String: [String: Double]]]!
    }
    
    struct LocationManagerStruct {
        let activityType = CLActivityType.fitness
        let desiredAccuracy = kCLLocationAccuracyHundredMeters
        let distanceFilter = 100.0
        let allowsBackgroundLocationUpdates = true
        var manager: CLLocationManager?
    }
    
    var Database = UserDefaultsStandardStruct()
    var Location = LocationManagerStruct()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var startButton: UIBarButtonItem!
    @IBOutlet weak var stopButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize.
        loadData()
        setLocation(latitude: 0.0, longitude: 0.0)
        setButtonEnabled(start: true, stop: false)
    }
    
    private func loadData() {
        if Database.standard.object(forKey: Database.forKey) == nil {
            Database.data = [String: [String: [String: Double]]]()
        } else {
            Database.data = (Database.standard.dictionary(forKey: Database.forKey) as! [String: [String: [String: Double]]])
        }
    }
    
    private func setLocation(latitude: Double, longitude: Double) {
        self.latitudeLabel.text = String(format: " LAT: %.1f", latitude)
        self.longitudeLabel.text = String(format: " LON: %.1f", longitude)
    }
    
    private func setButtonEnabled(start: Bool, stop: Bool) {
        self.startButton.isEnabled = start
        self.stopButton.isEnabled = stop
    }
    
    private func alert(title: String = "Warning", message: String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        let alertAction = UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func getDateFormat(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
        let format = DateFormatter()
        format.locale = Locale(identifier: "ja_JP")
        format.dateStyle = dateStyle
        format.timeStyle = timeStyle
        return format.string(from: Date())
    }
    
    private func getDateFormat(dateFormat: String) -> String {
        let format = DateFormatter()
        format.locale = Locale(identifier: "ja_JP")
        format.dateFormat = dateFormat
        return format.string(from: Date())
    }
    
    @IBAction func onTouchStart(_ sender: Any) {
        // Initialize location manager.
        Location.manager = CLLocationManager()
        Location.manager!.delegate = self
        
        // Set accuracy of location service.
        Location.manager?.activityType = Location.activityType
        Location.manager?.desiredAccuracy = Location.desiredAccuracy
        Location.manager?.distanceFilter = Location.distanceFilter
        Location.manager?.allowsBackgroundLocationUpdates = Location.allowsBackgroundLocationUpdates
        
        // Set to track user.
        self.mapView.userTrackingMode = MKUserTrackingMode.followWithHeading
        self.mapView.showsUserLocation = true
        
        // Update buttons.
        setButtonEnabled(start: false, stop: true)
    }
    
    @IBAction func onTouchStop(_ sender: Any) {
        guard let manager = Location.manager else { return }
        
        // Free location manager.
        manager.stopUpdatingLocation()
        manager.delegate = nil
        
        Location.manager = nil
        self.mapView.userTrackingMode = MKUserTrackingMode.none
        self.mapView.showsUserLocation = false
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        setLocation(latitude: 0.0, longitude: 0.0)
        setButtonEnabled(start: true, stop: false)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager.requestAlwaysAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            alert(message: "Location service is disabled.")
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }
        
        // Get tracking data.
        let date = getDateFormat(dateFormat: "yyyy/MM/dd")
        let time = getDateFormat(dateFormat: "HH:mm:ss")
        let coordinate = CLLocationCoordinate2DMake(lastLocation.coordinate.latitude, lastLocation.coordinate.longitude)
        
        // Save tracking data.
        if Database.data[date] == nil {
            Database.data[date] = [String: [String: Double]]()
        }
        Database.data[date]![time] = [
            "latitude": coordinate.latitude,
            "longitude": coordinate.longitude,
        ]
        Database.standard.set(Database.data, forKey: Database.forKey)
        
        // Set Location.
        setLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        // Set annotation.
        let annotation = MKPointAnnotation()
        annotation.title = String(time.prefix(5))
        annotation.coordinate = coordinate
        self.mapView.addAnnotation(annotation)
        self.mapView.selectAnnotation(annotation, animated: true)
        self.mapView.showAnnotations(self.mapView.annotations, animated: true)
    }
    
}
