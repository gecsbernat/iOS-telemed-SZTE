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
    
    @IBOutlet weak var segmented: UISegmentedControl!
    
    @IBAction func segmentedAction(_ sender: UISegmentedControl) {
        naploTable.reloadData()
    }
    
    var naplo : [NaploEntity] = [] //ebben taroljuk a coredata adatot
    var naplo2 : [Naplo2Entity] = []
    let dateformatter = DateFormatter()
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
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm"
        naploTable.dataSource = self
        naploTable.delegate = self
        naploTable.rowHeight = 80
        
        alertText.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        alertText.text = "Nincs adat."
        print(segmented.selectedSegmentIndex)
    }
    
    //mennyi sorbol all a table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmented.selectedSegmentIndex {
        case 0 : return naplo.count
        case 1 : return naplo2.count
        default : return naplo.count
        }
    }
    
    //cella beallitasa
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = naploTable.dequeueReusableCell(withIdentifier: "naploTableCell")
        
        switch segmented.selectedSegmentIndex {
        case 0:
            let bejegyzes = naplo[indexPath.row]
            let datum = bejegyzes.datum!
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
        case 1 :
            let bejegyzes = naplo2[indexPath.row]
            let datum = bejegyzes.when!
            cell?.textLabel?.text = bejegyzes.what!
            cell?.detailTextLabel?.text = "Dátum: \(datum)"
        default:
            return cell!
        }

        
        return cell!
    }
    
    //torles balra huzasnal
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let context1 = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        switch segmented.selectedSegmentIndex {
        case 0:
            if editingStyle == .delete {
                let bejegyzes = naplo[indexPath.row]
                context1.delete(bejegyzes)
                
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                getData()
            }
        case 1 :
            if editingStyle == .delete {
                let bejegyzes = naplo2[indexPath.row]
                context1.delete(bejegyzes)
                
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                getData()
            }
        default:
            break
        }

        atlag()
        naploTable.reloadData()
    }
    
    //adatnyeres a coredata-bol, datum szerint rendezve: legutobbi elol.
    func getData(){
       let context1 = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest1: NSFetchRequest<NaploEntity> = NaploEntity.fetchRequest()
        let sort1 = NSSortDescriptor(key: "datum", ascending: false)
        fetchRequest1.sortDescriptors = [sort1]
        do{
            naplo = try context1.fetch(fetchRequest1)
        }
        catch{
            print("Error fetching data.")
        }
        
        let context2 = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest2: NSFetchRequest<Naplo2Entity> = Naplo2Entity.fetchRequest()
        fetchRequest2.returnsObjectsAsFaults = false
        let sort2 = NSSortDescriptor(key: "when", ascending: false)
        fetchRequest2.sortDescriptors = [sort2]
        do{
            naplo2 = try context2.fetch(fetchRequest2)
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
        var date: String?
        var DIA: Int?
        var SYS: Int?
        var event: String?
        
        var export: String = NSLocalizedString("Datum,Esemeny,SYS,DIA\n", comment: "")
        for ertek in naplo {
            date = ertek.value(forKey: "datum") as! String!
            DIA = ertek.value(forKey: "dia") as? Int!
            SYS = ertek.value(forKey: "sys") as? Int!
            event = ertek.value(forKey: "esemeny") as? String!
            export += "\(date!),\(String(describing: event!)),\(String(describing: SYS!)),\(String(describing: DIA!))\n"
        }
        export += ",,,\n"
        for ertek2 in naplo2 {
            date = ertek2.value(forKey: "when") as! String!
            event = ertek2.value(forKey: "what") as? String!
            export += "\(date!),\(String(describing: event!)),-,-\n"
        }
        print("This is what the app will export: \(export)") //debug
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
            avgDia.removeAll()
            avgSys.removeAll()
            dailyDia.removeAll()
            dailySys.removeAll()
            dailyCount.removeAll()
            //Napok kigyűjtése
            var days = 0
            var dayCounter = 0
            
            //Előző nap, ciklusban kell
            var prevDay = dateformatter.date(from: naplo[0].value(forKey: "datum") as! String)
            
            //Utolsó felvett adat, nem tartozik az átlaghoz
            let lastSys = naplo[0].value(forKey: "sys") as! Int
            let lastDia = naplo[0].value(forKey: "dia") as! Int
            
            //Megszámoljuk a napokat
            for i in 1..<naplo.count
            {
                let order = NSCalendar.current.compare(prevDay!, to: dateformatter.date(from: naplo[i].value(forKey: "datum") as! String)!, toGranularity: .day)
                if((order != .orderedSame) || (i == 1 && order == .orderedSame)){
                    days += 1
                }
                prevDay = dateformatter.date(from: naplo[i].value(forKey: "datum") as! String)
            }

            if(days > sectionSize) {
                //Ujrainicializálás
                prevDay = dateformatter.date(from: naplo[1].value(forKey: "datum") as! String)
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
                    let order = NSCalendar.current.compare(prevDay!, to: (dateformatter.date(from: naplo[i].value(forKey: "datum") as! String))!,
                                                           toGranularity: .day)
                    if(order != .orderedSame && i != 1){
                        dayCounter += 1
                    }
                    dailySys[dayCounter] += naplo[i].value(forKey: "sys") as! Int
                    dailyDia[dayCounter] += naplo[i].value(forKey: "dia") as! Int
                    dailyCount[dayCounter] += 1
                    
                    prevDay = dateformatter.date(from: naplo[i].value(forKey: "datum") as! String)
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

                if (lastSys >= refSys + offsetProblemSys && lastDia >= refDia + offsetProblemDia){
                    //alertText.backgroundColor = UIColor.red.withAlphaComponent(0.2)
                    //alertText.text = "Mindkét vérnyomásmérték jóval magasabb a referenciaértéknél, kérem forduljon orvoshoz!"
                    print("Mindkét vérnyomásmérték jóval magasabb a referenciaértéknél, kérem forduljon orvoshoz!")
                    //print(1)
                    writeAlertText(string: "Mindkét vérnyomásmérték jóval magasabb a referenciaértéknél, kérem forduljon orvoshoz!", color: UIColor.red.withAlphaComponent(0.2))
                } else if (lastSys < refSys + offsetProblemSys && lastDia >= refDia + offsetProblemDia){
                    //alertText.backgroundColor = UIColor.red.withAlphaComponent(0.2)
                    //alertText.text = "A diasztolés jóval magasabb a referenciaértéknél, kérem forduljon orvoshoz!"
                    print("A diasztolés jóval magasabb a referenciaértéknél, kérem forduljon orvoshoz!")
                    //print(2)
                    writeAlertText(string: "A diasztolés jóval magasabb a referenciaértéknél, kérem forduljon orvoshoz!", color: UIColor.red.withAlphaComponent(0.2))
                } else if (lastSys >= refSys + offsetProblemSys && lastDia < refDia + offsetProblemDia){
                    //alertText.backgroundColor = UIColor.red.withAlphaComponent(0.2)
                    //alertText.text = "A szisztolés jóval magasabb a referenciaértéknél, kérem forduljon orvoshoz!"
                    print("A szisztolés jóval magasabb a referenciaértéknél, kérem forduljon orvoshoz!")
                    //print(3)
                    writeAlertText(string: "A szisztolés jóval magasabb a referenciaértéknél, kérem forduljon orvoshoz!", color: UIColor.red.withAlphaComponent(0.2))
                } else {
                    print("Nincs a korlátot átlépő kiugró érték")
                    //alertText.backgroundColor = UIColor.green.withAlphaComponent(0.2)
                    //alertText.text = "Minden rendben!"
                    //print(4)
                    writeAlertText(string: "Minden rendben!", color: UIColor.green.withAlphaComponent(0.2))
                }
                
                if (lastSys >= avgSys[0] + offsetProblemSys && lastDia >= avgDia[0] + offsetProblemDia){
                   // alertText.backgroundColor = UIColor.red.withAlphaComponent(0.2)
                   // alertText.text = "Mindkét vérnyomásmérték jóval magasabb az átlagnál, kérem forduljon orvoshoz!"
                    print("Mindkét vérnyomásmérték jóval magasabb az átlagnál, kérem forduljon orvoshoz!")
                    //print(5)
                    writeAlertText(string: "Mindkét vérnyomásmérték jóval magasabb az átlagnál, kérem forduljon orvoshoz!", color: UIColor.red.withAlphaComponent(0.2))
                } else if (lastSys < avgSys[0] + offsetProblemSys && lastDia >= avgDia[0] + offsetProblemDia){
                    //alertText.backgroundColor = UIColor.red.withAlphaComponent(0.2)
                    //alertText.text = "A diasztolés jóval magasabb az átlagnál, kérem forduljon orvoshoz!"
                    print("A diasztolés jóval magasabb az átlagnál, kérem forduljon orvoshoz!")
                    //print(6)
                    writeAlertText(string: "A diasztolés jóval magasabb az átlagnál, kérem forduljon orvoshoz!", color: UIColor.red.withAlphaComponent(0.2))
                } else if (lastSys >= avgSys[0] + offsetProblemSys && lastDia < avgDia[0] + offsetProblemDia){
                    //alertText.backgroundColor = UIColor.red.withAlphaComponent(0.2)
                    //alertText.text = "A szisztolés jóval magasabb az átlagnál, kérem forduljon orvoshoz!"
                    print("A szisztolés jóval magasabb az átlagnál, kérem forduljon orvoshoz!")
                   // print(7)
                    writeAlertText(string: "A szisztolés jóval magasabb az átlagnál, kérem forduljon orvoshoz!", color: UIColor.red.withAlphaComponent(0.2))
                } else {
                    print("Nincs a korlátot átlépő kiugró érték")
                    //alertText.backgroundColor = UIColor.green.withAlphaComponent(0.2)
                    //alertText.text = "Minden rendben!"
                   // print(8)
                    writeAlertText(string: "Minden rendben!", color: UIColor.green.withAlphaComponent(0.2))
                }
            }
        }else{
            alertText.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
            alertText.text = "Nincs elég adat."
        }
    }
    
    //export gomb
    @IBAction func exportButton(_ sender: UIBarButtonItem) {
        if(naplo.count != 0 || naplo2.count != 0){
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
    
    func writeAlertText(string: String, color: UIColor){
        let prevtext = alertText.text!
        if(prevtext == "Nincs adat." || prevtext == "Nincs elég adat." || prevtext == "Minden rendben!"){
            alertText.text = string
            alertText.backgroundColor = color
        }
    }
}
