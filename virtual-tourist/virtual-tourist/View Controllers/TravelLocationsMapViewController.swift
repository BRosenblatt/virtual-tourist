//
//  ViewController.swift
//  virtual-tourist
//
//  Created by Becca Kauper on 9/7/23.
//

import UIKit
import MapKit

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let gestureRecognizer = UILongPressGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        configureLongPressGesture()
    }
    
    func configureLongPressGesture() {
        gestureRecognizer.delegate = self
        gestureRecognizer.numberOfTouchesRequired = 1
        gestureRecognizer.minimumPressDuration = 0.5
        gestureRecognizer.addTarget(self, action: #selector(handleLongPress))
        
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func handleLongPress() {
        print("press")
        guard gestureRecognizer.state == .began else {
            return
        }
        // get x and y
        let location = gestureRecognizer.location(in: mapView)

        // figure out how to get lat and long from x and y
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        print(coordinate.latitude, coordinate.longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        print("shouldRecognizeSimultaneous called")
        return true
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKMarkerAnnotationView

        // show pin after gesture initiated
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            pinView?.markerTintColor = .red
            pinView?.animatesWhenAdded = true
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
}

