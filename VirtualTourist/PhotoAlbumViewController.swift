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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.addAnnotation(annotation)
    }
    
}