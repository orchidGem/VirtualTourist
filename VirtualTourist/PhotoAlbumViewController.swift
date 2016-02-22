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
    @IBOutlet weak var collectionView: UICollectionView!
    var annotation =  MKPointAnnotation()
    //var images = [String]()
    var images = ["https://farm2.staticflickr.com/1652/24659375791_8a9da88c13.jpg", "https://farm2.staticflickr.com/1652/24659375791_8a9da88c13.jpg"]

    var pin: Pin!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        print("view will appear")
        print("Images in album")
        print((pin.photos.count))
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
        return images.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! ImageCell
        let imageUrlString = NSURL(string: images[indexPath.row])
        let imageData = NSData(contentsOfURL: imageUrlString!)
        cell.imageView.image = UIImage(data: imageData!)
        
        
        return cell
    }
    
}