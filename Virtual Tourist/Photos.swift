////
////  PhotosAlbumViewController.swift
////  Virtual Tourist
////
////  Created by NISHANTH NAGELLA on 5/23/18.
////  Copyright © 2018 Udacity. All rights reserved.
////
//
//
//import Foundation
//import MapKit
//import UIKit
//import CoreData
//
//class Photos : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
//
//    @IBOutlet var mapView : MKMapView!
//    @IBOutlet var newCollectionButton: UIButton!
//    @IBOutlet var collectionView: UICollectionView!
//    @IBOutlet weak var noImagesLabel: UILabel!
//    var index : Int!
//    var photosObject : [[String: AnyObject]]?
//    var selectedPhotos : [Int]!
//    var selectedPin : CLLocationCoordinate2D!
//    var photoCount: Int!
//    let annotation = MKPointAnnotation()
//    var newImageForExistingPin = false
//    var pinPhotos : [PinPhotos] = []
//    var dataController : DataController!
//    var fetchResultController: NSFetchedResultsController<PinPhotos>!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        collectionView.allowsMultipleSelection = true
//        mapView.delegate = self
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        mapView.showsUserLocation = true
//
//        let fetchRequest : NSFetchRequest<PinPhotos> = PinPhotos.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "latitude == %@", selectedPin.latitude)
//        fetchRequest.predicate = NSPredicate(format: "longitude == %@", selectedPin.longitude)
//        let sortDescriptors = NSSortDescriptor(key: "latitude", ascending: false)
//        fetchRequest.sortDescriptors = [sortDescriptors]
//        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "Pins")
//        fetchResultController.delegate = self
//
//        do{
//            try fetchResultController.performFetch()
//        }catch {
//            print(error.localizedDescription)
//        }
//
//        if photoCount == 0 {
//            noImagesLabel.isHidden = true
//        }else{
//            noImagesLabel.isHidden = false
//        }
//    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        fetchResultController = nil
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        if pinPhotos.count == 0 {
//            getNewImageSet()
//            collectionView.reloadData()
//        }
//
//        photoCount = pinPhotos.count
//
//        if newImageForExistingPin {
//            getNewImageSet()
//        }
//
//
//        if  let index = pinPhotos.index(where: {($0.latitude == selectedPin?.latitude) && ($0.longitude == selectedPin?.longitude)}) {
//            self.index = index
//        }else{
//            index = 0
//        }
//
//        annotation.coordinate = selectedPin
//        mapView.addAnnotation(annotation)
//
//        collectionView.reloadData()
//    }
//
//
//    @IBAction func newCollectionPressed() {
//        if newCollectionButton.currentTitle == "New Collection" {
//            newCollectionButton.isEnabled = false
//            getNewImageSet()
//
//        }else{
//            newCollectionButton.setTitle("New Collection", for: .normal)
//        }
//    }
//
//    func getNewImageSet(){
//
//        FlickFinderImagesAPI.getImages(Double(selectedPin.latitude), Double(selectedPin.longitude)){ (success,data,error) in
//            performUIUpdatesOnMain {
//                if error != nil {
//                    self.noImagesLabel.isHidden = false
//                }
//
//                if success! {
//                    self.photosObject = data
//                    self.photoCount = data?.count
//                    self.getImages()
//                    self.collectionView.reloadData()
//                }
//            }
//        }
//    }
//
//
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//
//        switch type {
//        case .delete:
//            collectionView.deleteItems(at: [indexPath!])
//            print("sf")
//        case .insert :
//            collectionView.reloadItems(at: [indexPath!])
//        default:
//            print("ad")
//        }
//    }
//
//
//    func getImages(){
//
//
//        //
//        //
//        //        //        if pinPhotos.count == 0 {
//        //        //TODO:
//        //        //            performUIUpdatesOnMain {
//        //        //                self.newCollectionButton.isEnabled = false
//        //        //            }
//        //
//        //            let backgroundContext = dataController.backgroundContext
//        //            backgroundContext?.perform {
//        //
//        //             if let photoObjects = self.photosObject {
//        ////            DispatchQueue.global(qos: .default).async {
//        //                for object in photoObjects {
//        //                    if let imageUrlString = object[Constants.FlickrResponseKeys.MediumURL] as?  String{
//        //                        let imageURL = URL(string: imageUrlString)
//        //                        if let imageData = try? Data(contentsOf: imageURL!) {
//        //
//        //
//        //
//        //                            let pinData = PinPhotos(context: self.dataController.viewContext)
//        //                            pinData.images?.append(imageData)
//        //                            pinData.longitude = self.selectedPin.longitude
//        //                            pinData.latitude = self.selectedPin.latitude
//        //                            try? self.dataController.viewContext.save()
//        //                            self.pinPhotos.append(pinData)
//        //
//        ////                            if let indexPath = self.collectionView.indexPathsForSelectedItems{
//        ////                                self.collectionView.deselectItem(at: indexPath.first!, animated: true)
//        ////                                self.collectionView.reloadItems(at: indexPath)
//        ////                            }
//        //
//        //                            //TODO:
//        //                            performUIUpdatesOnMain {
//        //                                self.collectionView.reloadData()
//        //                                if self.photosObject?.count == self.pinPhotos[self.index].images?.count {
//        //                                    self.newCollectionButton.isEnabled = true
//        //                                }
//        //                            }
//        //                        }
//        //                    }
//        //                }
//        ////            }
//        //                        }
//        //        }
//    }
//}
//
//
//extension PhotosAlbumViewController : MKMapViewDelegate {
//
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        let reuseId = "pin"
//
//        var pinView  = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)  as? MKPinAnnotationView
//
//        if pinView == nil {
//            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
//            pinView?.animatesDrop = true
//            pinView?.tintColor = UIColor.red
//        }else{
//            pinView?.annotation = annotation
//        }
//        return pinView
//    }
//
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return (fetchResultController.sections?.count)! ?? 1
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        ////        if photosObject != nil {
//        ////            let count = photosObject?.count
//        //            if photoCount == 0 {
//        //                noImagesLabel.isHidden = false
//        //                return 0
//        //            }else{
//        //                noImagesLabel.isHidden = true
//        //                return photoCount
//        //            }
//        ////        }else{
//        ////            noImagesLabel.isHidden = true
//        ////            return photoCount ?? 0
//        ////        }
//        let im = fetchResultController.sections?[section].numberOfObjects
//
//        return photoCount ?? 0
//    }
//
//
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        //        let p = pinPhotos(at: indexPath)
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
//
//        //        let pinData = fetchResultController.object(at: indexPath)
//
//        performUIUpdatesOnMain {
//            cell.activityIndicator.startAnimating()
//
//            //            if let images = pinData.images {
//            //                if indexPath.row < images.count {
//            //                    cell.imageView.image = images
//            //                }
//            //
//            //            }
//            if self.pinPhotos.count == 0 {
//
//                if let images = self.pinPhotos[self.index].images {
//                    if indexPath.row < (images.count) {
//                        //TODO:
//                        cell.imageView.image = UIImage(data: images)
//                    }else{
//                        cell.imageView.image = UIImage(named: "placeholder")
//                    }
//                    cell.activityIndicator.stopAnimating()
//                }
//            }
//            else{
//                cell.imageView.image = UIImage(named: "placeholder")
//            }
//        }
//        return cell
//    }
//
//
//
//
//    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        if photosObject?.count == pinPhotos[index].images?.count {
//            return true
//        }else{
//            return false
//        }
//    }
//
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//        let cell = collectionView.cellForItem(at: indexPath)
//        cell?.layer.borderWidth = 2.0
//        cell?.layer.borderColor = UIColor.blue.cgColor
//        newCollectionButton.setTitle("Remove Selected Pictures", for: .normal)
//
//        if (selectedPhotos) != nil {
//            self.selectedPhotos.append(indexPath.row)
//        }else{
//            selectedPhotos = [indexPath.row]
//        }
//
//
//    }
//
//
//
//
//
//}
