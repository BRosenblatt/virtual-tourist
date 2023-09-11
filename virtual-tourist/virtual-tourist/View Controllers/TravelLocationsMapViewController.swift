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
    let tapGestureRecognizer = UITapGestureRecognizer()
    let annotation = MKPointAnnotation()

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
        print(coordinate.latitude, coordinate.longitude)
        
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        storeNewPin()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        print("shouldRecognizeSimultaneous called")
        return true
    }
    
    // MARK: - Configure pinView

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
    
    // MARK: Fetch pins from store
    
    func fetchPinsFromStore() {
        let fetchRequest = Pin.fetchRequest()
        do {
            pins = try dataController.viewContext.fetch(fetchRequest)
        } catch {
            print("Couldn't fetch: \(error)")
        }
    }
    
    func storeNewPin() {
        dataController.viewContext.perform {
            let pin = Pin(context: self.dataController.viewContext)
            pin.longitude = self.annotation.coordinate.longitude
            pin.latitude = self.annotation.coordinate.latitude
            pin.identifier = ""
            try? self.dataController.viewContext.save()
        }
    }
    
    // MARK: - Handle pinWasTapped action
    
//    func pinWasTapped() {
//        tapGestureRecognizer.numberOfTapsRequired = 1
//        tapGestureRecognizer.addTarget(self, action: #selector(handleTap))
//
//        mapView.addGestureRecognizer(tapGestureRecognizer)
//
//        showphotoAlbumViewController()
//    }
//
//    @objc func handleTap() {
//        guard tapGestureRecognizer.state == .began else {
//            return
//        }
//
//        let tappedPin = mapView.annotations.first { annotation in
//
//        }
//    }
    
    // MARK: Present PhotoAlbumViewController
    
    func showphotoAlbumViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let photoAlbumViewController = storyboard.instantiateViewController(withIdentifier: "PhotoAlbumViewController")
        photoAlbumViewController.modalPresentationStyle = .fullScreen
        self.present(photoAlbumViewController, animated: true)
    }
}

