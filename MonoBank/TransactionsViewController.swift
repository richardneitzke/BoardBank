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
        
        let transaction = BankManager.shared.transactions.last
        let receipt = BankManager.shared.managedReceipts.last
        var newBalance = Int()
        
        if transaction?.payerIndex == -1 {
            let receivedAmount = transaction?.amount
            let currentPlayerBalance = BankManager.shared.players[(transaction?.payeeIndex)!].balance
            newBalance = currentPlayerBalance - receivedAmount!
            BankManager.shared.players[(transaction?.payeeIndex)!].balance = newBalance
            BankManager.shared.managedUsers[(transaction?.payeeIndex)!].balance = Int16(newBalance)
        } else if transaction?.payeeIndex == -1{
            let receivedAmount = transaction?.amount
            let currentPlayerBalance = BankManager.shared.players[(transaction?.payerIndex)!].balance
            newBalance = currentPlayerBalance + receivedAmount!
            BankManager.shared.players[(transaction?.payerIndex)!].balance = newBalance
            BankManager.shared.managedUsers[(transaction?.payerIndex)!].balance = Int16(newBalance)
        } else {
            let receivedAmount = transaction?.amount
            let currentPayeeBalance = BankManager.shared.players[(transaction?.payeeIndex)!].balance
            let currentPayerBalance = BankManager.shared.players[(transaction?.payerIndex)!].balance
            let newCurrentPayeeBalance = currentPayeeBalance - receivedAmount!
            let newCurrentPayerBalance = currentPayerBalance + receivedAmount!
            BankManager.shared.players[(transaction?.payeeIndex)!].balance = newCurrentPayeeBalance
            BankManager.shared.players[(transaction?.payerIndex)!].balance = newCurrentPayerBalance
            BankManager.shared.managedUsers[(transaction?.payeeIndex)!].balance = Int16(newCurrentPayeeBalance)
            BankManager.shared.managedUsers[(transaction?.payerIndex)!].balance = Int16(newCurrentPayerBalance)
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
