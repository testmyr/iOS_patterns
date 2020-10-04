//
//  DetailedViewPresenter.swift
//  MVPCoordinatorTrainingApp
//
//  Created by sdk on 3/25/19.
//  Copyright © 2019 Sdk. All rights reserved.
//

import Foundation

protocol DetailedVCProtocol: AnyObject {
    func updateView()
    func enableButton()
}

protocol DetailedViewPresenterProtocol {
    var view: DetailedVCProtocol? { get set }
    
    func getGenres() -> String
    func getReleaseDate() -> String
    func getOverview() -> String
    func getTitle() -> String
    func getImageData() -> Data?
    
    func playTrailerClicked()
    func enableButton()
}


class MovieInfo {
    var movieId: String!
    var imageData: Data?
}


class DetailedViewPresenter {
    var movieInfo: MovieInfo!
    var movieDetails: MovieDetailed?
    weak var coordinator: CoordinatorToDetailedProtocol?
    weak var view: DetailedVCProtocol?
    
    init(movieInfo: MovieInfo) {
        self.movieInfo = movieInfo
        self.start()
    }
    
    func start() {
        SimpleWebService.shared.getDetailedDescription(byMovieID: movieInfo.movieId) { (isSuccess, result) in
            if isSuccess && result != nil {
                self.movieDetails = result
                self.view?.updateView()
            }
        }
    }
}

extension DetailedViewPresenter: DetailedViewPresenterProtocol {
    func getGenres() -> String {
        return movieDetails?.genres?.joined(separator: ", ") ?? ""
    }
    func getReleaseDate() -> String {
        return movieDetails?.releaseDate ?? ""
    }
    func getOverview() -> String {
        return movieDetails?.overview ?? ""
    }
    func getTitle() -> String {
        return movieDetails?.title ?? ""
    }
    func getImageData() -> Data? {
        return movieInfo.imageData
    }
    
    func playTrailerClicked() {
        coordinator?.playTrailerClicked(movieId: self.movieInfo.movieId)
    }
    func enableButton() {
        view?.enableButton()
    }
}
