//
//  UjIdopontViewController.swift
//  ios-telemed
//
//  Created by Gecs Bernat on 2017. 05. 10..
//  Copyright © 2017. ios2017. All rights reserved.
//

import UIKit
import CoreData
import EventKit

class UjIdopontViewController: UIViewController {
    @IBOutlet weak var orvosneveText: UITextField!
    @IBOutlet weak var helyszinText: UITextField!
    @IBOutlet weak var idopontText: UILabel!
    @IBOutlet weak var saveCalendar: UISwitch!
    var date = NSDate()

    @IBAction func datePicker(_ sender: UIDatePicker) {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm"
        date = sender.date as NSDate
        idopontText.text = dateformatter.string(from: sender.date)
    }
    
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        if(orvosneveText.text?.isEmpty)!{
            let alert = UIAlertController(title: "Hiba!", message: "Üres az Orvos neve mező.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else if(helyszinText.text?.isEmpty)!{
            let alert = UIAlertController(title: "Hiba!", message: "Üres a Helyszín mező.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let bejegyzes = IdopontEntity(context: context)
        
            bejegyzes.orvosneve = orvosneveText.text!
            bejegyzes.helyszin = helyszinText.text!
            bejegyzes.datum = date
        
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            if(saveCalendar.isOn){
                addEventToCalendar(title: orvosneveText.text!, description: helyszinText.text!, startDate: date as Date, endDate: date as Date)
            }
            dismiss(animated: true, completion: nil)
        }
    }
    
    //esemeny mentese a naptarba
    func addEventToCalendar(title: String, description: String?, startDate: Date, endDate: Date, completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        let eventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                let event = EKEvent(eventStore: eventStore)
                event.title = "Orvosi időpont"
                event.startDate = startDate
                event.endDate = endDate
                event.notes = "Orvos neve: \(title)"
                event.location = description
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                } catch let e as NSError {
                    completion?(false, e)
                    return
                }
                completion?(true, nil)
            } else {
                completion?(false, error as NSError?)
            }
        })
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
