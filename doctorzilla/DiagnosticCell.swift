//
//  DiagnosticCell.swift
//  doctorzilla
//
//  Created by Javier Merchán on 9/15/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit

class DiagnosticCell: UITableViewCell {

	@IBOutlet weak var createdAt: UILabel!
	@IBOutlet weak var descriptionText: UITextView!
	
	var rDiagnostic: RDiagnostic!
	
	override func awakeFromNib() {
		
		super.awakeFromNib()
	}
	
	func configureCell(rDiagnostic: RDiagnostic) {
		
		self.rDiagnostic = rDiagnostic
		
		createdAt.text = self.rDiagnostic.parsedDate()
		descriptionText.text = self.rDiagnostic.diagnosticDescription
	}

}
