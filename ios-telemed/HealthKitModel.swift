//
//  HealthKitModel.swift
//  ios-telemed
//
//  Created by Rita Sumegi on 2017. 05. 22..
//  Copyright © 2017. ios2017. All rights reserved.
//

import Foundation
import  HealthKit

class HealthKitModel {
    
    var healthstore: HKHealthStore? = nil
    var readdata: NSSet? = nil
    var writedata:NSSet? = nil
    
    func initialize() -> Bool{
        var succ = false
        if HKHealthStore.isHealthDataAvailable() {
            healthstore = HKHealthStore()
            let systolic = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)
            let diastolic = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)
            readdata = NSSet(objects: systolic!, diastolic!)
            writedata = NSSet(objects: systolic!,diastolic!)
            healthstore?.requestAuthorization(toShare: writedata as? Set<HKSampleType>, read: readdata as? Set<HKObjectType>, completion: {
                (success, error) in
                if(success){succ = true}
            })
        }
        return succ
    }
}
