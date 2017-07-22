//
//  AddPlayerViewController.swift
//  MonoBank
//
//  Created by Richard Neitzke on 04/01/2017.
//  Copyright © 2017 Richard Neitzke. All rights reserved.
//

import UIKit

class AddPlayerViewController: UITableViewController, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	@IBOutlet var nameTextField: UITextField!
	@IBOutlet var balanceTextField: UITextField!
	@IBOutlet var currencySymbolLabel: UILabel!
	@IBOutlet var tokenCollectionView: UICollectionView!
	
	let tokens = ["cannon", "car", "cat", "dog", "hat", "horse", "iron", "money", "ship", "shoe", "thimble", "wheelbarrow"]
	var selectedToken = 0
	
	override func viewDidLoad() {
		currencySymbolLabel.text = BankManager.shared.currencySymbol
		balanceTextField.text = String(BankManager.shared.defaultBalance)
		balanceTextField.placeholder = String(BankManager.shared.defaultBalance)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		nameTextField.becomeFirstResponder()
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField.restorationIdentifier == "nameTextField" {
			balanceTextField.becomeFirstResponder()
		}
		return false
	}
	
	// TableView
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 2 && indexPath.row == 0 {
			let strippedBalance = balanceTextField.text!.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
			let name = nameTextField.text!.isEmpty ? "Player" : nameTextField.text!
			let balance = Int(strippedBalance) == nil ? BankManager.shared.defaultBalance : Int(strippedBalance)!
			let player = Player(name: name, balance: balance, token: Token(rawValue: tokens[selectedToken])!)
			BankManager.shared.players.append(player)
			BankManager.shared.save()
			let mainViewController = navigationController?.viewControllers.first as! MainViewController
			mainViewController.playerCollectionView.reloadData()
			mainViewController.playerNumberChanged()
			navigationController?.popViewController(animated: true)
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.section == 1 && indexPath.row == 0 {
			// iPhone has two rows, iPad has one row
			let rowsHeight = UIDevice.current.userInterfaceIdiom == .phone ? tokenCellSize.height*2: tokenCellSize.height
			return rowsHeight + 30
		} else {
			return 44
		}
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if section == 0 {
			return 25
		} else {
			return 5
		}
	}
	
	// Token CollectionView
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 12
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let tokenCell = collectionView.dequeueReusableCell(withReuseIdentifier: "tokenCell", for: indexPath) as! TokenCollectionViewCell
		let isSelected = indexPath.item == selectedToken
		let tokenName = isSelected ? tokens[indexPath.item] + "_filled" : tokens[indexPath.item]
		tokenCell.tokenView.image = UIImage(named: tokenName)!.withRenderingMode(.alwaysTemplate)
		let affineTransform = isSelected ? CGAffineTransform(scaleX: 1.1, y: 1.1) : CGAffineTransform.identity
		UIView.animate(withDuration: 0.1, animations: {
			tokenCell.transform = affineTransform
		})
		return tokenCell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		selectedToken = indexPath.item
		collectionView.reloadData()
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return tokenCellSize
	}
	
	var tokenCellSize: CGSize {
		// iPhone has two rows, iPad has one row
		let amountOfCellsInRow: CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 6 : 12
		let horizontalSpace = 20 + (10 * amountOfCellsInRow - 1)
		let width = (tableView.bounds.width-horizontalSpace)/amountOfCellsInRow
		return CGSize(width: width, height: width)
	}
	
}
