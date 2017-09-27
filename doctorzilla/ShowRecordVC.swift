//
//  ShowRecordVC.swift
//  doctorzilla
//
//  Created by Javier Merchán on 9/14/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit
import RealmSwift
import ReachabilitySwift
import SafariServices

class ShowRecordVC: UITableViewController {

	@IBOutlet weak var hvNumber: UILabel!
	@IBOutlet weak var profilePicture: UIImageView!
	@IBOutlet weak var name: UILabel!
	@IBOutlet weak var document: UILabel!
	@IBOutlet weak var birthday: UILabel!
	@IBOutlet weak var firstConsultation: UILabel!
	@IBOutlet weak var occupation: UILabel!
	@IBOutlet weak var phoneNumber: UILabel!
	@IBOutlet weak var cellphoneNumber: UILabel!
	@IBOutlet weak var email: UILabel!
	@IBOutlet weak var insurance: UILabel!
	@IBOutlet weak var address: UILabel!
	@IBOutlet weak var referredBy: UILabel!
	@IBOutlet weak var weight: UILabel!
	@IBOutlet weak var height: UILabel!
	@IBOutlet weak var imc: UILabel!
	@IBOutlet weak var pressure: UILabel!
	
	//Counters
	@IBOutlet weak var consultationsCounter: UILabel!
	@IBOutlet weak var diagnosticsCounter: UILabel!
	@IBOutlet weak var backgroundsCounter: UILabel!
	@IBOutlet weak var notesCounter: UILabel!
	@IBOutlet weak var attachmentsCounter: UILabel!
	
	var rMedrecord: RMedicalRecord!
	let realm = try! Realm()
	let dataHelper = DataHelper()
	let sync = Synchronize()
	
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		self.updateUI()
	}
	
	
	override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		ReachabilityManager.shared.addListener(listener: self)
	}
	
	
	override func viewDidDisappear(_ animated: Bool) {
		
		super.viewDidDisappear(animated)
		
		ReachabilityManager.shared.removeListener(listener: self)
	}
	
	
	override func viewDidAppear(_ animated: Bool) {
		
		//...
	}
	
	
	func updateUI() {
		
		checkNetwork()
		
		hvNumber.text = self.rMedrecord.hv.isEmpty
			? "Nueva en DoctorZilla"
			: "[ #HV \(self.rMedrecord.hv) ]"
		
		/*
		if self.rMedrecord.profilePic.length == 0 {
		
			// si hay senal descargar, sino no hacer nada
			self.dataHelper.downloadProfilePicture(rec: self.rMedrecord, completed: {
				self.profilePictureImage.image = UIImage(data: self.rMedrecord.profilePic as Data)
			})
		} else {
			profilePictureImage.image = UIImage(data: self.rMedrecord.profilePic as Data)
		}
		*/
		
		name.text = "\(self.rMedrecord.name.capitalized) \(self.rMedrecord.lastName.capitalized)"
		
		document.text = self.rMedrecord.document
		
		birthday.text = "\(self.rMedrecord.parsedBirthdayDate()) (\(self.rMedrecord.age()) años)"
		
		firstConsultation.text = self.rMedrecord.parsedFirstConsultationDate().isEmpty
			? "N/A"
			: self.rMedrecord.parsedFirstConsultationDate()
		
		occupation.text = self.rMedrecord.occupation?.name.capitalized
		
		email.text = self.rMedrecord.email.lowercased()
		
		phoneNumber.text = self.rMedrecord.phone
		
		cellphoneNumber.text = self.rMedrecord.cellphone
		
		insurance.text = self.rMedrecord.insurance?.name.capitalized
		
		address.text = self.rMedrecord.address.capitalized
		
		referredBy.text = self.rMedrecord.referredBy.capitalized
		
		weight.text = self.rMedrecord.weight == 0
			? "N/A"
			: "\(self.rMedrecord.weight) kg."
		
		height.text = self.rMedrecord.height == 0
			? "N/A"
			: "\(Float(self.rMedrecord.height)/100)m"
		
		imc.text = self.rMedrecord.IMC() == 0
			? "N/A"
			: "\(self.rMedrecord.IMC())"
		
		pressure.text =  (self.rMedrecord.pressure_s == "?" || self.rMedrecord.pressure_d == "?")
			? "N/A"
			: "\(self.rMedrecord.pressure_s)/\(self.rMedrecord.pressure_d)"
		
		consultationsCounter.text = "Consultas Médicas (\(self.rMedrecord.consultations.count))"
		
		diagnosticsCounter.text = "Diagnósticos (\(self.rMedrecord.diagnostics().count))"
		
		backgroundsCounter.text = "Antecedentes (\(self.rMedrecord.backgrounds.count))"
		
		notesCounter.text = "Notas Operatorias (\(self.rMedrecord.operativeNotes().count))"
		
		attachmentsCounter.text = "Anexos (\(self.rMedrecord.attachments.count))"
		
	}
	
	
	@IBAction func editButtonTapped(_ sender: Any) {
		
		performSegue(withIdentifier: "EditRecordVC", sender: self.rMedrecord)
	}
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == "EditRecordVC" {
			
			if let editRecordVC = segue.destination as? EditRecordVC {
				
				if let rMedrec = sender as? RMedicalRecord {
					
					editRecordVC.rMedrecord = rMedrec
				}
			}
		}
		else if segue.identifier == "IndexConsultationsVC" {
			
			if let indexConsultationsVC = segue.destination as? IndexConsultationsVC {
			
				if let rConsultations = sender as? List<RConsultation> {
					
					indexConsultationsVC.rConsultations = rConsultations
				}
			}
		}
		else if segue.identifier == "ShowRecordDiagnosticsVC" {
			
			if let showRecordDxVC = segue.destination as? ShowRecordDiagnosticsVC {
				
				if let rDiagnostics = sender as? [RDiagnostic] {
					
					showRecordDxVC.rDiagnostics = rDiagnostics
				}
			}
		}
		else if segue.identifier == "ShowRecordBackgroundsVC" {
			
			if let showRecordBgVC = segue.destination as? ShowRecordBackgroundsVC {
				
				if let rBackgrounds = sender as? List<RBackground> {
					
					showRecordBgVC.rBackgrounds = rBackgrounds
				}
			}
		}
		else if segue.identifier == "IndexOperativeNotesVC" {
			
			if let indexNotesVC = segue.destination as? IndexOperativeNotesVC {
				
				if let rOperativeNotes = sender as? [ROperativeNote] {
					
					indexNotesVC.rOperativeNotes = rOperativeNotes
				}
			}
		}
		else if segue.identifier == "ShowRecordAttachmentsVC" {
			
			if let showRecordAttchVC = segue.destination as? ShowRecordAttachmentsVC {
				
				if let rAttachments = sender as? List<RAttachment> {
					
					showRecordAttchVC.rAttachments = rAttachments
				}
			}
		}
	}
	
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if indexPath.section == 1 {
			
			if indexPath.row == 4 {
				
				performSegue(withIdentifier: "IndexConsultationsVC", sender: self.rMedrecord.consultations)
			}
			else if indexPath.row == 5 {
				
				performSegue(withIdentifier: "ShowRecordDiagnosticsVC", sender: self.rMedrecord.diagnostics())
			}
			else if indexPath.row == 6 {
			
				performSegue(withIdentifier: "ShowRecordBackgroundsVC", sender: self.rMedrecord.backgrounds)
			}
			else if indexPath.row == 7 {
				
				performSegue(withIdentifier: "IndexOperativeNotesVC", sender: self.rMedrecord.operativeNotes())
			}
			else if indexPath.row == 8 {
				
				performSegue(withIdentifier: "ShowRecordAttachmentsVC", sender: self.rMedrecord.attachments)
			}
		}
	}
	
}
