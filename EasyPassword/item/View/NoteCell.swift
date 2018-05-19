//
//  NoteCell.swift
//  EasyPassword
//
//  Created by libowen on 2018/1/3.
//  Copyright © 2018年 libowen. All rights reserved.
//

import UIKit

class NoteCell: UITableViewCell {
    
    @IBOutlet weak var customTextLabel: UILabel!
    @IBOutlet weak var customDetailTextLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
