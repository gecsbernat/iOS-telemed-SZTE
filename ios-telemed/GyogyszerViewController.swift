//
//  NaploViewController.swift
//  ios-telemed
//
//  Created by Tibor on 5/1/17.
//  Copyright © 2017 ios2017. All rights reserved.
//
import UIKit

class GyogyszerViewController: UIViewController {
    
    
    @IBOutlet weak var addButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    @IBAction func addItem(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Új gyógyszer", message: "", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Hozzáadás", style: .default, handler: ({
            (_) in
           //TODO
        }))
        let cancelAction = UIAlertAction(title: "Mégse", style: .cancel, handler: nil)
        alertController.addTextField(configurationHandler: {
            (textField) in
            
            textField.placeholder = "Gyógyszer neve"
        })
        /*Placeholderek, ide picker félék kellenek, de nemtom hogy*/
        alertController.addTextField(configurationHandler: {
            (textField) in
            
            textField.placeholder = "Mennyiség típusa"
        })
        alertController.addTextField(configurationHandler: {
            (textField) in
            
            textField.placeholder = "Mennyiség"
        })
        alertController.addTextField(configurationHandler: {
            (textField) in
            
            textField.placeholder = "Mikor"
        })

        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
