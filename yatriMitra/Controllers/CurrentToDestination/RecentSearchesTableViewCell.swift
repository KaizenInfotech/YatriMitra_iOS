//
//  RecentSearchesTableViewCell.swift
//  yatriMitra
//
//  Created by Kaizen Infotech Solutions Private Limited. on 21/08/24.
//

import UIKit

class RecentSearchesTableViewCell: UITableViewCell {

    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var mainLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            // Disable selection highlight
            self.selectionStyle = .none
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            
            // Disable selection highlight
            self.selectionStyle = .none
        }

}
