//
//  Coordinator.swift
//  MVPCoordinatorTrainingApp
//
//  Created by sdk on 3/25/19.
//  Copyright © 2019 Sdk. All rights reserved.
//

import Foundation
import UIKit

protocol DetailedVPToCordinator: AnyObject {
    func enableButton()
}


protocol CoordinatorToGeneralProtocol: AnyObject {
    func didSelectRow(_ row: Int)
}
protocol CoordinatorToDetailedProtocol: AnyObject {
    func playTrailerClicked(movieId: String)
}

class Coordinator {
    let window: UIWindow?
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    lazy var rootNavigationController: UINavigationController = {
        let popularMoviesVC: GeneralViewController = storyboard.instantiateViewController(withIdentifier: "GeneralViewController") as! GeneralViewController
        popularMoviesVC.viewPresenter = popularMoviesViewPresenter
        return UINavigationController(rootViewController: popularMoviesVC)
    }()
    lazy var popularMoviesViewPresenter: GeneralViewPresenter = {
        let viewPresenter = GeneralViewPresenter()
        viewPresenter.coordinator = self
        return viewPresenter
    }()
    weak var detailedVP: DetailedVPToCordinator?
    
    
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

extension Coordinator: CoordinatorToGeneralProtocol {
    func didSelectRow(_ row: Int) {
        if let selectedMovie = popularMoviesViewPresenter.selectedMovie {
            if let detailedVC = storyboard.instantiateViewController(withIdentifier: "DetailedViewController") as? DetailedViewController {
                let detailedVP = DetailedViewPresenter(movieInfo: selectedMovie)
                detailedVP.coordinator = self
                detailedVC.viewPresenter = detailedVP
                detailedVC.title = "Movie Detail"
                self.rootNavigationController.pushViewController(detailedVC, animated: true)
            }
        }
        
    }
}

extension Coordinator: CoordinatorToDetailedProtocol {
    func playTrailerClicked(movieId: String) {
        if let playerVC = self.storyboard.instantiateViewController(withIdentifier: "PlayerViewController") as? PlayerViewController {
            playerVC.title = "Trailer"
            let playerViewPresenter = PlayerViewPresenter(movieId: movieId) { [unowned self] in
                DispatchQueue.main.async {
                    self.rootNavigationController.pushViewController(playerVC, animated: true)
                    self.detailedVP?.enableButton()
                    assert(self.detailedVP == nil)
                }
            }
            playerVC.viewPresenter = playerViewPresenter
        }
    }
}