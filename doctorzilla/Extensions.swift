//
//  Extensions.swift
//  doctorzilla
//
//  Created by Javier Merchán on 6/6/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation

extension Date {

	func fromDatePickerToString() -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		let strDate = dateFormatter.string(from: self)
		return strDate
	}
	
}
