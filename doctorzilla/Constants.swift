//
//  Constants.swift
//  doctorzilla
//
//  Created by Javier Merchán on 5/18/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import Foundation

let URL_BASE =				"http://doctorzilla-api.herokuapp.com/v1"
let URL_SIGN_IN =			"/sign-in"
let URL_SIGN_OUT =			"/sign-out"
let URL_USERS =				"/users/"
let URL_MEDICAL_RECORDS =	"/medical_records/"
let URL_ATTACHMENTS =		"/attachments/"
let URL_BACKGROUNDS =		"/backgrounds/"
let URL_CONSULTATIONS =		"/consultations/"
let URL_DIAGNOSTICS =		"/diagnostics/"
let URL_INSURANCES =		"/insurances/"
let URL_OCCUPATIONS =		"/occupations/"
let URL_OPERATIVE_NOTES =	"/operative_notes/"
let URL_PHYSICAL_EXAMS =	"/physical_exams/"
let URL_PLANS =				"/plans/"
let URL_PROCEDURES =		"/procedures/"
let URL_REASONS =			"/reasons/"
let URL_REPORTS =			"/reports/"

let URL_PLAN_PROCEDURES =			"/plans/:plan_id/procedures/"
let URL_CONSULTATION_DIAGNOSTICS =	"/consultations/:consultation_id/diagnostics/"

let URL_RECORD_BACKGROUND_UPDATE = "/medical_records/:medical_record_id/backgrounds/"

let URL_SYNCS =				"/syncs/"
let URL_LATEST_UPDATES =	"/latest_data/"
let URL_LAST_SYNC =			"/last_sync/"
let URL_SET_ACTIONS = 		"/set_syncs_actions/"
let URL_ACTIVITIES = 		"/activities_report"

let URL_SEARCH_RECORDS = "/search_records/"

let RECORDS_CSV = "Records.csv"

let GENDERS = ["Masculino","Femenino"]

typealias DownloadComplete = () -> ()
