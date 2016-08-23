//
//  MapViewController.swift
//  Emblem
//
//  Created by Dane Jordan on 8/4/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//

import UIKit
import SwiftyJSON
import SocketIOClientSwift

class MapViewController: UIViewController {
    
    
    var serverUrl:NSURL!
    var user:User?
    let locationManager = CLLocationManager()
    let env = NSProcessInfo.processInfo().environment
    var socket: SocketIOClient!
    var currLat:CLLocation!
    var currLong:CLLocation!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBAction func addMarkerPressed(sender: AnyObject) {
        var lat = ""
        var long = ""
        if let location = mapView.myLocation {
            lat = String(location.coordinate.latitude)
            long = String(location.coordinate.longitude)

        }

        let url = "\(EnvironmentVars.serverLocation)place/art/find/\(lat)/\(long)"
        
        HTTPRequest.get(NSURL(string: url)!, getCompleted: {(response, data) in
            if response.statusCode == 200 || response.statusCode == 201 {
                let json = JSON(data:data)
                let placeId = json["id"].stringValue
                self.performSegueWithIdentifier(ARViewController.getEntrySegueFromMapView(), sender: placeId)
                if (json.array?.count > 0) {
                    var highestRated = json[0]
                    for(_, art):(String, JSON) in json {
                        if (highestRated["votes"].int32Value < art["votes"].int32Value) {
                            highestRated = art;
                        }
                    }
                    
                    let url = "\(EnvironmentVars.serverLocation)art/\(highestRated["id"].stringValue)/download"
                    
                    NSLog(highestRated["votes"].stringValue)
                    
                    HTTPRequest.get(NSURL(string: url)!, getCompleted: { (response, data) in
                        if response.statusCode == 200 {
                            let image = UIImage(data: data)!
                            ARViewController.receiveArt(image)
                        }
                    })
                } else {
                    // send nil to server
                }
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let server = env["DEV_SERVER/PLACE"] as String? {
            self.serverUrl = NSURL(string: server)!
            
        } else {
            self.serverUrl = NSURL(string: "http://138.68.23.39:3000/place")!
        }

        initLocationServices()
        
        socket = SocketIOClient(socketURL: self.serverUrl!, options: [.Log(false), .ForcePolling(true)])
        socket.on("connect") {data, ack in
            print("Socket Connected")
        }
        
        socket.on("place/createPlace") {data, ack in

            if let dataDict = data[0] as? NSDictionary {
                let lat = String(dataDict["lat"]!)
                let long = String(dataDict["long"]!)
                self.createMarker(lat, longitude: long)
            }
        }
        
        socket.connect()

        getMarkers(self.serverUrl!)
        
    }
    
    class func getEntrySegueFromLogin() -> String {
        return "LoginToMapViewSegue"
    }
    
    func initLocationServices() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.myLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    
    func getMarkers(scriptURL: NSURL) {
        HTTPRequest.get(scriptURL){(response, data) in
            print("GetMarkers: \(response.statusCode)")
            if response.statusCode == 200 {
                let json = JSON(data:data)
                print(json)
                for(_, subJSON):(String, JSON) in json {
                    self.createMarker(subJSON["lat"].stringValue, longitude: subJSON["long"].stringValue)
                }
            }
        }
    }
    
    func createMarker(latitude: String, longitude: String) {
        dispatch_async(dispatch_get_main_queue()) {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2DMake(CLLocationDegrees(latitude)!, CLLocationDegrees(longitude)!)
            marker.appearAnimation = kGMSMarkerAnimationPop
            marker.map = self.mapView
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
            print("location authorized")
            
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0) 
            locationManager.stopUpdatingLocation()

        }
    }
}
