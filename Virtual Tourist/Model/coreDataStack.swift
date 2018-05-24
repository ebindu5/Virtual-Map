////
////  coreDataStack.swift
////  Virtual Tourist
////
////  Created by NISHANTH NAGELLA on 5/23/18.
////  Copyright © 2018 Udacity. All rights reserved.
////
//
//import Foundation
//import CoreData
//
//extension PhotosAlbumViewController {
//
//    func saveImageToDisk() {
//        let fm = FileManager.default
//        let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)
//        let url = urls.last?.appendingPathComponent(".txt")
//
//        do {
//            try pinPhotos.images?.write(to: url!)
////            try pinPhotos.write(to: url!, atomically: true, encoding: String.Encoding.utf8)
//        } catch {
//            print("Error while writing")
//        }
//
////        do {
////            let content = try String(contentsOf: url!, encoding: String.Encoding.utf8)
////
////            if content == "Hi There!" {
////                print("yay")
////            } else {
////                print("oops")
////            }
////        } catch {
////            print("Something went wrong")
////        }
//    }
//
//
//    func GetImagesFromDisk() {
//                do {
//                    let content = try Data(contentsOf: URL(string: pinPhotos.imagePath!)!)
//
//                //    let content = try String(contentsOf: url!, encoding: String.Encoding.utf8)
//        
////                    if content == "Hi There!" {
////                        print("yay")
////                    } else {
////                        print("oops")
////                    }
//                } catch {
//                    print("Something went wrong")
//                }
//    }
//
//
//
//}
