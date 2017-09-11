//
//  AttachmentCell.swift
//  doctorzilla
//
//  Created by Javier Merchán on 9/10/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit

class AttachmentCell: UITableViewCell {

	@IBOutlet weak var descriptionLabel: UILabel!
	
	var rAttachment: RAttachment!
	
    override func awakeFromNib() {
        super.awakeFromNib()
    }
	
	func configureCell(rAttachment: RAttachment) {
		self.rAttachment = rAttachment
		
		descriptionLabel.text = self.rAttachment.attachmentDescription
	}

}
