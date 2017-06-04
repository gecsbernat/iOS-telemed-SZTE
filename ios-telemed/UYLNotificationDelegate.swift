//
//  File.swift
//  ios-telemed
//
//  Created by Rita Sumegi on 2017. 06. 04..
//  Copyright © 2017. ios2017. All rights reserved.
//
import UIKit
import Foundation
import UserNotifications
import CoreData

class UYLNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            print("Dismiss Action")
        case UNNotificationDefaultActionIdentifier:
            print("Default")
        case "Snooze":
            print("Snooze")
        case "OK" :
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let naplo = NaploEntity(context: context)
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy-MM-dd HH:mm"
            naplo.esemeny = "Gyógyszer bevétel"
            naplo.datum = dateformatter.string(from: Date())
            naplo.dia = 0
            naplo.sys = 0
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            print("ok")
        case "Delete":
            print("Delete")  
        default:
            print("Unknown action")
        }
        completionHandler()
    }
}
