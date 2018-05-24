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

class PhotosAlbumViewController : UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet var mapView : MKMapView!
    @IBOutlet var newCollectionButton: UIButton!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var noImagesLabel: UILabel!
    var index : Int!
    var photosObject : [[String: AnyObject]]?
    var selectedPhotos : [Int]!
    var selectedPin : Pins!
//    var photoCount: Int!
    let annotation = MKPointAnnotation()
    var newImageForExistingPin = false
    var pinPhotos : PinPhotos!
    var pics = [PinPhotos]()
    var dataController : DataController!
    var fetchResultController: NSFetchedResultsController<PinPhotos>!
    var saveNotificationToken : Any?
    
    
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
        collectionView.reloadData()
        addNotificationObserver()
    }
    
    deinit {
        removeNotificationObserver()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchResultController = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if pics.count == 0 {
            getNewImageSet()
        }
        
        collectionView.reloadData()
        mapView.addAnnotation(selectedPin)
        collectionView.reloadData()
    }
    
    
    @IBAction func newCollectionPressed() {
        if newCollectionButton.currentTitle == "New Collection" {
            newCollectionButton.isEnabled = false
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
                    self.collectionView.reloadData()
                    self.getImages()
                }
            }
        }
    }
    
    func getImages(){
        
        if let photoObjects = self.photosObject {
            for objects in photoObjects {
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
        return pics.count ?? (photosObject?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        
//        print(PinPhotos(context: dataController.viewContext))
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



extension PhotosAlbumViewController {
    
    func addNotificationObserver(){
        removeNotificationObserver()
        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: dataController.viewContext, queue: nil, using: handleNotificationObserver(notification:))
    }
    
    func removeNotificationObserver(){
        if let token = saveNotificationToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    func reloadData(){
        collectionView.reloadData()
    }
    func handleNotificationObserver(notification: Notification){
        DispatchQueue.main.async {
            self.reloadData()
        }
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.reloadData()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.reloadData()
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
            print("sf")
        case .insert :
            collectionView.reloadItems(at: [indexPath!])
        default:
            print("ad")
        }
    }
}
