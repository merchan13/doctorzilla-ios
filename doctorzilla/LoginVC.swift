//
//  LoginVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/10/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift
import ReachabilitySwift

class LoginVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
	
	let user = User()
	var rUser = RUser()
	let realm = try! Realm()
	
	var networkConnection = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		print("\nPath to Realm file: " + realm.configuration.fileURL!.absoluteString)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ReachabilityManager.shared.addListener(listener: self)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		ReachabilityManager.shared.removeListener(listener: self)
	}
	
	@IBAction func loginButtonTapped(_ sender: Any) {
		let userEmail = emailTextField.text!
		let userPassword = passwordTextField.text!
		
		DispatchQueue.main.async {
			self.activityIndicatorView.startAnimating()
		}
		
		checkNetwork()
		
		if networkConnection {
			user.signIn(email: userEmail, password: userPassword) {
				if AuthToken.sharedInstance.token != "" && AuthToken.sharedInstance.token != nil {
					try! self.realm.write {
						if self.realm.object(ofType: RUser.self, forPrimaryKey: 1) == nil {
							let rUser = RUser()
							rUser.id = 1
							rUser.email = self.user.email
							rUser.password = self.user.password
							self.realm.add(rUser, update: true)
							self.rUser = rUser
						}
					}
					
					self.dowloadOccupations {
						self.dowloadInsurances {
							self.dowloadDiagnostics {
								self.dowloadReasons {
									
									self.dowloadRecords {
										DispatchQueue.main.async {
											self.activityIndicatorView.stopAnimating()
										}
										self.downloadConsultations {
											/*
											self.downloadPlans{
											self.downloadOperativeNotes()
											}
											*/
										}
										//self.downloadPrescriptions()
										//self.downloadAttachments()
										self.performSegue(withIdentifier: "DashboardVC", sender: self.user)
									}
								}
							}
						}
					}
				} else {
					DispatchQueue.main.async {
						self.activityIndicatorView.stopAnimating()
						self.loginAlert()
					}
				}
			}
		} else {
			if let userInRealm = self.realm.object(ofType: RUser.self, forPrimaryKey: 1) {
				self.rUser = userInRealm
			}
			if self.rUser.signIn(email: userEmail, password: userPassword) {
				DispatchQueue.main.async {
					self.activityIndicatorView.stopAnimating()
					
					
					/*
					
						PROBAR CONSULTAS REALM
					
					*/
					
					// Cómo leer fecha guarada en realm en UTC iso8601
					let veras = self.realm.object(ofType: RMedicalRecord.self, forPrimaryKey: 5)?.lastUpdate.iso8601
					print("FECHA DE REALM (con iso8601) \(veras!)\n\n")
					
					// Obtener records MAS recientes
					let masActuales = self.realm.objects(RMedicalRecord.self).filter("lastUpdate > %@", "2017-07-01T02:20:42Z".dateFromISO8601!)
					print(masActuales)
					
					//Obtener el record MAS reciente
					let records = self.realm.objects(RMedicalRecord.self)
					let actDate = records.max(ofProperty: "lastUpdate") as Date?
					let dataString = actDate?.iso8601
					print(dataString!)
					
					
					
					
					
					
					
					
					self.performSegue(withIdentifier: "DashboardVC", sender: self.rUser)
				}
			} else {
				DispatchQueue.main.async {
					self.activityIndicatorView.stopAnimating()
					self.loginAlert()
				}
			}
		}
	}
	
	func dowloadOccupations(completed: @escaping DownloadComplete) {
		let url = "\(URL_BASE)\(URL_OCCUPATIONS)"
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		Alamofire.request(url, method: .get, headers: headers).responseJSON { response in
			if let occupationDictionary = response.result.value as? [Dictionary<String, AnyObject>]{
				
				try! self.realm.write {
					for occupation in occupationDictionary {
						let rOccupation = ROccupation()
						if let occupationId = occupation["id"] as? Int {
							rOccupation.id = occupationId
						}
						if let occupationName = occupation["name"] as? String {
							rOccupation.name = occupationName
						}
						
						self.realm.add(rOccupation, update: true)
					}
				}
			}
			completed()
		}
	}
	
	func dowloadInsurances(completed: @escaping DownloadComplete) {
		let url = "\(URL_BASE)\(URL_INSURANCES)"
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		Alamofire.request(url, method: .get, headers: headers).responseJSON { response in
			if let insuranceDictionary = response.result.value as? [Dictionary<String, AnyObject>]{
				
				try! self.realm.write {
					for insurance in insuranceDictionary {
						let rInsurance = RInsurance()
						if let insuranceId = insurance["id"] as? Int {
							rInsurance.id = insuranceId
						}
						if let insuranceName = insurance["name"] as? String {
							rInsurance.name = insuranceName
						}
						
						self.realm.add(rInsurance, update: true)
					}
				}
			}
			completed()
		}
	}
	
	func dowloadDiagnostics(completed: @escaping DownloadComplete) {
		let url = "\(URL_BASE)\(URL_DIAGNOSTICS)"
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		Alamofire.request(url, method: .get, headers: headers).responseJSON { response in
			if let diagnosticDictionary = response.result.value as? [Dictionary<String, AnyObject>]{
				
				try! self.realm.write {
					for diagnostic in diagnosticDictionary {
						let rDiagnostic = RDiagnostic()
						if let diagnosticId = diagnostic["id"] as? Int {
							rDiagnostic.id = diagnosticId
						}
						if let diagnosticDescription = diagnostic["description"] as? String {
							rDiagnostic.diagnosticDescription = diagnosticDescription
						}
						
						self.realm.add(rDiagnostic, update: true)
					}
				}
			}
			completed()
		}
	}
	
	func dowloadReasons(completed: @escaping DownloadComplete) {
		let url = "\(URL_BASE)\(URL_REASONS)"
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		Alamofire.request(url, method: .get, headers: headers).responseJSON { response in
			if let reasonDictionary = response.result.value as? [Dictionary<String, AnyObject>]{
				
				try! self.realm.write {
					for reason in reasonDictionary {
						let rReason = RReason()
						if let reasonId = reason["id"] as? Int {
							rReason.id = reasonId
						}
						if let reasonDescription = reason["description"] as? String {
							rReason.reasonDescription = reasonDescription
						}
						
						self.realm.add(rReason, update: true)
					}
				}
			}
			completed()
		}
	}
	
	func dowloadRecords(completed: @escaping DownloadComplete) {
		let url = "\(URL_BASE)\(URL_MEDICAL_RECORDS)"
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		Alamofire.request(url, method: .get, headers: headers).responseJSON { response in
			if let recordDictionary = response.result.value as? [Dictionary<String, AnyObject>]{
				try! self.realm.write {
					for rec in recordDictionary {
						let rMedRecord = RMedicalRecord()
						// ID
						if let recordId = rec["id"] as? Int {
							rMedRecord.id = recordId
						}
						// DOCUMENT
						if let documentType = rec["document_type"] as? String {
							if let document = rec["document"] as? String {
								rMedRecord.document = "\(documentType)-\(document)"
							}
						}
						// NAME
						if let name = rec["name"] as? String {
							rMedRecord.name = name
						}
						// LAST NAME
						if let lastName = rec["last_name"] as? String {
							rMedRecord.lastName = lastName
						}
						// BIRTHDAY
						if let birthday = rec["birthday"] as? String {
							rMedRecord.birthday = birthday
						}
						// FIRST CONSULTATION
						if let firstConsultation = rec["first_consultation_date"] as? String {
							rMedRecord.firstConsultation = firstConsultation
						}
						// OCCUPATION
						if let occupationDict = rec["occupation"] as? Dictionary<String, AnyObject> {
							if let occupation = occupationDict["id"] as? Int {
								if let occupationRLM = self.realm.object(ofType: ROccupation.self, forPrimaryKey: occupation) {
									rMedRecord.occupation = occupationRLM
								}
							}
						}
						// EMAIL
						if let email = rec["email"] as? String {
							rMedRecord.email = email
						}
						// PHONE
						if let phone = rec["phone_number"] as? String {
							rMedRecord.phone = phone
						}
						// CELLPHONE
						if let cellphone = rec["cellphone_number"] as? String {
							rMedRecord.cellphone = cellphone
						}
						// ADDRESS
						if let address = rec["address"] as? String {
							rMedRecord.address = address
						}
						// GENDER
						if let gender = rec["gender"] as? String {
							rMedRecord.gender = gender
						}
						// INSURANCE
						if let insuranceDict = rec["insurance"] as? Dictionary<String, AnyObject> {
							if let insurance = insuranceDict["id"] as? Int {
								if let insuranceRLM = self.realm.object(ofType: RInsurance.self, forPrimaryKey: insurance) {
									rMedRecord.insurance = insuranceRLM
								}
							}
						}
						// REFERRED BY
						if let referredBy = rec["referred_by"] as? String {
							rMedRecord.referredBy = referredBy
						}
						// LAST UPDATE DATE
						if let lastUpdate = rec["updated_at"] as? String {
							rMedRecord.lastUpdate = lastUpdate.dateFromISO8601!
						}
						// PHYSIC DATA
						if let physicData = rec["physic_data"] as? Dictionary<String, AnyObject> {
							// Height
							if let height = physicData["height"] as? Int {
								rMedRecord.height = height
							}
							// Weight
							if let weight = physicData["weight"] as? Int {
								rMedRecord.weight = weight
							}
							// Pressure D
							if let pressure_d = physicData["pressure_d"] as? String {
								rMedRecord.pressure_d = pressure_d
							}
							// Pressure S
							if let pressure_s = physicData["pressure_s"] as? String {
								rMedRecord.pressure_s = pressure_s
							}
						}
						
						rMedRecord.user = self.rUser
						self.realm.add(rMedRecord, update: true)
					}
				}
			}
			completed()
		}
	}
	
	func downloadConsultations(completed: @escaping DownloadComplete) {
		let consultationURL = "\(URL_BASE)\(URL_CONSULTATIONS)"
		
		let headers: HTTPHeaders = [
			"Authorization": "Token token=\(AuthToken.sharedInstance.token!)"
		]
		
		let records = self.realm.objects(RMedicalRecord.self)
		
		for record in records {
			let parameters: Parameters = [
				"record": record.id
			]
			
			Alamofire.request(consultationURL, method: .get, parameters: parameters, headers: headers).responseJSON { (response) in
				if let dict = response.result.value as? [Dictionary<String, AnyObject>] {
					try! self.realm.write {
						
						record.consultations.removeAll()
						
						for consultationDict in dict {
							let rConsultation = RConsultation()
							// ID
							if let id = consultationDict["id"] as? Int {
								rConsultation.id = id
							}
							// DATE
							if let date = consultationDict["created_at"] as? String {
								rConsultation.date = date
							}
							// AFFLICTION
							if let affliction = consultationDict["affliction"] as? String {
								rConsultation.affliction = affliction
							}
							// EVOLUTION
							if let evolution = consultationDict["evolution"] as? String {
								rConsultation.evolution = evolution
							}
							// HEIGHT
							if let height = consultationDict["height"] as? Int {
								rConsultation.height = height
							}
							// WEIGHT
							if let weight = consultationDict["weight"] as? Int {
								rConsultation.weight = weight
							}
							// PRESSURE_S
							if let pressure_s = consultationDict["pressure_s"] as? String {
								rConsultation.pressure_s = pressure_s
							}
							// PRESSURE_D
							if let pressure_d = consultationDict["pressure_d"] as? String {
								rConsultation.pressure_d = pressure_d
							}
							// NOTE
							if let note = consultationDict["note"] as? String {
								rConsultation.note = note
							}
							// DIAGNOSTIC
							if let diagnosticDict = consultationDict["diagnostic"] as?  Dictionary<String, AnyObject> {
								if let diagnostic = diagnosticDict["id"] as? Int {
									if let diagnosticRLM = self.realm.object(ofType: RDiagnostic.self, forPrimaryKey: diagnostic) {
										rConsultation.diagnostic = diagnosticRLM
									}
								}
							}
							// REASON
							if let reasonDict = consultationDict["reason"] as? Dictionary<String, AnyObject> {
								if let reason = reasonDict["id"] as? Int {
									if let reasonRLM = self.realm.object(ofType: RReason.self, forPrimaryKey: reason) {
										rConsultation.reason = reasonRLM
									}
								}
							}
							// BACKGROUNDS
							if let backgrounds = consultationDict["backgrounds"] as? [Dictionary<String, AnyObject>] {
								rConsultation.backgrounds.removeAll()
								for bg in backgrounds {
									let rBackground = RBackground()
									rBackground.id = bg["id"] as! Int
									rBackground.backgroundType = bg["background_type"] as! String
									rBackground.backgroundDescription = bg["description"] as! String
									self.realm.add(rBackground, update: true)
									
									rConsultation.backgrounds.append(rBackground)
								}
							}
							// PHYSICAL EXAMS
							if let physicalExams = consultationDict["physical_exams"] as? [Dictionary<String, AnyObject>] {
								rConsultation.physicalExams.removeAll()
								for pe in physicalExams {
									let rPhysicalExam = RPhysicalExam()
									rPhysicalExam.id = pe["id"] as! Int
									rPhysicalExam.examType = pe["exam_type"] as! String
									rPhysicalExam.observation = pe["observation"] as! String
									self.realm.add(rPhysicalExam, update: true)
									
									rConsultation.physicalExams.append(rPhysicalExam)
								}
							}
							
							self.realm.add(rConsultation, update: true)
							record.consultations.append(rConsultation)
						}
					}
				}
				completed()
			}
		}
	}
	
	func loginAlert() {
		let alertController = UIAlertController(title: "Error", message: "La contraseña o correo que introdujo son inválidos", preferredStyle: .alert)
		
		let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
		alertController.addAction(defaultAction)
		
		self.present(alertController, animated: true, completion: nil)
	}
	
    //Cerrar teclado cuando se toca cualquier espacio de la pantalla.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //Cerrar teclado cuando se presiona "return"
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension LoginVC: NetworkStatusListener {
	
	func networkStatusDidChange(status: Reachability.NetworkStatus) {
		switch status {
		case .notReachable:
			networkConnection = false
		case .reachableViaWiFi:
			networkConnection = true
		case .reachableViaWWAN:
			networkConnection = true
		}
	}
	
	func checkNetwork() {
		switch ReachabilityManager.shared.reachability.currentReachabilityStatus {
		case .notReachable:
			networkConnection = false
		case .reachableViaWiFi:
			networkConnection = true
		case .reachableViaWWAN:
			networkConnection = true
		}
	}
}

