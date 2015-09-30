//
//  ShowSingleAdCell.swift
//  Classify
//
//  Created by Matti Heikkinen on 9/18/15.
//  Copyright (c) 2015 FV iMAGINATION. All rights reserved.
//

import Foundation
import UIKit

class ReviewCell: UITableViewCell {
    
    
    @IBOutlet weak var contentText: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var markLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
