//
//  HistoryViewController.swift
//  swift-TrackLocation
//
//  Created by nsuhara on 2018/11/24.
//  Copyright © 2018 nsuhara. All rights reserved.
//

import UIKit
import MapKit

class HistoryViewController: UIViewController {

    struct UserDefaultsStandardStruct {
        let forKey = "com.nsuhara.swift-TrackLocation"
        let standard = UserDefaults.standard
        var date: String!
        var time: String!
        var location: [String: [String: Double]]!
    }
    
    var Database = UserDefaultsStandardStruct()
    var scheduledTimer: Timer? = nil
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize.
        self.navigationItem.title = Database.time
        loadData()
        setAnnotation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let timer = self.scheduledTimer {
            timer.invalidate()
        }
    }
    
    private func loadData() {
        if Database.standard.object(forKey: Database.forKey) == nil {
            Database.location = [String: [String: Double]]()
        } else {
            Database.location = (Database.standard.dictionary(forKey: Database.forKey) as! [String: [String: [String: Double]]])[Database.date]!
        }
    }

    private func setAnnotation() {
        var selected: String!
        for time in Database.location.keys.sorted() {
            if time == Database.time {
                selected = time
                continue
            }
            showAnnotations(time: time)
        }
        showAnnotations(time: selected)
    }
    
    private func showAnnotations(time: String) {
        let coordinate = CLLocationCoordinate2DMake(Database.location[time]!["latitude"]!, Database.location[time]!["longitude"]!)
        let annotation = MKPointAnnotation()
        annotation.title = String(time.prefix(5))
        annotation.coordinate = coordinate
        self.mapView.addAnnotation(annotation)
        self.mapView.selectAnnotation(annotation, animated: true)
        self.mapView.showAnnotations(self.mapView.annotations, animated: true)
    }
    
    @IBAction func onTouchPlay(_ sender: Any) {
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        if let timer = self.scheduledTimer {
            timer.invalidate()
        }
        self.scheduledTimer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(self.callbackTimer),
            userInfo: Database.location.keys.sorted(),
            repeats: false)
    }
    
    @objc func callbackTimer(timer: Timer) {
        var locations = timer.userInfo as! [String]
        guard locations.count > 0 else { return }
        
        showAnnotations(time: locations[0])
        locations.remove(at: 0)
        guard locations.count > 0 else { return }
        
        if let timer = self.scheduledTimer {
            timer.invalidate()
        }
        self.scheduledTimer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(self.callbackTimer),
            userInfo: locations,
            repeats: false)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
