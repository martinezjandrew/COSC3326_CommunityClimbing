//
//  YourSubmissionsViewController.swift
//  communityclimbing
//
//  Created by Turing on 12/3/23.
//

import UIKit

class YourSubmissionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var projects: [Project] = []
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell (style: UITableViewCell.CellStyle.default, reuseIdentifier: "Cell")
        
        var content = cell.defaultContentConfiguration()
        
        content.text = projects[indexPath.row].name
        
        cell.contentConfiguration = content
        
        cell.backgroundColor = ColorScheme.shared.accentPrimary
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedProject = projects[indexPath.row]
        print("Selected \(selectedProject.name)")
        if let viewController = storyboard?.instantiateViewController(identifier: "Look") as? ViewProjectViewController {
            viewController.project = selectedProject
            self.present(viewController, animated: true, completion: nil)
           }
    }
    
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var imgProfilePicture: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblProjects.backgroundColor = ColorScheme.shared.accentPrimary
        view.backgroundColor = ColorScheme.shared.background
        
        lblUsername.text = activeUser
        imgProfilePicture.image = activeUserProfilePicture
        
        
        imgProfilePicture.contentMode = .scaleAspectFill
        imgProfilePicture.layer.cornerRadius = imgProfilePicture.frame.size.width / 2
        
        tblProjects.dataSource = self
        tblProjects.delegate = self
        tblProjects.reloadData()
    }
    
    @IBOutlet weak var tblProjects: UITableView!
    
    override func viewDidAppear(_ animated: Bool) {
        projects = []
        
        var data = [ProjectData]()
        
        do {
            data = try context.fetch(ProjectData.fetchRequest())
            
            for existingProject in data {
                if existingProject.gym == selectedGym && existingProject.creator == activeUser {
                    let project = Project(name: existingProject.name!, creator: existingProject.creator!, availableSnapPoints: existingProject.availableSnapPoints!, occupiedSnapPoints: existingProject.occupiedSnapPoints!, gym: existingProject.gym!, snapPoints: existingProject.snapPoints!, wallWidth: Int(existingProject.wallWidth), wallHeight: Int(existingProject.wallHeight))
                    projects.append(project)
                }
            }
        } catch{}
        tblProjects.reloadData()
    }
}
