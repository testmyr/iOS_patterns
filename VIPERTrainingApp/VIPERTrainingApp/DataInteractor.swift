//
//  DataInteractor.swift
//  VIPERTrainingApp
//
//  Created by sdk on 5/8/19.
//  Copyright © 2019 Sdk. All rights reserved.
//

import Foundation
import CoreData
import Photos

fileprivate class CoreDataHelper {
    private init() {}
    static let shared = CoreDataHelper()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "VIPERTrainingApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
}

//can be divided but let it be shared because it's quite convenient in this particular case
class DataInteractor: NSObject {
    lazy private var webService = SimpleWebService.shared
    
    static let shared = DataInteractor()
    override private init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
    }
    
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    
    fileprivate var imageAssets: PHFetchResult<PHAsset>?
    //GalleryPhotosPresenterToInteractorProtocol
    weak var galleryPhotosPresenter:GalleryPhotosInteractorToPresenterProtocol?
}

// MARK: PHPhotoLibraryChangeObserver
extension DataInteractor: PHPhotoLibraryChangeObserver {
    /// - Tag: RespondToChanges
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        if imageAssets != nil {
            DispatchQueue.main.sync {
                // Check each of the three top-level fetches for changes.
                if let changeDetails = changeInstance.changeDetails(for: imageAssets!) {
                    // Update the cached fetch result.
                    imageAssets = changeDetails.fetchResultAfterChanges
                    //and pass tme to the presenter
                    self.galleryPhotosPresenter?.assetsFetch(assets: self.imageAssets)
                }
            }
        }
    }
}


extension DataInteractor: GalleryPhotosPresenterToInteractorProtocol {
    func fetchImages() {
        PHPhotoLibrary.requestAuthorization { [unowned self] (authStatus) in
            if authStatus == .authorized {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                self.imageAssets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                self.galleryPhotosPresenter?.assetsFetch(assets: self.imageAssets)
            }
        }
    }
}
