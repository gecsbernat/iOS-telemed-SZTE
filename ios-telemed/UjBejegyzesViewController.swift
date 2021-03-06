//
//  UjBejegyzesViewController.swift
//  ios-telemed
//
//  Created by Gecs Bernat on 2017. 05. 02..
//  Copyright © 2017. ios2017. All rights reserved.
//

import UIKit
import CoreData
import HealthKit

class UjBejegyzesViewController: UIViewController {

    @IBOutlet weak var eventText: UITextField! //event text
    @IBOutlet weak var diaText: UITextField! //dia text
    @IBOutlet weak var sysText: UITextField! //sys text
    @IBOutlet weak var idopontText: UILabel! //idopont text
    @IBOutlet weak var saveHealthBTN: UISwitch! //healthkit
    @IBOutlet weak var saveReferenceSwitch: UISwitch!
    
    var reference : [ReferenceEntity] = []
    
    var healthstore: HKHealthStore? = nil
    var readdata:NSSet? = nil
    var writedata:NSSet? = nil
    let dateformatter = DateFormatter()
    var date: String = "" //date valtozo
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm"
        date = dateformatter.string(from: Date())
        if HKHealthStore.isHealthDataAvailable() {
            saveHealthBTN.isEnabled = true
            healthstore = HKHealthStore()
            let systolic = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)
            let diastolic = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)
            readdata = NSSet(objects: systolic!, diastolic!)
            writedata = NSSet(objects: systolic!,diastolic!)
            healthstore?.requestAuthorization(toShare: writedata as? Set<HKSampleType>, read: readdata as? Set<HKObjectType>, completion: {(success, error) in})
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func datePicker(_ sender: UIDatePicker) {
        //date = date.addingTimeInterval(7200) //fix 2 hour difference
        idopontText.text = dateformatter.string(from: sender.date)
        date = idopontText.text!
    }
    
    //adatok mentese core data-ba
    @IBAction func addEvent(_ sender: UIBarButtonItem) {
        if(eventText.text!.isEmpty){
            let alert = UIAlertController(title: "Hiba!", message: "Üres az esemény mező.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else if(sysText.text!.isEmpty){
            let alert = UIAlertController(title: "Hiba!", message: "Üres a SYS.Hgmm mező.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else if(diaText.text!.isEmpty){
            let alert = UIAlertController(title: "Hiba!", message: "Üres a DIA.Hgmm mező.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else if(Int16(sysText.text!)! > 300){
            let alert = UIAlertController(title: "Hiba!", message: "Túl magas SYS.Hgmm érték!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else if(Int16(sysText.text!)! < 10 && Int16(sysText.text!)! != 0){
            let alert = UIAlertController(title: "Hiba!", message: "Túl alacsony SYS.Hgmm érték!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else if(Int16(diaText.text!)! > 300){
            let alert = UIAlertController(title: "Hiba!", message: "Túl magas DIA.Hgmm érték!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else if(Int16(diaText.text!)! < 10 && Int16(diaText.text!)! != 0){
            let alert = UIAlertController(title: "Hiba!", message: "Túl alacsony DIA.Hgmm érték!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
        
            
            
            if(Int16(diaText.text!) == 0){
                let context1 = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let naplo2 = Naplo2Entity(context: context1)
                naplo2.what = eventText.text ?? "Ismeretlen"
                naplo2.when = date
                
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                print("asd")
                dismiss(animated: true, completion: nil)
            }else{
                let context2 = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let naplo = NaploEntity(context: context2)
                naplo.esemeny = eventText.text ?? "Ismeretlen"
                naplo.datum = date
                naplo.dia = Int16(diaText.text!) ?? 0
                naplo.sys = Int16(sysText.text!) ?? 0
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
                if(saveHealthBTN.isOn){
                    saveBloodPressure(systolic: Double(sysText.text!)!, diastolic: Double(diaText.text!)!)
                }
            
                if(saveReferenceSwitch.isOn){
                    saveReference()
                }
                dismiss(animated: true, completion: nil)
            }
        }

    }
    
    func saveReference(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ReferenceEntity> = ReferenceEntity.fetchRequest()
        do{
            reference = try context.fetch(fetchRequest)
    
        }
        catch{
            print("Error fetching data.")
        }
        reference[0].refSys = Int16(sysText.text!)!
        reference[0].refDia = Int16(diaText.text!)!
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    //adat mentese healthkitbe
    public func saveBloodPressure(systolic systolicValue: Double, diastolic diastolicValue: Double) {
        let unit = HKUnit.millimeterOfMercury()
        
        let systolicQuantity = HKQuantity(unit: unit, doubleValue: systolicValue)
        let diastolicQuantity = HKQuantity(unit: unit, doubleValue: diastolicValue)
        
        let systolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)!
        let diastolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)!
        
        let nowDate = dateformatter.date(from: date)!
        let systolicSample = HKQuantitySample(type: systolicType, quantity: systolicQuantity, start: nowDate, end: nowDate)
        let diastolicSample = HKQuantitySample(type: diastolicType, quantity: diastolicQuantity, start: nowDate, end: nowDate)
        
        let objects: Set<HKSample> = [systolicSample, diastolicSample]
        let type = HKObjectType.correlationType(forIdentifier: .bloodPressure)!
        let correlation = HKCorrelation(type: type, start: nowDate, end: nowDate, objects: objects)
        
        
        healthstore?.save(correlation) { (success, error) -> Void in
            if !success {
                print("An error occured saving the Blood pressure sample \(systolicSample). In your app, try to handle this gracefully. The error was: \(String(describing: error)).")
            }
        }
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}
