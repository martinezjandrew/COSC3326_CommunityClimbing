//
//  EveryonesSubmissionsViewController.swift
//  communityclimbing
//
//  Created by Turing on 12/3/23.
//

import UIKit

class ProjectTableViewCell: UITableViewCell{
    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var lblProjectName: UILabel!
    @IBOutlet weak var lblCreator: UILabel!
}

class EveryonesSubmissionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var projects: [Project] = []
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = UITableViewCell (style: UITableViewCell.CellStyle.default, reuseIdentifier: "ProjectCell") as! ProjectTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell", for: indexPath) as! ProjectTableViewCell
        
        let project = projects[indexPath.row]
        
        cell.lblCreator?.text = project.creator
        cell.lblProjectName?.text = project.name
        
        cell.imgProfilePic.contentMode = .scaleAspectFill
        cell.imgProfilePic.layer.cornerRadius = cell.imgProfilePic.frame.size.width / 2

        
        var data = [UserAccounts]()
        
        do {
            data = try context.fetch(UserAccounts.fetchRequest())
            
            for user in data {
                if user.username == project.creator {
                    if user.profilePicture != nil {
                        cell.imgProfilePic.image = UIImage(data: user.profilePicture!)
                    }
                }
            }
        } catch{}
        
        cell.backgroundColor = ColorScheme.shared.accentPrimary
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedProject = projects[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath) as? ProjectTableViewCell
        
        print("Selected \(selectedProject.name)")
        if let viewController = storyboard?.instantiateViewController(identifier: "Look") as? ViewProjectViewController {
            viewController.selectedUserProfilePicture = cell?.imgProfilePic.image ?? UIImage()
            viewController.project = selectedProject
            self.present(viewController, animated: true, completion: nil)
           }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorScheme.shared.background
        tblProjects.backgroundColor = ColorScheme.shared.accentPrimary
        lblTitle.text?.append(" \(selectedGym) community")
        tblProjects.dataSource = self
        tblProjects.delegate = self
        tblProjects.reloadData()
    }
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tblProjects: UITableView!
    
    override func viewDidAppear(_ animated: Bool) {
        projects = []
        
        var data = [ProjectData]()
        
        do {
            data = try context.fetch(ProjectData.fetchRequest())
            
            for existingProject in data {
                if existingProject.gym == selectedGym {
                    let project = Project(name: existingProject.name!, creator: existingProject.creator!, availableSnapPoints: existingProject.availableSnapPoints!, occupiedSnapPoints: existingProject.occupiedSnapPoints!, gym: existingProject.gym!, snapPoints: existingProject.snapPoints!, wallWidth: Int(existingProject.wallWidth), wallHeight: Int(existingProject.wallHeight))
                    projects.append(project)
                }
            }
        } catch{}
        tblProjects.reloadData()
    }
}
