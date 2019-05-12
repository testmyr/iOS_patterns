//
//  GalleryPhotosRouter.swift
//  VIPERTrainingApp
//
//  Created by sdk on 5/8/19.
//  Copyright © 2019 Sdk. All rights reserved.
//

import Foundation
import UIKit

class GalleryPhotosRouter: GalleryPhotosRouterProtocol {
    private static let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    class func createGalleryPhotosModule() -> GalleryPhotosViewController {
        let view = storyboard.instantiateViewController(withIdentifier: "GalleryPhotosViewController") as! GalleryPhotosViewController
        let presenter: GalleryPhotosViewToPresenterProtocol & GalleryPhotosInteractorToPresenterProtocol = GalleryPhotosPresenter()
        let router: GalleryPhotosRouterProtocol = GalleryPhotosRouter()
        
        DataInteractor.shared.galleryPhotosPresenter = presenter
        view.presenter = presenter
        presenter.view = view
        presenter.router = router
        
        return view
    }
    
    
    func pushToUploadedList(navigationConroller:UINavigationController) {        
        let uploadedListModule = UploadedListRouter.createUploadedListModule()
        navigationConroller.pushViewController(uploadedListModule, animated: true)
    }
}
