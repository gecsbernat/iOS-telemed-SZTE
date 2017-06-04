//
//  HealthkitViewController.swift
//  ios-telemed
//
//  Created by Rita Sumegi on 2017. 06. 02..
//  Copyright © 2017. ios2017. All rights reserved.
//

import UIKit
import CoreData
import HealthKit

class HealthkitViewController: UIViewController {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var healthstore: HKHealthStore? = nil
    var readdata:NSSet? = nil
    var writedata:NSSet? = nil
    let dateformatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm"
        if HKHealthStore.isHealthDataAvailable() {
            healthstore = HKHealthStore()
            let systolic = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)
            let diastolic = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)
            readdata = NSSet(objects: systolic!, diastolic!)
            writedata = NSSet(objects: systolic!,diastolic!)
            healthstore?.requestAuthorization(toShare: writedata as? Set<HKSampleType>, read: readdata as? Set<HKObjectType>, completion: {(success, error) in
                if let error = error { print(error) }
                self.fetchHealthkit()
                self.delayWithSeconds(1) {
                    self.dismiss(animated: true, completion: nil)
                }
                
            })
        }else{
            let alert = UIAlertController(title: "", message: "Nem érhető el a Healthkit", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //adatkinyerés healthkitből
    func fetchHealthkit(){
        indicator.startAnimating()
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: true)
        let type = HKQuantityType.correlationType(forIdentifier: HKCorrelationTypeIdentifier.bloodPressure)
        
        let sampleQuery = HKSampleQuery(sampleType: type!, predicate: nil, limit: 0, sortDescriptors: [sortDescriptor]){ (sampleQuery, results, error ) -> Void in
            let dataLst = results as? [HKCorrelation];
            let context4 = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            context4.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            for index in 0 ..< dataLst!.count {
                let data1 = (dataLst![index].objects(for: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureSystolic)!)).first as? HKQuantitySample
                let data2 = (dataLst![index].objects(for: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureDiastolic)!)).first as? HKQuantitySample
                
                let date = self.dateformatter.string(from: (data1?.startDate)!)
                let systolic = data1?.quantity.doubleValue(for: HKUnit.millimeterOfMercury())
                let diastolic = data2?.quantity.doubleValue(for: HKUnit.millimeterOfMercury())

                let bejegyzes = NaploEntity(context: context4)
                bejegyzes.datum = date
                bejegyzes.esemeny = "Vérnyomás mérés"
                bejegyzes.dia = Int16(diastolic!)
                bejegyzes.sys = Int16(systolic!)
                
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
            }
        }
        self.healthstore?.execute(sampleQuery)
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
}
