//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Laura Evans on 2/15/16.
//  Copyright © 2016 Laura Evans. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var annotation =  MKPointAnnotation()
    var images: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.addAnnotation(annotation)
        
        FlickrClient.sharedInstance.getImagesByLatLong() { (success, imagesArray, errorString) in
            if success {
                print(imagesArray)
            } else {
                print("FAIL!")
            }
        }
    }
}

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! ImageCell
        
        return cell
    }
    
}