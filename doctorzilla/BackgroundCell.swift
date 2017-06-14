//
//  BackgroundCell.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/31/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit

class BackgroundCell: UICollectionViewCell {
	
	@IBOutlet weak var typeLabel: UILabel!
	@IBOutlet weak var descriptionTextView: UITextView!
	
	var background: Background!
	var rBackground: RBackground!
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func configureCell(_ background: Background) {
		self.background = background
		typeLabel.text = self.background.backgroundType
		descriptionTextView.text = self.background.backgroundDescription
	}
	
	func configureCell(_ rBackground: RBackground) {
		self.rBackground = rBackground
		typeLabel.text = self.rBackground.backgroundType
		descriptionTextView.text = self.rBackground.backgroundDescription
	}
}
