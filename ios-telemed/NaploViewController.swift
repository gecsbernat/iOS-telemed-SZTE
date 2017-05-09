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
    
    //export gomb
    @IBAction func exportButton(_ sender: UIBarButtonItem) {
        exportDatabase()
    }

    var naplo : [NaploEntity] = [] //ebben taroljuk a coredata adatot
    
    override func viewDidLoad() {
        super.viewDidLoad()
        naploTable.dataSource = self
        naploTable.delegate = self
        naploTable.rowHeight = 80
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
            cell?.detailTextLabel?.text = "Dátum: \(datum)\nVérnyomás: \(SYS)/\(DIA), pulzusnyomás: \(pulse)"
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
            print("Error fetching data.")
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
            if(ertek.value(forKey: "dia") as! Double != 0.0 && ertek.value(forKey: "sys") as! Double != 0.0){
                atlagDIA += ertek.value(forKey: "dia") as! Double
                atlagSYS += ertek.value(forKey: "sys") as! Double
                cnt += 1.0
            }
        }
        
        atlagDIA = (cnt != 0) ? atlagDIA / cnt : 0.0
        atlagSYS = (cnt != 0) ? atlagSYS / cnt : 0.0
        atlagPul = atlagSYS - atlagDIA
        db = Int(cnt)
        atlagText.text = String("\(db) minta átlaga: \(atlagSYS.rounded())/\(atlagDIA.rounded()), pulzusnyomás: \(atlagPul.rounded())")
    }
    
    //export begin
    func exportDatabase() {
        let exportString = createExportString()
        saveAndExport(exportString: exportString)
    }
    
    //tempfile letrehozas
    func saveAndExport(exportString: String) {
        let date: String = String(describing: Date())
        let exportFilePath = NSTemporaryDirectory() + "naploexport"+date+".csv"
        let exportFileURL = NSURL(fileURLWithPath: exportFilePath)
        FileManager.default.createFile(atPath: exportFilePath, contents: NSData() as Data, attributes: nil)

        var fileHandle: FileHandle? = nil
        do {
            fileHandle = try FileHandle(forWritingTo: exportFileURL as URL)
        } catch {
            print("Error with fileHandle")
        }
        
        if fileHandle != nil {
            fileHandle!.seekToEndOfFile()
            let csvData = exportString.data(using: String.Encoding.utf8, allowLossyConversion: false)
            fileHandle!.write(csvData!)
            
            fileHandle!.closeFile()
            
            let firstActivityItem = NSURL(fileURLWithPath: exportFilePath)
            let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [firstActivityItem], applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    //csv string
    func createExportString() -> String {
        var date: NSDate?
        var DIA: Double?
        var SYS: Double?
        var event: String?
        
        var export: String = NSLocalizedString("Date,Event,SYS,DIA\n", comment: "")
        for ertek in naplo {
            date = ertek.value(forKey: "date") as? NSDate!
            DIA = ertek.value(forKey: "dia") as? Double!
            SYS = ertek.value(forKey: "sys") as? Double!
            event = ertek.value(forKey: "event") as? String!
            export += "\(date!),\(String(describing: event!)),\(String(describing: SYS!)),\(String(describing: DIA!))\n"
        }
        //print("This is what the app will export: \(export)") //debug
        return export
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
