//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by NISHANTH NAGELLA on 5/16/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class PhotoAlbumViewController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource  {
    
    @IBOutlet var mapView : MKMapView!
    @IBOutlet var newCollectionButton: UIButton!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var noImagesLabel: UILabel!
    var annotations: [MKAnnotation]!
    var imageCollection = [UIImage]()
    var photosObject : [[String: AnyObject]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        mapView.addAnnotations(annotations)
        mapView.showsUserLocation = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
//        FlickFinderImagesAPI.getImages(Double((annotations.first?.coordinate.latitude)!), Double((annotations.first?.coordinate.longitude)!)){ (success,data,error) in
//
//            if error != nil {
//                print(error)
//            }
//
//            if success! {
//
//                performUIUpdatesOnMain {
//                    self.photosObject = data
//                }
//
//            }
//
//        }
        
    }
    
    @IBAction func newCollectionPressed() {
        FlickFinderImagesAPI.getImages(Double((annotations.first?.coordinate.latitude)!), Double((annotations.first?.coordinate.longitude)!)){ (success,data,error) in
            
            if error != nil {
                print(error)
            }
            
            if success! {
                
                performUIUpdatesOnMain {
                    self.photosObject = data
                    self.collectionView.reloadData()
                }
                
            }
            
        }
    
    
    }
}


extension PhotoAlbumViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView  = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)  as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.animatesDrop = true
            pinView?.tintColor = UIColor.red
        }else{
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let photosObject = photosObject {
            return photosObject.count
        }else{
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = cell.center
        cell.contentView.addSubview(activityIndicator)
        
        performUIUpdatesOnMain {
            if let photosArray = self.photosObject {
                var i = 0
                for array in photosArray {
                    let imageUrlString = array[Constants.FlickrResponseKeys.MediumURL] as? String
                    if let imageUrlString = imageUrlString{
                        let imageURL = URL(string: imageUrlString)
                        if let imageData = try? Data(contentsOf: imageURL!) {
//                            if self.imageCollection.count == 0 {
                                activityIndicator.stopAnimating()
                                self.imageCollection.append(UIImage(data: imageData)!)
                                cell.imageView.image = self.imageCollection[indexPath.row]
                                print("f")
//                            }
                            i = i + 1
                            if i == 10 {
                                break
                            }
                        }
                    }
                    
                }
            }
        }
     
        

        
//        if  imageCollection.count > 0 {
//            cell.imageView.image = imageCollection[indexPath.row]
//        }else{
//            noImagesLabel.isHidden = false
//        }
        return cell
    }
    
    
}
