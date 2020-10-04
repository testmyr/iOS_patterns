//
//  GeneralViewPresenter.swift
//  MVPCoordinatorTrainingApp
//
//  Created by sdk on 3/25/19.
//  Copyright © 2019 Sdk. All rights reserved.
//

import Foundation
import UIKit

protocol GeneralVCProtocol: AnyObject {
    func updateView()
    func updateRow(rowIndex: Int)
    //spinner better rewrite as setting state by using an enum
    func showSpinner()
    func hideSpinner()
}

protocol GeneralViewPresenterProtocol {
    var view: GeneralVCProtocol? { get set }
    func numberOfMovies() -> Int
    func movieFor(rowAtIndex index: Int) -> MovieDescription
    func getNextPage()
    func fetchPoster(forIndex index: Int)
    func cancelFetchingPoster(forIndex index: Int)
    func searchFor(text: String)
    func didSelectRow(_ row: Int)
}

class GeneralViewPresenter {
    weak var coordinator: CoordinatorToGeneralProtocol?
    weak var view: GeneralVCProtocol?
    
    private(set) var selectedMovie: MovieInfo?
    private var isPageLoading = false
    private var movies = [MovieDescription]()
    private var showedMovies: [MovieDescription]?
    
    init() {
        start()
    }
    
    func start() {
        SimpleWebService.shared.getPopularMovies(forPage: 1) { (isSuccess, result) in
            if isSuccess && result != nil {
                self.movies.append(contentsOf: result!)
                self.view?.updateView()
            }
        }
    }
}

extension GeneralViewPresenter: GeneralViewPresenterProtocol {
    func numberOfMovies() -> Int {
        return showedMovies == nil ? movies.count : showedMovies!.count
    }
    func movieFor(rowAtIndex index: Int) -> MovieDescription {
        return showedMovies == nil ? movies[index] : showedMovies![index]
    }
    
    func getNextPage() {
        if isPageLoading || showedMovies != nil {
            return
        }
        isPageLoading = true
        let duePageIndex = movies.count / 20 + 1
        SimpleWebService.shared.getPopularMovies(forPage: duePageIndex) { (isSuccess, result) in
            if isSuccess && result != nil {
                self.movies.append(contentsOf: result!)
                self.view?.updateView()//insertRow(synchronized with the getting the next page via OperationQueue) might be used
            }
            self.isPageLoading = false
        }
    }
    
    func fetchPoster(forIndex index: Int) {
        if let imagePath = self.movies[index].backdrop_path {
            SimpleWebService.shared.getPosterDataForImage(withPath: imagePath) { (success, imageData) in
                self.movies[index].backdropPathImageData = imageData
                self.view?.updateRow(rowIndex: index)//must be synchronized with the getting the next page via OperationQueue
            }
        }
    }
    
    func cancelFetchingPoster(forIndex index: Int) {
        if let imagePath = self.movies[index].backdrop_path {
            SimpleWebService.shared.cancelGettingPosterDataForImage(withPath: imagePath)
        }
    }
    
    func searchFor(text: String) {
        if text.count > 2 {
            showedMovies = movies.filter{$0.title.contains(text)}
            self.view?.updateView()
        } else if let moviesFiltered = showedMovies, moviesFiltered.count != movies.count {
            showedMovies = nil
            self.view?.updateView()
        }
    }
    
    func didSelectRow(_ row: Int) {
        let moviesList = showedMovies == nil ? movies : showedMovies!
        selectedMovie = MovieInfo()
        selectedMovie?.movieId = String(moviesList[row].id)
        selectedMovie?.imageData = moviesList[row].backdropPathImageData
        coordinator?.didSelectRow(row)
    }
}
