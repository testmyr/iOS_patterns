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
    @IBOutlet weak var plrVw: YTPlayerView!
    
    
    var viewModel: PlayerViewModelProtocol! {
        didSet {
            viewModel.viewDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let youtubeID = viewModel.getYoutubeId() {
            plrVw.load(withVideoId: youtubeID)
            plrVw.playVideo()
        }
    }
}

extension PlayerViewController: PlayerViewModelViewDelegate {
    func loadPlayer() {
        if plrVw != nil, let youtubeID = viewModel.getYoutubeId() {
            plrVw.load(withVideoId: youtubeID)
            plrVw.playVideo()
        }
    }
}
