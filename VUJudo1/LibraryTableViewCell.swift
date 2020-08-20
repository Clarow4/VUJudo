//
//  LibraryTableViewCell.swift
//  VUJudo1
//
//  Created by Christina LaRow on 5/3/20.
//  Copyright © 2020 Christina LaRow. All rights reserved.
//

import UIKit

class LibraryTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var wazaName: UILabel!
    
    @IBOutlet weak var plusSign: UIImageView!
    @IBOutlet weak var plusButton: UIButton!
}




