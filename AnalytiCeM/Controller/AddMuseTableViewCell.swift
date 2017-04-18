//
//  AddMuseTableViewCell.swift
//  AnalytiCeM
//
//  Created by Gaël on 19/04/2017.
//  Copyright © 2017 Polyech. All rights reserved.
//

import UIKit

class AddMuseTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlet
    
    @IBOutlet var labelName: UILabel!
    @IBOutlet var btnAdd: UIButton!
    
    // MARK: - View

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
