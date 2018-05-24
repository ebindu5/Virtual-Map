//
//  PhotosAlbumViewController.swift
//  Virtual Tourist
//
//  Created by NISHANTH NAGELLA on 5/16/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation
import MapKit
import UIKit
import CoreData

class PhotosAlbumViewController : UIViewController {
    
    @IBOutlet var mapView : MKMapView!
    @IBOutlet var newCollectionButton: UIButton!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var noImagesLabel: UILabel!
    var index : Int!
    var photosObject : [[String: AnyObject]]?
    var selectedPhotos : [PinPhotos]!
    var selectedPin : Pins!
    let annotation = MKPointAnnotation()
    var newImageForExistingPin = false
    var pinPhotos : PinPhotos!
    var pics = [PinPhotos]()
    var saveNotificationToken : Any?
    var isLoading = false
     private let coreDataAccess = CoreDataAccess.sharedInstance
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.allowsMultipleSelection = true
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        mapView.showsUserLocation = true
        pics = coreDataAccess.fetchAllPinPhotos(selectedPin)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.addAnnotation(selectedPin)
        mapView.showAnnotations([selectedPin], animated: true)
        noImagesLabel.isHidden = true
        if pics.count == 0 {
             newCollectionButton.isEnabled = false
            getNewImageSet()
        }else{
            collectionView.reloadData()
        }
    }
    
    
    @IBAction func newCollectionPressed() {
        if newCollectionButton.currentTitle == "New Collection" {
            newCollectionButton.isEnabled = false
            if pics.count != 0 {
                coreDataAccess.deleteAllImages(pics)
                pics.removeAll()
            }
            getNewImageSet()
            
        }else{
            
            coreDataAccess.deleteAllImages(selectedPhotos)
            if let selectedPics = selectedPhotos {
                for photo in selectedPics {
                    pics = pics.filter{ $0 != photo}
                }
            }
            newCollectionButton.setTitle("New Collection", for: .normal)
            collectionView.reloadData()
        }
    }
    
    func getNewImageSet(){
        FlickFinderImagesAPI.getImages(Double(self.selectedPin.latitude), Double(self.selectedPin.longitude)){ (success,data,error) in
            performUIUpdatesOnMain {
                if error != nil {
                    self.noImagesLabel.isHidden = false
                }
                if success! {
                    self.photosObject = data
                    if data?.count == 0 {
                        self.noImagesLabel.isHidden = false
                    } else{
                        self.isLoading = true
                        self.collectionView.reloadData()
                        self.getImages()
                    }
                }
            }
        }
    }
    
    func getImages(){
        if let photoObjects = self.photosObject {
            DispatchQueue.global(qos: .default).async {
                for i in 0..<photoObjects.count {
                    let objects = photoObjects[i]
                    if let imageUrlString = objects[Constants.FlickrResponseKeys.MediumURL] as?  String{
                        let imageURL = URL(string: imageUrlString)
                        if let imageData = try? Data(contentsOf: imageURL!) {
                            performUIUpdatesOnMain {
                                if let pinData = self.coreDataAccess.saveImageData(imageData, self.selectedPin){
                                     self.pics.append(pinData)
                                }
                                self.collectionView.reloadData()
                            }
                        }
                    }
                    
                    if (photoObjects.count == ( i + 1 )) {
                        self.isLoading = false
                        performUIUpdatesOnMain {
                            self.newCollectionButton.isEnabled = true
                        }
                    }
                }
            }
        }
    }
}


extension PhotosAlbumViewController : MKMapViewDelegate {
    
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
    
    
}

extension PhotosAlbumViewController : UICollectionViewDelegate, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var itemCount = 0
        if(isLoading){
            itemCount =  photosObject?.count ?? 0
        } else {
            itemCount = pics.count
        }
        
        return itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        
        performUIUpdatesOnMain {
            cell.activityIndicator.startAnimating()
            if self.selectedPhotos != nil {
                if self.selectedPhotos.contains(self.pics[indexPath.row]){
                    cell.overlayView.isHidden = false
                }else{
                    cell.overlayView.isHidden = true
                }
            }
       
            if indexPath.row < (self.pics.count) {
                cell.imageView.image = UIImage(data: self.pics[indexPath.row].images!)
            }else{
                cell.imageView.image = UIImage(named: "placeholder")
            }
            cell.activityIndicator.stopAnimating()
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell
        cell?.overlayView.isHidden = true
        selectedPhotos = selectedPhotos.filter{ $0 != pics[indexPath.row]}
        if (selectedPhotos) == nil {
            newCollectionButton.setTitle("New Collection", for: .normal)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell
        newCollectionButton.setTitle("Remove Selected Pictures", for: .normal)
        cell?.overlayView.isHidden = false
        if (selectedPhotos) != nil {
            self.selectedPhotos.append(pics[indexPath.row])
        }else{
            selectedPhotos = [pics[indexPath.row]]
        }
    }
}

