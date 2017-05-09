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
        
        //datepicker stuff »»»»
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 35.0))
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        toolBar.barStyle = UIBarStyle.default
        toolBar.tintColor = UIColor.white
        toolBar.backgroundColor = UIColor.black
        
        let todayBtn = UIBarButtonItem(title: "Most", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UjBejegyzesViewController.tappedToolBarBtn))
        let okBarBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(UjBejegyzesViewController.donePressed))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        label.font = UIFont(name: "Helvetica", size: 12)
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.blue
        label.text = " "
        label.textAlignment = NSTextAlignment.center
        let textBtn = UIBarButtonItem(customView: label)
        toolBar.setItems([todayBtn,flexSpace,textBtn,flexSpace,okBarBtn], animated: true)
        dateTextField.inputAccessoryView = toolBar
        //««« datepicker stuff
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
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateTextField.text = dateFormatter.string(from: sender.date)
        date = sender.date as NSDate
    }
    
    func donePressed(_ sender: UIBarButtonItem) {
        dateTextField.resignFirstResponder()
    }
    
    func tappedToolBarBtn(_ sender: UIBarButtonItem) {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateTextField.text = dateformatter.string(from: Date())
        date = Date() as NSDate
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    //«« datepicker eddig tart
    
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
