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


fileprivate class UploadOperation: Operation {
    var asset: PHAsset!
    private enum State: String {
        case ready
        case executing
        case finished
        
        fileprivate var keyPath: String {
            return "is" + rawValue.capitalized
        }
    }
    
    private let stateQueue = DispatchQueue(label: "read/write.state.operation", attributes: .concurrent)
    private var state_ = State.ready
    private var state: State {
        get {
            return stateQueue.sync(execute: {
                state_
            })
        }
        set {
            let oldValue = state
            willChangeValue(forKey: state.keyPath)
            willChangeValue(forKey: newValue.keyPath)
            stateQueue.sync(flags: .barrier, execute: {
                state_ = newValue
            })
            didChangeValue(forKey: state.keyPath)
            didChangeValue(forKey: oldValue.keyPath)
        }
    }
    
    init(_ asset: PHAsset) {
        self.asset = asset
    }
    
    open override var isReady: Bool {
        return super.isReady && state == .ready
    }
    
    public override var isExecuting: Bool {
        return state == .executing
    }
    
    public override var isFinished: Bool {
        return state == .finished
    }
    
    public override func start() {
        if isCancelled {
            finish()
            return
        }
        self.state = .executing
        main()
    }
    open override func main() {
        let option = PHImageRequestOptions()
        option.isNetworkAccessAllowed = true
        option.isSynchronous = true
        //TODO refactoring
        DataInteractor.shared.manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option) { (image, info) in
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
                    let assetIdentifier = self.asset.localIdentifier
                    DataInteractor.shared.webService.uploadImage(withData: imageData){ imageLink, timeStamp in
                        if let imageLink = imageLink, let timeStamp = timeStamp {
                            DataInteractor.shared.saveUrlItemToStorage(url: imageLink, timeStamp: timeStamp)
                            DataInteractor.shared.galleryPhotosPresenter?.assets(withIdentifier: assetIdentifier, wasSuccessfullyUploaded: true)
                        } else {
                            DataInteractor.shared.galleryPhotosPresenter?.assets(withIdentifier: assetIdentifier, wasSuccessfullyUploaded: false)
                        }
                        self.finish()
                    }
                }
            }
        }
    }
    
    public final func finish() {
        if isExecuting {
            state = .finished
        }
    }
}


fileprivate class CoreDataHelper {
    private init() {}
    static let shared = CoreDataHelper()
    
    lazy var viewContext: NSManagedObjectContext = self.persistentContainer.viewContext
    var savingContext: NSManagedObjectContext {
        return self.persistentContainer.newBackgroundContext()
    }
    
    private lazy var persistentContainer: NSPersistentContainer = {
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
    fileprivate lazy var webService = { SimpleWebService.shared }()
    
    fileprivate lazy var manager = { PHImageManager.default() }()
    fileprivate var imageAssets: PHFetchResult<PHAsset>?
    lazy var uploadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Serial queue for the uploading-getting_response"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    lazy var fetchedResults: NSFetchedResultsController<ImageUrl> = {
        let fetchRequest = NSFetchRequest<ImageUrl>(entityName:"ImageUrl")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending:false)]
        fetchRequest.fetchBatchSize = 20
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: CoreDataHelper.shared.viewContext,
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
        let uploadOp = UploadOperation(asset)
        uploadOp.qualityOfService = .userInitiated
        uploadQueue.addOperation(uploadOp)
    }
    
    func saveUrlItemToStorage(url: String, timeStamp: Date) {
        let saveContext = CoreDataHelper.shared.savingContext
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
    func getItem(atIndexPath indexPath: IndexPath) -> UploadedListModel {
        let url = fetchedResults.object(at: indexPath).url
        let timeStamp = fetchedResults.object(at: indexPath).timeStamp
        return UploadedListModel(timeStamp: timeStamp, url: url)
    }
    func numberOfItems(inSection section: Int) -> Int {
        return fetchedResults.sections?[section].numberOfObjects ?? 0
    }
}
