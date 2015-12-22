/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse
import MapKit
import CoreLocation


class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var user: PFUser!
    
    var seconds = 0.0
    var distance = 0.0
    
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager.activityType = CLActivityType.AutomotiveNavigation
        
        // Movement threshold for new events
        _locationManager.distanceFilter = 10.0
        return _locationManager
    }()
    
    lazy var locations = [CLLocation]()
    lazy var timer = NSTimer()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        let testObject: PFObject = PFObject(className: "TestObject")
//        testObject["foo"] = "bar"
//        testObject.saveInBackground()
//        
        sleep(2)

        mapView.mapType = MKMapType.Hybrid
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType(rawValue: 0)!
        mapView.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
        
        if #available(iOS 9.0, *) {
            mapView.showsTraffic = true
        } else {
            // Fallback on earlier versions
            
        }
        
        print(user)
        
        startRun()
        
        startLocationUpdates()
        
        //locationManager.startUpdatingLocation()
//        
//        
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        
//        let CLAuthStatus = CLLocationManager.authorizationStatus()
//        
//        if CLAuthStatus == .NotDetermined || CLAuthStatus == .Denied || CLAuthStatus == .AuthorizedWhenInUse {
//            // present an alert indicating location authorization required
//            // and offer to take the user to Settings for the app via
//            // UIApplication -openUrl: and UIApplicationOpenSettingsURLString
//            locationManager.requestAlwaysAuthorization()
//            locationManager.requestWhenInUseAuthorization()
//        }
//        
//        if CLAuthStatus == CLAuthorizationStatus.AuthorizedAlways || CLAuthStatus == CLAuthorizationStatus.Authorized || CLAuthStatus == CLAuthorizationStatus.AuthorizedWhenInUse {
//        
//            locationManager.startUpdatingLocation()
//            locationManager.startUpdatingHeading()
//            locationManager.startMonitoringSignificantLocationChanges()
//            
//        } else {
//            
//            displayError("Error", message: "Acepta usar tu localizacion.")
//            
//        }
        
        //testLocation()
        
        
        
        
        
        //*********************//tec 25.649038, -100.290060 finish 25.736101, -100.286986
        
//        let request = MKDirectionsRequest()
//        request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 25.649038, longitude: -100.290060), addressDictionary: nil))
//        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 25.736101, longitude: -100.286986), addressDictionary: nil))
//        request.requestsAlternateRoutes = true
//        request.transportType = MKDirectionsTransportType.Any
//        
//        let directions = MKDirections(request: request)
//        
//        directions.calculateDirectionsWithCompletionHandler { [unowned self] response, error in
//            guard let unwrappedResponse = response else { return }
//            
//            for route in unwrappedResponse.routes {
//                self.mapView.addOverlay(route.polyline)
//                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
//            }
//        }
    }

    override func viewWillAppear(animated: Bool) {
        
        
        locationManager.requestAlwaysAuthorization()

        sleep(2)
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        timer.invalidate()
    }
    
    // MARK: corelocation methods delegate
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
//        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error) -> Void in
//           
//            if (error != nil) {
//                print("Reverse geocoder failed with error" + error!.localizedDescription)
//                return
//            }
//            
//            if placemarks!.count > 0 {
//                
//                let pm = placemarks![0] as CLPlacemark
//                
//                print("The data gathered is something ")
//                //self.displayLocationInfo(pm)
//                
//            } else {
//                print("Problem with the data received from geocoder")
//            }
//        })
//        if locations.count == 1 {
//            
//            print("present location \(locations.last?.coordinate) \(locations.count) ")
//            
//            if let oldLocationNew = locations.last as CLLocation? {
//                
//                let newCoordinates = oldLocationNew.coordinate
//                var area = [newCoordinates]
//                let polyline = MKPolyline(coordinates: &area, count: area.count)
//                mapView.addOverlay(polyline)
//            }
//            
//        }
//        
//        if locations.count > 1 {
//            
//            print("present location \(locations.last?.coordinate) old \(locations[locations.count - 2].coordinate) \(locations.count)")
//        }
        
        for location in locations {
            if location.horizontalAccuracy < 20 {
                //update distance
                if self.locations.count > 0 {
                    distance += location.distanceFromLocation(self.locations.last!)
                }
                
                //save location
                self.locations.append(location)
                print("distance \(distance)")
                print("location \(location.coordinate.latitude) \(location.coordinate.longitude)")
            }
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
        print("present location \(newLocation.coordinate.latitude), \(newLocation.coordinate.longitude)")
        
        let oldCoordinates = oldLocation.coordinate
        let newCoordinates = newLocation.coordinate
        var area = [oldCoordinates, newCoordinates]
        var polyline = MKPolyline(coordinates: &area, count: area.count)
        mapView.addOverlay(polyline)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    
        print("Error n locations update \(error.description)")
        
    }
    
    //
    
    // MARK: map delegate
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        if (overlay is MKPolyline) {
            let pr = MKPolylineRenderer(overlay: overlay)
            pr.strokeColor = UIColor.redColor()
            pr.lineWidth = 5
            return pr
        } else {
            
            print("some error")
            return MKOverlayRenderer()
        }
    }
    
    //
    
    func displayLocationInfo(placemark: CLPlacemark) {
        
        
            //stop updating location to save battery life
        //self.locationManager.stopUpdatingLocation()
        
        print((placemark.locality != nil) ? placemark.locality! : "")
        print((placemark.postalCode != nil) ? placemark.postalCode! : "")
        print((placemark.administrativeArea != nil) ? placemark.administrativeArea! : "")
        print((placemark.country != nil) ? placemark.country! : "")
        //print(((placemark.description != "") ? placemark.description : ""))
            
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func testLocation() {
        
        let lat: CLLocationDegrees = 37.586601
        let lng: CLLocationDegrees = 127.009381
        
        //
        let latDelta: CLLocationDegrees = 0.008
        let lngDelta: CLLocationDegrees = 0.008
        
        let theSpan: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lngDelta)
        
        let initLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, lng)
        let theRegion: MKCoordinateRegion = MKCoordinateRegionMake(initLocation, theSpan)
        self.mapView.setRegion(theRegion, animated: true)
        
        
        
    }
    
    func eachSecond(timer: NSTimer) {
        
        seconds++
        //let secondsQuantity = HKQuantity(unit: HKUnit.secondUnit(), doubleValue: seconds)
        print("Time: \(seconds)")
        //let distanceQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: distance)
        //print("Distance: " + distanceQuantity.description)
    }
    
    func startLocationUpdates() {
        // Here, the location manager will be lazily instantiated
        locationManager.startUpdatingLocation()
    }
    
    func displayError(error: String, message: String) {
        
        let alert: UIAlertController = UIAlertController(title: error, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) { alert in
            
            //self.dismissViewControllerAnimated(true, completion: nil)
            })
        presentViewController(alert, animated: true, completion: nil)
    
    }

    func startRun() {
        
        seconds = 0.0
        distance = 0.0
        locations.removeAll(keepCapacity: false)
        timer = NSTimer.scheduledTimerWithTimeInterval(1,
            target: self,
            selector: "eachSecond:",
            userInfo: nil,
            repeats: true)
        startLocationUpdates()
    }
    
}
