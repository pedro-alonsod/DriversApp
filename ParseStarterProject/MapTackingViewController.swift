//
//  MapTackingViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Pedro Alonso on 21/12/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import CoreLocation
import MapKit

class MapTackingViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanciaLabel: UILabel!
    
    var user: PFUser!
    var saveCoordenates: PFObject!
    
    var manager: CLLocationManager!
    var locationsInRoute: [CLLocation] = []
    
    var timerToSaveInParse: NSTimer = NSTimer()
    var seconds = 0.0
    
    var firstDistanceBool = true
    var distanceFromTrip: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        print("Usuario de mapa \(user)")
        
        //Setup our Location Manager
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.requestAlwaysAuthorization()
        //manager.startUpdatingLocation()
        startTrack()
        startLocationUpdates()
        
        //set up map
        mapView.delegate = self
        mapView.mapType = MKMapType.Standard
        mapView.showsUserLocation = true
        if #available(iOS 9.0, *) {
            mapView.showsTraffic = true
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 9.0, *) {
            mapView.showsScale = true
        } else {
            // Fallback on earlier versions
        }
        mapView.showsBuildings = true
        
        
        
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("this location \(locations[0])")
        print("Locations.count \(locations.count)")
        print("locationsInRoute.count \(locationsInRoute.count)")
        print("stuff \(locations[0].speed) timestamp \(locations[0].timestamp) course \(locations[0].course) \(locations[0].coordinate) altitude \(locations[0].altitude)")
        print("distance test \(locations[0].coordinate.latitude) \(locations[0].coordinate.longitude)")
        
        if firstDistanceBool {
            
            distanceFromTrip = locations[0]
            firstDistanceBool = false
        }
        
        locationsInRoute.append(locations[0] )
        
        
        let point: PFGeoPoint = PFGeoPoint(location: locations[0])
        saveCoordenates = PFObject(className: "Route")
        saveCoordenates["kids"] = "0"
        saveCoordenates["longitude"] = locations[0].coordinate.longitude
        saveCoordenates["latitude"] = locations[0].coordinate.latitude
        saveCoordenates["start"] = point
        var i = 0
        
        do {
            
            try saveCoordenates.save()
            print("la i \(i)")
            i++
            
        } catch let error {
            
            print(error)
        }
        
        let spanX = 0.025
        let spanY = 0.025
        var newRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpanMake(spanX, spanY))
        
        mapView.setRegion(newRegion, animated: true)
        
        if locationsInRoute.count > 1 {
            
            var sourceIndex = locationsInRoute.count - 1
            
            var destinationIndex = locationsInRoute.count - 2
            
            let c1 = locationsInRoute[sourceIndex].coordinate
            let c2 = locationsInRoute[destinationIndex].coordinate
            
            var a = [c1, c2]
            
            var polyline = MKPolyline(coordinates: &a, count: a.count)
            
            mapView.addOverlay(polyline)
            
        }
        
        
    }
    
    // MARK: MKMapViewdelegates
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolyline {
            
            var polylineRender = MKPolylineRenderer(overlay: overlay)
            polylineRender.strokeColor = UIColor.blueColor()
            polylineRender.lineWidth = 4
            
            return polylineRender
        }
        
        return MKPolylineRenderer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func eachSecond(timer: NSTimer) {
        
        seconds += 5.0
        distanceLabel.text = "\(round(locationsInRoute.last!.speed * 1.609344)) km/h"
        
        if locationsInRoute.count > 0 {
        
            let dist = locationsInRoute.last!.distanceFromLocation(distanceFromTrip)
            
            print("viendo ke sale con la distancia \(dist.description)")
            
            distanciaLabel.text = "\(round(dist)) mts"
            
        }
        
        
        
        timeLabel.text = "\(seconds)"
        
    }
    //
    
    func startTrack() {
        
        seconds = 0.0
        //distance = 0.0
        //locations.removeAll(keepCapacity: false)
        timerToSaveInParse = NSTimer.scheduledTimerWithTimeInterval(5,
            target: self,
            selector: "eachSecond:",
            userInfo: nil,
            repeats: true)
        startLocationUpdates()
    }
    
    func startLocationUpdates() {
        
        
        
        
        manager.startUpdatingLocation()

    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        timerToSaveInParse.invalidate()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        
        manager.requestAlwaysAuthorization()
        
        sleep(2)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
