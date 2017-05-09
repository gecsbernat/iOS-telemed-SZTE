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
    @IBOutlet weak var atlagText: UILabel!
    
    @IBAction func exportButton(_ sender: UIBarButtonItem) {
       let shareVC = UIActivityViewController(activityItems: ["asd"], applicationActivities: nil)
        shareVC.popoverPresentationController?.sourceView = self.view
        self.present(shareVC, animated: true, completion: nil)
    }

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
        atlag()
        naploTable.reloadData()
    }
    
    //mennyi sorbol all a table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return naplo.count
    }
    
    //cella beallitasa
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = naploTable.dequeueReusableCell(withIdentifier: "naploTableCell")
        let bejegyzes = naplo[indexPath.row]
        var datum = String(describing: bejegyzes.date!)
        let index = datum.index(datum.startIndex, offsetBy: 19)
        datum = datum.substring(to: index)
        let SYS = bejegyzes.sys
        let DIA = bejegyzes.dia
        cell?.textLabel?.text = bejegyzes.event
        
        if(SYS != 0.0 && DIA != 0.0){
            let pulse = SYS - DIA
            cell?.detailTextLabel?.text = "Dátum: \(datum)\nSYS.mmHg: \(SYS), DIA.mmHg: \(DIA), pulzusnyomás: \(pulse)"
        }else{
            cell?.detailTextLabel?.text = "Dátum: \(datum)"
        }
        
        return cell!
    }
    
    //torles balra huzasnal
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if editingStyle == .delete {
            let bejegyzes = naplo[indexPath.row]
            context.delete(bejegyzes)
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            getData()
        }
        atlag()
        naploTable.reloadData()
    }
    
    //adatnyeres a coredata-bol, datum szerint rendezve: legutobbi elol.
    func getData(){
       let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NaploEntity> = NaploEntity.fetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        do{
            naplo = try context.fetch(fetchRequest)
        }
        catch{
            print("error")
        }
    }
    
    //atlagertekek szamitasa
    func atlag(){
        var atlagDIA = 0.0
        var atlagSYS = 0.0
        var atlagPul = 0.0
        var cnt = 0.0
        var db = 0
        
        for ertek in naplo {
            if(ertek.value(forKey: "dia")as! Double != 0.0 && ertek.value(forKey: "sys") as! Double != 0.0){
                atlagDIA += ertek.value(forKey: "dia") as! Double
                atlagSYS += ertek.value(forKey: "sys") as! Double
                cnt += 1.0
            }
        }
        
        atlagDIA = (cnt != 0) ? atlagDIA / cnt : 0.0
        atlagSYS = (cnt != 0) ? atlagSYS / cnt : 0.0
        atlagPul = atlagSYS - atlagDIA
        db = Int(cnt)
        atlagText.text = String("\(db) db minta átlaga: SYS:\(atlagSYS.rounded()), DIA:\(atlagDIA.rounded()), pulzusnyomás:\(atlagPul.rounded())")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
