//
//  PECell.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/31/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit

class PECell: UICollectionViewCell {
    
	@IBOutlet weak var typeLabel: UILabel!
	@IBOutlet weak var observationTextView: UITextView!
	
	var physicalExam: PhysicalExam!
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func configureCell(_ physicalExam: PhysicalExam) {
		
		self.physicalExam = physicalExam
		
		typeLabel.text = self.physicalExam.PEType
		observationTextView.text = self.physicalExam.observation
		
	}
	
}
