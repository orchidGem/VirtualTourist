//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Laura Evans on 2/7/16.
//  Copyright © 2016 Laura Evans. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mapView.delegate = self
    }


}

