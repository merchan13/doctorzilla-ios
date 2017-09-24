//
//  MedicalRecordCell.swift
//  doctorzilla
//
//  Created by Javier Merchán on 9/20/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit

class MedicalRecordCell: UITableViewCell {

	@IBOutlet weak var profileImage: UIImageView!
	@IBOutlet weak var name: UILabel!
	@IBOutlet weak var document: UILabel!
	
	var rMedicalRecord: RMedicalRecord!
	
	override func awakeFromNib() {
		
        super.awakeFromNib()
    }
	
	func configureCell(rMedicalRecord: RMedicalRecord) {
		
		self.rMedicalRecord = rMedicalRecord
		
		name.text = "\(self.rMedicalRecord.name.capitalized) \(self.rMedicalRecord.lastName.capitalized)"
		
		document.text = self.rMedicalRecord.document
		
		if self.rMedicalRecord.profilePic.length == 0 {
			
			profileImage.image = UIImage(named: "drzilla_imagotipo_color_2")
		}
		else {
			
			profileImage.image = UIImage(data: self.rMedicalRecord.profilePic as Data)
		}
	}
}
