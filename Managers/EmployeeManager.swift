//
//  EmployeeManager.swift
//  DundeePrizeManager
//
//  Created by infra on 25/02/24.
//

import Foundation

class EmployeeManager {
    func getEmployee() -> [DundieEmployee] {
        let data: DundieEmployeePage = Bundle.main.decode(file:"Employees.json")
        let pokemon: [DundieEmployee] = data.results
        
        return pokemon
    }
}
