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
        popularMoviesVC.viewModel = popularMoviesModel
        return UINavigationController(rootViewController: popularMoviesVC)
    }()
    
    var popularMoviesModel: GeneralViewModel {
        let viewModel = GeneralViewModel()
        viewModel.coordinatorDelegate = self
        return viewModel
    }
    
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
    func didSelectRow(_ row: Int, from controller: UIViewController) {
    
    }
}
