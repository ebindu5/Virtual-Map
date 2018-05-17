//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by NISHANTH NAGELLA on 5/16/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet var gesture: UILongPressGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    @IBAction func deletePins(_ sender: Any) {
    }
    
    @IBAction func editMapView(_ sender: Any) {
        
        if editButton.title == "Edit" {
            editButton.title = "Done"
            deleteButton.isHidden = false
        }else{
            editButton.title = "Edit"
            deleteButton.isHidden = true
        }
    }
    
    @IBAction func createPin(_ sender: Any) {
        let annotation = MKPointAnnotation()
        let touchPoint = gesture.location(in: mapView)
        annotation.coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        annotation.title = "jh"
        mapView.addAnnotation(annotation)
    }
    
}

extension TravelLocationsMapViewController : MKMapViewDelegate {
    
   
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil{
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.pinTintColor = UIColor.red
        }else{
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
       let vc = storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as? PhotoAlbumViewController
        navigationController?.pushViewController(vc!, animated: true)
    }
    
}

