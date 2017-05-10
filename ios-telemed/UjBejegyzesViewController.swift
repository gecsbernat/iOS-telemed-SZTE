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
    @IBOutlet weak var diaText: UITextField! //dia text
    @IBOutlet weak var sysText: UITextField! //sys text
    @IBOutlet weak var idopontText: UILabel! //idopont text
    
    var date = NSDate() //date valtozo
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        }else if(Int16(sysText.text!)! > 200){
            let alert = UIAlertController(title: "Hiba!", message: "Túl magas SYS.Hgmm érték!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else if(Int16(sysText.text!)! < 10 && Int16(sysText.text!)! != 0){
            let alert = UIAlertController(title: "Hiba!", message: "Túl alacsony SYS.Hgmm érték!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else if(Int16(diaText.text!)! > 200){
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
            
            naplo.event = eventText.text ?? "Ismeretlen"
            naplo.date = date
            naplo.dia = Int16(diaText.text!) ?? 0
            naplo.sys = Int16(sysText.text!) ?? 0
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            dismiss(animated: true, completion: nil)
        }

    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

}
