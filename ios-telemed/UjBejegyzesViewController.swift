//
//  UjBejegyzesViewController.swift
//  ios-telemed
//
//  Created by Gecs Bernat on 2017. 05. 02..
//  Copyright © 2017. ios2017. All rights reserved.
//

import UIKit

class UjBejegyzesViewController: UIViewController {

    @IBOutlet weak var eventText: UITextField! //event text
    @IBOutlet weak var dateTextField: UITextField! //date text
    @IBOutlet weak var diaText: UITextField! //dia text
    @IBOutlet weak var sysText: UITextField! //sys text
    var date = NSDate() //date valtozo
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //datepicker itt kezdodik »»
    @IBAction func datePicker(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.dateAndTime
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(UjBejegyzesViewController.datePickerValueChanged), for: UIControlEvents.valueChanged)
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.medium
        dateTextField.text = dateFormatter.string(from: sender.date)
        date = sender.date as NSDate
    }//«« datepicker eddig tart
    
    //adatok mentese core data-ba
    @IBAction func addEvent(_ sender: UIButton) {
        
        if(eventText.text!.isEmpty){
            let alert = UIAlertController(title: "Hiba!", message: "Üres az esemény mező.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else if(diaText.text!.isEmpty){
            let alert = UIAlertController(title: "Hiba!", message: "Üres a DIA.mmHG mező.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else if(sysText.text!.isEmpty){
            let alert = UIAlertController(title: "Hiba!", message: "Üres a SYS.mmHg mező.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let naplo = NaploEntity(context: context)
            
            naplo.event = eventText.text ?? "Ismeretlen"
            naplo.date = date
            naplo.dia = Double(diaText.text!) ?? 0.0
            naplo.sys = Double(sysText.text!) ?? 0.0
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            navigationController?.popViewController(animated: true)
        }

    }

}
