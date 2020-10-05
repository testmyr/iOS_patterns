//
//  DetailedViewController.swift
//  MVPCoordinatorTrainingApp
//
//  Created by sdk on 3/25/19.
//  Copyright © 2019 Sdk. All rights reserved.
//

import Foundation
import UIKit

class DetailedViewController: UIViewController {
    @IBOutlet weak var imgPoster: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var bntWatchTrailer: UIButton!
    
    @IBOutlet weak var lblGenres: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblOverview: UILabel!
    
    @IBOutlet weak var scrllvw: UIScrollView!
    
    
    var viewPresenter: DetailedViewPresenterProtocol! {
        didSet {
            viewPresenter.view = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @IBAction func btnWatchTrailerClicked(_ sender: Any) {
        viewPresenter.playTrailerClicked()
        bntWatchTrailer.isUserInteractionEnabled = false
    }
    
}

extension DetailedViewController: DetailedVCProtocol {
    func enableButton() {
        bntWatchTrailer.isUserInteractionEnabled = true
    }
    func updateView() {
        DispatchQueue.main.async {
            if let imgData = self.viewPresenter.getImageData() {
                self.imgPoster.image = UIImage(data: imgData)
            }
            self.lblTitle.text = self.viewPresenter.getTitle()
            self.lblGenres.text = self.viewPresenter.getGenres()
            self.lblDate.text = self.viewPresenter.getReleaseDate()
            self.lblOverview.text = self.viewPresenter.getOverview()
        }
    }
}
