//
//  GalleryPhotosProtocols.swift
//  VIPERTrainingApp
//
//  Created by sdk on 5/9/19.
//  Copyright © 2019 Sdk. All rights reserved.
//

import Foundation
import UIKit
import Photos

//adopted by GalleryPhotosRouter
protocol GalleryPhotosRouterProtocol: class {
    static func createGalleryPhotosModule() -> GalleryPhotosViewController
    func pushToUploadedList(navigationConroller:UINavigationController)
}

//adopted by DataInteractor
protocol GalleryPhotosPresenterToInteractorProtocol:class {
    
    var galleryPhotosPresenter:GalleryPhotosInteractorToPresenterProtocol? { get set }
    func fetchImages()
    func uploadAsset(_ asset: PHAsset)
    
}

//adopted by GalleryPhotosPresenter
protocol GalleryPhotosInteractorToPresenterProtocol: class {
    func assetsFetch(assets: PHFetchResult<PHAsset>?)
    func assets(withIdentifier identifier: String, wasSuccessfullyUploaded success: Bool)
}
protocol GalleryPhotosViewToPresenterProtocol: class {
    var thumbnailSize: CGSize! { get set }
    var view:GalleryPhotosViewProtocol? { get set }
    //var interactor: GalleryPhotosPresenterToInteractorProtocol? {get set}
    var router: GalleryPhotosRouterProtocol? {get set}
    func startFetching()
    func updateCachedAssets(addedAssets: [PHAsset], removedAssets: [PHAsset])
    func fetchItemFor(indexPath: IndexPath, success: @escaping (String, UIImage, Bool) -> Void )
    func numberOfPhotoItems() -> Int
    func selectItem(atIndex index: Int)
    func pushToUploadedList (navigationConroller navigationController:UINavigationController)
    subscript(index: Int) -> PHAsset? { get }
}

//adopted by GalleryPhotosViewController
protocol GalleryPhotosViewProtocol: class {
    var presenter: GalleryPhotosViewToPresenterProtocol? { get set }
    func updateView()
    func reloadCellWithIdentifier(identifier: String)
}
