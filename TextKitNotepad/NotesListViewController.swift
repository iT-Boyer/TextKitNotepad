//
//  NotesListViewController.swift
//  TextKitNotepad
//
//  Created by huoshuguang on 2016/11/19.
//  Copyright © 2016年 recomend. All rights reserved.
//

import UIKit

class NotesListViewController: UITableViewController {

    var notes:NSMutableArray = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let note = NoteModel.init("Shopping List\r\r1. Cheese\r2. Biscuits\r3. Sausages\r4. IMPORTANT Cash for going out!\r5. -potatoes-\r6. A copy of iOS6 by tutorials\r7. A new iPhone\r8. A present for mum")
        let note2 = NoteModel("Meeting notes\rA long and drawn out meeting, it lasted hours and hours and hours!")
        let note3 = NoteModel("Perfection ... \n\nPerfection is achieved not when there is nothing left to add, but when there is nothing left to take away - Antoine de Saint-Exupery")
        let note4 = NoteModel("Notes on iOS7\nThis is a big change in the UI design, it's going to take a *lot* of getting used to!")
        notes.addObjects(from: [note,note2,note3,note4])
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewDidAppear(_ animated: Bool)
    {
        tableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notes.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteListCell", for: indexPath)

        // Configure the cell...
        let note = notes[indexPath.row] as! NoteModel
//        cell.textLabel?.text = note.title
        let font = UIFont.preferredFont(forTextStyle: .headline)
        let textColor = UIColor.init(red: 0.175, green: 0.458, blue: 0.831, alpha: 1.0)
        //字体凸版印刷效果
        let store:[NSAttributedString.Key:Any] = [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue):textColor,
                                                  NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue):font,
                                                  NSAttributedString.Key(rawValue: NSAttributedString.Key.textEffect.rawValue):NSAttributedString.TextEffectStyle.letterpressStyle]
        cell.textLabel?.attributedText = NSAttributedString.init(string: note.title, attributes: store);
        
        
        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        
        if segue.identifier == "AddNewNote" {
            //
            let editNote = segue.destination as! NoteEditorViewController
            editNote.note = NoteModel("")
            notes.add(editNote.note)
        }
        
        if segue.identifier == "CellSelected" {
            //
            let editNote = segue.destination as! NoteEditorViewController
            let path = tableView.indexPathForSelectedRow
            editNote.note = notes[(path?.row)!] as! NoteModel
        }
    }
    
    
    @IBAction func ibaBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
