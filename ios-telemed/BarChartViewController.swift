//
//  BarChartViewController.swift
//  ios-telemed
//
//  Created by Gecs Bernat on 2017. 05. 23..
//  Copyright © 2017. ios2017. All rights reserved.
//

import UIKit
import CoreData
import Charts

class BarChartViewController: UIViewController {

    @IBOutlet weak var linechart: LineChartView!
    
    var idopontok: [String] = []
    var systolic: [Double] = []
    var diastolic: [Double] = []
    var naplo : [NaploEntity] = []
    
    func getData(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NaploEntity> = NaploEntity.fetchRequest()
        let sort = NSSortDescriptor(key: "datum", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        do{
            naplo = try context.fetch(fetchRequest)
        }
        catch{
            print("Error fetching data.")
        }
    }
    
    func convertdata(){
        for ertek in naplo {
            var datum = String(describing: ertek.value(forKey: "datum")!)
            let index = datum.index(datum.startIndex, offsetBy: 10)
            let index2 = datum.index(datum.startIndex, offsetBy: 6)
            datum = datum.substring(to: index) + "\n" + datum.substring(from: index).substring(to: index2)
            let sys = ertek.value(forKey: "sys") as! Double
            let dia = ertek.value(forKey: "dia") as! Double
            if(sys != 0.0 && dia != 0.0){
                idopontok.append(datum)
                systolic.append(sys)
                diastolic.append(dia)
            }
        }
    }
    
    func setChart(dataPoints: [String], systolic: [Double], diastolic: [Double]) {
        
        var dataEntries1: [ChartDataEntry] = []
        var dataEntries2: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: systolic[i])
            dataEntries1.append(dataEntry)
        }
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: diastolic[i])
            dataEntries2.append(dataEntry)
        }

        let lineChartDataSet1 = LineChartDataSet(values: dataEntries1, label: "SYS")
        lineChartDataSet1.colors = [UIColor(red: 255, green: 0, blue: 0, alpha: 1)]
        lineChartDataSet1.circleColors = [UIColor(red: 255, green: 0, blue: 0, alpha: 1)]
        
        let lineChartDataSet2 = LineChartDataSet(values: dataEntries2, label: "DIA")
        lineChartDataSet2.colors = [UIColor(red: 0, green: 0, blue: 255, alpha: 1)]
        lineChartDataSet2.circleColors = [UIColor(red: 0, green: 0, blue: 255, alpha: 1)]
        
        let lineChartData = LineChartData(dataSets: [lineChartDataSet1,lineChartDataSet2])
        
        linechart.data = lineChartData
        linechart.animate(yAxisDuration: 2, easingOption: .easeInOutQuart)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        convertdata()
        linechart.noDataText = "Nincs adat."
        linechart.chartDescription?.text = "Vérnyomás adatok"
        linechart.legend.enabled = true
        linechart.pinchZoomEnabled = false
        linechart.scaleXEnabled = true
        linechart.scaleYEnabled = false
        linechart.doubleTapToZoomEnabled = false
        
        linechart.xAxis.valueFormatter = IndexAxisValueFormatter(values: idopontok)
        linechart.xAxis.granularity = 1
        
        if(!naplo.isEmpty){
            setChart(dataPoints: idopontok, systolic: systolic, diastolic: diastolic)
        }
    }
}
