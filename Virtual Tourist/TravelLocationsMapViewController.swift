//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by NISHANTH NAGELLA on 5/16/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class TravelLocationsMapViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deleteLabel: UILabel!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet var gesture: UILongPressGestureRecognizer!
    var pins : [Pins] = []
    var pinPhotos = [PinPhotos]()
    var dataController : DataController!
    var fetchResultController : NSFetchedResultsController<Pins>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        let fetchRequest: NSFetchRequest<Pins> = Pins.fetchRequest()
        let sortDescriptors = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptors]
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            pins = result
        }
        
        if pins.count != 0 {
            self.mapView.addAnnotations(pins)
        }
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
    
    @IBAction func createPin(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
        if  deleteLabel.isHidden {
            if gestureRecognizer.state == .began {
                let annotation = MKPointAnnotation()
                let touchPoint = gesture.location(in: mapView)
                annotation.coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
                
                let pin: Pins = Pins(context: dataController.viewContext)
                pin.latitude = annotation.coordinate.latitude
                pin.longitude = annotation.coordinate.longitude
                pin.creationDate = Date()
                
                try? dataController.viewContext.save()
                
                pins.append(pin)
                mapView.addAnnotation(annotation)
            }
        }
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
        
        
        if  let index = pins.index(where: { (aPin) -> Bool in
            (aPin.latitude == view.annotation?.coordinate.latitude) &&
                (aPin.longitude == view.annotation?.coordinate.longitude) })  {
       
            let selectedPin = pins[index]
            
            if !deleteLabel.isHidden {
                    dataController.viewContext.delete(selectedPin)
                    try? dataController.viewContext.save()
                    pins.remove(at: index)
                    mapView.removeAnnotation(view.annotation!)
            }else{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PhotosAlbumViewController") as? PhotosAlbumViewController
                vc?.dataController = self.dataController
                vc?.selectedPin = selectedPin
                self.navigationController?.pushViewController(vc!, animated: true)

            }
        }
    }
    
    
    
}

