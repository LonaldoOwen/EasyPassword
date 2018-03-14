//
//  ResultsTableViewController.swift
//  EasyPassword
//
//  Created by libowen on 2018/3/13.
//  Copyright © 2018年 libowen. All rights reserved.
//

import UIKit

class ResultsTableViewController: BaseTableViewController {
    
    
    // MARK: - Properties
    var filteredItems = [Item]()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register cell
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "ResultsItemCell")
    }

    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultsItemCell", for: indexPath)
        let item = filteredItems[indexPath.row]
        configureCell(cell, forItem: item)
        
        return cell
    }

}
