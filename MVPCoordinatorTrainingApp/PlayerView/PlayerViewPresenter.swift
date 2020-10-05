//
//  PlayerViewPresenter.swift
//  MVPCoordinatorTrainingApp
//
//  Created by sdk on 4/29/19.
//  Copyright © 2019 Sdk. All rights reserved.
//

import Foundation

protocol PlayerViewProtocol: AnyObject {
    func loadPlayer()
}

protocol PlayerViewPresenterProtocol {
    var view: PlayerViewProtocol? { get set }
    func getYoutubeId() -> String?
}

class PlayerViewPresenter {
    private var movieId: String?
    private var youtubeID: String?
    weak var view: PlayerViewProtocol?
    
    init(movieId: String, afterMathClosure: @escaping () -> Void) {
        self.movieId = movieId
        start{afterMathClosure()}
    }
    
    func start(afterMathClosure: @escaping () -> Void) {
        if movieId != nil {
            SimpleWebService.shared.getYouTubeVideoId(byMovieID: movieId!) { (isSuccess, result) in
                if isSuccess && result != nil {
                    self.youtubeID = result
                    afterMathClosure()
                }
            }
        }
    }
}

extension PlayerViewPresenter: PlayerViewPresenterProtocol {
    func getYoutubeId() -> String? {
        return youtubeID
    }
}
