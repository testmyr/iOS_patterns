//
//  Coordinator.swift
//  MVVMCTrainingApp
//
//  Created by sdk on 3/25/19.
//  Copyright © 2019 Sdk. All rights reserved.
//

import Foundation
import UIKit

class Coordinator {
    let window: UIWindow?
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    lazy var rootNavigationController: UINavigationController = {
        let popularMoviesVC: GeneralViewController = storyboard.instantiateViewController(withIdentifier: "GeneralViewController") as! GeneralViewController
        popularMoviesVC.viewModel = popularMoviesViewModel
        return UINavigationController(rootViewController: popularMoviesVC)
    }()
    lazy var popularMoviesViewModel: GeneralViewModel = {
        let viewModel = GeneralViewModel()
        viewModel.coordinatorDelegate = self
        return viewModel
    }()
    var detailedViewModel: DetailedViewModel!
    
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    func start() {
        guard let window = window else {
            return
        }
        window.rootViewController = rootNavigationController
        window.makeKeyAndVisible()
    }
}

extension Coordinator: GeneralViewModelCoordinatorDelegate {
    func didSelectRow(_ row: Int) {
        if let selectedMovie = popularMoviesViewModel.selectedMovie {
            detailedViewModel = DetailedViewModel(movieInfo: selectedMovie)
            detailedViewModel.coordinatorDelegate = self
            if let detailedVC = storyboard.instantiateViewController(withIdentifier: "DetailedViewController") as? DetailedViewController {
                detailedVC.viewModel = detailedViewModel
                detailedVC.title = "Movie Detail"
                self.rootNavigationController.pushViewController(detailedVC, animated: true)
            }
        }
        
    }
}

extension Coordinator: DetailedViewModelCoordinatorDelegate {
    func playTrailerClicked(movieId: String) {
        if let playerVC = self.storyboard.instantiateViewController(withIdentifier: "PlayerViewController") as? PlayerViewController {
            playerVC.title = "Trailer"
            let playerViewModel = PlayerViewModel(movieId: movieId) { [unowned self] in
                DispatchQueue.main.async {
                    self.rootNavigationController.pushViewController(playerVC, animated: true)
                    self.detailedViewModel.enableButton()
                }
            }
            playerViewModel.coordinatorDelegate = self
            playerVC.viewModel = playerViewModel
        }
    }
}
