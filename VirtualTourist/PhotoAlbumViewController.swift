//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Laura Evans on 2/15/16.
//  Copyright © 2016 Laura Evans. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    var annotation =  MKPointAnnotation()
    var pin: Pin!
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        print("view will appear")
        print("Images in album:")
        print(pin.photos.count)
        
        collectionView.reloadData()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("view did load")
        
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        mapView.addAnnotation(annotation)
        
    }
}

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pin.photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! ImageCell
        
        let photo = pin.photos[indexPath.row]
        let filename = photo.filePath
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        let getImagePath = paths.stringByAppendingPathComponent(filename)
        cell.imageView.image = UIImage(contentsOfFile: getImagePath)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let photoToDelete = pin.photos[indexPath.item]
        let filename = photoToDelete.filePath
        
        // Remove photo from shared context and save
        sharedContext.deleteObject(photoToDelete)
        CoreDataStackManager.sharedInstance().saveContext()
        
        // Delete file from Documents folder
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        let imagePath = paths.stringByAppendingPathComponent(filename)
        
        do {
            try NSFileManager.defaultManager().removeItemAtPath(imagePath)
        } catch let error as NSError {
            print("Error deleting file :( \(error)")
        }
        
        // Remove cell from collection view
        collectionView.deleteItemsAtIndexPaths([indexPath])

    }
    
}