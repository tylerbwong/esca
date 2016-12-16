//
//  LeaderBoardTVC.swift
//  esca
//
//  Created by Brandon Vo on 12/16/16.
//
//

import UIKit

class LeaderBoardTVC: UITableViewCell {

    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
