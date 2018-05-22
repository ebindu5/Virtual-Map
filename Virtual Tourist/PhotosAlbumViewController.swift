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

class PhotosAlbumViewController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var mapView : MKMapView!
    @IBOutlet var newCollectionButton: UIButton!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var noImagesLabel: UILabel!
    var index : Int!
    var photosObject : [[String: AnyObject]]?
    var selectedPhotos : [Int]!
    var selectedPin : CLLocationCoordinate2D!
    var photoCount: Int!
    let annotation = MKPointAnnotation()
    var newImageForExistingPin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.allowsMultipleSelection = true
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        mapView.showsUserLocation = true
        
        if photoCount == 0 {
            noImagesLabel.isHidden = true
        }else{
            noImagesLabel.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if newImageForExistingPin {
            getNewImageSet()
        }
        if let index = photoAlbumData.pinPhotoAlbum.index(where: {($0.selectedPin?.latitude == selectedPin?.latitude && $0.selectedPin?.longitude == selectedPin?.longitude)}) {
            self.index = index
            //
        }else{
            index = 0
        }
        
        annotation.coordinate = selectedPin
        mapView.addAnnotation(annotation)
        
        
        getImages()
        collectionView.reloadData()
    }
    
    
    @IBAction func newCollectionPressed() {
        if newCollectionButton.currentTitle == "New Collection" {
            newCollectionButton.isEnabled = false
            getNewImageSet()
            
        }else{
            newCollectionButton.setTitle("New Collection", for: .normal)
            //            collectionView.reloadData()
        }
    }
    
    func getNewImageSet(){
        photoAlbumData.pinPhotoAlbum[index].images = nil
        //        photoAlbumData.pinPhotoAlbum[index].photosObject = nil
        FlickFinderImagesAPI.getImages(Double(annotation.coordinate.latitude), Double(annotation.coordinate.longitude)){ (success,data,error) in
            performUIUpdatesOnMain {
                if error != nil {
                    self.noImagesLabel.isHidden = false
                }
                if success! {
                    self.photosObject = data
                    self.getImages()
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func getImages(){
       
        if photoAlbumData.pinPhotoAlbum[index].images == nil {
            performUIUpdatesOnMain {
                self.newCollectionButton.isEnabled = false
            }
            if let photoObjects = self.photosObject {
                DispatchQueue.global(qos: .default).async {
                    for object in photoObjects {
                        if let imageUrlString = object[Constants.FlickrResponseKeys.MediumURL] as?  String{
                            var pImage = UIImage()
                            let imageURL = URL(string: imageUrlString)
                            if let imageData = try? Data(contentsOf: imageURL!) {
                                pImage = UIImage(data: imageData)!
                                if  photoAlbumData.pinPhotoAlbum[self.index].images != nil {
                                    photoAlbumData.pinPhotoAlbum[self.index].images?.append(pImage)
                                    
                                }else{
                                    photoAlbumData.pinPhotoAlbum[self.index] = PhotoAlbumStruct( selectedPin: self.selectedPin, images: [pImage])
                                }
                                
                                performUIUpdatesOnMain {
                                    if self.photosObject?.count == photoAlbumData.pinPhotoAlbum[self.index].images?.count {
                                        self.newCollectionButton.isEnabled = true
                                    }
                                }
                            }
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
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if photosObject != nil {
            let count = photosObject?.count
            if count == 0 {
                noImagesLabel.isHidden = false
                return 0
            }else{
                noImagesLabel.isHidden = true
                return count!
            }
        }else{
            noImagesLabel.isHidden = true
            return photoCount ?? 0
        }
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        performUIUpdatesOnMain {
            cell.activityIndicator.startAnimating()
            if let images = photoAlbumData.pinPhotoAlbum[self.index].images {
                if indexPath.row < images.count {
                    cell.imageView.image = images[indexPath.row]
                }else{
                    cell.imageView.image = UIImage(named: "placeholder")
                }
                cell.activityIndicator.stopAnimating()
            }else{
                cell.imageView.image = UIImage(named: "placeholder")
            }
        }
        return cell
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if photosObject?.count == photoAlbumData.pinPhotoAlbum[index].images?.count {
            return true
        }else{
            return false
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 2.0
        cell?.layer.borderColor = UIColor.blue.cgColor
        newCollectionButton.setTitle("Remove Selected Pictures", for: .normal)
        
        if (selectedPhotos) != nil {
            self.selectedPhotos.append(indexPath.row)
        }else{
            selectedPhotos = [indexPath.row]
        }
        
        
    }
    
    
    
    
    
}
