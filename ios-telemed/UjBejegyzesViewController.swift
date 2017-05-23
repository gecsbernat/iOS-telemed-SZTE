//
//  UjBejegyzesViewController.swift
//  ios-telemed
//
//  Created by Gecs Bernat on 2017. 05. 02..
//  Copyright © 2017. ios2017. All rights reserved.
//

import UIKit
import HealthKit

class UjBejegyzesViewController: UIViewController {

    @IBOutlet weak var eventText: UITextField! //event text
    @IBOutlet weak var diaText: UITextField! //dia text
    @IBOutlet weak var sysText: UITextField! //sys text
    @IBOutlet weak var idopontText: UILabel! //idopont text
    @IBOutlet weak var saveHealthBTN: UISwitch! //healthkit
    
    var healthstore: HKHealthStore? = nil
    var readdata:NSSet? = nil
    var writedata:NSSet? = nil
    
    var date = NSDate() //date valtozo
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm"
        date = sender.date as NSDate
        idopontText.text = dateformatter.string(from: sender.date)
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
        
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let naplo = NaploEntity(context: context)
            
            naplo.esemeny = eventText.text ?? "Ismeretlen"
            naplo.datum = date
            naplo.dia = Int16(diaText.text!) ?? 0
            naplo.sys = Int16(sysText.text!) ?? 0
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            if(saveHealthBTN.isOn){
                saveBloodPressure(systolic: Double(sysText.text!)!, diastolic: Double(diaText.text!)!)
            }
            
            dismiss(animated: true, completion: nil)
        }

    }
    
    //adat mentese healthkitbe
    public func saveBloodPressure(systolic systolicValue: Double, diastolic diastolicValue: Double) {
        let unit = HKUnit.millimeterOfMercury()
        
        let systolicQuantity = HKQuantity(unit: unit, doubleValue: systolicValue)
        let diastolicQuantity = HKQuantity(unit: unit, doubleValue: diastolicValue)
        
        let systolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)!
        let diastolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)!
        
        let nowDate = Date()
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
