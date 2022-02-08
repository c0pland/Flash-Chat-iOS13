//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase
class ChatViewController: UIViewController {
    let db = Firestore.firestore()
    var messages: [Message] = []
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.register(UINib(nibName: constants.cellNibName, bundle: nil), forCellReuseIdentifier: constants.cellIdentifier)
        navigationController?.navigationItem.hidesBackButton = true
        loadMessages()
    }
    func loadMessages() {
        db.collection(constants.FStore.collectionName).order(by: constants.FStore.dateField).addSnapshotListener( ) { querySnapshot, error in
            if let e = error {
                print("Error: \(e)")
            } else {
                if let snapshotDocument = querySnapshot?.documents {
                    self.messages = []
                    for doc in snapshotDocument {
                        let data = doc.data()
                        if let messageSender = data[constants.FStore.senderField] as? String, let messageBody = data[constants.FStore.bodyField] as? String {
                            let newMessage = Message(sender: messageSender, body: messageBody)
                            self.messages.append(newMessage)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email {
            db.collection(constants.FStore.collectionName).addDocument(data: [constants.FStore.senderField: messageSender, constants.FStore.bodyField: messageBody, constants.FStore.dateField: Date().timeIntervalSince1970]) { error in
                if let e = error {
                    print("Error\(e)")
                }else {
                    DispatchQueue.main.async {
                        self.messageTextfield.text = ""
                    }
                }
            }
        }
    }
    
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier:  constants.cellIdentifier, for: indexPath) as! MessageCell
        cell.label?.text = message.body
        if message.sender == Auth.auth().currentUser?.email { //message from current user
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: constants.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: constants.BrandColors.purple)
        }else {
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: constants.BrandColors.purple)
            cell.label.textColor = UIColor(named: constants.BrandColors.lightPurple)
        }
        
        return cell
    }
}
