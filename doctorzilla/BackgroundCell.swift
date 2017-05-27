//
//  BackgroundCell.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/26/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit

class BackgroundCell: UICollectionViewCell {
	
	//@IBOutlet weak var nameLabel: UILabel!
	//@IBOutlet weak var idLabel: UILabel!
	
	var background: Background!
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func configureCell(_ background: Background) {
		
		self.background = background
		
		//nameLabel.text = self.medrecord.lastName.capitalized
		//idLabel.text = self.medrecord.document
		
	}
	
}
