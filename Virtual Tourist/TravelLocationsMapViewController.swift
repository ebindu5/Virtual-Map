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
        photoAlbumData.pins.append(annotation.coordinate)
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
             let selectedAnnotations = self.mapView.selectedAnnotations
             let selectedPin = selectedAnnotations.last?.coordinate
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PhotosAlbumViewController") as? PhotosAlbumViewController
            
            let latitude = (self.mapView.selectedAnnotations.last?.coordinate.latitude)!
            let longitude = (self.mapView.selectedAnnotations.last?.coordinate.longitude)!
           
            let index = photoAlbumData.pinPhotoAlbum.index(where: {($0.selectedPin?.latitude == selectedPin?.latitude && $0.selectedPin?.longitude == selectedPin?.longitude)})
            
            var fetchData = true
            if (index != nil) {
                
                if photoAlbumData.pinPhotoAlbum[index!].images != nil {
                    fetchData = false
                    vc?.selectedPin = selectedPin
                    vc?.photoCount = photoAlbumData.pinPhotoAlbum[index!].images?.count
                    
                }else{
                    vc?.newImageForExistingPin = true
                }
                performUIUpdatesOnMain {
                    self.navigationController?.pushViewController(vc!, animated: true)
                }
            }
            
            if fetchData {
                
                FlickFinderImagesAPI.getImages(Double(latitude), Double((longitude))){ (success,data,error) in
                    if error != nil {
                        print(error!)
                    }
                    
                    if success! {
                        vc?.photosObject = data
                    vc?.selectedPin = selectedPin
                        vc?.photoCount = data?.count
                    let photodata = PhotoAlbumStruct(selectedPin: selectedPin, images: nil)
                    photoAlbumData.pinPhotoAlbum.append(photodata)
                    performUIUpdatesOnMain {
                        self.navigationController?.pushViewController(vc!, animated: true)
                    }
                    }
                }
            }
        }
    }
    

    
}

