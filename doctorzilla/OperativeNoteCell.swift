//
//  OperativeNoteCell.swift
//  doctorzilla
//
//  Created by Javier Merchán on 9/6/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit

class OperativeNoteCell: UITableViewCell {

	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	
	var rOperativeNote: ROperativeNote!
	
    override func awakeFromNib() {
        super.awakeFromNib()
    }

	func configureCell(rOperativeNote: ROperativeNote) {
		self.rOperativeNote = rOperativeNote
		
		dateLabel.text = self.rOperativeNote.parsedCreationDate()
		descriptionLabel.text = self.rOperativeNote.opNoteDescription
	}

}
