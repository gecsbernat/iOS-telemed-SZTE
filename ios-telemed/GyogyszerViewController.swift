//
//  NaploViewController.swift
//  ios-telemed
//
//  Created by Tibor on 5/1/17.
//  Copyright © 2017 ios2017. All rights reserved.
//
import UIKit
import CoreData
import UserNotifications

class GyogyszerViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var medTable: UITableView!
    var meds: [GyogyszerEntity] = []
    let center = UNUserNotificationCenter.current()

    override func viewDidLoad() {
        super.viewDidLoad()
        medTable.dataSource = self
        medTable.delegate = self
        medTable.reloadData()
        if(meds.count == 0){
            center.removeAllDeliveredNotifications()
            center.removeAllPendingNotificationRequests()
        }
    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getMeds()
        medTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = medTable.dequeueReusableCell(withIdentifier: "MedCell")
        let record = meds[indexPath.row]
        var datum = String(describing: record.datum!)
        let index = datum.index(datum.startIndex, offsetBy: 16)
        datum = datum.substring(to: index)
        cell?.textLabel?.text = record.nev! + ", " + String(describing: record.mennyiseg) + " " + record.mennyisegTipus! + ", " + record.mikor!
        cell?.detailTextLabel?.text = datum
        return cell!
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if editingStyle == .delete {
            let record = meds[indexPath.row]
            let id = record.nev
            context.delete(record)
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            center.removePendingNotificationRequests(withIdentifiers: [id!])
            getMeds()
            medTable.reloadData()
        }
        
    }
    
    func getMeds(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<GyogyszerEntity> = GyogyszerEntity.fetchRequest()
        let sort = NSSortDescriptor(key: "datum", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        do{
            meds = try context.fetch(fetchRequest)
        }
        catch{
            print("Hiba az adatkinyeres soran!")
        }

    }
    
    func saveMeds(nev: String, mennyiseg: Int16, mennyisegTipus: String, mikor: String, date: String){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let med = GyogyszerEntity(context: context)
        med.datum = NSDate()
        med.mennyiseg = mennyiseg
        med.mennyisegTipus = mennyisegTipus
        med.mikor = mikor
        med.nev = nev
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        meds.insert(med, at: 0)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
