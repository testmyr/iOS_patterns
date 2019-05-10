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
    private let webService = { SimpleWebService.shared }
    private let imageManager = PHCachingImageManager()
    
    static let shared = DataInteractor()
    lazy var fetchedResults: NSFetchedResultsController<ImageUrl> = {
        let fetchRequest = NSFetchRequest<ImageUrl>(entityName:"ImageUrl")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending:false)]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: CoreDataHelper.shared.persistentContainer.viewContext,
                                                    sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        
        do {
            try controller.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return controller
    }()
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
    //UploadedListPresenterToInteractorProtocol
    weak var uploadedListPresenter:UploadedListInteractorToPresenterProtocol?
}

extension DataInteractor: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        uploadedListPresenter?.beginUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            uploadedListPresenter?.insertRow(at: newIndexPath!)
        case .delete:
            uploadedListPresenter?.deleteRow(at: indexPath!)
        case .update:
            uploadedListPresenter?.updateRow(at: indexPath!)
        case .move:
            uploadedListPresenter?.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        uploadedListPresenter?.endUpdates()
    }
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
                    //and pass it then to the presenter
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
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                self.imageAssets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                self.galleryPhotosPresenter?.assetsFetch(assets: self.imageAssets)
            }
        }
    }
    
    func uploadItem(atIndex index: Int)  {
        //TODO check whether it has been uploaded already
        if true {
            if let asset = self.imageAssets?[index] {
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                option.isNetworkAccessAllowed = true
                option.isSynchronous = true
                manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option) { (image, info) in
                    //Extract the image data
                    if var imageData = image!.pngData() {
                        //Image size is limited by web service API. That's why:
                        let maxAllowedSize = 1024 * 1024 * 10 - 1
                        if imageData.count > maxAllowedSize {
                            var acceptableCompression = CGFloat(1)
                            let step = CGFloat(0.05)
                            repeat {
                                imageData = image!.jpegData(compressionQuality: acceptableCompression)!
                                acceptableCompression -= step
                            } while imageData.count > maxAllowedSize && acceptableCompression > step
                        }
                        self.webService().uploadImage(withData: imageData){ imageLink, timeStamp in
                            if let imageLink = imageLink, let timeStamp = timeStamp {
                                self.saveUrlItemToStorage(url: imageLink, timeStamp: timeStamp)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func saveUrlItemToStorage(url: String, timeStamp: Date) {
        let saveContext = CoreDataHelper.shared.persistentContainer.newBackgroundContext()
        saveContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        saveContext.undoManager = nil
        
        guard let image = NSEntityDescription.insertNewObject(forEntityName: "ImageUrl", into: saveContext) as? ImageUrl else {
            print("Error!")
            return
        }
        image.timeStamp = timeStamp
        image.url = url
        do {
            try saveContext.save()
        } catch {
            print("Error: \(error)\n. Couldn't be saved.")
        }
    }
}

extension DataInteractor: UploadedListPresenterToInteractorProtocol {
    func getItem(atIndexPath indexPath: IndexPath) -> ImageUrl {
        return fetchedResults.object(at: indexPath)
    }
    func numberOfItems(inSection section: Int) -> Int {
        return fetchedResults.sections?[section].numberOfObjects ?? 0
    }
}
