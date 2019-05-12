//
//  UploadedListRouter.swift
//  VIPERTrainingApp
//
//  Created by sdk on 5/8/19.
//  Copyright © 2019 Sdk. All rights reserved.
//

import Foundation
import UIKit

class UploadedListRouter: UploadedListRouterProtocol {
    private static let storyboard = UIStoryboard(name: "Main", bundle: nil)
    static func createUploadedListModule() -> UploadedListVC {
        let view = storyboard.instantiateViewController(withIdentifier: "UploadedListVC") as! UploadedListVC
        let presenter: UploadedListViewToPresenterProtocol & UploadedListInteractorToPresenterProtocol = UploadedListPresenter()
        let router: UploadedListRouterProtocol = UploadedListRouter()

        DataInteractor.shared.uploadedListPresenter = presenter
        view.presenter = presenter
        presenter.view = view
        presenter.router = router
        
        return view

    }
    func goToLink(link: String) {
        guard let url = URL(string: link) else { return }
        UIApplication.shared.open(url)
    }
}
