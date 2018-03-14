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
    let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    var managedObjectContext: NSManagedObjectContext!
    var pinLatitude = SnapShot.shared.currentPinLat
    var pinLongitude = SnapShot.shared.currentPinLong
    var pinObjectID: NSManagedObjectID?
    var currentPin: Pin?

    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var picturesCollectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! MyCollectionViewCell
        
        //let imageFromPin = currentPin.managedObjectContext?.object(with: pinObjectID!)
        let arrayOfImages = currentPin?.pictures
        let singleImage = arrayOfImages?.anyObject() as? NSData
        if singleImage == nil {
            cell.cellImage?.image = imagemResult
        } else {
            let extractedImage = UIImage(data: singleImage! as Data)
            cell.cellImage?.image = extractedImage
        }
        //let extractedImage = UIImage(data: singleImage as! Data)
        //cell.cellImage?.image = extractedImage
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("You selected pic number \(indexPath.item)!")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let pinLatitude = SnapShot.shared.currentPinLat
        let pinLongitude = SnapShot.shared.currentPinLong
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = SnapShot.shared.snapShot
        
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        DispatchQueue.main.async {
            self.fetchCurrentPin()
        }
        /*
        FlickrAPIClient.sharedInstance().taskForGetMethod() { result, error in
            if error == nil {
                print("\(String(describing: result))")
                let imageURL = URL(string: result as! String)
                if let imageData = try? Data(contentsOf: imageURL!) {
                    DispatchQueue.main.async {
                        self.imagemResult = UIImage(data: imageData)
                    }
                } else {
                    print("Image does not exist at \(String(describing: imageURL))")
                }
            }else {
                print("\(String(describing: error))")
            }
        }*/
        
        
    }

    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func networkRequest(_ sender: Any) {
        //picturesCollectionView.reloadData()
        let picture = Photo(context: managedObjectContext)
        picture.picture = NSData(data: UIImageJPEGRepresentation(imageView.image!, 0.3)!) as Data
        picture.pin = currentPin
        do {
            try picture.managedObjectContext?.save()
        } catch {
            print("Could not save data \(error.localizedDescription)")
        }
        
        /*
        FlickrAPIClient.sharedInstance().taskForGetMethod() { result, error in
            if error == nil {
                print("\(String(describing: result))")
                let imageURL = URL(string: result as! String)
                if let imageData = try? Data(contentsOf: imageURL!) {
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(data: imageData)
                    }
                } else {
                    print("Image does not exist at \(String(describing: imageURL))")
                }
            }else {
                print("\(String(describing: error))")
            }
        }*/
        
        fetchCurrentPin()
        
        picturesCollectionView.reloadData()

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
                self.pinObjectID = pin.objectID
                currentPin = pin
            }
        }catch {
            print("Could not find current object: \(error.localizedDescription)")
        }
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




