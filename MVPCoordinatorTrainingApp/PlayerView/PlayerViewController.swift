//
//  PlayerViewController.swift
//  MVPCoordinatorTrainingApp
//
//  Created by sdk on 4/29/19.
//  Copyright © 2019 Sdk. All rights reserved.
//

import Foundation
import UIKit
import youtube_ios_player_helper

class PlayerViewController: UIViewController {
    @IBOutlet weak var vwPlayer: YTPlayerView!
    
    
    var viewPresenter: PlayerViewPresenterProtocol! {
        didSet {
            viewPresenter.view = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let youtubeID = viewPresenter.getYoutubeId() {
            vwPlayer.load(withVideoId: youtubeID)
            vwPlayer.playVideo()
        }
    }
}

extension PlayerViewController: PlayerViewProtocol {
    func loadPlayer() {
        if vwPlayer != nil, let youtubeID = viewPresenter.getYoutubeId() {
            vwPlayer.load(withVideoId: youtubeID)
            vwPlayer.playVideo()
        }
    }
}
