//
//  EditBackgroundsVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 9/3/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit
import RealmSwift
import ReachabilitySwift

class EditBackgroundsVC: UIViewController, UITextViewDelegate {
	
	@IBOutlet weak var familyTextView: UITextView!
	@IBOutlet weak var allergyTextView: UITextView!
	@IBOutlet weak var diabetesTextView: UITextView!
	@IBOutlet weak var asthmaTextView: UITextView!
	@IBOutlet weak var heartTextView: UITextView!
	@IBOutlet weak var medicineTextView: UITextView!
	@IBOutlet weak var surgicalTextView: UITextView!
	@IBOutlet weak var otherTextView: UITextView!
	
	var rRecord: RMedicalRecord!
	var recordBgs = List<RBackground>()
	let realm = try! Realm()
	let dataHelper = DataHelper()
	let dataHelperRLM = DataHelperRLM()
	
	var networkConnection = false
	
    override func viewDidLoad() {
		self.familyTextView.delegate = self
		self.allergyTextView.delegate = self
		self.diabetesTextView.delegate = self
		self.asthmaTextView.delegate = self
		self.heartTextView.delegate = self
		self.medicineTextView.delegate = self
		self.surgicalTextView.delegate = self
		self.otherTextView.delegate = self
		
		self.recordBgs = self.rRecord.backgrounds
		
		loadValues()
    }
	
	func loadValues() {
		if recordBgs.contains(where: { $0.backgroundType == "Familiares" }) {
			self.familyTextView.text = self.recordBgs.first(where: { $0.backgroundType == "Familiares" })!.backgroundDescription
		}
		
		if recordBgs.contains(where: { $0.backgroundType == "Alergias" }) {
			self.allergyTextView.text = self.recordBgs.first(where: { $0.backgroundType == "Alergias" })!.backgroundDescription
		}
		
		if recordBgs.contains(where: { $0.backgroundType == "Diábetes" }) {
			self.diabetesTextView.text = self.recordBgs.first(where: { $0.backgroundType == "Diábetes" })!.backgroundDescription
		}
		
		if recordBgs.contains(where: { $0.backgroundType == "Asma" }) {
			self.asthmaTextView.text = self.recordBgs.first(where: { $0.backgroundType == "Asma" })!.backgroundDescription
		}
		
		if recordBgs.contains(where: { $0.backgroundType == "Cardiopatías" }) {
			self.heartTextView.text = self.recordBgs.first(where: { $0.backgroundType == "Cardiopatías" })!.backgroundDescription
		}
		
		if recordBgs.contains(where: { $0.backgroundType == "Medicamentos" }) {
			self.medicineTextView.text = self.recordBgs.first(where: { $0.backgroundType == "Medicamentos" })!.backgroundDescription
		}
		
		if recordBgs.contains(where: { $0.backgroundType == "Quirúrgicos" }) {
			self.surgicalTextView.text = self.recordBgs.first(where: { $0.backgroundType == "Quirúrgicos" })!.backgroundDescription
		}
		
		if recordBgs.contains(where: { $0.backgroundType == "Otros" }) {
			self.otherTextView.text = self.recordBgs.first(where: { $0.backgroundType == "Otros" })!.backgroundDescription
		}
	}
	
	
	@IBAction func saveChangesButtonTapped(_ sender: Any) {
		let refreshAlert = UIAlertController(title: "Alerta", message: "¿Está seguro de que quiere editar los Antecedentes?", preferredStyle: UIAlertControllerStyle.alert)
		refreshAlert.addAction(UIAlertAction(title: "Si", style: .destructive, handler: { (action: UIAlertAction!) in
			
			let family = self.familyTextView.text!
			let allergy = self.allergyTextView.text!
			let diabetes = self.diabetesTextView.text!
			let asthma = self.asthmaTextView.text!
			let heart = self.heartTextView.text!
			let medicine = self.medicineTextView.text!
			let surgical = self.surgicalTextView.text!
			let other = self.otherTextView.text!
			
			try! self.realm.write {
				
				self.rRecord.lastUpdate = Date().iso8601.dateFromISO8601!
				
				if self.recordBgs.contains(where: { $0.backgroundType == "Familiares" }) {
					let bg = self.recordBgs.first(where: { $0.backgroundType == "Familiares" })!
					
					if family == "" {
						self.realm.delete(bg)
					} else {
						self.realm.create(RBackground.self, value: ["id":bg.id, "backgroundDescription":family], update: true)
					}
				} else {
					if family != "" {
						let rBg = RBackground()
						rBg.id = -1
						rBg.recordId = self.rRecord.id
						rBg.backgroundType = "Familiares"
						rBg.backgroundDescription = family
						self.realm.add(rBg, update: true)
						self.rRecord.backgrounds.append(rBg)
						self.recordBgs.append(rBg)
					}
				}
				
				if self.recordBgs.contains(where: { $0.backgroundType == "Alergias" }) {
					let bg = self.recordBgs.first(where: { $0.backgroundType == "Alergias" })!
					
					if allergy == "" {
						self.realm.delete(bg)
					} else {
						self.realm.create(RBackground.self, value: ["id":bg.id, "backgroundDescription":allergy], update: true)
					}
				} else {
					if allergy != "" {
						let rBg = RBackground()
						rBg.id = -2
						rBg.recordId = self.rRecord.id
						rBg.backgroundType = "Alergias"
						rBg.backgroundDescription = allergy
						self.realm.add(rBg, update: true)
						self.rRecord.backgrounds.append(rBg)
						self.recordBgs.append(rBg)
					}
				}
				
				if self.recordBgs.contains(where: { $0.backgroundType == "Diábetes" }) {
					let bg = self.recordBgs.first(where: { $0.backgroundType == "Diábetes" })!
					
					if diabetes == "" {
						self.realm.delete(bg)
					} else {
						self.realm.create(RBackground.self, value: ["id":bg.id, "backgroundDescription":diabetes], update: true)
					}
				} else {
					if diabetes != "" {
						let rBg = RBackground()
						rBg.id = -3
						rBg.recordId = self.rRecord.id
						rBg.backgroundType = "Diábetes"
						rBg.backgroundDescription = diabetes
						self.realm.add(rBg, update: true)
						self.rRecord.backgrounds.append(rBg)
						self.recordBgs.append(rBg)
					}
				}
				
				if self.recordBgs.contains(where: { $0.backgroundType == "Asma" }) {
					let bg = self.recordBgs.first(where: { $0.backgroundType == "Asma" })!
					
					if asthma == "" {
						self.realm.delete(bg)
					} else {
						self.realm.create(RBackground.self, value: ["id":bg.id, "backgroundDescription":asthma], update: true)
					}
				} else {
					if asthma != "" {
						let rBg = RBackground()
						rBg.id = -4
						rBg.recordId = self.rRecord.id
						rBg.backgroundType = "Asma"
						rBg.backgroundDescription = asthma
						self.realm.add(rBg, update: true)
						self.rRecord.backgrounds.append(rBg)
						self.recordBgs.append(rBg)
					}
				}
				
				if self.recordBgs.contains(where: { $0.backgroundType == "Cardiopatías" }) {
					let bg = self.recordBgs.first(where: { $0.backgroundType == "Cardiopatías" })!
					
					if heart == "" {
						self.realm.delete(bg)
					} else {
						self.realm.create(RBackground.self, value: ["id":bg.id, "backgroundDescription":heart], update: true)
					}
				} else {
					if heart != "" {
						let rBg = RBackground()
						rBg.id = -5
						rBg.recordId = self.rRecord.id
						rBg.backgroundType = "Cardiopatías"
						rBg.backgroundDescription = heart
						self.realm.add(rBg, update: true)
						self.rRecord.backgrounds.append(rBg)
						self.recordBgs.append(rBg)
					}
				}
				
				if self.recordBgs.contains(where: { $0.backgroundType == "Medicamentos" }) {
					let bg = self.recordBgs.first(where: { $0.backgroundType == "Medicamentos" })!
					
					if medicine == "" {
						self.realm.delete(bg)
					} else {
						self.realm.create(RBackground.self, value: ["id":bg.id, "backgroundDescription":medicine], update: true)
					}
				} else {
					if medicine != "" {
						let rBg = RBackground()
						rBg.id = -6
						rBg.recordId = self.rRecord.id
						rBg.backgroundType = "Medicamentos"
						rBg.backgroundDescription = medicine
						self.realm.add(rBg, update: true)
						self.rRecord.backgrounds.append(rBg)
						self.recordBgs.append(rBg)
					}
				}
				
				if self.recordBgs.contains(where: { $0.backgroundType == "Quirúrgicos" }) {
					let bg = self.recordBgs.first(where: { $0.backgroundType == "Quirúrgicos" })!
					
					if surgical == "" {
						self.realm.delete(bg)
					} else {
						self.realm.create(RBackground.self, value: ["id":bg.id, "backgroundDescription":surgical], update: true)
					}
				} else {
					if surgical != "" {
						let rBg = RBackground()
						rBg.id = -7
						rBg.recordId = self.rRecord.id
						rBg.backgroundType = "Quirúrgicos"
						rBg.backgroundDescription = surgical
						self.realm.add(rBg, update: true)
						self.rRecord.backgrounds.append(rBg)
						self.recordBgs.append(rBg)
					}
				}
				
				if self.recordBgs.contains(where: { $0.backgroundType == "Otros" }) {
					let bg = self.recordBgs.first(where: { $0.backgroundType == "Otros" })!
					
					if other == "" {
						self.realm.delete(bg)
					} else {
						self.realm.create(RBackground.self, value: ["id":bg.id, "backgroundDescription":other], update: true)
					}
				} else {
					if other != "" {
						let rBg = RBackground()
						rBg.id = -8
						rBg.recordId = self.rRecord.id
						rBg.backgroundType = "Otros"
						rBg.backgroundDescription = other
						self.realm.add(rBg, update: true)
						self.rRecord.backgrounds.append(rBg)
						self.recordBgs.append(rBg)
					}
				}
				
				self.checkNetwork()
				
				if self.networkConnection {
					
					self.dataHelper.updateBackgrounds(record: self.rRecord, recordBgs: self.recordBgs, completed: {
						
						self.dataHelper.fixNewBackgrounds(record: self.rRecord, recordBgs: self.recordBgs, completed: {
							
							self.dismiss(animated: true, completion: nil)
							
						})
						
					})
					
				} else {
					
					self.dismiss(animated: true, completion: nil)
					
				}
			}
		}))
		
		refreshAlert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { (action: UIAlertAction!) in
			print("Update Canceled")
		}))
		
		present(refreshAlert, animated: true, completion: nil)
	}
	
	
	@IBAction func backButtonTapped(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
	
	//Cerrar teclado cuando se toca cualquier espacio de la pantalla.
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true)
	}
	

	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		if(text == "\n") {
			textView.resignFirstResponder()
			return false
		}
		return true
	}
	
}

extension EditBackgroundsVC: NetworkStatusListener {
	
	func networkStatusDidChange(status: Reachability.NetworkStatus) {
		if status == .notReachable {
			networkConnection = false
		} else {
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
