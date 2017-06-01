//
//  SettingsController.swift
//  ios-telemed
//
//  Created by Tibor on 5/31/17.
//  Copyright © 2017 ios2017. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SettingsController: UIViewController {
    
    @IBOutlet weak var thresholdSys: UITextField!
    @IBOutlet weak var thresholdDia: UITextField!
    @IBOutlet weak var sections: UITextField!
    
    var reference : [ReferenceEntity] = []
    
    
    enum ConvertError: Error {
        case numberFormat
    }
    
    @IBAction func saveReferences(_ sender: UIBarButtonItem) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ReferenceEntity> = ReferenceEntity.fetchRequest()
        do{
            reference = try context.fetch(fetchRequest)
            
        }
        catch{
            print("Error fetching data.")
        }
        if (thresholdSys.text?.isEmpty == false){
            do {
                try  reference[0].sysAlertThreshold = convertToInt16(text: thresholdSys.text!)
            } catch {
                let alert = UIAlertController(title: "Hiba!", message: "Egy mennyiseg nem szam!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        if (thresholdDia.text?.isEmpty == false){
            do {
                try  reference[0].diaAlertThreshold = convertToInt16(text: thresholdDia.text!)
            } catch {
                let alert = UIAlertController(title: "Hiba!", message: "Egy mennyiseg nem szam!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        if (sections.text?.isEmpty == false){
           // var test : Int32
            do {
                try  reference[0].sectionSize = convertToInt32(text: sections.text!)
               /* if(test > reference[0].sectionSize){
                    let alert = UIAlertController(title: "Hiba!", message: "Nagyobb a szelet, mint amennyi adat van!", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {*/
                //}
                
            } catch {
                let alert = UIAlertController(title: "Hiba!", message: "Egy mennyiseg nem szam!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        dismiss(animated: true, completion: nil)
    }
    
    func convertToInt16(text : String) throws -> Int16 {
        guard let result = Int16(text) else {
            throw ConvertError.numberFormat
        }
        return result
    }
    
    func convertToInt32(text : String) throws -> Int32 {
        guard let result = Int32(text) else {
            throw ConvertError.numberFormat
        }
        return result
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
