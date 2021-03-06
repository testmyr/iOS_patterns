//
//  UploadedListPresenter.swift
//  VIPERTrainingApp
//
//  Created by sdk on 5/8/19.
//  Copyright © 2019 Sdk. All rights reserved.
//

import Foundation

class UploadedListPresenter {
    weak var view: UploadedListViewProtocol?
    let interactor: UploadedListPresenterToInteractorProtocol = DataInteractor.shared
    var router: UploadedListRouterProtocol?
}

// MARK: - UploadedListInteractorToPresenterProtocol
extension UploadedListPresenter: UploadedListInteractorToPresenterProtocol {
    
    func beginUpdates() {
        view?.beginUpdates()
    }
    func insertRow(at indexPath: IndexPath) {
        view?.insertRow(at: indexPath)
    }
    func deleteRow(at indexPath: IndexPath) {
        view?.deleteRow(at: indexPath)
    }
    func updateRow(at indexPath: IndexPath) {
        view?.updateRow(at: indexPath)
    }
    func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        view?.moveRow(at: indexPath, to: newIndexPath)
    }
    func endUpdates() {
        view?.endUpdates()
    }
}

// MARK: - UploadedListViewToPresenterProtocol
extension UploadedListPresenter: UploadedListViewToPresenterProtocol {
    func getItem(atIndexPath indexPath: IndexPath) -> UploadedListModel {
        return interactor.getItem(atIndexPath: indexPath)
    }
    
    func numberOfItems(inSection section: Int) -> Int {
        return interactor.numberOfItems(inSection: section)
    }
    
    func goToLink(link: String) {
        router?.goToLink(link: link)
    }    
}
