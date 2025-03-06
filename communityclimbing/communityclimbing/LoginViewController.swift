//
//  LoginViewController.swift
//  communityclimbing
//
//  Created by Turing on 12/3/23.
//

import UIKit
import CoreData

let appDelegate = UIApplication.shared.delegate as! AppDelegate
let context = appDelegate.persistentContainer.viewContext

var activeUser: String?
var activeUserProfilePicture: UIImage?

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnCreateAccount.tintColor = ColorScheme.shared.accentTertiary
        lblTitle.textColor = ColorScheme.shared.textPrimary
        view.backgroundColor = ColorScheme.shared.background
        btlLogIn.tintColor = ColorScheme.shared.accentPrimary
        lblErrorMessage.isHidden = true
        lblLogIn.textColor = ColorScheme.shared.textSecondary
    }
    
    
    @IBOutlet weak var btnCreateAccount: UIButton!
    @IBOutlet weak var lblLogIn: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblErrorMessage: UILabel!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBOutlet weak var btlLogIn: UIButton!
    @IBAction func btnLogIn(_ sender: UIButton) {
        var data = [UserAccounts]()
        
        do {
            data = try context.fetch(UserAccounts.fetchRequest())
            
            for existingAccount in data {
                if (existingAccount.username! == txtUsername.text && existingAccount.password! == txtPassword.text) {
                    activeUser = txtUsername.text
                    
                    if let imageData = existingAccount.profilePicture {
                        if let image = UIImage(data: imageData) {
                            activeUserProfilePicture = image
                        } else {
                            print("UIImage couldn't be created from binary data for user \(activeUser ?? "unkown user")")
                        }
                    } else {
                        print("user \(activeUser ?? "unkown") has no picture")
                    }
                    print("Valid log in")
                    
                    let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let vc : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "GymSelection") as UIViewController
                    self.present(vc, animated:true, completion: nil)
                    
                    return
                }
            }
        }
        catch{}
        print("Invalid log in")
        lblErrorMessage.isHidden = false
    }
    
    @IBAction func btnCreateAccount(_ sender: Any) {
    }
    
}
