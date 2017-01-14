//
//  Player.swift
//  MonoBank
//
//  Created by Richard Neitzke on 03/01/2017.
//  Copyright © 2017 Richard Neitzke. All rights reserved.
//

import Foundation

/// Represents a player of the current game

class Player: NSObject, NSCoding {
	
	var name: String
	var balance: Int
	var token: Token
	
	init(name: String, balance: Int, token: Token) {
		self.name = name
		self.balance = balance
		self.token = token
	}
	
	// Methods to conform to NSCoding
	
	required convenience init?(coder aDecoder: NSCoder) {
		guard let name = aDecoder.decodeObject(forKey: "name") as? String,
			let tokenRawValue = aDecoder.decodeObject(forKey: "token") as? String
			else { return nil }
		
		self.init(name: name, balance: aDecoder.decodeInteger(forKey: "balance"), token: Token(rawValue: tokenRawValue)!)
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(name, forKey: "name")
		aCoder.encode(balance, forKey: "balance")
		aCoder.encode(token.rawValue, forKey: "token")
	}

}
