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
    
    @IBOutlet weak var locationIcon: UIImageView!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var statusButton: UIButton!
    var isCompleted = false {
        didSet {
            updateColorCode()
        }
    }
    var isOverdue = false {
        didSet {
            updateColorCode()
        }
    }
    var hasLocation = false {
        didSet {
            if hasLocation == true {
                locationIcon.image = UIImage(named: "LocationIcon.png")
            } else {
                locationIcon.image = nil
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        detail.text = ""
        locationIcon.image = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Private methods
    
    private func updateColorCode() {
        statusButton.isSelected = isCompleted
        if isCompleted {
            name.textColor = UIColor.gray
            detail.textColor = UIColor.gray
        } else if isOverdue {
            name.textColor = UIColor.red
            detail.textColor = UIColor.red
            statusButton.setTitleColor(UIColor.red, for: .normal)
        } else {
            name.textColor = UIColor.darkText
            detail.textColor = UIColor.darkText
        }
    }
}
