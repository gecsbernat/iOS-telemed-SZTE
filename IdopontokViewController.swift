//
//  IdopontokViewController.swift
//  ios-telemed
//
//  Created by Gecs Bernat on 2017. 05. 09..
//  Copyright © 2017. ios2017. All rights reserved.
//

import UIKit
import CoreData

class IdopontokViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var idopontokTable: UITableView! //tableview
    
    var idopontok: [IdopontEntity] = [] //tomb az adatok tarolasara

    override func viewDidLoad() {
        super.viewDidLoad()
        idopontokTable.dataSource = self
        idopontokTable.delegate = self
        idopontokTable.reloadData()
    }
    
    //betoltes
    override func viewWillAppear(_ animated: Bool) {
        getData()
        idopontokTable.reloadData()
    }
    
    //uj idopont letrehozasa
    @IBAction func ujIdopont(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Új időpont", message: "", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Mentés", style: .default, handler: ({
            (_) in
            let text = alertController.textFields![0].text
            let date = alertController.textFields![1].text
            self.saveData(text: text!, date: date!)
            self.idopontokTable.reloadData()
        }))
        
        let cancelAction = UIAlertAction(title: "Mégse", style: .cancel, handler: nil)
        
        alertController.addTextField(configurationHandler: {
            (textField) in
            
            textField.placeholder = "Szöveg"
        })
        
        alertController.addTextField(configurationHandler: {
            (textField) in
            
            textField.placeholder = "Időpont"
        })
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }

    
    //mennyi sorbol all a table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return idopontok.count
    }
    
    //cella beallitasa
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = idopontokTable.dequeueReusableCell(withIdentifier: "idopontCell")
        let bejegyzes = idopontok[indexPath.row]
        var datum = String(describing: bejegyzes.date!)
        let index = datum.index(datum.startIndex, offsetBy: 16)
        datum = datum.substring(to: index)
        cell?.textLabel?.text = bejegyzes.text
        cell?.detailTextLabel?.text = datum
        return cell!
    }
    
    //adatnyeres coredata-bol
    func getData(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<IdopontEntity> = IdopontEntity.fetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        do{
            idopontok = try context.fetch(fetchRequest)
        }
        catch{
            print("Error fetching data.")
        }
    }
    
    //adatok mentese
    func saveData(text: String, date: String){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let idopont = IdopontEntity(context: context)
        idopont.text = text
        idopont.date = NSDate()
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        idopontok.insert(idopont, at: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
