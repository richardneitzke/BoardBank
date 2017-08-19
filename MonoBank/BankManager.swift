//
//  BankManager.swift
//  MonoBank
//
//  Created by Richard Neitzke on 03/01/2017.
//  Copyright © 2017 Richard Neitzke. All rights reserved.
//
import CoreData
import Foundation
import UIKit

// Manages data

class BankManager {
	
	static let shared = BankManager()
    
	// Formats balances with the current currency symbol
	let numberFormatter = NumberFormatter()
	
	// Currency symbol used by the app
	var currencySymbol = "$" {
		didSet {
			numberFormatter.currencySymbol = currencySymbol
		}
	}
	
	// Default balance when adding a player
	var defaultBalance = 1500
	
	// Amount which the user can quickly add in the player menu
	var quickAddAmount = 200
	
	// All players of the current game
	var players = [Player]()
    
    // All managedUser entities of the current game
    var managedUsers = [User]()
    
    // All transactions of the current game
    var transactions = [Transaction]()
    
    // All managedReceipts entities of the current game
    var managedReceipts = [Receipt]()
    
    var index = Int16(0)
	
	var soundsEnabled = true
	
    // Use 'private' to "initialize" when shared is called
	private init() {
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
        // Loading Users from core data
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let managedContext = appDelegate.persistentContainer.viewContext
        do {
            
            let userSortDescriptor = NSSortDescriptor(key: "index", ascending: true)
            let request: NSFetchRequest<User> = User.fetchRequest()
            request.sortDescriptors = [userSortDescriptor]
            
            let users = try managedContext.fetch(request) as [User]
            let receipts = try managedContext.fetch(Receipt.fetchRequest()) as [Receipt]
            
            for user in users {
                let player = Player(name: user.name!, balance: Int(user.balance), token: Token(rawValue: user.token!)!)
                players.append(player)
                managedUsers.append(user)
            }
            
            for receipt in receipts {
                let transaction = Transaction(amount: Int(receipt.amount), payee: receipt.payee!, payeeIndex: Int(receipt.payeeIndex), payer: receipt.payer!, payerIndex: Int(receipt.payerIndex))
                transactions.append(transaction)
                managedReceipts.append(receipt)
            }
        }
        catch let error as NSError{
            print("Could not fetch. \(error), \(error.userInfo)")
        }
            
		}
		if let soundsEnabled = UserDefaults.standard.object(forKey: "soundsEnabled") as? Bool {
			self.soundsEnabled = soundsEnabled
		}
		
		// Configure numberFormatter
		numberFormatter.numberStyle = .currency
		numberFormatter.locale = Locale(identifier: "es_CL")
		numberFormatter.currencySymbol = currencySymbol
	}
	
	//Saves the current settings of the BankManager
	func saveSettings() {
		UserDefaults.standard.set(currencySymbol, forKey: "currencySymbol")
		UserDefaults.standard.set(defaultBalance, forKey: "defaultBalance")
		UserDefaults.standard.set(quickAddAmount, forKey: "quickAddAmount")
		UserDefaults.standard.set(soundsEnabled, forKey: "soundsEnabled")
	}
    
    //Saves the newly created Player to core data
    func savePlayer(_ player: Player) {
        
        let user = User(entity: User.entity(), insertInto: CoreDataStack.managedContext)
        user.name = player.name
        user.balance = Int16(player.balance)
        user.token = player.token.rawValue
        user.index += index
        index += 1
        
        managedUsers.append(user)
        
        //In case if user moved collectionView cells before adding players
        for i in (0..<managedUsers.count){
            managedUsers[i].index = Int16(i)
        }
        CoreDataStack.appDelegate.saveContext()
    }
    
    //Saves the newly created Transaction to core data
    func saveTransaction(_ transaction: Transaction){
        
        let receipt = Receipt(entity: Receipt.entity(), insertInto: CoreDataStack.managedContext)
        receipt.amount = Int16(transaction.amount)
        receipt.payee = transaction.payee
        receipt.payeeIndex = Int16(transaction.payeeIndex)
        receipt.payer = transaction.payer
        receipt.payerIndex = Int16(transaction.payerIndex)
        
        managedReceipts.append(receipt)
        CoreDataStack.appDelegate.saveContext()
    }
    
    func saveChangedOrder() {
        
        for i in (0..<managedUsers.count){
            managedUsers[i].index = Int16(i)
        }
        
        CoreDataStack.appDelegate.saveContext()
    }
	
}
