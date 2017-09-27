//
//  ExamCell.swift
//  doctorzilla
//
//  Created by Javier Merchán on 9/27/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit

class ExamCell: UITableViewCell {

	@IBOutlet weak var examType: UILabel!
	@IBOutlet weak var observation: UITextView!
	
	var rExam: RPhysicalExam!
	
	override func awakeFromNib() {
		
		super.awakeFromNib()
	}
	
	func configureCell(rExam: RPhysicalExam) {
		
		self.rExam = rExam
		
		examType.text = self.rExam.examType
		observation.text = self.rExam.observation
	}
}
