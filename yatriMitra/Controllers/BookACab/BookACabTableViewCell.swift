//
//  BookACabTableViewCell.swift
//  yatriMitra
//
//  Created by Kaizen Infotech Solutions Private Limited. on 17/06/24.
//

import UIKit

class BookACabTableViewCell: UITableViewCell {

    @IBOutlet weak var bookACabCellView: UIView!
    @IBOutlet weak var rideFareLbl: UILabel!
    @IBOutlet weak var rideExpInMins: UILabel!
    @IBOutlet weak var rideTypeImg: UIImageView!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var fareCardBtn: UIButton!
    @IBOutlet weak var rideTypeLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
//        bookACabCellView.layer.cornerRadius=10
//        bookACabCellView.layer.masksToBounds=true
//        if selected {
//            bookACabCellView.backgroundColor = UIColor(red: 255/255, green: 250/255, blue: 141/255, alpha: 1.0)
//        } else {
//            bookACabCellView.backgroundColor = .white
//        }
        // Configure the view for the selected state
    }

}
