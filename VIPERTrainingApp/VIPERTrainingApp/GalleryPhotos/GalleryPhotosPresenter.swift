//
//  GalleryPhotosPresenter.swift
//  VIPERTrainingApp
//
//  Created by sdk on 5/9/19.
//  Copyright © 2019 Sdk. All rights reserved.
//

import Foundation
import Photos

class GalleryPhotosPresenter {
    private let imageManager = PHCachingImageManager()
    private var imageAssets: PHFetchResult<PHAsset>?
    var thumbnailSize: CGSize!
    private var uploadIdentifiersPool = Set<String>()
    
    //GalleryPhotosViewToPresenterProtocol
    weak var view: GalleryPhotosViewProtocol?
    let interactor: GalleryPhotosPresenterToInteractorProtocol = DataInteractor.shared
    var router: GalleryPhotosRouterProtocol?
}

// MARK: - GalleryPhotosInteractorToPresenterProtocol
extension GalleryPhotosPresenter: GalleryPhotosInteractorToPresenterProtocol {
    func assetsFetch(assets: PHFetchResult<PHAsset>?) {
        if assets != nil {
            imageAssets = assets
            view?.updateView()
        }
    }
    
    func assets(withIdentifier identifier: String, wasSuccessfullyUploaded success: Bool) {
        self.uploadIdentifiersPool.remove(identifier)
        self.view?.reloadCellWithIdentifier(identifier: identifier)
        if !success {
            view?.showAlert()
        }
    }
}

// MARK: - GalleryPhotosViewToPresenterProtocol
extension GalleryPhotosPresenter: GalleryPhotosViewToPresenterProtocol {
    func startFetching() {
        interactor.fetchImages()
    }
    
    func updateCachedAssets(addedAssets: [PHAsset], removedAssets: [PHAsset]) {
        imageManager.startCachingImages(for: addedAssets,
                                        targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        
        imageManager.stopCachingImages(for: removedAssets,
                                       targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
    }
    
    func numberOfPhotoItems() -> Int {
        return imageAssets == nil ? 0 : imageAssets!.count
    }
    func fetchItemFor(indexPath: IndexPath, success: @escaping (String, UIImage, Bool) -> Void ) {
        let asset = imageAssets!.object(at: indexPath.row)
        // Request an image for an asset from the PHCachingImageManager.
        imageManager.requestImage(for: asset, targetSize: thumbnailSize ?? PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            if let image = image {
                let identifier = asset.localIdentifier
                let isUploading = self.uploadIdentifiersPool.contains(identifier)
                success(identifier, image, isUploading)
            }
        })
    }
    
    func selectItem(atIndex index: Int)  {
        if let asset = imageAssets?.object(at: index) {
            uploadIdentifiersPool.insert(asset.localIdentifier)
            interactor.uploadAsset(asset)
        }
    }
    
    
    func pushToUploadedList (navigationConroller navigationController:UINavigationController) {
        router?.pushToUploadedList(navigationConroller: navigationController)
    }
    
    subscript(index: Int) -> PHAsset? {
        return imageAssets?.object(at: index)
    }
}
