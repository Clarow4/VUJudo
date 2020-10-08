//
//  LeaderboardCell.swift
//  VUJudo1
//
//  Created by Christina LaRow on 7/16/20.
//  Copyright © 2020 Christina LaRow. All rights reserved.
//

import UIKit

class LeaderboardCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBOutlet weak var rankText: UILabel!
    @IBOutlet weak var scoreText: UILabel!
    
}
