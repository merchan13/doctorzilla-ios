//
//  EditRecordVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 6/2/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit
import RealmSwift
import ReachabilitySwift

class EditRecordVC: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITextViewDelegate {

	
	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var lastNameTextField: UITextField!
	@IBOutlet weak var occupationPickerView: UIPickerView!
	@IBOutlet weak var birthdayDatePicker: UIDatePicker!
	@IBOutlet weak var phoneTextField: UITextField!
	@IBOutlet weak var cellphoneTextField: UITextField!
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var addressTextView: UITextView!
	@IBOutlet weak var referredByTextField: UITextField!
	@IBOutlet weak var insurancePickerView: UIPickerView!
	
	var rMedrecord: RMedicalRecord!
	var occupations: Results<ROccupation>!
	var insurances: Results<RInsurance>!
	let realm = try! Realm()
	let dataHelper = DataHelper()
	let synchronizer = Synchronize()
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.nameTextField.delegate = self
		self.lastNameTextField.delegate = self
		self.phoneTextField.delegate = self
		self.cellphoneTextField.delegate = self
		self.emailTextField.delegate = self
		self.addressTextView.delegate = self
		self.referredByTextField.delegate = self
		
		self.occupations = self.realm.objects(ROccupation.self)
		self.insurances = self.realm.objects(RInsurance.self)
		
		self.occupationPickerView.delegate = self
		self.occupationPickerView.dataSource = self
		self.insurancePickerView.delegate = self
		self.insurancePickerView.dataSource = self
		
		loadValues()
    }
	
	
	func loadValues() {
		
		self.nameTextField.text = self.rMedrecord.name
		
		self.lastNameTextField.text = self.rMedrecord.lastName
		
		self.birthdayDatePicker.date = self.rMedrecord.birthdayToDate()
		
		self.phoneTextField.text = self.rMedrecord.phone
		
		self.cellphoneTextField.text = self.rMedrecord.cellphone
		
		self.emailTextField.text = self.rMedrecord.email
		
		self.addressTextView.text = self.rMedrecord.address
		
		self.referredByTextField.text = self.rMedrecord.referredBy
		
		if let occupation = self.rMedrecord.occupation {
			
			self.occupationPickerView.selectRow(self.occupations.index(where: {$0.name == occupation.name})!, inComponent: 0, animated: true)
		}
		
		if let insurance = self.rMedrecord.insurance {
			
			self.insurancePickerView.selectRow(self.insurances.index(where: {$0.name == insurance.name})!, inComponent: 0, animated: true)
		}
	}
	
	
	@IBAction func saveChangesButtonTapped(_ sender: UIButton) {
		
		let refreshAlert = UIAlertController(title: "Alerta", message: "¿Está seguro de que quiere editar la Historia Médica?", preferredStyle: UIAlertControllerStyle.alert)
		
		refreshAlert.addAction(UIAlertAction(title: "Si", style: .destructive, handler: { (action: UIAlertAction!) in
		
			let name = self.nameTextField.text!
			
			let lastName = self.lastNameTextField.text!
			
			let occupation = self.occupations[self.occupationPickerView.selectedRow(inComponent: 0)].id
			
			let birthday = self.birthdayDatePicker.date.fromDatePickerToString
			
			let phone = self.phoneTextField.text!
			
			let cellphone = self.cellphoneTextField.text!
			
			let email = self.emailTextField.text!
			
			let address = self.addressTextView.text!
			
			let referredBy = self.referredByTextField.text!
			
			let insurance = self.insurances[self.insurancePickerView.selectedRow(inComponent: 0)].id
			
			try! self.realm.write {
				
				self.rMedrecord.name = name
				
				self.rMedrecord.lastName = lastName
				
				self.rMedrecord.occupation = self.realm.object(ofType: ROccupation.self, forPrimaryKey: occupation)
				
				self.rMedrecord.birthday = birthday
				
				self.rMedrecord.phone = phone
				
				self.rMedrecord.cellphone = cellphone
				
				self.rMedrecord.email = email
				
				self.rMedrecord.address = address
				
				self.rMedrecord.referredBy = referredBy
				
				self.rMedrecord.insurance = self.realm.object(ofType: RInsurance.self, forPrimaryKey: insurance)
				
				self.rMedrecord.lastUpdate = Date().iso8601.dateFromISO8601!
				
				self.checkNetwork()
				
				if NetworkConnection.sharedInstance.haveConnection {
					
					//self.dataHelper.updateRecord(record: self.rMedrecord, completed: {
						
						//self.synchronizer.saveSync(syncDesc: "Sincronización de actualización de Historia Médica en app móvil") {
					
							self.navigationController?.popViewController(animated: true)
						//}
						
					//})
				} else {
					
					self.navigationController?.popViewController(animated: true)
				}
			}
		}))
		
		refreshAlert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { (action: UIAlertAction!) in
			
			print("Update Canceled")
		}))
		
		present(refreshAlert, animated: true, completion: nil)
	}
	
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		
		return 1
	}
	
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		
		if pickerView == self.occupationPickerView {
			
			return self.occupations.count
		}
		else if pickerView == self.insurancePickerView {
			
			return self.insurances.count
		}
		
		return 0
	}
	
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		
		if pickerView == self.occupationPickerView {
			
			return self.occupations[row].name
			
		} else if pickerView == self.insurancePickerView {
			
			return self.insurances[row].name
		}
		return ""
	}
	
	
	//Cerrar teclado cuando se toca cualquier espacio de la pantalla.
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		
		self.view.endEditing(true)
	}
	
	
	//Cerrar teclado cuando se presiona "return"
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		
		self.nameTextField.resignFirstResponder()
		
		
		self.lastNameTextField.resignFirstResponder()
		
		self.phoneTextField.resignFirstResponder()
		
		self.cellphoneTextField.resignFirstResponder()
		
		self.emailTextField.resignFirstResponder()
		
		self.referredByTextField.resignFirstResponder()
		
		return true
	}
	
	
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		
		if(text == "\n") {
			
			textView.resignFirstResponder()
			
			return false
		}
		
		return true
	}
}
