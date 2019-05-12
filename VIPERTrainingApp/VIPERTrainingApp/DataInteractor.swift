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
    private lazy var webService = { SimpleWebService.shared }()
    
    private lazy var manager = { PHImageManager.default() }()
    fileprivate var imageAssets: PHFetchResult<PHAsset>?
    private var assetsQueue = Queue<PHAsset>()
    private let queue = DispatchQueue(label: "Serial queue for the upload-response")
    private var isAssetUploading = false
    
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
    
    static let shared = DataInteractor()
    override private init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    //GalleryPhotosPresenterToInteractorProtocol
    weak var galleryPhotosPresenter:GalleryPhotosInteractorToPresenterProtocol?
    //UploadedListPresenterToInteractorProtocol
    weak var uploadedListPresenter:UploadedListInteractorToPresenterProtocol?
}

// MARK: NSFetchedResultsControllerDelegate
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

// MARK: - GalleryPhotosPresenterToInteractorProtocol
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
    
    func uploadAsset(_ asset: PHAsset) {
        uploadAsset(asset, ignoreQueue: false)
    }
    
    private func uploadAsset(_ asset: PHAsset, ignoreQueue: Bool) {
        //TODO check whether it has been uploaded already
        
        let option = PHImageRequestOptions()
        option.isNetworkAccessAllowed = true
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option) { (image, info) in
            if let image = image {
                //Extract the image data
                if var imageData = image.pngData() {
                    //Image size is limited by web service API. That's why:
                    let maxAllowedSize = 1024 * 1024 * 10 - 1
                    if imageData.count > maxAllowedSize {
                        var acceptableCompression = CGFloat(1)
                        let step = CGFloat(0.05)
                        repeat {
                            imageData = image.jpegData(compressionQuality: acceptableCompression)!
                            acceptableCompression -= step
                        } while imageData.count > maxAllowedSize && acceptableCompression > step
                    }
                    self.queue.async {
                        let assetIdentifier = asset.localIdentifier
                        if ignoreQueue || (self.assetsQueue.size == 0 && !self.isAssetUploading) {
                            self.isAssetUploading = true
                            self.webService.uploadImage(withData: imageData){ [unowned self] imageLink, timeStamp in
                                if let imageLink = imageLink, let timeStamp = timeStamp {
                                    self.saveUrlItemToStorage(url: imageLink, timeStamp: timeStamp)
                                    self.galleryPhotosPresenter?.assets(withIdentifier: assetIdentifier, wasSuccessfullyUploaded: true)
                                } else {
                                    self.galleryPhotosPresenter?.assets(withIdentifier: assetIdentifier, wasSuccessfullyUploaded: false)
                                }
                                self.queue.sync {
                                    if let nextAsset = self.assetsQueue.dequeue() {
                                        self.uploadAsset(nextAsset, ignoreQueue: true)
                                    } else {
                                        self.isAssetUploading = false
                                    }
                                }
                            }
                        } else {
                            self.assetsQueue.enqueue(asset)
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

// MARK: - UploadedListPresenterToInteractorProtocol
extension DataInteractor: UploadedListPresenterToInteractorProtocol {
    func getItem(atIndexPath indexPath: IndexPath) -> ImageUrl {
        return fetchedResults.object(at: indexPath)
    }
    func numberOfItems(inSection section: Int) -> Int {
        return fetchedResults.sections?[section].numberOfObjects ?? 0
    }
}
