//
//  DetailedViewModel.swift
//  MVVMCTrainingApp
//
//  Created by sdk on 3/25/19.
//  Copyright © 2019 Sdk. All rights reserved.
//

import Foundation

class MovieInfo {
    var movieId: String!
    var imageData: Data?
}

protocol DetailedViewModelProtocol {
    var viewDelegate: DetailedViewModelViewDelegate? { get set }
    
    func getGenres() -> String
    func getReleaseDate() -> String
    func getOverview() -> String
    func getTitle() -> String
    func getImageData() -> Data?
    
    func playTrailerClicked()
    func enableButton()
}

protocol DetailedViewModelViewDelegate: AnyObject {
    func updateView()
    func enableButton()
}

protocol DetailedViewModelCoordinatorDelegate: AnyObject {
    func playTrailerClicked(movieId: String)
}


class DetailedViewModel {
    var movieInfo: MovieInfo!
    var movieDetails: MovieDetailed?
    weak var coordinatorDelegate: DetailedViewModelCoordinatorDelegate?
    weak var viewDelegate: DetailedViewModelViewDelegate?
    
    init(movieInfo: MovieInfo) {
        self.movieInfo = movieInfo
        self.start()
    }
    
    func start() {
        SimpleWebService.shared.getDetailedDescription(byMovieID: movieInfo.movieId) { (isSuccess, result) in
            if isSuccess && result != nil {
                self.movieDetails = result
                self.viewDelegate?.updateView()
            }
        }
    }
}

extension DetailedViewModel: DetailedViewModelProtocol {
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
        coordinatorDelegate?.playTrailerClicked(movieId: self.movieInfo.movieId)
    }
    func enableButton() {
        viewDelegate?.enableButton()
    }
}
