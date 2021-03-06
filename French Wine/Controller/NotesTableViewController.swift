//
//  NotesTableViewController.swift
//  French Wine
//
//  Created by Jan Polzer on 1/1/19.
//  Copyright © 2019 Apps KC. All rights reserved.
//

import UIKit
import CoreData

typealias NoteHandler = (Bool, [Note]) -> ()

class NotesTableViewController: UITableViewController {
    
    
    // MARK: - Properties
    
    private var coreData = CoreDataStack()
    private var noteToUpdate: Note?
    private var noteList = [Note]()
    private var note: Note?
    private var wineService: WineService?
    
    var managedObjectContext: NSManagedObjectContext? {
        didSet {
            if let moc = managedObjectContext {
                wineService = WineService(moc: moc)
            }
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func addNoteButton(_ sender: Any) {
        present(alertController(actionType: "Add"), animated: true, completion: nil)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Notes"
        loadNotes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func awakeFromNib() {
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noteList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath) as! NoteTableViewCell
        
        cell.configureCell(note: noteList[indexPath.row])
        
        return cell
    }
    
    // MARK: - Tableview delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        noteToUpdate = noteList[indexPath.row]
        present(alertController(actionType: "Update"), animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            wineService?.delete(note: noteList[indexPath.row], deleteHandler: { [weak self] (success) in
                if success {
                    self?.noteList.remove(at: indexPath.row)
                    self?.tableView.deleteRows(at: [indexPath], with: .fade)
                } else {
                    let alertController = UIAlertController(title: "Delete failed", message: "", preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(alertAction)
                    self?.present(alertController, animated: true, completion: nil)
                }
            })
        }
    }
    
    // MARK: - Private functions
    
    private func alertController(actionType: String) -> UIAlertController {
        
        let alertController = UIAlertController(title: "Wine note", message: "", preferredStyle: UIAlertController.Style.alert)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            if self.noteToUpdate?.body == "" {
                textField.placeholder = "Write a new note"
            } else {
                textField.text = self.noteToUpdate?.body
            }
        }
        
        let defaultAction = UIAlertAction(title: actionType, style: UIAlertAction.Style.default, handler: { alert -> Void in
            guard
                let body = alertController.textFields![0].text
                else {return}
            
            if actionType == "Add" {
                self.wineService?.addNote(body: body, completion: { (success, notes) in
                    if success {
                        self.noteList = notes
                    }
                })
            } else if actionType == "Update" {
                guard
                    let body = alertController.textFields?[0].text,
                    !body.isEmpty,
                    let noteToUpdate = self.noteToUpdate
                    else {return}
                
                self.wineService?.update(note: noteToUpdate, withBody: body)
                self.noteToUpdate = nil
            }
            // run on non-main thread
            DispatchQueue.main.async {
                self.loadNotes()
            }
        })
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in
            self.noteToUpdate = nil
        })
        
        alertController.addAction(defaultAction)
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
    private func loadNotes() {
        
        if let notes = wineService?.getNotes() {
            noteList = notes
            tableView.reloadData()
        }
    }
}
