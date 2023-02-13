//
//  NotesTableViewController.swift
//  FSNotes
//
//  Created by sergey on 13.02.2023.
//

import UIKit

class NotesTableViewController: UITableViewController {
    var notes: [String] = []
    var folderName: String = "" {
        didSet {
            notes = DocumentsModel.notes(from: folderName)
        }
    }
    @IBAction func addFile(_ sender: Any) {
        createAlert()
    }
    
    func createAlert() {
        let alert = UIAlertController(title: "Create New Folder", message: "Enter folder name", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = "New Note \(self.notes.count+1)"
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            guard let alert = alert else { return }
            let textField = alert.textFields![0]
            if let text = textField.text {
                DocumentsModel.create(file: text, in: self.folderName)
                self.notes = DocumentsModel.notes(from: self.folderName)
                self.tableView.reloadData()
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItems?.append(self.editButtonItem)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "note")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "note", for: indexPath) as! TableViewCell

        // Configure the cell...
        cell.label.text = notes[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goeditor", sender: notes[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            DocumentsModel.remove(file: notes[indexPath.row], in: folderName)
            notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! TextViewController
        vc.folderName = folderName
        vc.noteName = sender as? String
    }
    

}
