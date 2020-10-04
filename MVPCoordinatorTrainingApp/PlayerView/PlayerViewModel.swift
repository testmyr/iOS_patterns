//
//  PlayerViewModel.swift
//  MVPCoordinatorTrainingApp
//
//  Created by sdk on 4/29/19.
//  Copyright © 2019 Sdk. All rights reserved.
//

import Foundation

class PlayerViewModel {
    private var movieId: String?
    private var youtubeID: String?
    weak var viewDelegate: PlayerViewModelViewDelegate?
    
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

extension PlayerViewModel: PlayerViewModelProtocol {
    func getYoutubeId() -> String? {
        return youtubeID
    }
}

protocol PlayerViewModelProtocol {
    var viewDelegate: PlayerViewModelViewDelegate? { get set }
    func getYoutubeId() -> String?
}


protocol PlayerViewModelViewDelegate: AnyObject {
    func loadPlayer()
}
