//
//  EditConsultationVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 6/2/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit
import RealmSwift
import ReachabilitySwift

class EditConsultationVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITextViewDelegate  {

	@IBOutlet weak var reasonPickerView: UIPickerView!
	@IBOutlet weak var afflictionTextView: UITextView!
	@IBOutlet weak var weightTextField: UITextField!
	@IBOutlet weak var heightTextField: UITextField!
	@IBOutlet weak var pressure_sTextField: UITextField!
	@IBOutlet weak var pressure_dTextField: UITextField!
	@IBOutlet weak var evolutionTextView: UITextView!
	@IBOutlet weak var notesTextView: UITextView!
	@IBOutlet weak var diagnosticPickerView: UIPickerView!
	
	var rConsultation: RConsultation!
	var reasons: Results<RReason>!
	let realm = try! Realm()
	let dataHelper = DataHelper()
	let dataHelperRLM = DataHelperRLM()
	let synchronizer = Synchronize()
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.afflictionTextView.delegate = self
		self.weightTextField.delegate = self
		self.heightTextField.delegate = self
		self.pressure_sTextField.delegate = self
		self.pressure_dTextField.delegate = self
		self.evolutionTextView.delegate = self
		self.notesTextView.delegate = self
		
		self.reasons = self.realm.objects(RReason.self)
		
		self.reasonPickerView.delegate = self
		self.reasonPickerView.dataSource = self
		self.diagnosticPickerView.delegate = self
		self.diagnosticPickerView.dataSource = self
		
		loadValues()
    }
	
	func loadValues() {
		self.afflictionTextView.text = self.rConsultation.affliction
		self.weightTextField.text = "\(self.rConsultation.weight)"
		self.heightTextField.text = "\(self.rConsultation.height)"
		self.pressure_sTextField.text = self.rConsultation.pressure_s
		self.pressure_dTextField.text = self.rConsultation.pressure_d
		self.evolutionTextView.text = self.rConsultation.evolution
		self.notesTextView.text = self.rConsultation.note
		
		if let reason = self.rConsultation.reason {
			self.reasonPickerView.selectRow(self.reasons.index(where: {$0.reasonDescription == reason.reasonDescription})!, inComponent: 0, animated: true)
		}
	}
	
	@IBAction func backgroundButtonTapped(_ sender: Any) {
	}
	
	@IBAction func saveChangesButtonTapped(_ sender: Any) {
		let refreshAlert = UIAlertController(title: "Alerta", message: "¿Está seguro de que quiere editar la Consulta Médica?", preferredStyle: UIAlertControllerStyle.alert)
		refreshAlert.addAction(UIAlertAction(title: "Si", style: .destructive, handler: { (action: UIAlertAction!) in
			
			let affliction = self.afflictionTextView.text!
			let weight = self.weightTextField.text!
			let height = self.heightTextField.text!
			let pressure_s = self.pressure_sTextField.text!
			let pressure_d = self.pressure_dTextField.text!
			let evolution = self.evolutionTextView.text!
			let notes = self.notesTextView.text!
			let reason = self.reasons[self.reasonPickerView.selectedRow(inComponent: 0)].id
			
			try! self.realm.write {
				self.rConsultation.affliction = affliction
				self.rConsultation.weight = Int(weight)!
				self.rConsultation.height = Int(height)!
				self.rConsultation.pressure_s = pressure_s
				self.rConsultation.pressure_d = pressure_d
				self.rConsultation.evolution = evolution
				self.rConsultation.note = notes
				self.rConsultation.reason = self.realm.object(ofType: RReason.self, forPrimaryKey: reason)
				self.rConsultation.lastUpdate = Date().iso8601.dateFromISO8601!
				
				self.checkNetwork()
				
				if NetworkConnection.sharedInstance.haveConnection {
					
					self.dataHelper.updateConsultation(consultation: self.rConsultation, completed: {
						
						self.synchronizer.saveSync(syncDesc: "Sincronización de actualización de Consulta Médica en app móvil") {
							self.dismiss(animated: true, completion: nil)
						}
						
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
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		if pickerView == self.reasonPickerView {
			return self.reasons.count
		} else {
			return 0
		}
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		if pickerView == self.reasonPickerView {
			return self.reasons[row].reasonDescription
		} else {
			return "N/A"
		}
	}
	
	//Cerrar teclado cuando se toca cualquier espacio de la pantalla.
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true)
	}
	
	//Cerrar teclado cuando se presiona "return"
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		self.weightTextField.resignFirstResponder()
		self.heightTextField.resignFirstResponder()
		self.pressure_sTextField.resignFirstResponder()
		self.pressure_dTextField.resignFirstResponder()
		return true
	}
	
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		if(text == "\n") {
			self.afflictionTextView.resignFirstResponder()
			self.evolutionTextView.resignFirstResponder()
			self.notesTextView.resignFirstResponder()
			return false
		}
		return true
	}
}
