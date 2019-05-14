//
//  GeneralViewModel.swift
//  MVVMCTrainingApp
//
//  Created by sdk on 3/25/19.
//  Copyright © 2019 Sdk. All rights reserved.
//

import Foundation
import UIKit

protocol GeneralViewModelProtocol {
    var viewDelegate: GeneralViewModelViewDelegate? { get set }
    
    func numberOfMovies() -> Int
    func movieFor(rowAtIndex index: Int) -> MovieDescription
    func getNextPage()
    func fetchPoster(forIndex index: Int)
    func cancelFetchingPoster(forIndex index: Int)
    
    func searchFor(text: String)
    
    func didSelectRow(_ row: Int)
}

protocol GeneralViewModelViewDelegate: AnyObject {
    func updateView()
    func updateRow(rowIndex: Int)
    //spinner better rewrite as setting state by using an enum
    func showSpinner()
    func hideSpinner()
}

protocol GeneralViewModelCoordinatorDelegate: AnyObject {
    func didSelectRow(_ row: Int)
}


class GeneralViewModel {
    var isPageLoading = false
    var movies = [MovieDescription]()
    var showedMovies: [MovieDescription]?
    weak var coordinatorDelegate: GeneralViewModelCoordinatorDelegate?
    weak var viewDelegate: GeneralViewModelViewDelegate?
    
    var selectedMovie: MovieInfo?
    
    init() {
        start()
    }
    
    func start() {
        SimpleWebService.shared.getPopularMovies(forPage: 1) { (isSuccess, result) in
            if isSuccess && result != nil {
                self.movies.append(contentsOf: result!)
                self.viewDelegate?.updateView()
            }
        }
    }
}

extension GeneralViewModel: GeneralViewModelProtocol {
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
        let downloadGroup = DispatchGroup()
        downloadGroup.enter()
        let duePageIndex = movies.count / 20 + 1
        SimpleWebService.shared.getPopularMovies(forPage: duePageIndex) { (isSuccess, result) in
            if isSuccess && result != nil {
                self.movies.append(contentsOf: result!)
                self.viewDelegate?.updateView()
            }
            self.isPageLoading = false
        }
    }
    
    func fetchPoster(forIndex index: Int) {
        if let imagePath = self.movies[index].backdrop_path {
            SimpleWebService.shared.getPosterDataForImage(withPath: imagePath) { (success, imageData) in
                self.movies[index].backdropPathImageData = imageData
                self.viewDelegate?.updateRow(rowIndex: index)
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
            self.viewDelegate?.updateView()
        } else if let moviesFiltered = showedMovies, moviesFiltered.count != movies.count {
            showedMovies = nil
            self.viewDelegate?.updateView()
        }
    }
    
    func didSelectRow(_ row: Int) {
        let moviesList = showedMovies == nil ? movies : showedMovies!
        selectedMovie = MovieInfo()
        selectedMovie?.movieId = String(moviesList[row].id)
        selectedMovie?.imageData = moviesList[row].backdropPathImageData
        coordinatorDelegate?.didSelectRow(row)
    }
}
