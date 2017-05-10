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
        idopontokTable.rowHeight = 50
    }
    
    //betoltes
    override func viewWillAppear(_ animated: Bool) {
        getData()
        idopontokTable.reloadData()
    }

    //mennyi sorbol all a table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return idopontok.count
    }
    
    //cella beallitasa
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = idopontokTable.dequeueReusableCell(withIdentifier: "idopontCell")
        let bejegyzes = idopontok[indexPath.row]
        var datum = String(describing: bejegyzes.datum!)
        let index = datum.index(datum.startIndex, offsetBy: 16)
        datum = datum.substring(to: index)
        cell?.textLabel?.text = bejegyzes.orvosneve! + ", " + bejegyzes.helyszin!
        cell?.detailTextLabel?.text = datum
        return cell!
    }
    
    //torles balrehuzassal
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if editingStyle == .delete {
            let bejegyzes = idopontok[indexPath.row]
            context.delete(bejegyzes)
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            getData()
            idopontokTable.reloadData()
        }
        
    }
    
    //adatnyeres coredata-bol
    func getData(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<IdopontEntity> = IdopontEntity.fetchRequest()
        let sort = NSSortDescriptor(key: "datum", ascending: false)
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
        idopont.orvosneve = text
        idopont.datum = NSDate()
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        idopontok.insert(idopont, at: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
