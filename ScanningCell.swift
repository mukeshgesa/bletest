//
//  ScanningCell.swift
//  OptixMeter
//
//  Created by gesdevios2 on 30/09/21.
//

import UIKit

class ScanningCell: UITableViewCell {

    @IBOutlet weak var lblBLEDeviceName: UILabel!
    
    @IBOutlet weak var lblBLEAddress: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
