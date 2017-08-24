//
//  Player.swift
//  MonoBank
//
//  Created by Richard Neitzke on 03/01/2017.
//  Copyright © 2017 Richard Neitzke. All rights reserved.
//

import Foundation

/// Represents a player of the current game

class Player: NSObject {
	
	var name: String
	var balance: Int
	var token: Token
    var id: String
	
    init(name: String, balance: Int, token: Token, id: String) {
		self.name = name
		self.balance = balance
		self.token = token
        self.id = id
	}

}
