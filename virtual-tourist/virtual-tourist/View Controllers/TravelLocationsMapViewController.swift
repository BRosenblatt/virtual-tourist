//
//  ViewController.swift
//  virtual-tourist
//
//  Created by Becca Kauper on 9/7/23.
//

import UIKit
import MapKit

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    var pins: [Pin] = []
    var dataController: DataController!
    
    @IBOutlet weak var mapView: MKMapView!
    
    let gestureRecognizer = UIGestureRecognizer()
    let longPressGestureRecognizer = UILongPressGestureRecognizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        gestureRecognizer.delegate = self
        mapView.delegate = self
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        fetchPinsFromStore()
        configureLongPressGesture()
    }
    
    // MARK: - Handle long-press action
    
    func configureLongPressGesture() {
        longPressGestureRecognizer.numberOfTouchesRequired = 1
        longPressGestureRecognizer.minimumPressDuration = 0.5
        longPressGestureRecognizer.addTarget(self, action: #selector(addNewPin))
        
        mapView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc func addNewPin() {
        guard longPressGestureRecognizer.state == .began else {
            return
        }
        // get x and y
        let location = longPressGestureRecognizer.location(in: mapView)

        // figure out how to get lat and long from x and y
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()

        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        storeNewPin(annotation: annotation)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - Configure pinView

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKMarkerAnnotationView

        // show pin after gesture initiated
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            pinView?.animatesWhenAdded = true
        } else {
            pinView?.annotation = annotation
        }
        
        pinView?.markerTintColor = .red

        return pinView
    }
    
    // MARK: Fetch pins from store
    
    func fetchPinsFromStore() {
        let fetchRequest = Pin.fetchRequest()
        do {
            pins = try dataController.viewContext.fetch(fetchRequest)
            var annotations: [MKAnnotation] = []
            annotations = pins.map({ pin in
                annotationForPin(pin)
            })
            mapView.addAnnotations(annotations)
        } catch {
            print("Couldn't fetch: \(error)")
        }
    }
    
    func annotationForPin(_ pin: Pin) -> MKAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate.latitude = pin.latitude
        annotation.coordinate.longitude = pin.longitude
        return annotation
    }
    
    func storeNewPin(annotation: MKPointAnnotation) {
        dataController.viewContext.perform {
            let pin = Pin(context: self.dataController.viewContext)
            pin.longitude = annotation.coordinate.longitude
            pin.latitude = annotation.coordinate.latitude
            pin.identifier = UUID().uuidString
            self.pins.append(pin)
            try? self.dataController.viewContext.save()
        }
    }
    
    // MARK: - Handle pinWasTapped action & present PhotoAlbumViewController
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let latitude = view.annotation?.coordinate.latitude, let longitude = view.annotation?.coordinate.longitude else {
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let photoAlbumCollectionViewController = storyboard.instantiateViewController(withIdentifier: "PhotoAlbumCollectionViewController") as! PhotoAlbumCollectionViewController
        photoAlbumCollectionViewController.pin = pins.first(where: { pin in
            pin.latitude == latitude && pin.longitude == longitude
        })
        photoAlbumCollectionViewController.dataController = dataController
        navigationController?.pushViewController(photoAlbumCollectionViewController, animated: true)
    }
}

