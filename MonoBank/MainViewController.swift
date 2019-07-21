//
//  MainViewController.swift
//  MonoBank
//
//  Created by Richard Neitzke on 03/01/2017.
//  Copyright © 2017 Richard Neitzke. All rights reserved.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

	@IBOutlet var playerCollectionView: UICollectionView!
	@IBOutlet var addPlayerButton: UIBarButtonItem!
	@IBOutlet var infoLabel: UILabel!
	
	/// Maximum amount of players
	let maxPlayers = 6
	/// Number of player cells per row
	var numberOfPlayersPerRow: CGFloat = 2
	
	// Variables for Transactions
	var fromPoint: CGPoint?
	var fromPlayer: Int?
	var toPlayer: Int?
	
	// Current path and layer of the transaction line
	var linePath = UIBezierPath()
	var lineLayer = CAShapeLayer()
	
	// Cell that is currently being moved
	var movingCell: UICollectionViewCell?
	
	// AudiPlayer for playing the cash register sound
	var audioPlayer: AVAudioPlayer!
	
	override func viewDidLoad() {
		// Configure gestureRecognizer
		let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(panGestureRecognizer:)))
		let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
		self.view.addGestureRecognizer(panGestureRecognizer)
		self.view.addGestureRecognizer(longPressGestureRecognizer)
		
		// Configure lineLayer
		lineLayer.lineWidth = 5
		lineLayer.strokeColor = UIColor.gray.cgColor
		view.layer.addSublayer(lineLayer)
		
		// Initialize numberOfPlayersPerRow
		numberOfPlayersPerRow = UIApplication.shared.statusBarOrientation.isPortrait ? 2 : 3
		
		// Initialize audioPlayer
		if let soundPath = Bundle.main.path(forResource: "CashRegister", ofType: "mp3") {
			let soundURL = URL(fileURLWithPath: soundPath)
			try! audioPlayer = AVAudioPlayer(contentsOf: soundURL)
		} else {
			audioPlayer = AVAudioPlayer()
		}
		
		playerNumberChanged()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		// Refresh numberOfPlayersPerRow
		numberOfPlayersPerRow = UIApplication.shared.statusBarOrientation.isPortrait ? 2 : 3
		playerCollectionView.reloadData()
	}
	
	/// Disable/enable addPlayerButton
	func playerNumberChanged() {
		if BankManager.shared.players.count < maxPlayers {
			addPlayerButton.isEnabled = true
		} else {
			addPlayerButton.isEnabled = false
		}
		if BankManager.shared.players.count > 0 {
			infoLabel.isHidden = true
		} else {
			infoLabel.isHidden = false
		}
	}
	
	// Methods that handle transactions
	
    @objc func handlePanGesture(panGestureRecognizer: UIPanGestureRecognizer) {
		switch panGestureRecognizer.state {
		case .began:
			// New line, reset fromPlayer and fromPoint
			fromPlayer = nil
			fromPoint = nil
			
			if let fromPlayer = playerForPoint(gestureRecognizer: panGestureRecognizer) {
				self.fromPlayer = fromPlayer
				fromPoint = panGestureRecognizer.location(in: view)
				animateCellPop(forPlayer: fromPlayer, active: true)
				
			}
		case .changed:
			// Draw line between fromPoint and current location
			guard let fromPoint = fromPoint else { return }
			linePath.removeAllPoints()
			linePath.move(to: fromPoint)
			linePath.addLine(to: panGestureRecognizer.location(in: view))
			lineLayer.opacity = 1
			lineLayer.path = linePath.cgPath
			
			// Animate transaction pop of toPlayer
			guard let potentialToPlayer = playerForPoint(gestureRecognizer: panGestureRecognizer) else {
				animateCellPop(forPlayer: toPlayer, active: false)
				toPlayer = nil
				return
			}
			
			guard potentialToPlayer != fromPlayer else {
				animateCellPop(forPlayer: toPlayer, active: false)
				toPlayer = nil
				return
			}
			
			if potentialToPlayer != toPlayer {
				animateCellPop(forPlayer: toPlayer, active: false)
				animateCellPop(forPlayer: potentialToPlayer, active: true)
				toPlayer = potentialToPlayer
			}
			
			
		case .ended:
			// Animate fade away of transaction line
			UIView.animate(withDuration: 1, animations: { self.lineLayer.opacity = 0 })
			
			// Animate transaction pop
			animateCellPop(forPlayer: fromPlayer, active: false)
			animateCellPop(forPlayer: toPlayer, active: false)
			
			toPlayer = nil
			
			guard let toPlayer = playerForPoint(gestureRecognizer: panGestureRecognizer),
				let fromPlayer = fromPlayer, fromPlayer != toPlayer
				else { return }
			
			let fromName = fromPlayer == -1 ? "Bank" : BankManager.shared.players[fromPlayer].name
			let toName = toPlayer == -1 ? "Bank" : BankManager.shared.players[toPlayer].name
			
			let transactionAlertController = UIAlertController(title: "Transfer Money", message: "from \(fromName) to \(toName)", preferredStyle: .alert)
			transactionAlertController.addTextField(configurationHandler: {
				$0.keyboardType = .numberPad
				$0.text = BankManager.shared.currencySymbol + " "
			})
			let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
				// Transfer money from fromPlayer to toPlayer
				let strippedInput = transactionAlertController.textFields!.first!.text!.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
				if let amount = Int(strippedInput) {
					if fromPlayer == -1 {
						BankManager.shared.players[toPlayer].balance += amount
					} else if toPlayer == -1 {
						BankManager.shared.players[fromPlayer].balance -= amount
					} else {
						BankManager.shared.players[fromPlayer].balance -= amount
						BankManager.shared.players[toPlayer].balance += amount
					}
				}
				BankManager.shared.save()
				self.playerCollectionView.reloadData()
				if BankManager.shared.soundsEnabled { self.audioPlayer.play() }
			})
			transactionAlertController.addAction(okAction)
			let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
			transactionAlertController.addAction(cancelAction)
			present(transactionAlertController, animated: true)
		default:
			print("Gesture Recognizer State not handled")
		}
	}
	
	/// Returns the number of the playerCell at a given point, -1 for bank
	func playerForPoint(gestureRecognizer: UIGestureRecognizer) -> Int? {
		let item = playerCollectionView.indexPathForItem(at: gestureRecognizer.location(in: playerCollectionView))?.item
		guard let selectedItem = item else { return nil }
		return selectedItem - 1
	}
	
	/// Animates transaction pop for a player
	func animateCellPop(forPlayer player: Int?, active: Bool) {
		guard let player = player else { return }
		let cell = playerCollectionView.cellForItem(at: IndexPath(item: player+1, section: 0))
		let affineTransfrom = active ? CGAffineTransform(scaleX: 1.1, y: 1.1) : CGAffineTransform.identity
		UIView.animate(withDuration: 0.1, animations: {
			cell?.transform = affineTransfrom
		})
	}
	
	// Methods that handle moving cells
	
    @objc func handleLongPressGesture(gestureRecognizer: UILongPressGestureRecognizer) {
		let movingIndexPath = playerCollectionView.indexPathForItem(at: gestureRecognizer.location(in: playerCollectionView))
		switch gestureRecognizer.state {
		case .began:
			guard let indexPath = movingIndexPath else { break }
			guard indexPath.item != 0 else { break }
			movingCell = playerCollectionView.cellForItem(at: indexPath)
			UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
				self.movingCell?.alpha = 0.7
				self.movingCell?.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
			}, completion: nil)
			playerCollectionView.beginInteractiveMovementForItem(at: indexPath)
		case .changed:
			playerCollectionView.updateInteractiveMovementTargetPosition(gestureRecognizer.location(in: playerCollectionView))
			movingCell?.alpha = 0.7
			movingCell?.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
		case .ended:
			playerCollectionView.endInteractiveMovement()
			animatePuttingDownCell(cell: movingCell)
		default:
			playerCollectionView.cancelInteractiveMovement()
			animatePuttingDownCell(cell: movingCell)
		}
	}
	
	// Disable movement of the bank cell
	func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
		return indexPath.item == 0 ? false : true
	}
	
	func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		guard destinationIndexPath.item != 0 else { return }
		BankManager.shared.players.insert(BankManager.shared.players.remove(at: sourceIndexPath.item-1), at: destinationIndexPath.item-1)
	}
	
	// Disable movement to the bank cell
	func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
		if proposedIndexPath.item == 0 {
			return IndexPath(item: 1, section: 0)
		} else {
			return proposedIndexPath
		}
	}
	
	// By littlebitesofcocoa.com/104-interactive-collection-view-re-ordering
	func animatePuttingDownCell(cell: UICollectionViewCell?) {
		UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
			cell?.alpha = 1.0
			cell?.transform = CGAffineTransform.identity
		}, completion: nil)
	}
	
	
	
	// PlayerCollectionView
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return BankManager.shared.players.count + 1 // Bank + Players
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if indexPath.item == 0 {
			// Bank Cell
			let bankCell = collectionView.dequeueReusableCell(withReuseIdentifier: "bankCell", for: indexPath)
			return bankCell
		} else {
			// Player Cell
			let playerCell = collectionView.dequeueReusableCell(withReuseIdentifier: "playerCell", for: indexPath) as! PlayerCollectionViewCell
			let player = BankManager.shared.players[indexPath.item-1]
			playerCell.nameLabel.text = player.name
			playerCell.balanceLabel.text = BankManager.shared.numberFormatter.string(from: player.balance as NSNumber)!
			if player.balance > 0 {
				playerCell.balanceLabel.textColor = UIColor.black
			} else {
				playerCell.balanceLabel.textColor = UIColor.red
			}
			playerCell.tokenView.image = UIImage(named: player.token.rawValue)?.withRenderingMode(.alwaysTemplate)
			return playerCell
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if indexPath.item == 0 {
			return bankCellSize
		} else {
			return playerCellSize
		}
	}
	
	var bankCellSize: CGSize {
		let flowLayout = playerCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
		let horizintalInsets = flowLayout.sectionInset.left+flowLayout.sectionInset.right
		return CGSize(width: playerCollectionView.bounds.width-horizintalInsets, height: playerCollectionView.bounds.height/8)
	}
	
	var playerCellSize: CGSize {
		let flowLayout = playerCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
		let horizintalInsets = flowLayout.sectionInset.left+flowLayout.sectionInset.right
		let verticalInsets = flowLayout.sectionInset.top + flowLayout.sectionInset.bottom
		
		let horizontalSpace = horizintalInsets + (flowLayout.minimumInteritemSpacing * (numberOfPlayersPerRow - 1))
		let width = (playerCollectionView.bounds.width-horizontalSpace)/numberOfPlayersPerRow
		
		let verticalSpace = verticalInsets + (flowLayout.minimumLineSpacing * ceil(CGFloat(maxPlayers)/numberOfPlayersPerRow))
		let height = (playerCollectionView.bounds.height-verticalSpace-(playerCollectionView.bounds.height/8))/ceil(CGFloat(maxPlayers)/numberOfPlayersPerRow)

		return CGSize(width: width, height: height)
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if indexPath.item != 0 {
			let cell = collectionView.cellForItem(at: indexPath)!
			let player = BankManager.shared.players[indexPath.item-1]
			let playerAlertController = UIAlertController(title: "\(player.name): \(BankManager.shared.numberFormatter.string(from: player.balance as NSNumber)!)", message: "What do you want to do with this player?", preferredStyle: .actionSheet)
			//
			playerAlertController.popoverPresentationController?.sourceView = cell.contentView
			playerAlertController.popoverPresentationController?.sourceRect = cell.contentView.frame
			let quickAddAction = UIAlertAction(title: "Add \(BankManager.shared.numberFormatter.string(from: BankManager.shared.quickAddAmount as NSNumber)!)", style: .default, handler: { action in
				player.balance += BankManager.shared.quickAddAmount
				BankManager.shared.save()
				collectionView.reloadData()
			})
			playerAlertController.addAction(quickAddAction)
			let renameAction = UIAlertAction(title: "Rename", style: .default, handler: { action in
				let renameAlertController = UIAlertController(title: "Rename Player", message: "Enter a new name for \(player.name).", preferredStyle: .alert)
				renameAlertController.addTextField(configurationHandler: { $0.autocapitalizationType = .words })
				let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
					if !renameAlertController.textFields!.first!.text!.isEmpty {
						player.name = renameAlertController.textFields!.first!.text!
						BankManager.shared.save()
						collectionView.reloadData()
					}
				})
				renameAlertController.addAction(okAction)
				let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
				renameAlertController.addAction(cancelAction)
				self.present(renameAlertController, animated: true)
			})
			playerAlertController.addAction(renameAction)
			let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { action in
				BankManager.shared.players.remove(at: indexPath.item-1)
				BankManager.shared.save()
				collectionView.reloadData()
				self.playerNumberChanged()
			})
			playerAlertController.addAction(deleteAction)
			let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
			playerAlertController.addAction(cancelAction)
			present(playerAlertController, animated: true)
		}
	}
	
	// Methods required to support landscape
	
	override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
		numberOfPlayersPerRow = toInterfaceOrientation.isPortrait ? 2 : 3
	}
	
	override func viewWillLayoutSubviews() {
		playerCollectionView.reloadData()
	}
	
	
}
