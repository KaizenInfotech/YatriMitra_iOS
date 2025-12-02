//
//  RideHistoryTableViewCell.swift
//  yatriMitra
//
//  Created by Kaizen Infotech Solutions Private Limited. on 18/06/24.
//

import UIKit

class RideHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var rideHistoryTblViewCell: UIView!
    @IBOutlet weak var rideTypeLbl: UILabel!
    @IBOutlet weak var driverImage: UIImageView!
    @IBOutlet weak var rideDate: UILabel!
    @IBOutlet weak var rideTypeImg: UIImageView!
    @IBOutlet weak var sourceaddress: UITextField!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var approx_Fare: UILabel!
    @IBOutlet weak var rideStatusLbl: UILabel!
    @IBOutlet weak var distinationaddress: UITextField!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
