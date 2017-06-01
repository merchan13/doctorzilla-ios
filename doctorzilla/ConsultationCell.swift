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
	
	var consultation: Consultation!
	
    override func awakeFromNib() {
        super.awakeFromNib()
    }
	
	func updateUI(consultation: Consultation) {
	
		self.consultation = consultation
		
		dateLabel.text = self.consultation.parsedConsultationDate()
		reasonLabel.text = self.consultation.reason
		
	}

}
