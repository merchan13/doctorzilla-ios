//
//  ReportCell.swift
//  doctorzilla
//
//  Created by Javier Merchán on 9/28/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit

class ReportCell: UITableViewCell {

	@IBOutlet weak var reportInfo: UILabel!
	
	var rReport: RReport!
	
    override func awakeFromNib() {
		
        super.awakeFromNib()
    }
	
	func configureCell(rReport: RReport) {
		
		self.rReport = rReport
		
		//reportInfo.text = self.rReport.parsedDate()
		
		reportInfo.text = self.rReport.parsedCreationDate()
	}

}
