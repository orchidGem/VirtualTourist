//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Laura Evans on 2/7/16.
//  Copyright © 2016 Laura Evans. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {

    var pins: [Pin]!
    @IBOutlet weak var mapView: MKMapView!
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mapView.delegate = self
        
        //print(mapView.region)
        
        var longPressRecogniser = UILongPressGestureRecognizer(target: self, action: "dropPin:")
        longPressRecogniser.minimumPressDuration = 1
        mapView.addGestureRecognizer(longPressRecogniser)
        
        pins = fetchAllPins()
        loadLocations()

    }
    
    
    // Add Pin Annotation on Hold Gesture
    func dropPin(gestureRecognizer: UIGestureRecognizer) {
        
        if gestureRecognizer.state != UIGestureRecognizerState.Began
        {
            return
        }
     
        // Get location of tap and convert to map coordinates
        let touchLocation = gestureRecognizer.locationInView(mapView)
        let pinCoordinates = mapView.convertPoint(touchLocation, toCoordinateFromView: mapView)
        
        // Create pin annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = pinCoordinates
        mapView.addAnnotation(annotation)
        
        // Create and save new pin
        let dictionary: [String : AnyObject] = [
            Pin.Keys.Latitude : pinCoordinates.latitude,
            Pin.Keys.Longitude : pinCoordinates.longitude
        ]
        
        // Save new pin
        let newPin = Pin(dictionary: dictionary, context: sharedContext)
        CoreDataStackManager.sharedInstance().saveContext()
        
    }
    
    func fetchAllPins() -> [Pin] {
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
        } catch {
            print("Error in fetch request \(error)")
            return [Pin]()
        }
    }
    
    //MARK - Load Locations on Map
    func loadLocations() {
        
        // Remove currently existing pins
        mapView.removeAnnotations(mapView.annotations)
        
        // We will create an MKPointAnnotation for each dictionary in "locations". The
        // point annotations will be stored in this array, and then provided to the map view.
        var annotations = [MKPointAnnotation]()
        
        // The "locations" array is loaded with the sample data below. We are using the dictionaries
        // to create map annotations. This would be more stylish if the dictionaries were being
        // used to create custom structs. Perhaps StudentLocation structs.
        
        for pin in pins {
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude as Double, longitude: pin.longitude as Double)
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        
        // When the array is complete, we add the annotations to the map.
        self.mapView.addAnnotations(annotations)
        
    }



//    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//        print("region changed")
//        print(mapView.region)
//    }
    
    // MARK: - MKMapViewDelegate

    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {

        // Present photo album view controller and pass annotation
        let photoAlbumViewContoller = storyboard!.instantiateViewControllerWithIdentifier("photoAlbumViewController") as! PhotoAlbumViewController
        photoAlbumViewContoller.annotation.coordinate = view.annotation!.coordinate
        navigationController!.pushViewController(photoAlbumViewContoller, animated: true)
        
    }
    


}


