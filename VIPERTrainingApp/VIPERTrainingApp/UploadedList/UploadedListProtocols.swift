//
//  UploadedListProtocols.swift
//  VIPERTrainingApp
//
//  Created by sdk on 5/8/19.
//  Copyright © 2019 Sdk. All rights reserved.
//

import Foundation


//adopted by UploadedListsRouter
protocol UploadedListRouterProtocol: class {
    static func createUploadedListModule() -> UploadedListVC
}

//adopted by DataInteractor
protocol UploadedListPresenterToInteractorProtocol:class {
    var uploadedListPresenter:UploadedListInteractorToPresenterProtocol? { get set }
    func getItem(atIndexPath indexPath: IndexPath) -> ImageUrl
    func numberOfItems(inSection section: Int) -> Int
    
}

//adopted by UploadedListPresenter
protocol UploadedListInteractorToPresenterProtocol: class {
    func beginUpdates()
    func insertRow(at: IndexPath)
    func deleteRow(at: IndexPath)
    func updateRow(at: IndexPath)
    func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath)
    func endUpdates()
}
protocol UploadedListViewToPresenterProtocol: class {
    func getItem(atIndexPath indexPath: IndexPath) -> ImageUrl
    func numberOfItems(inSection section: Int) -> Int
    var view:UploadedListViewProtocol? { get set }
    //var interactor: GalleryPhotosPresenterToInteractorProtocol? {get set}
    var router: UploadedListRouterProtocol? {get set}
    func selectItem(atIndex index: Int)
}



//adopted by UploadedListVC
protocol UploadedListViewProtocol: class {
    var presenter: UploadedListViewToPresenterProtocol? { get set }
    
    func beginUpdates()
    func insertRow(at: IndexPath)
    func deleteRow(at: IndexPath)
    func updateRow(at: IndexPath)
    func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath)
    func endUpdates()
}
