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
        srchBar.delegate = self
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
    
    func showAlertWithMessage(message: String, cancelled: @escaping ()->Void){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {action in
            cancelled()
        })
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
}

extension GeneralViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchText = searchBar.text {
            viewModel.searchFor(text: searchText)
        }
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(false)
//        if let searchText = searchBar.text {
//            viewModel.searchFor(text: searchText)
//        }
    }
}


extension GeneralViewController: GeneralViewModelViewDelegate {
    func updateView() {
        if let tblVw = self.tblPopularMovies {
            DispatchQueue.main.async {
                tblVw.reloadData()
            }
        }
    }
    func updateRow(rowIndex: Int) {
        DispatchQueue.main.async {
            let indexPath = IndexPath(item: rowIndex, section: 0)
            self.tblPopularMovies.reloadRows(at: [indexPath], with: .fade)
        }
    }
    func showSpinner() {
        LLSpinner.spin(style: .whiteLarge) {
            self.showAlertWithMessage(message: "Be patient!", cancelled: {})
        }
    }

    func hideSpinner() {
        LLSpinner.stop()
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
        if indexPath.row > viewModel.numberOfMovies() - 10 {
            viewModel.getNextPage()
        }
        if let imgData = popularMovie.backdropPathImageData {
            cell.imgMoviePoster.image = UIImage(data: imgData)
        } else {            
            cell.imgMoviePoster.image = nil
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRow(indexPath.row)
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
