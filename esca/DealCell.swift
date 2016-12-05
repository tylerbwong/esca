//
//  DealCell.swift
//  esca
//
//  Created by Tyler Wong on 11/22/16.
//
//

import UIKit

class DealCell: UITableViewCell {
    @IBOutlet weak var dealPercentLabel: UILabel!
    @IBOutlet weak var dealDateLabel: UILabel!
    @IBOutlet weak var dealDescriptionLabel: UILabel!
    @IBOutlet weak var dealAuthorLabel: UILabel!
    @IBOutlet weak var dealTitleLabel: UILabel!
    @IBOutlet weak var dealImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
