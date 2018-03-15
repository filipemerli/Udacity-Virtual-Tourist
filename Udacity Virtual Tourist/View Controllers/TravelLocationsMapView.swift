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
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var managedObjectContext: NSManagedObjectContext!
    var notInEditingMode = true
    var animatePins = false
    var longPress = UILongPressGestureRecognizer()
    var annotations = [MKPointAnnotation]()
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var redBottomButton: UIButton!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        standartState()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.isRotateEnabled = false
        longPress = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(longGesture:)))
        longPress.minimumPressDuration = 1.8
        mapView.addGestureRecognizer(longPress)
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        populateMap()
        zoomOnMap()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //Tirar screenshot
        
    }
    
    // Salvar ultima "tela" visualizada pelo usuario no Userdefaults!
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        UserDefaults.standard.set(mapView.centerCoordinate.latitude, forKey: "defaultLatitude")
        UserDefaults.standard.set(mapView.centerCoordinate.longitude, forKey: "defaultLongitude")
        UserDefaults.standard.set(mapView.region.span.latitudeDelta, forKey: "defLatiDelta")
        UserDefaults.standard.set(mapView.region.span.longitudeDelta, forKey: "defLongiDelta")
    }
    
    // MARK: MapView Delegates
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
            pinView!.animatesDrop = animatePins
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let pinLatitude = view.annotation?.coordinate.latitude else {
            print("erro")
            return
        }
        guard let pinLongitude = view.annotation?.coordinate.longitude else {
            print("erro")
            return
        }
        if notInEditingMode == false {
            let pinRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
            let pinLatPredicate = NSPredicate(format: "pinLatitude = %lf", pinLatitude)
            let pinLonPredicate = NSPredicate(format: "pinLongitude = %lf", pinLongitude)
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [pinLatPredicate, pinLonPredicate])
            pinRequest.predicate = compoundPredicate
            do {
                let objects = try managedObjectContext.fetch(pinRequest)
                for pinToDelete in objects {
                    managedObjectContext.delete(pinToDelete)
                }
                try managedObjectContext.save()
            }catch {
                print("Could not delete object: \(error.localizedDescription)")
            }
            mapView.removeAnnotation(view.annotation!)
        } else {
            SnapShot.shared.currentPinLat = pinLatitude
            SnapShot.shared.currentPinLong = pinLongitude
            let layer = UIApplication.shared.keyWindow!.layer
            let scale = UIScreen.main.scale
            UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale)
            layer.render(in: UIGraphicsGetCurrentContext()!)
            let capturedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            SnapShot.shared.snapShot = capturedImage
            let controller = storyboard?.instantiateViewController(withIdentifier: "PicturesViewController")
            self.present(controller!, animated: false, completion: nil)
        }
    }
    
    @objc func addAnnotation(longGesture: UIGestureRecognizer) {
        if (longGesture.state == UIGestureRecognizerState.began && notInEditingMode) {
            animatePins = true
            let touchPoint = longGesture.location(in: mapView)
            let pinCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let newAnnotation = MKPointAnnotation()
            newAnnotation.coordinate = pinCoordinates
            newAnnotation.title = " "
            let primeiroPinSalvo = Pin(context: managedObjectContext)
            primeiroPinSalvo.pinLatitude = pinCoordinates.latitude
            primeiroPinSalvo.pinLongitude = pinCoordinates.longitude
            do {
                try primeiroPinSalvo.managedObjectContext?.save()
                pins.append(primeiroPinSalvo)
            } catch {
                print("Could not save data \(error.localizedDescription)")
            }
            annotations.append(newAnnotation)
            mapView.addAnnotation(newAnnotation)
            fetchRequests()
        }
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
        mapView.removeAnnotations(mapView.annotations)
        annotations.removeAll()
        fetchRequests()
        for singlePin in pins {
            let lat = CLLocationDegrees(singlePin.pinLatitude)
            let lon = CLLocationDegrees(singlePin.pinLongitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            annotation.title = " "
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
    }
    
    @objc func editPinsPressed() {
        animatePins = false
        editionState()
    }
    
    @objc func donePressed() {
        mapView.frame.origin.y = 0
        populateMap()
        standartState()
    }
    
    //MARK: Buttons configurations
    func standartState() {
        notInEditingMode = true
        redBottomButton.isHidden = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,target: self, action: #selector(editPinsPressed))
    }
    
    func editionState() {
        notInEditingMode = false
        redBottomButton.isHidden = false
        let redButtomHeight = redBottomButton.frame.size.height
        mapView.frame.origin.y = 0 - redButtomHeight
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
    }
    
    //MARK: Core Data Functions
    
    func fetchRequests() {
        pins.removeAll()
        let pinRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        do {
            pins = try managedObjectContext.fetch(pinRequest)
        } catch {
            print("Could not load data \(error.localizedDescription)")
        }
    }
}
