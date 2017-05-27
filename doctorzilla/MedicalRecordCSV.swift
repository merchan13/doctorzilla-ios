//
//  MedicalRecordCSV.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/24/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation

class MedicalRecordCSV {

	func create(csvText: String) {
		
		if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
			
			let path = dir.appendingPathComponent(RECORDS_CSV)
			
			do {
				try csvText.write(to: path, atomically: false, encoding: String.Encoding.utf8)
			}
			catch {
				print("Failed to create file")
				print("\(error)")
			}
			
		}
		
	}

}
