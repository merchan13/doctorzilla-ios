//
//  Constants.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/18/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation

let URL_BASE = "http://doctorzilla-api.herokuapp.com"
let URL_SIGN_IN = "/sign-in"
let URL_SIGN_OUT = "/sign-out"
let URL_USERS = "/users/"
let URL_MEDICAL_RECORDS = "/medical_records/"

let URL_ATTACHMENTS = "/attachments/"
let URL_BACKGROUNDS = "/backgrounds/"
let URL_CONSULTATIONS = "/consultations/"
let URL_DIAGNOSTICS = "/diagnostics/"
let URL_INSURANCES = "/insurances/"
let URL_MEDICINES = "/medicines/"
let URL_OCCUPATIONS = "/occupations/"
let URL_OPERATIVE_NOTES = "/operative_notes/"
let URL_PHYSICAL_EXAMS = "/physical_exams/"
let URL_PLANS = "/plans/"
let URL_PRESCRIPTIONS = "/prescriptions/"
let URL_PROCEDURES = "/procedures/"
let URL_REASONS = "/reasons/"

let URL_PLAN_PROCEDURES = "/plans/:plan_id/procedures/"
let URL_PROCEDURE_PLANS = "/procedures/:procedure_id/plans/"
let URL_PRESCRIPTION_MEDICINES = "/prescriptions/:prescription_id/medicines/"
let URL_MEDICINE_PRESCRIPTIONS = "/medicines/:medicine_id/prescriptions/"

let URL_LATEST_UPDATES = "/latest_updates/"
let URL_LAST_SYNCH = "/last_synch/"

let RECORDS_CSV = "Records.csv"

typealias DownloadComplete = () -> ()
