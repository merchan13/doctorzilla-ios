//
//  RealmObjects.swift
//  doctorzilla
//
//  Created by Javier Merchán on 6/7/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation
import RealmSwift

// [ BACKGROUND ]
class RBackground: Object {
	private dynamic var _id = 0
	private dynamic var _backgroundType = ""
	private dynamic var _backgroundDescription = ""
	
	// Belongs to:
	private let consultations = LinkingObjects(fromType: RConsultation.self, property: "backgrounds")
	
	var id: Int {
		get { return _id }
		set { _id = (newValue) }
	}
	
	var backgroundType: String {
		get { return _backgroundType }
		set { _backgroundType = (newValue) }
	}
	
	var backgroundDescription: String {
		get { return _backgroundDescription }
		set { _backgroundDescription = (newValue) }
	}
	
	var consultation: RConsultation {
		return self.consultations.first!
	}
	
	override static func primaryKey() -> String? {
		return "_id"
	}
}

// CONSULTATION
class RConsultation: Object {
	private dynamic var _id = 0
	
	var id: Int {
		get { return _id }
		set { _id = (newValue) }
	}
	
	override static func primaryKey() -> String? {
		return "_id"
	}
}

// [ INSURANCE ]
class RInsurance: Object {
	private dynamic var _id = 0
	private dynamic var _name = ""
	
	// Has many:
	let medrecords = List<RMedicalRecord>()
	
	var id: Int {
		get { return _id }
		set { _id = (newValue) }
	}
	
	var name: String {
		get { return _name }
		set { _name = (newValue) }
	}
	
	override static func primaryKey() -> String? {
		return "_id"
	}
}

// [ MEDICAL RECORD ]
class RMedicalRecord: Object {
	private dynamic var _id = 0
	private dynamic var _document = ""
	private dynamic var _name = ""
	private dynamic var _lastName = ""
	private dynamic var _birthday = ""
	private dynamic var _firstConsultation = ""
	private dynamic var _email = ""
	private dynamic var _phone = ""
	private dynamic var _cellphone = ""
	private dynamic var _address = ""
	private dynamic var _gender = ""
	private dynamic var _referredBy = ""
	private dynamic var _height = 0
	private dynamic var _weight = 0
	private dynamic var _pressure_d = ""
	private dynamic var _pressure_s = ""
	private dynamic var _lastUpdate = ""
	
	// Has many:
	private let backgrounds = List<RBackground>()
	
	// Belongs to:
	private let users = LinkingObjects(fromType: RUser.self, property: "medrecords")
	private let occupations = LinkingObjects(fromType: ROccupation.self, property: "medrecords")
	private let insurances = LinkingObjects(fromType: RInsurance.self, property: "medrecords")
	
	var id: Int {
		get { return self._id }
		set { self._id = (newValue) }
	}
	
	var document: String {
		get { return self._document }
		set { self._document = (newValue) }
	}
	
	var name: String {
		get { return self._name }
		set { self._name = (newValue) }
	}
	
	var lastName: String {
		get { return self._lastName }
		set { self._lastName = (newValue) }
	}
	
	var birthday: String {
		get { return self._birthday }
		set { self._birthday = (newValue) }
	}
	
	var firstConsultation: String {
		get { return self._firstConsultation }
		set { self._firstConsultation = (newValue) }
	}
	
	var email: String {
		get { return self._email }
		set { self._email = (newValue) }
	}
	
	var phone: String {
		get { return self._phone }
		set { self._phone = (newValue) }
	}
	
	var cellphone: String {
		get { return self._cellphone }
		set { self._cellphone = (newValue) }
	}
	
	var address: String {
		get { return self._address }
		set { self._address = (newValue) }
	}
	
	var gender: String {
		get { return self._gender }
		set { self._gender = (newValue) }
	}
	
	var referredBy: String {
		get { return self._referredBy }
		set { self._referredBy = (newValue) }
	}
	
	var height: Int {
		get { return self._height }
		set { self._height = (newValue) }
	}
	
	var weight: Int {
		get { return self._weight }
		set { self._weight = (newValue) }
	}
	
	var pressure_d: String {
		get { return self._pressure_d }
		set { self._pressure_d = (newValue) }
	}
	
	var pressure_s: String {
		get { return self._pressure_s }
		set { self._pressure_s = (newValue) }
	}
	
	var lastUpdate: String {
		get { return self._lastUpdate }
		set { self._lastUpdate = (newValue) }
	}
	
	var user: RUser {
		return self.users.first!
	}
	
	var occupation: ROccupation {
		return self.occupations.first!
	}
	
	var insurance: RInsurance {
		return self.insurances.first!
	}
	
	override static func primaryKey() -> String? {
		return "_id"
	}
}

// [ OCCUPATION ]
class ROccupation: Object {
	private dynamic var _id = 0
	private dynamic var _name = ""
	
	// Has many:
	let medrecords = List<RMedicalRecord>()
	
	var id: Int {
		get { return _id }
		set { _id = (newValue) }
	}
	
	var name: String {
		get { return _name }
		set { _name = (newValue) }
	}
	
	override static func primaryKey() -> String? {
		return "_id"
	}
}

// PHYSICAL EXAM
class RPhysicalExam: Object {
	private dynamic var _id = 0
	
	var id: Int {
		get { return _id }
		set { _id = (newValue) }
	}
	
	override static func primaryKey() -> String? {
		return "_id"
	}
}

// [ USER ]
class RUser: Object {
	private dynamic var _id = 0
	private dynamic var _email = ""
	private dynamic var _password = ""
	
	// Has many:
	let medrecords = List<RMedicalRecord>()
	
	var id: Int {
		get { return _id }
		set { _id = (newValue) }
	}
	
	var email: String {
		get { return _email }
		set { _email = (newValue) }
	}
	
	var password: String {
		get { return _password }
		set { _password = (newValue) }
	}
	
	override static func primaryKey() -> String? {
		return "_id"
	}
}


















