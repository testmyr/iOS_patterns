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
    
    //GalleryPhotosViewToPresenterProtocol
    weak var view: GalleryPhotosViewProtocol?
    //var interactor: GalleryPhotosPresenterToInteractorProtocol?
    let interactor: GalleryPhotosPresenterToInteractorProtocol = DataInteractor.shared
    var router: GalleryPhotosRouterProtocol?
}

extension GalleryPhotosPresenter:GalleryPhotosInteractorToPresenterProtocol {
    func assetsFetch(assets: PHFetchResult<PHAsset>?) {
        if assets != nil {
            imageAssets = assets
            view?.updateView()
        }
    }
}

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
    func fetchItemFor(indexPath: IndexPath, success: @escaping (String, UIImage) -> Void ) {
        let asset = imageAssets!.object(at: indexPath.row)
        // Request an image for the asset from the PHCachingImageManager.
        imageManager.requestImage(for: asset, targetSize: thumbnailSize ?? PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            if let image = image {
                success(asset.localIdentifier, image)
            }
        })
    }
    
    func selectItem(atIndex index: Int)  {
        interactor.uploadItem(atIndex: index)
    }
    
    func pushToUploadedList (navigationConroller navigationController:UINavigationController) {
        let uploadedListModule = UploadedListRouter.createUploadedListModule()
        navigationController.pushViewController(uploadedListModule, animated: true)
        
    }
    
    subscript(index: Int) -> PHAsset? {
        return imageAssets?.object(at: index)
    }
}
