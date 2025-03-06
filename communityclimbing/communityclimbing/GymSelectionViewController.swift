//
//  GymSelectionViewController.swift
//  communityclimbing
//
//  Created by Turing on 12/3/23.
//

import UIKit

var selectedGym: String = ""

class GymSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gyms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "Cell")
        
        var content = cell.defaultContentConfiguration()
        
        content.text = gyms[indexPath.row].name
        
        cell.contentConfiguration = content
        
        cell.backgroundColor = ColorScheme.shared.accentPrimary
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedGym = gyms[indexPath.row].name
        if let viewController = storyboard?.instantiateViewController(identifier: "GymSubmissionsForum") as? UITabBarController {           
            self.present(viewController, animated: true, completion: nil)
           }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblItems.backgroundColor = ColorScheme.shared.accentPrimary
        view.backgroundColor = ColorScheme.shared.background
        view.inputViewController?.tabBarItem.badgeColor = ColorScheme.shared.accentPrimary
        
        
        tblItems.dataSource = self
        tblItems.delegate = self
        tblItems.reloadData()
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var tblItems: UITableView!

}
