//
//  UjGyogyszerViewController.swift
//  ios-telemed
//
//  Created by Tibor on 5/23/17.
//  Copyright © 2017 ios2017. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class UjGyogyszerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var medName: UITextField!
    
    @IBOutlet weak var medAmount: UITextField!

    @IBOutlet weak var medAmountType: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var time = NSDate()
    
    @IBAction func timepicker(_ sender: UIDatePicker) {

        time = sender.date as NSDate
       // time = time.addingTimeInterval(7200) //fix 2 hour difference
        
    }
    
    
    var selectedType : String?
    var selectedWhen : String?
    
    
    enum ConvertError: Error {
        case numberFormat
    }
    
    let amountPickerDataSource = [["Tabletta", "Csepp", "Kapszula", "Kúp", "Kávéskanál", "Teáskanál", "ml"], ["Evés előtt", "Evés közben", "Evés után"]]

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(component == 0)
        {
            return amountPickerDataSource[0].count;
        }
        
        if(component == 1)
        {
            return amountPickerDataSource[1].count;
        }
        return -1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        return amountPickerDataSource[component][row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if(component == 0)
        {
            selectedType =  amountPickerDataSource[0][row];
        }
        if(component == 1)
        {
            selectedWhen =  amountPickerDataSource[1][row];
        }
    }
    
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        if (medName.text?.isEmpty)!{
            let alert = UIAlertController(title: "Hiba!", message: "Üres gyogyszer neve mező.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if (medAmount.text?.isEmpty)!{
            let alert = UIAlertController(title: "Hiba!", message: "Üres gyogyszer mennyiség mező.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let record = GyogyszerEntity(context: context)
            record.nev = medName.text!
            do {
                try record.mennyiseg = convertToInt16()
            } catch is Error {
                let alert = UIAlertController(title: "Hiba!", message: "A gyogyszer mennyiseg nem szam!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            record.mennyisegTipus = selectedType
            record.mikor = selectedWhen
            record.datum = time
            
            //notification
            let center = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = "Gyógyszerbevétel időpontja"
            content.subtitle = "Kérem vegye be \(String(describing: medName.text!)) nevű gyógyszerét!"
            content.body = "\(record.mennyiseg) \(String(describing: selectedType!)) \(String(describing: selectedWhen!))"
            content.sound = UNNotificationSound.default()
            content.badge = 1
            let triggerDaily = Calendar.current.dateComponents([.hour,.minute], from: time as Date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)
            let identifier = "\(String(describing: medName.text!))"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            center.add(request, withCompletionHandler: { (error) in
                if error != nil {
                    print(error!)
                }else{
                    print(request)
                }
            })
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            dismiss(animated: true, completion: nil)

        }
    }
    
    func convertToInt16() throws -> Int16 {
        guard let result = Int16(medAmount.text!) else {
            throw ConvertError.numberFormat
        }
        return result
    }
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        medAmountType.dataSource = self;
        medAmountType.delegate = self;
        selectedType = "Tabletta"
        selectedWhen = "Evés előtt"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

