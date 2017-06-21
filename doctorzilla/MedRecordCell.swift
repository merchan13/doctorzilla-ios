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
	
	var rMedrecord: RMedicalRecord!
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func configureCell(_ rMedrecord: RMedicalRecord) {
		self.rMedrecord = rMedrecord
		
		nameLabel.text = self.rMedrecord.lastName.capitalized
		idLabel.text = self.rMedrecord.document
		
		if self.rMedrecord.profilePic.length == 0 {
			thumbImage.image = UIImage(named: "drzilla_imagotipo_color_2")
		} else {
			thumbImage.image = UIImage(data: self.rMedrecord.profilePic as Data)
		}
	}
	
}
