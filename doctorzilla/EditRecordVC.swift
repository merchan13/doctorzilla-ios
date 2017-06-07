//
//  EditRecordVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 6/2/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit

class EditRecordVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var lastNameTextField: UITextField!
	@IBOutlet weak var occupationPickerView: UIPickerView!
	@IBOutlet weak var birthdayDatePicker: UIDatePicker!
	@IBOutlet weak var genderPickerView: UIPickerView!
	@IBOutlet weak var phoneTextField: UITextField!
	@IBOutlet weak var cellphoneTextField: UITextField!
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var addressTextView: UITextView!
	@IBOutlet weak var referredByTextField: UITextField!
	@IBOutlet weak var insurancePickerView: UIPickerView!
	
	var medrecord: MedicalRecord!
	var occupations = [Occupation]()
	var insurances = [Insurance]()
	var genders = ["Masculino","Femenino"]
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.nameTextField.delegate = self
		self.lastNameTextField.delegate = self
		
		let dataHelper = DataHelper()
		
		self.occupationPickerView.delegate = self
		self.occupationPickerView.dataSource = self
		self.insurancePickerView.delegate = self
		self.insurancePickerView.dataSource = self
		self.genderPickerView.delegate = self
		self.genderPickerView.dataSource = self
		
		dataHelper.downloadOccupations {
			self.occupations = dataHelper.occupations
			self.occupationPickerView.reloadComponent(0)
			self.occupationPickerView.selectRow(self.occupations.index(where: {$0.name == self.medrecord.occupation})!, inComponent: 0, animated: true)
		}
		
		dataHelper.downloadInsurances {
			self.insurances = dataHelper.insurances
			self.insurancePickerView.reloadComponent(0)
			self.insurancePickerView.selectRow(self.insurances.index(where: {$0.name == self.medrecord.insurance})!, inComponent: 0, animated: true)
		}
		
		loadValues()
    }
	
	func loadValues() {
		self.nameTextField.text = self.medrecord.name
		self.lastNameTextField.text = self.medrecord.lastName
		self.birthdayDatePicker.date = self.medrecord.birthdayToDate()
		self.phoneTextField.text = self.medrecord.phone
		self.cellphoneTextField.text = self.medrecord.cellphone
		self.emailTextField.text = self.medrecord.email
		self.addressTextView.text = self.medrecord.address
		self.referredByTextField.text = self.medrecord.referredBy
		
		if self.medrecord.gender == "masculine" {
			self.genderPickerView.selectRow(0, inComponent: 0, animated: true)
		} else if self.medrecord.gender == "femenine" {
			self.genderPickerView.selectRow(1, inComponent: 0, animated: true)
		}
	}
	
	@IBAction func saveChangedButtonTapped(_ sender: UIButton) {
		let refreshAlert = UIAlertController(title: "Alerta", message: "¿Está seguro de que quiere editar la Historia Médica?", preferredStyle: UIAlertControllerStyle.alert)
		
		refreshAlert.addAction(UIAlertAction(title: "Si", style: .destructive, handler: { (action: UIAlertAction!) in
			
			var updatedGen = ""
			
			if self.genderPickerView.selectedRow(inComponent: 0) == 0 {
				updatedGen = "masculine"
			} else if self.genderPickerView.selectedRow(inComponent: 0) == 1 {
				updatedGen = "femenine"
			}
			
			self.medrecord.updateRecord(name: self.nameTextField.text!, lastName: self.lastNameTextField.text!,
			                            occupation: self.occupations[self.occupationPickerView.selectedRow(inComponent: 0)].occupationId,
			                            birthday: self.birthdayDatePicker.date.fromDatePickerToString(),
			                            gender: updatedGen, phone: self.phoneTextField.text!, cellphone: self.cellphoneTextField.text!, email: self.emailTextField.text!,
			                            address: self.addressTextView.text!, referredBy: self.referredByTextField.text!,
			                            insurance: self.insurances[self.insurancePickerView.selectedRow(inComponent: 0)].insuranceId) {
				self.dismiss(animated: true, completion: nil)
			}
		}))
		
		refreshAlert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { (action: UIAlertAction!) in
			print("Update Canceled")
		}))
		
		present(refreshAlert, animated: true, completion: nil)
	}
	
	@IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
		dismiss(animated: true, completion: nil)
	}
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		if pickerView == self.occupationPickerView {
			return self.occupations.count
		} else if pickerView == self.insurancePickerView {
			return self.insurances.count
		}
		return genders.count
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		if pickerView == self.occupationPickerView {
			return self.occupations[row].name
		} else if pickerView == self.insurancePickerView {
			return self.insurances[row].name
		}
		return genders[row]
	}
	
	//Cerrar teclado cuando se toca cualquier espacio de la pantalla.
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true)
	}
	
	//Cerrar teclado cuando se presiona "return"
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		self.nameTextField.resignFirstResponder()
		self.lastNameTextField.resignFirstResponder()
		return true
	}

}
