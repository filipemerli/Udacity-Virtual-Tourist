//
//  TravelLocationsMapView.swift
//  Udacity Virtual Tourist
//
//  Created by Filipe Merli on 05/03/2018.
//  Copyright © 2018 Filipe Merli. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapView: UIViewController, MKMapViewDelegate {
    
    var pins = [Pin]()
    
    var managedObjectContext: NSManagedObjectContext!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var redBottomButton: UIButton!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        standartState()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.isRotateEnabled = false
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(LongGesture:)))
        longPress.minimumPressDuration = 1.8
        mapView.addGestureRecognizer(longPress)
        
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        populateMap()
        zoomOnMap()

    }
    
    // Salvar ultima "tela" visualizada pelo usuario no Userdefaults!
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        UserDefaults.standard.set(mapView.centerCoordinate.latitude, forKey: "defaultLatitude")
        UserDefaults.standard.set(mapView.centerCoordinate.longitude, forKey: "defaultLongitude")
        
        UserDefaults.standard.set(mapView.region.span.latitudeDelta, forKey: "defLatiDelta")
        UserDefaults.standard.set(mapView.region.span.longitudeDelta, forKey: "defLongiDelta")
        
    }
    
    // MUDAR ESTILO DO PIN
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }


@IBOutlet weak var mapView: MKMapView!
    
    @objc func addAnnotation(LongGesture: UIGestureRecognizer) {
        let touchPoint = LongGesture.location(in: mapView)
        let pinCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let newAnnotation = MKPointAnnotation()
        newAnnotation.coordinate = pinCoordinates
        
        print("APERTOOOOU")
        
        let primeiroPinSalvo = Pin(context: managedObjectContext)
        primeiroPinSalvo.pinLatitude = pinCoordinates.latitude
        primeiroPinSalvo.pinLongitude = pinCoordinates.longitude
        
        do {
            try self.managedObjectContext.save()
        } catch {
            print("Could not save data \(error.localizedDescription)")
        }
        
        mapView.addAnnotation(newAnnotation)
    }
    
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
    
    func populateMap() {
        
        let pinRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        do {
            pins = try managedObjectContext.fetch(pinRequest)
        } catch {
            print("Could not load data \(error.localizedDescription)")
        }
        
        print("NUMEROS DE PINS  = \(pins.count)")
        
        mapView.removeAnnotations(mapView.annotations)
        var annotations = [MKPointAnnotation]()
        
        for singlePin in pins {
            let lat = CLLocationDegrees(singlePin.pinLatitude)
            let lon = CLLocationDegrees(singlePin.pinLongitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            annotations.append(annotation)
        }
        self.mapView.addAnnotations(annotations)
    }
    
    @objc func editPinsPressed() {
        editionState()
    }
    
    @objc func donePressed() {
        mapView.frame.origin.y = 0
        standartState()
    }
    
    
    //MARK: Buttons configurations
    
    func standartState() {
        redBottomButton.isHidden = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,target: self, action: #selector(editPinsPressed))
        
    }
    
    func editionState() {
        redBottomButton.isHidden = false
        let redButtomHeight = redBottomButton.frame.size.height
        mapView.frame.origin.y = 0 - redButtomHeight
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
    }
    

}
