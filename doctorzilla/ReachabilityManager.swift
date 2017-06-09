//
//  ReachabilityManager.swift
//  doctorzilla
//
//  Created by Javier Merchán on 6/7/17.
//  Copyright © 2017 Merchan. All rights reserved.
//

import UIKit
import ReachabilitySwift

/// Protocol for listenig network status change
public protocol NetworkStatusListener : class {
	func networkStatusDidChange(status: Reachability.NetworkStatus)
}

class ReachabilityManager: NSObject {
	
	// Shared instance.
	static let shared = ReachabilityManager()
	
	// Boolean to track network reachability.
	var isNetworkAvailable : Bool {
		return reachabilityStatus != .notReachable
	}
	
	// Tracks current NetworkStatus (notReachable, reachableViaWiFi, reachableViaWWAN).
	var reachabilityStatus: Reachability.NetworkStatus = .notReachable
	
	// Reachibility instance for Network status monitoring.
	let reachability = Reachability()!
	
	// Array of delegates which are interested to listen to network status change.
	var listeners = [NetworkStatusListener]()
	
	/// Called whenever there is a change in NetworkReachibility Status.
	///
	/// — parameter notification: Notification with the Reachability instance.
	func reachabilityChanged(notification: Notification) {
		let reachability = notification.object as! Reachability
		
		switch reachability.currentReachabilityStatus {
		case .notReachable:
			print("\nNetwork became unreachable")
		case .reachableViaWiFi:
			print("\nNetwork reachable through WiFi")
		case .reachableViaWWAN:
			print("\nNetwork reachable through Cellular Data")
		}
		
		// Sending message to each of the delegates
		for listener in listeners {
			listener.networkStatusDidChange(status: reachability.currentReachabilityStatus)
		}
	}
	
	
	/// Starts monitoring the network availability status.
	func startMonitoring() {
		NotificationCenter.default.addObserver(self,
		                                       selector: #selector(self.reachabilityChanged),
		                                       name: ReachabilityChangedNotification,
		                                       object: reachability)
		do{
			try reachability.startNotifier()
		}catch{
			print("\nCould not start reachability notifier")
		}
	}
	
	/// Stops monitoring the network availability status.
	func stopMonitoring(){
		reachability.stopNotifier()
		NotificationCenter.default.removeObserver(self,
		                                          name: ReachabilityChangedNotification,
		                                          object: reachability)
	}
	
	/// Adds a new listener to the listeners array.
	///
	/// - parameter delegate: a new listener
	func addListener(listener: NetworkStatusListener){
		listeners.append(listener)
	}
	
	/// Removes a listener from listeners array.
	///
	/// - parameter delegate: the listener which is to be removed.
	func removeListener(listener: NetworkStatusListener){
		listeners = listeners.filter{ $0 !== listener}
	}
}

