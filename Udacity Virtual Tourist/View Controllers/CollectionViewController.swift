//
//  CollectionViewController.swift
//  Udacity Virtual Tourist
//
//  Created by Filipe Merli on 12/03/2018.
//  Copyright © 2018 Filipe Merli. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let reuseIdentifier = "cell"
    var imagemResult: UIImage?
    let itensPerRow: CGFloat = 3
    let sectionInsets = UIEdgeInsets(top: 40.0, left: 15.0, bottom: 40.0, right: 15.0)
    var managedObjectContext: NSManagedObjectContext!
    var pinLatitude = SnapShot.shared.currentPinLat
    var pinLongitude = SnapShot.shared.currentPinLong
    var pinObjectID: NSManagedObjectID?
    var currentPin: Pin!
    var photos: [Photo] = [Photo]()
    var numberOfPics: Int = 0

    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var picturesCollectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfPics
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! MyCollectionViewCell
        if let photos = currentPin?.pictures?.allObjects as? [Photo] {
            let imageFromPin = photos[indexPath.item]
            if imageFromPin == nil {
                cell.cellImage?.image = imagemResult
            }else {
                cell.cellImage?.image = UIImage(data: imageFromPin.picture as! Data)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoToDelete = photos[indexPath.item]
        do {
            managedObjectContext.delete(photoToDelete)
            try managedObjectContext.save()
        }catch {
            print("Could not delete object: \(error.localizedDescription)")
        }
        updateCollection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let pinLatitude = SnapShot.shared.currentPinLat
        let pinLongitude = SnapShot.shared.currentPinLong
        let coordinatesRange = bboxString(latitude: pinLatitude!, longitude: pinLongitude!)
        FlickrAPIClient.FlickrConstants.bboxRange = coordinatesRange
        fetchCurrentPin()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = SnapShot.shared.snapShot
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        picturesCollectionView.reloadData()
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func networkRequest(_ sender: Any) {
        updateCollection()
    }
    
    func updateCollection() {
        fetchCurrentPin()
        if numberOfPics >= 9 {
            //print("Already up to date")
            photos = currentPin.pictures!.allObjects as! [Photo]
            newCollectionButton.isEnabled = true
        }else {
            newCollectionButton.isEnabled = false
            let group = DispatchGroup()
            group.enter()
            
            DispatchQueue.main.async {
                FlickrAPIClient.sharedInstance().taskForGetMethod() { result, error in
                    if error == nil {
                        let imageURL = URL(string: result as! String)
                        if let imageData = try? Data(contentsOf: imageURL!) {
                            let imageFromData = UIImage(data: imageData)
                            let picture = Photo(context: self.managedObjectContext)
                            picture.picture = NSData(data: UIImageJPEGRepresentation(imageFromData!, 0.3)!) as Data
                            picture.pin = self.currentPin
                            do {
                                try picture.managedObjectContext?.save()
                                group.leave()
                            } catch {
                                group.leave()
                                print("Could not save data \(error.localizedDescription)")
                            }
                        } else {
                            group.leave()
                            print("Image does not exist at \(String(describing: imageURL))")
                        }
                    }else {
                        self.sendUIMessage(message: "No images found at this point. Please, dele this Pin and try another place!")
                        print("\(String(describing: error))")
                    }
                }
            }
            group.notify(queue: .main) {
                self.fetchCurrentPin()
                self.picturesCollectionView.reloadData()
                if self.numberOfPics <= 9 {
                    self.updateCollection()
                }
            }
        }
        
    }
    
    func fetchCurrentPin() {
        let pinRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let pinLatPredicate = NSPredicate(format: "pinLatitude = %lf", pinLatitude!)
        let pinLonPredicate = NSPredicate(format: "pinLongitude = %lf", pinLongitude!)
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [pinLatPredicate, pinLonPredicate])
        pinRequest.predicate = compoundPredicate
        do {
            let objects = try managedObjectContext.fetch(pinRequest)
            for pin in objects {
                currentPin = pin
            }
        }catch {
            print("Could not find current object: \(error.localizedDescription)")
        }
        numberOfPics = (currentPin.pictures?.count)!
    }
    
    
    func bboxString(latitude: Double, longitude: Double) -> String {
        let minimumLon = max(longitude - 1.0, -180.0)
        let minimumLat = max(latitude - 1.0, -90.0)
        let maximumLon = min(longitude + 1.0, 180.0)
        let maximumLat = min(latitude + 1.0, 90.0)
        
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    func sendUIMessage(message: String) {
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) { action in
            alertController.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }

}

extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itensPerRow + 1)
        let availableWidth = picturesCollectionView.frame.width - paddingSpace
        let widthPerItem = availableWidth / itensPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
}




