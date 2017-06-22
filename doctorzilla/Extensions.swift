//
//  Extensions.swift
//  doctorzilla
//
//  Created by Javier Merchán on 6/6/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation
import UIKit

extension Date {

	var fromDatePickerToString: String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		let strDate = dateFormatter.string(from: self)
		return strDate
	}
	
	var iso8601: String {
		return Formatter.iso8601.string(from: self)
	}
	
}

extension String {
	
	var dateFromISO8601: Date? {
		return Formatter.iso8601.date(from: self)
	}
	
}

extension Formatter {
	
	static let iso8601: DateFormatter = {
		let formatter = DateFormatter()
		formatter.calendar = Calendar(identifier: .iso8601)
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.timeZone = TimeZone(secondsFromGMT: 0)
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssX"
		return formatter
	}()
	
}

extension UIImage {
	
	enum JPEGQuality: CGFloat {
		case lowest		= 0
		case low		= 0.25
		case medium		= 0.5
		case high		= 0.75
		case highest	= 1
	}
	
	var png: Data? { return UIImagePNGRepresentation(self) }
	
	func jpeg(_ quality: JPEGQuality) -> Data? {
		return UIImageJPEGRepresentation(self, quality.rawValue)
	}
	
}

