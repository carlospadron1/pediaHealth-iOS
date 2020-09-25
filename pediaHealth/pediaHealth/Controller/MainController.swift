//
//  ViewController.swift
//  pediaHealth
//
//  Created by Carlos on 05/09/20.
//  Copyright © 2020 Carlos Padrón. All rights reserved.
//

import UIKit

class MainController: UIViewController{
    
    //Variables
    var selectedMainIndex: IndexPath?
    var previousSelectedMainIndex: IndexPath?
    var collapsedCellHeight: [Int: CGFloat]  = [:]
    var expandedCellHeight: [Int: CGFloat]   = [:]
    //var isCellActive: [Int: Bool]      = [:]
    var cellBool: [Int: Bool]                = [:]
    
    var medCatalog = [Medicina](){ didSet{ DispatchQueue.main.async {self.MainTable.reloadData() } } }
    
    //Outlets
    @IBOutlet weak var MainTable: UITableView!

    

    override func viewDidLoad() {
        mainTableViewSetUp()
        getMedCatalog()
    }
     
    //Initial SetUp
    func getMedCatalog(){
        DataService.instance.createMedList { (res) in
            switch res {
            case .success(let medArray):
               
                let sortedArray:[Medicina] = medArray.sorted { (a: Medicina, b: Medicina) -> Bool in
                    return    a.nombre.folding(options: .diacriticInsensitive, locale: .none)
                           <  b.nombre.folding(options: .diacriticInsensitive, locale: .none)
                }
                self.medCatalog = sortedArray
            case .failure(let error):
                print(error)
            }
        }
    }
    
   
    
    
}

//MARK: - TableView Config 
extension MainController:  UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate{
    
    func mainTableViewSetUp(){
        self.MainTable.delegate = self
        self.MainTable.dataSource = self
    }
    
    //# Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.medCatalog.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //Sets Medicine's name
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === MainTable{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "MedName") as? MedCell{
                
                let backgroundView              =  UIView()
                backgroundView.backgroundColor  =  UIColor.white.withAlphaComponent(0.0)
                cell.selectedBackgroundView     =  backgroundView
                                
                cell.setMedName(name: self.medCatalog[indexPath.row].nombre, uso: self.medCatalog[indexPath.row].uso , array: self.medCatalog[indexPath.row].enfermedades, index: indexPath.row)
                //cell.setEnfmermedadArray(array: self.medCatalog[indexPath.row].enfermedades)
                
                
               			 
                
                cell.layoutIfNeeded()
                cell.layoutSubviews()
                cell.setNeedsUpdateConstraints()
                cell.updateConstraintsIfNeeded()

               //let tempIdx = self.selectedMainIndex = nil
                
                
                
     
              
                
                self.cellBool[indexPath.row]             =  true
                self.collapsedCellHeight[indexPath.row]  =  cell.collapsedCellHeight()
                self.expandedCellHeight[indexPath.row]  =  cell.expandedCellHeight()
                
                cell.updateSecondTableView()
                return cell
            }
        }
        self.cellBool[indexPath.row]             =   false
        self.collapsedCellHeight[indexPath.row]  =   0.0
        self.expandedCellHeight[indexPath.row]   =   0.0
        return UITableViewCell()
    }
    
    
    //Sets dynamic height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if self.cellBool[indexPath.row] != nil {
            if self.cellBool[indexPath.row]!{
                if let indexP = self.selectedMainIndex {
                    if indexP.row == indexPath.row {
                        return self.expandedCellHeight[indexPath.row]!
                    }
                }
                return self.collapsedCellHeight[indexPath.row]!
            }
        }
        return 85
        
        //return 400
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.previousSelectedMainIndex = self.selectedMainIndex
        self.selectedMainIndex         = indexPath
        
        let cell = tableView.cellForRow(at: self.selectedMainIndex!) as! MedCell
        cell.rotateIcon(open: true)
        
        if let indexP = self.previousSelectedMainIndex{
            if indexP.row == self.selectedMainIndex!.row {
                
                let cell = tableView.cellForRow(at: indexP) as! MedCell
                cell.rotateIcon(open: false)
                self.selectedMainIndex          =  nil
                self.previousSelectedMainIndex  =  nil
            }else{
                
                if let cell = tableView.cellForRow(at: indexP) as? MedCell {
                    cell.rotateIcon(open: false)
                }
                
            }
            
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        if let indexP = self.selectedMainIndex{
//            if let cell = self.MainTable.cellForRow(at: indexP) {
//                if !self.MainTable.visibleCells.contains(cell) {
//                  self.selectedMainIndex = nil
//                   // cell.rotateIcon(open: true)
//
//                    self.MainTable.beginUpdates()
//                    self.MainTable.endUpdates()
//                }
//
//            }
//        }
//    }
    
    
    
    
  
}


