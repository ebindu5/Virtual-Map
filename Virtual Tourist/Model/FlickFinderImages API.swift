//
//  FlickFinderImages API.swift
//  Virtual Tourist
//
//  Created by NISHANTH NAGELLA on 5/17/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class FlickFinderImagesAPI: UIViewController {
    
    static func fetchImagesfromAPI(_ latitude: CLLocationDegrees , _ longitude: CLLocationDegrees, completionHandlerForFetchImages: @escaping (_ success: Bool, _ response: [UIImage], _ error: String?) -> Void){
        
        let url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=9116ef876df135dcb30cb3a92fe06bfd&lat=48.8566&lon=2.3522&extras=url_m&format=json&nojsoncallback=1&auth_token=72157669088444118-a4fbcb2a9242fcf4&api_sig=ff30c85fa37219f15071ddc3d70f641f"
        
        let urlRequest = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            guard error == nil else{
                print(error?.localizedDescription)
                return
            }
            
            guard data != nil else{
                print("no data")
                return
            }
            
            if let parsedResult = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? AnyObject {
                
                if let photos = parsedResult!["photos"] as? [String: AnyObject] {
                    
                    if let pages = photos["pages"] as? Int {
                        
                        let randomPage = Int(arc4random_uniform(UInt32(pages)))
                        
                        let url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=9116ef876df135dcb30cb3a92fe06bfd&lat=48.8566&lon=2.3522&extras=url_m&page=\(randomPage)&format=json&nojsoncallback=1&auth_token=72157669090180858-dc2a3a3a8dc325f1&api_sig=12be8e08f5a013956e3f267a84dca41c"
                        
                        let urlRequest = URLRequest(url: URL(string: url)!)
                        
                        
                        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                            
                            guard error == nil else{
                                print(error?.localizedDescription)
                                return
                            }
                            
                            guard data != nil else{
                                print("no data")
                                return
                            }
                            
                            if let parsedResult = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? AnyObject {
                                
                                if let photos = parsedResult!["photos"] as? [String: AnyObject] , let photo = photos["photo"] as? [[String:AnyObject]] {
                                    
                                    if photo.count == 0 {
                                        completionHandlerForFetchImages(false,[],"no Images")
                                    }else{
                                        var finalImages = [UIImage]()
                                        for array in photo {
                                            
                                            if let url = URL(string: array["url_m"] as! String){
                                                let nw = NSData(contentsOf: url)
                                                
                                                finalImages.append(UIImage(data: nw! as Data)!)
                                                
                                            }
                                            
                                        }
                                        
                                        completionHandlerForFetchImages(true,finalImages,nil)
                                    }
                                }
                                
                            }
                            
                            
                        }
                        task.resume()
                    }
                    
                }else{
                    completionHandlerForFetchImages(false,[],"no Images")
                }
                
            }
            
            
        }
        task.resume()
        
    }
    
    
    static func displayImageFromFlickrBySearch(_ methodParameters: [String: AnyObject], completionHandlerForSearchImage: @escaping (_ success : Bool?, _ data: [UIImage]?,_ error: String?)-> Void){
        
        // create session and request
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
        
        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
                performUIUpdatesOnMain {
                    //                    self.setUIEnabled(true)
                    //                    self.photoTitleLabel.text = "No photo returned. Try again."
                    //                    self.photoImageView.image = nil
                }
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Is "photos" key in our result? */
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                displayError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            /* GUARD: Is "pages" key in the photosDictionary? */
            guard let totalPages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
                displayError("Cannot find key '\(Constants.FlickrResponseKeys.Pages)' in \(photosDictionary)")
                return
            }
            
            // pick a random page!
            let pageLimit = min(totalPages, 40)
            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
            self.displayImageFromFlickrBySearch(methodParameters, withPageNumber: randomPage){ (success, data, error) in
                
                guard error == nil else {
                    completionHandlerForSearchImage(false, nil,error)
                    return
                }
                
                /* GUARD: Was there any data returned? */
                guard let data = data else {
                    completionHandlerForSearchImage(false, nil,"No data was returned by the request!")
                    return
                }
                
                completionHandlerForSearchImage(true, data, nil)
                
            }
        }
        
        // start the task!
        task.resume()
    }
    

    
    static func displayImageFromFlickrBySearch(_ methodParameters: [String: AnyObject], withPageNumber: Int, completionHandlerforImageFromFlickr: @escaping (_ success: Bool?, _ data: [UIImage]?, _ error: String?) -> Void) {
        
        // add the page to the method's parameters
        var methodParametersWithPageNumber = methodParameters
        methodParametersWithPageNumber[Constants.FlickrParameterKeys.Page] = withPageNumber as AnyObject?
        
        // create session and request
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
        
        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
                performUIUpdatesOnMain {
                    //                    self.setUIEnabled(true)
                    //                    self.photoTitleLabel.text = "No photo returned. Try again."
                    //                    self.photoImageView.image = nil
                }
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Is the "photos" key in our result? */
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                displayError("Cannot find key '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            /* GUARD: Is the "photo" key in photosDictionary? */
            guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                displayError("Cannot find key '\(Constants.FlickrResponseKeys.Photo)' in \(photosDictionary)")
                return
            }
            
            if photosArray.count == 0 {
                displayError("No Photos Found. Search Again.")
                return
            } else {
                
                var finalImages = [UIImage]()
                for array in photosArray {
                    guard let imageUrlString = array[Constants.FlickrResponseKeys.MediumURL] as? String else {
                        displayError("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(array)")
                        return
                    }
                    let imageURL = URL(string: imageUrlString)
                    if let imageData = try? Data(contentsOf: imageURL!) {
                        finalImages.append(UIImage(data: imageData)!)
                    } else {
                         completionHandlerforImageFromFlickr(false, nil, "Image does not exist at \(imageURL)")
//                        displayError("Image does not exist at \(imageURL)")
                    }
                }
                
                completionHandlerforImageFromFlickr(true, finalImages, nil)
                //                let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
                //                let photoDictionary = photosArray[randomPhotoIndex] as [String: AnyObject]
                //                let photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String
                //
                //                /* GUARD: Does our photo have a key for 'url_m'? */
                //                guard let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                //                    displayError("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
                //                    return
                //                }
                //
                //                // if an image exists at the url, set the image and title
                //                let imageURL = URL(string: imageUrlString)
                //                if let imageData = try? Data(contentsOf: imageURL!) {
                //                    performUIUpdatesOnMain {
                //
                ////                        self.setUIEnabled(true)
                ////                        self.photoImageView.image = UIImage(data: imageData)
                ////                        self.photoTitleLabel.text = photoTitle ?? "(Untitled)"
                //                    }
                //                } else {
                //                    displayError("Image does not exist at \(imageURL)")
                //                }
            }
        }
        
        // start the task!
        task.resume()
    }
    
    // MARK: Helper for Creating a URL from Parameters
    
    static func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
}
