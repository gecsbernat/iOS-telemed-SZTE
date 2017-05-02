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
        
    }
    //«« datepicker eddig tart
    
    //adatok mentese core data-ba
    @IBAction func addEvent(_ sender: UIButton) {
        
        //if(!eventText.text!.isEmpty){
        //    print("asd")
      //  }
       
        //print("\(String(describing: dateTextField.text!))") //debug
        
        //let dateFormatter = DateFormatter()
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let naplo = NaploEntity(context: context)
        
        naplo.event = eventText.text ?? "Ismeretlen"
        
        //ezek nem mukodnek?????
        //let date = dateTextField.text!
        //naplo.date = dateFormatter.date(from: date)! as NSDate
        
        naplo.date = NSDate()
        naplo.dia = Double(diaText.text!) ?? 0.0
        naplo.sys = Double(sysText.text!) ?? 0.0
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController?.popViewController(animated: true)
    }

}
