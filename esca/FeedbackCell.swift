//
//  FeedbackCell.swift
//  esca
//
//  Created by Tyler Wong on 12/15/16.
//
//

import UIKit

class FeedbackCell: UITableViewCell {

    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
