//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Tomas Sidenfaden on 11/17/17.
//  Copyright © 2017 Tomas Sidenfaden. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {

    // MARK: Properties
    
    let annotation = MKPointAnnotation()
    let annotationArray: [MKPointAnnotation] = []
    
    var selectedPin: Pin?
    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        
        // Implement the tap gesture recognizer
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:)))
        longPressRecognizer.minimumPressDuration = 0.2
        mapView.addGestureRecognizer(longPressRecognizer)
        
        loadAnnotations()
    }
    
    // MARK: Lifecycle
    
    @objc func handleLongPress(_ gestureRecognizer : UIGestureRecognizer) {
        if gestureRecognizer.state != .began { return }
        print("Tap gesture recognized")
        
        // Create the annotation
        let touchPoint = gestureRecognizer.location(in: mapView)
        let newCoordinate = self.mapView.convert(touchPoint, toCoordinateFrom:self.mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinate

        // Initialize NSManagedObject 'Pin' with properties
        selectedPin = Pin(context: CoreDataStack.sharedInstance().context)
        selectedPin?.latitude = annotation.coordinate.latitude
        selectedPin?.longitude = annotation.coordinate.longitude
        
        if let selectedPin = selectedPin {
        let pinAnnotation = PinAnnotation(objectID: selectedPin.objectID, title: nil, subtitle: nil, coordinate: annotation.coordinate)

        // Add the annotation
        mapView.addAnnotation(pinAnnotation)
        }
        
        CoreDataStack.sharedInstance().saveContext()
        print("This is what the ole save looks like: \(CoreDataStack.sharedInstance().context)")
    }
    
    func loadAnnotations() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        do {
            if let pins = try? CoreDataStack.sharedInstance().context.fetch(fetchRequest) as! [Pin] {
                var pinAnnotations = [PinAnnotation]()
                
                for pin in pins {
                    let latitude = CLLocationDegrees(pin.latitude)
                    let longitude = CLLocationDegrees(pin.longitude)
                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    pinAnnotations.append(PinAnnotation(objectID: pin.objectID, title: nil, subtitle: nil, coordinate: coordinate))
                }
                
                mapView.addAnnotations(pinAnnotations)
            }
        }
    }
    
}

extension MapViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is MKPinAnnotationView)
    }
    
    /*
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            // Set the coordinates in the Pin struct
            if let pin = pin {
            pin.latitude = pinView!.annotation!.coordinate.latitude as Double
            pin.longitude = pinView!.annotation!.coordinate.longitude as Double
            pin.images = nil
            }
            
            // Download the images for the coordinates
//            FlickrClient.sharedInstance().getImagesFromFlickr(latitude: pin.latitude, longitude: pin.longitude, page: 1, completionHandlerForGetImages: { (pin, error) in
//
//                if let pin = pin {
//                    self.pin = pin
//                }
//            })
//            }
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
 */
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        do {
            let pinAnnotation = view.annotation as! PinAnnotation
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
            let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", argumentArray: [pinAnnotation.coordinate.latitude, pinAnnotation.coordinate.longitude])
            fetchRequest.predicate = predicate
            let pins = try CoreDataStack.sharedInstance().context.fetch(fetchRequest) as? [Pin]
            selectedPin = pins![0]
        } catch let error as NSError {
            print("failed to get pin by object id")
            print(error.localizedDescription)
            return
        }
            self.performSegue(withIdentifier: "collectionViewSegue", sender: self)
        }
    //        if editing {
    //            mapView.removeAnnotation(view.annotation!)
    //            CoreDataStackManager.sharedInstance().managedObjectContext.deleteObject(pin)
    //            CoreDataStackManager.sharedInstance().saveContext()
    //            return
    //        } else {
//
//        pin.latitude = (view.annotation?.coordinate.latitude)!
//        pin.longitude = (view.annotation?.coordinate.longitude)!
//
//        for existingPin in Pin.shared {
//            if existingPin.lat == view.annotation?.coordinate.latitude && existingPin.lon == view.annotation?.coordinate.longitude {
//                    self.pin = existingPin
//            }
//        }
//
//        if view.annotation?.title != nil {
//            self.performSegue(withIdentifier: "collectionViewSegue", sender: self)
//        }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "collectionViewSegue" {
            let controller = segue.destination as! CollectionViewController
            print("CoreDataStack context in segue= \(CoreDataStack.sharedInstance().context)")
            if let selectedPin = selectedPin {
                controller.selectedPin = selectedPin
                if let images = selectedPin.images?.allObjects as? [Images] {
                    controller.photos = images
                }
            }
            print("PrepareForSegue pin properties are: \n latitude: \(selectedPin?.latitude) \n longitude: \(selectedPin?.longitude)")
        }
    }
    
}




