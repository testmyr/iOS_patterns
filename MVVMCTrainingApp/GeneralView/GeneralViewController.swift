//
//  GeneralViewController.swift
//  MVVMCTrainingApp
//
//  Created by sdk on 3/25/19.
//  Copyright © 2019 Sdk. All rights reserved.
//

import Foundation
import UIKit

class GeneralViewController: UIViewController {
    @IBOutlet weak var tblPopularMovies: UITableView!
    @IBOutlet weak var srchBar: UISearchBar!
    
    var viewModel: GeneralViewModelProtocol! {
        didSet {
            viewModel.viewDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblPopularMovies.delegate = self
        tblPopularMovies.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            self.view.endEditing(false)
        }
        super.touchesBegan(touches, with: event)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}


extension GeneralViewController: GeneralViewModelViewDelegate {
    func updateView() {
        if let tblVw = self.tblPopularMovies {
            tblVw.reloadData()
        }
    }
}

extension GeneralViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfMovies()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let popularMovie = viewModel.movieFor(rowAtIndex: indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: "popularMovieCell") as! GeneralViewCell
        cell.lblMovieName.text = popularMovie.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRow(indexPath.row, from: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var cellHeight: CGFloat
        let height = tableView.frame.height
        let width = tableView.frame.width
        let coefficient: CGFloat = 0.3
        if UIDevice.current.userInterfaceIdiom == .phone {
            if width > height {
                cellHeight = height * coefficient
            } else {
                cellHeight = width * coefficient * CGFloat(1.2)
            }
        } else {
            return 50//to do
        }
        return cellHeight
    }
}
