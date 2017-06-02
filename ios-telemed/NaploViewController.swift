//
//  NaploViewController.swift
//  ios-telemed
//
//  Created by Gecs Bernat on 2017. 04. 27..
//  Copyright © 2017. ios2017. All rights reserved.
//

import UIKit
import CoreData
import HealthKit

class NaploViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var alertText: UILabel!
    @IBOutlet weak var naploTable: UITableView!
    @IBOutlet weak var atlagText: UILabel!
    @IBOutlet weak var refreshBTN: UIBarButtonItem!
    var naplo : [NaploEntity] = [] //ebben taroljuk a coredata adatot
    var reference : [ReferenceEntity] = []
    var healthstore: HKHealthStore? = nil
    var refSys = 120
    var refDia = 80
    var offsetProblemSys = 20
    var offsetProblemDia = 20
    var sectionSize = 5
    
    //Munkatömbök
    var avgSys : [Int] = []
    var avgDia : [Int] = []
    var dailySys : [Int] = []
    var dailyDia : [Int] = []
    var dailyCount : [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        naploTable.dataSource = self
        naploTable.delegate = self
        naploTable.rowHeight = 80
        
        alertText.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        alertText.text = "Nincs adat."
    }
    
    //mennyi sorbol all a table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return naplo.count
    }
    
    //cella beallitasa
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = naploTable.dequeueReusableCell(withIdentifier: "naploTableCell")
        let bejegyzes = naplo[indexPath.row]
        var datum = String(describing: bejegyzes.datum!)
        let index = datum.index(datum.startIndex, offsetBy: 19)
        datum = datum.substring(to: index)
        let SYS = bejegyzes.sys
        let DIA = bejegyzes.dia
        if(avgSys.count > 0 && avgDia.count > 0){
            if(Int16(SYS) >= Int16(avgSys[0] + offsetProblemSys) || Int16(DIA) >= Int16(avgDia[0] + offsetProblemDia)){
                cell?.textLabel?.text = "❗️" + bejegyzes.esemeny!
            }else{
                cell?.textLabel?.text = bejegyzes.esemeny!
            }
        }else{
            cell?.textLabel?.text = bejegyzes.esemeny!
        }

        if(SYS != 0 && DIA != 0){
            let pulse = SYS - DIA
            cell?.detailTextLabel?.text = "Dátum: \(datum)\nVérnyomás: \(SYS)/\(DIA), pulzusnyomás: \(pulse)"
        }else{
            cell?.detailTextLabel?.text = "Dátum: \(datum)"
        }
        
        return cell!
    }
    
    //torles balra huzasnal
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let context1 = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if editingStyle == .delete {
            let bejegyzes = naplo[indexPath.row]
            context1.delete(bejegyzes)
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            getData()
        }
        atlag()
        naploTable.reloadData()
    }
    
    //adatnyeres a coredata-bol, datum szerint rendezve: legutobbi elol.
    func getData(){
       let context2 = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NaploEntity> = NaploEntity.fetchRequest()
        let sort = NSSortDescriptor(key: "datum", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        do{
            naplo = try context2.fetch(fetchRequest)
        }
        catch{
            print("Error fetching data.")
        }
        
        getReferences()
    }
    
    //Referenciaértékek coredata-ból
    func getReferences(){
        let context3 = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ReferenceEntity> = ReferenceEntity.fetchRequest()
        do{
            reference = try context3.fetch(fetchRequest)
            if (reference == []){
                let reference = ReferenceEntity(context: context3)
                reference.refSys = Int16(refSys)
                reference.refDia = Int16(refDia)
                reference.sysAlertThreshold = Int16(offsetProblemSys)
                reference.diaAlertThreshold = Int16(offsetProblemDia)
                reference.sectionSize = Int32(sectionSize)
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
            } else {
                refSys = Int(reference[0].refSys)
                refDia = Int(reference[0].refDia)
                offsetProblemSys = Int(reference[0].sysAlertThreshold)
                offsetProblemDia = Int(reference[0].diaAlertThreshold)
                sectionSize = Int(reference[0].sectionSize)
            }
        }
        catch{
            print("Error fetching data.")
        }
    }
    
    //export begin
    func exportDatabase() {
        let exportString = createExportString()
        saveAndExport(exportString: exportString)
    }
    
    //tempfile letrehozas
    func saveAndExport(exportString: String) {
        let date: String = String(describing: Date())
        let exportFilePath = NSTemporaryDirectory() + "naploexport-"+date+".csv"
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
        var DIA: Int?
        var SYS: Int?
        var event: String?
        
        var export: String = NSLocalizedString("Datum,Esemeny,SYS,DIA\n", comment: "")
        for ertek in naplo {
            date = ertek.value(forKey: "datum") as? NSDate!
            DIA = ertek.value(forKey: "dia") as? Int!
            SYS = ertek.value(forKey: "sys") as? Int!
            event = ertek.value(forKey: "esemeny") as? String!
            export += "\(date!),\(String(describing: event!)),\(String(describing: SYS!)),\(String(describing: DIA!))\n"
        }
       // print("This is what the app will export: \(export)") //debug
        return export
    }
    
    //atlagertekek szamitasa
    func atlag(){
        var atlagDIA = 0
        var atlagSYS = 0
        var atlagPul = 0
        var cnt = 0
        var db = 0
        
        for ertek in naplo {
            if(ertek.value(forKey: "dia") as! Int != 0 && ertek.value(forKey: "sys") as! Int != 0){
                atlagDIA += ertek.value(forKey: "dia") as! Int
                atlagSYS += ertek.value(forKey: "sys") as! Int
                cnt += 1
            }
        }
        
        atlagDIA = (cnt != 0) ? atlagDIA / cnt : 0
        atlagSYS = (cnt != 0) ? atlagSYS / cnt : 0
        atlagPul = atlagSYS - atlagDIA
        db = Int(cnt)
        atlagText.text = String("\(db) minta átlaga: \(atlagSYS)/\(atlagDIA), pulzusnyomás: \(atlagPul)")
        
        if(naplo.count > sectionSize){
            
            //Napok kigyűjtése
            var days = 0
            var dayCounter = 0
            
            //Előző nap, ciklusban kell
            var prevDay = naplo[0].value(forKey: "datum") as! NSDate
            
            //Utolsó felvett adat, nem tartozik az átlaghoz
            let lastSys = naplo[0].value(forKey: "sys") as! Int
            let lastDia = naplo[0].value(forKey: "dia") as! Int
            
            //Megszámoljuk a napokat
            for i in 1..<naplo.count
            {
                let order = NSCalendar.current.compare(prevDay as Date, to: (naplo[i].value(forKey: "datum") as! NSDate) as Date,
                                                       toGranularity: .day)
                if((order != .orderedSame) || (i == 1 && order == .orderedSame)){
                    days += 1
                }
                prevDay = naplo[i].value(forKey: "datum") as! NSDate
            }

            if(days > sectionSize) {
                //Ujrainicializálás
                prevDay = naplo[1].value(forKey: "datum") as! NSDate
                let sections = days / sectionSize
                //let last = days % sectionSize
                
                //0-kal való feltöltés
                for _ in 0..<days
                {
                    dailySys.append(0)
                    dailyDia.append(0)
                    dailyCount.append(0)
                }
                
                //Kigyűjtöm tömbökbe a napra lebontott mérések összegét
                for i in 1..<naplo.count
                {
                    let order = NSCalendar.current.compare(prevDay as Date, to: (naplo[i].value(forKey: "datum") as! NSDate) as Date,
                                                           toGranularity: .day)
                    if(order != .orderedSame && i != 1){
                        dayCounter += 1
                    }
                    dailySys[dayCounter] += naplo[i].value(forKey: "sys") as! Int
                    dailyDia[dayCounter] += naplo[i].value(forKey: "dia") as! Int
                    dailyCount[dayCounter] += 1
                    
                    prevDay = naplo[i].value(forKey: "datum") as! NSDate
                }
                
                //Itt átlagolom
                for i in 0..<dayCounter
                {
                    dailySys[i] /= dailyCount[i]
                    dailyDia[i] /= dailyCount[i]
                }
                
                //A végleges tömb feltöltése
                for _ in 0..<sections
                {
                    avgSys.append(0)
                    avgDia.append(0)
                }
                
                //Hány napra való bontásból számoljunk átlagot?
                for i in 0..<sections
                {
                    for j in 0..<sectionSize
                    {
                        if(dailySys[j + i * sectionSize] != 0 && dailyDia[j + i * sectionSize] != 0){
                            
                            avgSys[i] += dailySys[j + i * sectionSize]
                            avgDia[i] += dailyDia[j + i * sectionSize]
                        }
                    }
                }
                //Itt átlagolom a végleges össyegeket
                for i in 0..<sections
                {
                    avgSys[i] /= sectionSize
                    avgDia[i] /= sectionSize
                }
                /*  if ( last > 0 ){
                 avgSys.append(0)
                 avgDia.append(0)
                 for i in 0..<last
                 {
                 avgSys[sections] += naplo[naplo.count - last + i].value(forKey: "sys") as! Int
                 avgDia[sections] += naplo[naplo.count - last + i].value(forKey: "dia") as! Int
                 }
                 avgSys[sections] /= last
                 avgDia[sections] /= last
                 for i in 0...sections
                 {
                 print("\(avgSys[i])/\(avgDia[i])")
                 }
                 } else {*/
                for i in 0..<sections
                {
                    print("\(avgSys[i])/\(avgDia[i])")
                }
                //}
                        print(days)
                if (lastSys >= refSys + offsetProblemSys && lastDia >= refDia + offsetProblemDia){
                    alertText.isHidden = false
                    alertText.backgroundColor = UIColor.red.withAlphaComponent(0.2)
                    alertText.text = "Mindkét vérnyomásmérték jóval magasabb a referenciaértéknél, kérem forduljon orvoshoz!"
                    print("Mindkét vérnyomásmérték jóval magasabb a referenciaértéknél, kérem forduljon orvoshoz!")
                } else if (lastSys < refSys + offsetProblemSys && lastDia >= refDia + offsetProblemDia){
                    alertText.isHidden = false
                    alertText.backgroundColor = UIColor.red.withAlphaComponent(0.2)
                    alertText.text = "A diasztolés jóval magasabb a referenciaértéknél, kérem forduljon orvoshoz!"
                    print("A diasztolés jóval magasabb a referenciaértéknél, kérem forduljon orvoshoz!")
                } else if (lastSys >= refSys + offsetProblemSys && lastDia < refDia + offsetProblemDia){
                    alertText.isHidden = false
                    alertText.backgroundColor = UIColor.red.withAlphaComponent(0.2)
                    alertText.text = "A szisztolés jóval magasabb a referenciaértéknél, kérem forduljon orvoshoz!"
                    print("A szisztolés jóval magasabb a referenciaértéknél, kérem forduljon orvoshoz!")
                } else {
                    print("Nincs a korlátot átlépő kiugró érték")
                    alertText.backgroundColor = UIColor.green.withAlphaComponent(0.2)
                    alertText.text = "Minden rendben!"
                }
                
                if (lastSys >= avgSys[0] + offsetProblemSys && lastDia >= avgDia[0] + offsetProblemDia){
                    alertText.isHidden = false
                    alertText.backgroundColor = UIColor.red.withAlphaComponent(0.2)
                    alertText.text = "Mindkét vérnyomásmérték jóval magasabb az átlagnál, kérem forduljon orvoshoz!"
                    print("A diasztolés jóval magasabb az átlagnál, kérem forduljon orvoshoz!")
                } else if (lastSys < avgSys[0] + offsetProblemSys && lastDia >= avgDia[0] + offsetProblemDia){
                    alertText.isHidden = false
                    alertText.backgroundColor = UIColor.red.withAlphaComponent(0.2)
                    alertText.text = "A diasztolés jóval magasabb az átlagnál, kérem forduljon orvoshoz!"
                    print("A diasztolés jóval magasabb az átlagnál, kérem forduljon orvoshoz!")
                } else if (lastSys >= avgSys[0] + offsetProblemSys && lastDia < avgDia[0] + offsetProblemDia){
                    alertText.isHidden = false
                    alertText.backgroundColor = UIColor.red.withAlphaComponent(0.2)
                    alertText.text = "A szisztolés jóval magasabb az átlagnál, kérem forduljon orvoshoz!"
                    print("A szisztolés jóval magasabb az átlagnál, kérem forduljon orvoshoz!")
                } else {
                    print("Nincs a korlátot átlépő kiugró érték")
                    alertText.backgroundColor = UIColor.green.withAlphaComponent(0.2)
                    alertText.text = "Minden rendben!"
                }
            }
        }else{
            alertText.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
            alertText.text = "Nincs elég adat."
        }
    }
    
    //export gomb
    @IBAction func exportButton(_ sender: UIBarButtonItem) {
        if(naplo.count != 0){
            exportDatabase()
        }else{
            let alert = UIAlertController(title: "", message: "Üres a napló.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //betoltes
    override func viewWillAppear(_ animated: Bool) {
        getData()
        atlag()
        naploTable.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
