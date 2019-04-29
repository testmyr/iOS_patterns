//
//  DetailedViewController.swift
//  MVVMCTrainingApp
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
    //used only for avoiding errors/warnings in IB
    @IBOutlet weak var cnstrHeightIB: NSLayoutConstraint!
    
    
    var viewModel: DetailedViewModelProtocol! {
        didSet {
            viewModel.viewDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrHeightIB.isActive = false
        updateView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @IBAction func btnWatchTrailerClicked(_ sender: Any) {
        viewModel.playTrailerClicked()
        bntWatchTrailer.isUserInteractionEnabled = false
    }
    
}

extension DetailedViewController: DetailedViewModelViewDelegate {
    func enableButton() {
        bntWatchTrailer.isUserInteractionEnabled = true
    }
    func updateView() {
        DispatchQueue.main.async {
            if let imgData = self.viewModel.getImageData() {
                self.imgPoster.image = UIImage(data: imgData)
            }
            self.lblTitle.text = self.viewModel.getTitle()
            self.lblGenres.text = self.viewModel.getGenres()
            self.lblDate.text = self.viewModel.getReleaseDate()
            self.lblOverview.text = self.viewModel.getOverview()
        }
    }
}
