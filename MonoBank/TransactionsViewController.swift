//
//  TransactionsViewController.swift
//  BoardBank
//
//  Created by Miguel Tepale on 8/16/17.
//  Copyright © 2017 Richard Neitzke. All rights reserved.
//

import UIKit

class TransactionsViewController: UIViewController {
    
    @IBOutlet weak var transactionsTableView: UITableView!
    @IBOutlet weak var undoButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        transactionsTableView.allowsSelection = false
        transactionsNumberChanged()
    }
    
    // Transfer money from toPlayer to fromPlayer
    @IBAction func undoButton(_ sender: UIBarButtonItem) {
        
        var newBalance = Int32()
        let receipt = BankManager.shared.managedReceipts.last
        var shiftedPayerIndex = Int()
        var shiftedPayeeIndex = Int()
        let transaction = BankManager.shared.transactions.last
        
        //Check for nil if banker is present
        if let payerIndex = BankManager.shared.players.index(where: {$0.name == transaction?.payer}) {
            shiftedPayerIndex = payerIndex
        }
        else {
            shiftedPayerIndex = -1
        }
        
        if let payeeIndex = BankManager.shared.players.index(where: {$0.name == transaction?.payee}) {
            shiftedPayeeIndex = payeeIndex
        }
        else {
            shiftedPayeeIndex = -1
        }
        
        //If tokens were moved, update indices
        if transaction?.payerIndex != shiftedPayerIndex {
            transaction?.payerIndex = shiftedPayerIndex
        }
        if transaction?.payeeIndex != shiftedPayeeIndex{
            transaction?.payeeIndex = shiftedPayeeIndex
        }
        
        //Undo transactions//
        
        //If banker payed
        if transaction?.payerIndex == -1 && shiftedPayeeIndex != -1 && shiftedPayerIndex != -1 {
            let receivedAmount = transaction?.amount
            let currentPlayerBalance = BankManager.shared.players[(transaction?.payeeIndex)!].balance
            
            newBalance = currentPlayerBalance - receivedAmount!
            BankManager.shared.players[(transaction?.payeeIndex)!].balance = newBalance
            BankManager.shared.managedUsers[(transaction?.payeeIndex)!].balance = newBalance
        //If banker was payed
        } else if transaction?.payeeIndex == -1 && shiftedPayeeIndex != -1 && shiftedPayerIndex != -1{
            let receivedAmount = transaction?.amount
            let currentPlayerBalance = BankManager.shared.players[(transaction?.payerIndex)!].balance
            newBalance = currentPlayerBalance + receivedAmount!
            BankManager.shared.players[(transaction?.payerIndex)!].balance = newBalance
            BankManager.shared.managedUsers[(transaction?.payerIndex)!].balance = newBalance
        }
        //If both payee and payer exist
          else if shiftedPayeeIndex >= 0 && shiftedPayerIndex >= 0{
            let receivedAmount = transaction?.amount
            let currentPayeeBalance = BankManager.shared.players[(transaction?.payeeIndex)!].balance
            let currentPayerBalance = BankManager.shared.players[(transaction?.payerIndex)!].balance
            let newCurrentPayeeBalance = currentPayeeBalance - receivedAmount!
            let newCurrentPayerBalance = currentPayerBalance + receivedAmount!
            
            BankManager.shared.players[(transaction?.payeeIndex)!].balance = newCurrentPayeeBalance
            BankManager.shared.players[(transaction?.payerIndex)!].balance = newCurrentPayerBalance
            BankManager.shared.managedUsers[(transaction?.payeeIndex)!].balance = newCurrentPayeeBalance
            BankManager.shared.managedUsers[(transaction?.payerIndex)!].balance = newCurrentPayerBalance
        }
        //If payee exists but payer does not
        else if shiftedPayeeIndex >= 0 && shiftedPayerIndex == -1 {
            let receivedAmount = transaction?.amount
            let currentPayeeBalance = BankManager.shared.players[(transaction?.payeeIndex)!].balance
            let newCurrentPayeeBalance = currentPayeeBalance - receivedAmount!
            BankManager.shared.players[(transaction?.payeeIndex)!].balance = newCurrentPayeeBalance
            BankManager.shared.managedUsers[(transaction?.payeeIndex)!].balance = newCurrentPayeeBalance
        }
        //If payer exists but payee does not
        else if shiftedPayeeIndex == -1 && shiftedPayerIndex >= 0   {
            let receivedAmount = transaction?.amount
            let currentPayerBalance = BankManager.shared.players[(transaction?.payerIndex)!].balance
            let newCurrentPayerBalance = currentPayerBalance + receivedAmount!
            BankManager.shared.players[(transaction?.payerIndex)!].balance = newCurrentPayerBalance
            BankManager.shared.managedUsers[(transaction?.payerIndex)!].balance = newCurrentPayerBalance
        }
        
        // If both shiftedPayeeIndex && shiftedPayerIndex == -1
        else {
        }
        
        BankManager.shared.transactions.removeLast()
        BankManager.shared.managedReceipts.removeLast()
        CoreDataStack.managedContext.delete(receipt!)
        CoreDataStack.appDelegate.saveContext()
        
        transactionsTableView.reloadData()
        transactionsNumberChanged()
    }
    
    // Disable/enable undoButton
    func transactionsNumberChanged() {
        if BankManager.shared.transactions.count == 0 {
            navigationItem.rightBarButtonItem = nil
        } else {
            navigationItem.rightBarButtonItem = undoButton
        }
    }
}

extension TransactionsViewController: UITabBarDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BankManager.shared.transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        
        let transaction = BankManager.shared.transactions[indexPath.row]
        cell.textLabel?.text = "\(transaction.payer) paid \(transaction.payee): \(BankManager.shared.numberFormatter.string(from: transaction.amount as NSNumber)!)"
        
        return cell
    }
    
}
