//
//  SessionTableViewCell.swift
//  AnalytiCeM
//
//  Created by Gaël on 21/05/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import UIKit

class SessionTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var activityName: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var duration: UILabel!
    
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
