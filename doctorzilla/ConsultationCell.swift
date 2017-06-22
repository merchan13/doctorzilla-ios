//
//  ConsultationCell.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/30/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit

class ConsultationCell: UITableViewCell {

	@IBOutlet weak var reasonLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	
	var rConsultation: RConsultation!
	
    override func awakeFromNib() {
        super.awakeFromNib()
    }
	
	func configureCell(rConsultation: RConsultation) {
		self.rConsultation = rConsultation
		
		dateLabel.text = self.rConsultation.parsedConsultationDate()
		reasonLabel.text = self.rConsultation.reason?.reasonDescription
	}

}
