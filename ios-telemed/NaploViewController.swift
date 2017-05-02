//
//  NaploViewController.swift
//  ios-telemed
//
//  Created by Gecs Bernat on 2017. 04. 27..
//  Copyright © 2017. ios2017. All rights reserved.
//

import UIKit
import CoreData

class NaploViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var naploTable: UITableView!

    var naplo : [NaploEntity] = [] //ebben taroljuk a coredata adatot
    
    override func viewDidLoad() {
        super.viewDidLoad()
        naploTable.dataSource = self
        naploTable.delegate = self
        self.naploTable.rowHeight = 80
    }
    
    //betoltes
    override func viewWillAppear(_ animated: Bool) {
        getData()
        naploTable.reloadData()
    }
    
    //mennyi sorbol all a table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return naplo.count
    }
    
    //cella beallitasa
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       // let cell = UITableViewCell()
        let cell = naploTable.dequeueReusableCell(withIdentifier: "naploTableCell")
        let bejegyzes = naplo[indexPath.row]
        cell?.textLabel?.text = bejegyzes.event
        cell?.detailTextLabel?.text = "Dátum: \(String(describing: bejegyzes.date!))  diammHg: \(bejegyzes.dia)  sysmmHg: \(bejegyzes.sys) \n"
        return cell!
    }
    
    //torles balra huzasnal
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if editingStyle == .delete {
            let bejegyzes = naplo[indexPath.row]
            context.delete(bejegyzes)
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            do{
                naplo = try context.fetch(NaploEntity.fetchRequest())
            }
            catch{
                print("error")
            }
        }
        naploTable.reloadData()
    }
    
    //adatnyeres a coredata-bol
    func getData(){
       let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do{
        naplo = try context.fetch(NaploEntity.fetchRequest())
        }
        catch{
            print("error")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
