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

    @IBOutlet weak var naploTable: UITableView!
    @IBOutlet weak var atlagText: UILabel!
    @IBOutlet weak var refreshBTN: UIBarButtonItem!
    var naplo : [NaploEntity] = [] //ebben taroljuk a coredata adatot
    var healthstore: HKHealthStore? = nil
    var readdata:NSSet? = nil
    var writedata:NSSet? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        naploTable.dataSource = self
        naploTable.delegate = self
        naploTable.rowHeight = 80
        
        if HKHealthStore.isHealthDataAvailable() {
            refreshBTN.isEnabled = true
            healthstore = HKHealthStore()
            let systolic = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)
            let diastolic = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)
            readdata = NSSet(objects: systolic!, diastolic!)
            writedata = NSSet(objects: systolic!,diastolic!)
            healthstore?.requestAuthorization(toShare: writedata as? Set<HKSampleType>, read: readdata as? Set<HKObjectType>, completion: {(success, error) in
                if(!success){
                    self.refreshBTN.isEnabled = false
                }
            })
        }else{
            refreshBTN.isEnabled = false
        }
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
        cell?.textLabel?.text = bejegyzes.esemeny
        
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
        let sort = NSSortDescriptor(key: "datum", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        do{
            naplo = try context.fetch(fetchRequest)
        }
        catch{
            print("Error fetching data.")
        }
    }
    
    //adatkinyerés healthkitből
    func fetchHealthkit(){
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: true)
        let type = HKQuantityType.correlationType(forIdentifier: HKCorrelationTypeIdentifier.bloodPressure)
        
        let sampleQuery = HKSampleQuery(sampleType: type!, predicate: nil, limit: 0, sortDescriptors: [sortDescriptor]){ (sampleQuery, results, error ) -> Void in
            let dataLst = results as? [HKCorrelation];
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                for index in 0 ..< dataLst!.count {
                    let data1 = (dataLst![index].objects(for: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureSystolic)!)).first as? HKQuantitySample
                    let data2 = (dataLst![index].objects(for: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureDiastolic)!)).first as? HKQuantitySample
                    
                    let date = data1?.startDate
                    let systolic = data1?.quantity.doubleValue(for: HKUnit.millimeterOfMercury())
                    let diastolic = data2?.quantity.doubleValue(for: HKUnit.millimeterOfMercury())
                    
                    let bejegyzes = NaploEntity(context: context)
                    bejegyzes.datum = date! as NSDate?
                    bejegyzes.esemeny = "Vérnyomás mérés"
                    bejegyzes.dia = Int16(diastolic!)
                    bejegyzes.sys = Int16(systolic!)
                    (UIApplication.shared.delegate as! AppDelegate).saveContext()
                    self.getData()
                    self.naploTable.reloadData()
                }
            }
        self.healthstore?.execute(sampleQuery)
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
    }
    
    //export gomb
    @IBAction func exportButton(_ sender: UIBarButtonItem) {
        exportDatabase()
    }
    
    //refresh gomb
    @IBAction func refreshData(_ sender: UIBarButtonItem) {
        fetchHealthkit()
        atlag()
        naploTable.reloadData()
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
