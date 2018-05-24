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
    var selectedPhotos : [Int]!
    var selectedPin : Pins!
    let annotation = MKPointAnnotation()
    var newImageForExistingPin = false
    var pinPhotos : PinPhotos!
    var pics = [PinPhotos]()
    var dataController : DataController!
    var fetchResultController: NSFetchedResultsController<PinPhotos>!
    var saveNotificationToken : Any?
    var isLoading = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.allowsMultipleSelection = true
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        mapView.showsUserLocation = true
        
        let fetchRequest : NSFetchRequest<PinPhotos> = PinPhotos.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "pins == %@", selectedPin)
        let sortDescriptors = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptors]
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            pics = result
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchResultController = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.addAnnotation(selectedPin)
        if pics.count == 0 {
            getNewImageSet()
        }else{
            collectionView.reloadData()
        }
    }
    
    
    @IBAction func newCollectionPressed() {
        if newCollectionButton.currentTitle == "New Collection" {
            newCollectionButton.isEnabled = false
            if pics.count != 0 {
                pics.removeAll()
            }
            getNewImageSet()
        }else{
            newCollectionButton.setTitle("New Collection", for: .normal)
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
                    self.isLoading = true
                    self.collectionView.reloadData()
                    self.getImages()
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
                                let pinData = PinPhotos(context: self.dataController.viewContext)
                                pinData.images = imageData
                                pinData.pins = self.selectedPin
                                pinData.creationDate = Date()
                                self.pics.append(pinData)
                                
                                do {
                                    try self.dataController.viewContext.save()
                                } catch {
                                    print("Failed saving")
                                }
                                self.collectionView.reloadData()
                            }
                        }
                    }
                    
                    if (photoObjects.count == ( i + 1 )) {
                        self.isLoading = false
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
        
        if itemCount == 0 {
            noImagesLabel.isHidden = false
        }else{
            noImagesLabel.isHidden = true
        }
        
        return itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        
        performUIUpdatesOnMain {
            cell.activityIndicator.startAnimating()
            if indexPath.row < (self.pics.count) {
                cell.imageView.image = UIImage(data: self.pics[indexPath.row].images!)
            }else{
                cell.imageView.image = UIImage(named: "placeholder")
            }
            cell.activityIndicator.stopAnimating()
        }
        return cell
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

