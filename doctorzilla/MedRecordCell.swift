//
//  MedRecordCell.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/23/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit

class MedRecordCell: UICollectionViewCell {

	@IBOutlet weak var thumbImage: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var idLabel: UILabel!
	
	var medrecord: MedicalRecord!
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func configureCell(_ medrecord: MedicalRecord) {
		
		self.medrecord = medrecord
		
		nameLabel.text = self.medrecord.lastName.capitalized
		idLabel.text = self.medrecord.document
		//thumbImage.image = UIImage(...
		
	}
	
}
