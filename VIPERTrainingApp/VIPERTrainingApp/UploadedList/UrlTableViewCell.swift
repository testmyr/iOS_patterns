//
//  UrlTableViewCell.swift
//  VIPERTrainingApp
//
//  Created by sdk on 5/9/19.
//  Copyright © 2019 Sdk. All rights reserved.
//

import UIKit

class UrlTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var lblUrl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
