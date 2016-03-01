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

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource  {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    var annotation =  MKPointAnnotation()
    var pin: Pin!
    
    // Keep track of insertions, deletions, and updates.
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        mapView.addAnnotation(annotation)
        
        // Fetch Photos
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("error fetching results \(error)")
        }
        // Set the fetchedResultsController.delegate = self
        fetchedResultsController.delegate = self
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

    
    // MARK : Custom Methods
    
    // Refresh collection
    @IBAction func newCollection(sender: AnyObject) {
        
        // delete all images in pin
        for photo in fetchedResultsController.fetchedObjects as! [Photo] {
            deleteFile(photo)
            sharedContext.deleteObject(photo)
        }
        
        let latitude = annotation.coordinate.latitude.description
        let longitude = annotation.coordinate.longitude.description
        
        // Fetch photos for Pin
        FlickrClient.sharedInstance.getImagesByLatLong(latitude, longitude: longitude) { (success, imagesArray, errorString) in
            if success {
                let photosCount = imagesArray.count
                print("\(photosCount) images loaded, time to loop through the array")
                
                // Save empty photos
                for _ in imagesArray {
                    let photo = Photo(dictionary: [Photo.Keys.FilePath : ""], context: self.sharedContext)
                    photo.pin = self.pin
                }
                CoreDataStackManager.sharedInstance().saveContext()
                
                // Loop through images and save files, updates photo objects
                for (index, image) in imagesArray.enumerate() {
                    let fileName = FlickrClient.sharedInstance.saveImage(image)
                    self.pin.photos[index].filePath = fileName
                    print("image downloaded and saved")
                    CoreDataStackManager.sharedInstance().saveContext()
                }
                
                print("finished downloading images")
                
            } else {
                print("FAIL!")
            }
        }

    }
    
    // Delete Photo
    
    func deleteFile(photo: Photo) {
        let filename = photo.filePath
        
        // Delete file from Documents folder
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        let imagePath = paths.stringByAppendingPathComponent(filename!)
        
        do {
            try NSFileManager.defaultManager().removeItemAtPath(imagePath)
        } catch let error as NSError {
            print("Error deleting file :( \(error)")
        }
    }
    
    //MARK: UICollectionView
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! ImageCell
        
        let photo = fetchedResultsController.objectAtIndexPath(indexPath)
        
        if photo.filePath!!.isEmpty {
            cell.imageView.image = UIImage(named: "placeholder")
        } else {
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
            let imagePath = paths.stringByAppendingPathComponent(photo.filePath!!)
            cell.imageView.image = UIImage(contentsOfFile: imagePath)
        }
        
        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        // Delete image file
        deleteFile(photo)
        
        // Delete object
        sharedContext.deleteObject(photo)
        CoreDataStackManager.sharedInstance().saveContext()
    
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    // MARK: - Fetched Results Controller Delegate
    
    // Whenever changes are made to Core Data the following three methods are invoked. This first method is used to create
    // three fresh arrays to record the index paths that will be changed.
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        // We are about to handle some new changes. Start out with empty arrays for each change type
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
        
        print("in controllerWillChangeContent")
    }
    
    // The second method may be called multiple times, once for each Photo object that is added, deleted, or changed.
    // We store the incex paths into the three arrays.
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type{
            
        case .Insert:
            //print("Insert an item")
            // Here we are noting that a new Photo instance has been added to Core Data. We remember its index path
            // so that we can add a cell in "controllerDidChangeContent". Note that the "newIndexPath" parameter has
            // the index path that we want in this case
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            //print("Delete an item")
            // Here we are noting that a Photo instance has been deleted from Core Data. We keep remember its index path
            // so that we can remove the corresponding cell in "controllerDidChangeContent". The "indexPath" parameter has
            // value that we want in this case.
            deletedIndexPaths.append(indexPath!)
            break
        case .Update:
            print("Update an item.")
            // We don't expect Photo instances to change after they are created. But Core Data would
            // notify us of changes if any occured. This can be useful if you want to respond to changes
            // that come about after data is downloaded. For example, when an images is downloaded from
            // Flickr in the Virtual Tourist app
            updatedIndexPaths.append(indexPath!)
            break
        case .Move:
            print("Move an item. We don't expect to see this in this app.")
            break
        default:
            break
        }
    }
    
    // This method is invoked after all of the changed in the current batch have been collected
    // into the three index path arrays (insert, delete, and upate). We now need to loop through the
    // arrays and perform the changes.
    //
    // The most interesting thing about the method is the collection view's "performBatchUpdates" method.
    // Notice that all of the changes are performed inside a closure that is handed to the collection view.
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        print("in controllerDidChangeContent. changes.count: \(insertedIndexPaths.count + deletedIndexPaths.count)")
        
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
            
            }, completion: nil)
    }

    
}

