//
//  UploadedListVC.swift
//  VIPERTrainingApp
//
//  Created by sdk on 5/8/19.
//  Copyright © 2019 Sdk. All rights reserved.
//

import Foundation
import UIKit

class UploadedListVC: UITableViewController {
    
    //UploadedListViewProtocol
    var presenter: UploadedListViewToPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Uploaded List"
    }
    
    
    // MARK: UITableViewController
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.numberOfItems(inSection: section) ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UrlTableViewCell", for: indexPath) as? UrlTableViewCell
            else { fatalError("Unexpected cell in collection view") }
        if let item = presenter?.getItem(atIndexPath: indexPath) {
            cell.lblUrl.text = item.url
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var cellHeight: CGFloat
        let height = tableView.frame.height
        let width = tableView.frame.width
        let coefficient: CGFloat = 0.15
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

extension UploadedListVC: UploadedListViewProtocol {
    
    func beginUpdates() {
        tableView.beginUpdates()
    }
    func insertRow(at indexPath: IndexPath) {
        tableView.insertRows(at: [indexPath], with: .fade)
    }
    func deleteRow(at indexPath: IndexPath) {
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    func updateRow(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        tableView.moveRow(at: indexPath, to: newIndexPath)
    }
    func endUpdates() {
        tableView.endUpdates()
    }
}
