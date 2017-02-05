//
//  ItemTableViewCell.swift
//  FastList
//
//  Created by Agustinus Sutandi on 1/29/17.
//  Copyright © 2017 FastListTeam. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var name: UIButton!
    var indexPath: IndexPath = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Actions
    
    @IBAction func checkOffItem(_ sender: UIButton) {
    }
    

}