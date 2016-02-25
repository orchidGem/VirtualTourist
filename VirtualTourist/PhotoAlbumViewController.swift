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
        
        collectionView.reloadData()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        mapView.addAnnotation(annotation)
    }
    
    // Layout the collection view
    override func viewDidLayoutSubviews() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        let frameWidth = collectionView.frame.size.width - (2 * layout.minimumInteritemSpacing)
        
        let width = floor(frameWidth/3)
        layout.itemSize = CGSize(width: width, height: width)
        collectionView.collectionViewLayout = layout
    }

    @IBAction func newCollection(sender: AnyObject) {
        
        // delete all images in pin
        for photo in pin.photos {
            deletePhoto(photo)
        }
        
        collectionView.reloadData()
        
        // Fetch new images
        FlickrClient.sharedInstance.getImagesByLatLong(pin.latitude.description, longitude: pin.longitude.description) { (success, imagesArray, errorString) in
            if success {
                let photosCount = imagesArray.count
                print("\(photosCount) images loaded, time to loop through the array")
                for image in imagesArray {
                    let photo = Photo(dictionary: [Photo.Keys.FilePath : image], context: self.sharedContext)
                    photo.pin = self.pin
                }
                CoreDataStackManager.sharedInstance().saveContext()
                
                // Reload collection view
                dispatch_async(dispatch_get_main_queue()) {
                    print("reload cells")
                    self.collectionView.reloadData()
                }
            } else {
                print("FAIL!")
            }
        }

    }
    
    func deletePhoto(photo: Photo) {
        let filename = photo.filePath
        
        // Remove photo from shared context and save
        sharedContext.deleteObject(photo)
        CoreDataStackManager.sharedInstance().saveContext()
        
        // Delete file from Documents folder
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        let imagePath = paths.stringByAppendingPathComponent(filename)
        
        do {
            try NSFileManager.defaultManager().removeItemAtPath(imagePath)
        } catch let error as NSError {
            print("Error deleting file :( \(error)")
        }
        
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
        deletePhoto(photoToDelete)
        
        // Remove cell from collection view
        collectionView.deleteItemsAtIndexPaths([indexPath])

    }
    
}