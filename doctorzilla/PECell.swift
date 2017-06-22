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
	
	var rPhysicalExam: RPhysicalExam!
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func configureCell(_ rPhysicalExam: RPhysicalExam) {
		
		self.rPhysicalExam = rPhysicalExam
		
		typeLabel.text = self.rPhysicalExam.examType
		observationTextView.text = self.rPhysicalExam.observation
	}
	
}
