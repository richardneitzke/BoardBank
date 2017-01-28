//
//  BankManager.swift
//  MonoBank
//
//  Created by Richard Neitzke on 03/01/2017.
//  Copyright © 2017 Richard Neitzke. All rights reserved.
//

import Foundation

/// Manages data

class BankManager {
	
	static let shared = BankManager()
	
	/// Formats balances with the current currency symbol
	let numberFormatter = NumberFormatter()
	
	/// Currency symbol used by the app
	var currencySymbol = "$" {
		didSet {
			numberFormatter.currencySymbol = currencySymbol
		}
	}
	
	/// Default balance when adding a player
	var defaultBalance = 1500
	
	/// Amount which the user can quickly add in the player menu
	var quickAddAmount = 200
	
	/// All players of the current game
	var players = [Player]()
	
	var soundsEnabled = true
	
	init() {
		// Fetch previously set values from UserDefaults
		if let currencySymbol = UserDefaults.standard.string(forKey: "currencySymbol") {
			self.currencySymbol = currencySymbol
		}
		if let defaultBalance = UserDefaults.standard.value(forKey: "defaultBalance") as? Int {
			self.defaultBalance = defaultBalance
		}
		if let quickAddAmount = UserDefaults.standard.value(forKey: "quickAddAmount") as? Int {
			self.quickAddAmount = quickAddAmount
		}
		if let playersData = UserDefaults.standard.object(forKey: "players") as? Data {
			players = NSKeyedUnarchiver.unarchiveObject(with: playersData) as! [Player]
		}
		if let soundsEnabled = UserDefaults.standard.object(forKey: "soundsEnabled") as? Bool {
			self.soundsEnabled = soundsEnabled
		}
		
		// Configure numberFormatter
		numberFormatter.numberStyle = .currency
		numberFormatter.locale = Locale(identifier: "es_CL")
		numberFormatter.currencySymbol = currencySymbol
	}
	
	/// Saves the current state of the BankManager
	func save() {
		UserDefaults.standard.set(currencySymbol, forKey: "currencySymbol")
		UserDefaults.standard.set(defaultBalance, forKey: "defaultBalance")
		UserDefaults.standard.set(quickAddAmount, forKey: "quickAddAmount")
		let playersData = NSKeyedArchiver.archivedData(withRootObject: players)
		UserDefaults.standard.set(playersData, forKey: "players")
		UserDefaults.standard.set(soundsEnabled, forKey: "soundsEnabled")
	}
	
}
