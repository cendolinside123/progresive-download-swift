//
//  songCell.swift
//  test progresive download
//
//  Created by Mac on 06/04/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit

class songCell: UITableViewCell {

    @IBOutlet weak var txtNmLagu: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setText(_ nmLagu:String){
        txtNmLagu.text = nmLagu
    }
    
}
