//
//  FolderTableViewController.swift
//  FSNotes
//
//  Created by sergey on 13.02.2023.
//

import UIKit

class FolderTableViewController: UITableViewController {
    
    var folders: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItems?.append(self.editButtonItem)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "folder")
        
        
        // initial state
        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: "isAppAlreadyLaunchedOnce") {
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            print("App launched first time")
            DocumentsModel.createFolder(with: "My folder")
            DocumentsModel.create(file: "Hello", in: "My folder")
            let url = Bundle.main.url(forResource: "Hello", withExtension: "rtf")!
            let attributedString = try? NSAttributedString(url: url, options: [.documentType:NSAttributedString.DocumentType.rtf], documentAttributes: nil)
            DocumentsModel.writeAttr(text: attributedString ?? .init(), to: "Hello", in: "My folder")
            folders = DocumentsModel.folders
            performSegue(withIdentifier: "gonotes", sender: folders[0])
        }
        folders = DocumentsModel.folders
    }
    @IBAction func addFolder(_ sender: Any) {
        createAlert()
    }
    
    func createAlert() {
        //1. Create alert
        let alert = UIAlertController(title: "Create New Folder", message: "Enter folder name", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = "New Folder"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            guard let alert = alert else { return }
            let textField = alert.textFields![0] // Force unwrapping because we know it exists.
            if let text = textField.text {
                DocumentsModel.createFolder(with: text)
                self.folders = DocumentsModel.folders
                self.tableView.reloadData()
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folders.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "folder", for: indexPath) as! TableViewCell
        
        // Configure the cell...
        cell.label.text = folders[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "gonotes", sender: folders[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            DocumentsModel.remove(file: nil, in: folders[indexPath.row])
            folders.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let vc = segue.destination as! NotesTableViewController
        vc.folderName = sender as! String
        
    }
    
    
}
