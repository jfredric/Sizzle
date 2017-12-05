//
//  RecipeStepTableViewCell.swift
//  Sizzle
//
//  Created by Joshua Fredrickson on 12/4/17.
//  Copyright © 2017 Joshua Fredrickson. All rights reserved.
//

import UIKit

class RecipeStepTableViewCell: UITableViewCell {

    @IBOutlet weak var instructionsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
