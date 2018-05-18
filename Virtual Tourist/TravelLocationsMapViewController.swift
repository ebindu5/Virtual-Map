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
    @IBOutlet weak var deleteLabel: UILabel!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet var gesture: UILongPressGestureRecognizer!
    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
  
    
    @IBAction func editMapView(_ sender: Any) {
        
        if editButton.title == "Edit" {
            editButton.title = "Done"
            deleteLabel.isHidden = false
        }else{
            editButton.title = "Edit"
            deleteLabel.isHidden = true
        }
    }
    
    @IBAction func createPin(_ sender: Any) {
        let annotation = MKPointAnnotation()
        let touchPoint = gesture.location(in: mapView)
        annotation.coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        annotations.append(annotation)
        mapView.addAnnotations(annotations)
    }
    
}

extension TravelLocationsMapViewController : MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil{
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.animatesDrop = true
            pinView?.pinTintColor = UIColor.red
        }else{
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if !deleteLabel.isHidden {
            if annotations.count > 0 {
                mapView.removeAnnotations(mapView.selectedAnnotations)
            }
            
        }else{
            let vc = storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as? PhotoAlbumViewController
            vc?.annotations = mapView.selectedAnnotations
            
            FlickFinderImagesAPI.getImages(Double((annotations.first?.coordinate.latitude)!), Double((annotations.first?.coordinate.longitude)!)){ (success,data,error) in
                
                if error != nil {
                    print(error)
                }
                
                if success! {
                    
//                    performUIUpdatesOnMain {
                        vc?.photosObject = data
//                    }
                    
                }
                
            }
            
            
            
            navigationController?.pushViewController(vc!, animated: true)
        }
        
      
    }
    
}

