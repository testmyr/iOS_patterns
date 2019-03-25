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
    
        func start()
        
        func searchFor(text: String)
        
        func didSelectRow(_ row: Int, from controller: UIViewController)
}

protocol GeneralViewModelViewDelegate: AnyObject {
    func updateView()
}

protocol GeneralViewModelCoordinatorDelegate: AnyObject {
    func didSelectRow(_ row: Int, from controller: UIViewController)
}


class GeneralViewModel {
    var movies = [MovieDescription]()
    weak var coordinatorDelegate: GeneralViewModelCoordinatorDelegate?
    weak var viewDelegate: GeneralViewModelViewDelegate?
    
    init() {
        self.start()
    }
}

extension GeneralViewModel: GeneralViewModelProtocol {
    func numberOfMovies() -> Int {
        return movies.count
    }
    func movieFor(rowAtIndex index: Int) -> MovieDescription {
        return movies[index]
    }
    
    func start() {
        SimpleWebService.shared.getPopularMovies(forPage: 1) { (isSuccess, result) in
            if isSuccess && result != nil {
                self.movies.append(contentsOf: result!)
                self.viewDelegate?.updateView()
            }
        }
    }
    
    func searchFor(text: String) {
        //show spinner
        
        // make filtering
        
        //hidespinner
    }
    
    func didSelectRow(_ row: Int, from controller: UIViewController) {
        
    }
}
