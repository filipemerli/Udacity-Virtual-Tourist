//
//  TravelLocationsMapView.swift
//  Udacity Virtual Tourist
//
//  Created by Filipe Merli on 05/03/2018.
//  Copyright © 2018 Filipe Merli. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsMapView: UIViewController, MKMapViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        
        mapView.isRotateEnabled = false
        
        zoomOnMap()

    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        UserDefaults.standard.set(mapView.centerCoordinate.latitude, forKey: "defaultLatitude")
        UserDefaults.standard.set(mapView.centerCoordinate.longitude, forKey: "defaultLongitude")
        
        UserDefaults.standard.set(mapView.region.span.latitudeDelta, forKey: "defLatiDelta")
        UserDefaults.standard.set(mapView.region.span.longitudeDelta, forKey: "defLongiDelta")
        
    }


@IBOutlet weak var mapView: MKMapView!
    
    
    func zoomOnMap() {
        var zoomLocation = CLLocationCoordinate2D()
        var zoomSpan = MKCoordinateSpan()
        zoomLocation.latitude = UserDefaults.standard.double(forKey: "defaultLatitude")
        zoomLocation.longitude = UserDefaults.standard.double(forKey: "defaultLongitude")
        zoomSpan.latitudeDelta = UserDefaults.standard.double(forKey: "defLatiDelta")
        zoomSpan.longitudeDelta = UserDefaults.standard.double(forKey: "defLongiDelta")

        let viewRegion = MKCoordinateRegionMake(zoomLocation, zoomSpan)
        mapView.setRegion(viewRegion, animated: false)
        
    }

}
