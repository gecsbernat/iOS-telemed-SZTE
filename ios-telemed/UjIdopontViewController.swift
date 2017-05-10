//
//  UjIdopontViewController.swift
//  ios-telemed
//
//  Created by Rita Sumegi on 2017. 05. 10..
//  Copyright © 2017. ios2017. All rights reserved.
//

import UIKit
import CoreData

class UjIdopontViewController: UIViewController {
    @IBOutlet weak var orvosneveText: UITextField!
    @IBOutlet weak var helyszinText: UITextField!
    @IBOutlet weak var idopontText: UILabel!
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
            dismiss(animated: true, completion: nil)
        }
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
