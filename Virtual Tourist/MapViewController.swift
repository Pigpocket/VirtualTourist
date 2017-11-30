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

class MapViewController: UIViewController, MKMapViewDelegate {

    // MARK: Properties
    
    let annotation = MKPointAnnotation()
    let annotationArray: [MKPointAnnotation] = []
    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Implement the tap gesture recognizer
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:)))
        longPressRecognizer.minimumPressDuration = 0.2
        mapView.addGestureRecognizer(longPressRecognizer)
        
        self.mapView.delegate = self
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
        annotation.title = "placeholder"
        
        // Add the annotation
        mapView.addAnnotation(annotation)
    }
    
}

extension MapViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is MKPinAnnotationView)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if view.annotation?.title != nil {
            
            let lat = view.annotation!.coordinate.latitude
            let lon = view.annotation!.coordinate.longitude
            
            FlickrClient.sharedInstance().getImagesFromFlicker(latitude: lat, longitude: lon, completionHandler: { (success, error) in
                if success {
                    OperationQueue.main.addOperation {
                        self.performSegue(withIdentifier: "collectionViewSegue", sender: self)
                    }
                } else {
                    print("You're totally fucked")
                }
            })
        }
    }
    
}


