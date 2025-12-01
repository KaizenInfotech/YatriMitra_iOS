//
//  SideMenuTableViewCell.swift
//  yatriMitra
//
//  Created by Kaizen Infotech Solutions Private Limited. on 12/06/24.
//

import UIKit

class SideMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        cellView.layer.cornerRadius = 10
        cellView.layer.masksToBounds = true
        // Configure the view for the selected state
    }
    
}
