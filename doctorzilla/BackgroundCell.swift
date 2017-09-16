//
//  BackgroundCell.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/31/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit

class BackgroundCell: UITableViewCell {
	
	@IBOutlet weak var type: UILabel!
	@IBOutlet weak var descriptionText: UITextView!
	
	var rBackground: RBackground!
	
	override func awakeFromNib() {
		
		super.awakeFromNib()
	}
	
	func configureCell(rBackground: RBackground) {
		
		self.rBackground = rBackground
		
		type.text = self.rBackground.backgroundType
		descriptionText.text = self.rBackground.backgroundDescription
	}
}
