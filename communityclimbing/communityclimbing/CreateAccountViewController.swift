//
//  CreateAccountViewController.swift
//  communityclimbing
//
//  Created by Turing on 12/3/23.
//

import UIKit
import CoreData

class CreateAccountViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorScheme.shared.background
        lblErrorMessage.isHidden = true
        
        imgPicture.contentMode = .scaleAspectFill
        imgPicture.layer.cornerRadius = imgPicture.frame.size.width / 2
    }
    
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtPasswordRepeated: UITextField!
    @IBOutlet weak var lblErrorMessage: UILabel!
    
    @IBAction func btnCreateAccount(_ sender: UIButton) {
        lblErrorMessage.isHidden = true
        
        var isInfoValid: Bool = true
        
        if(txtUsername.text == nil ||
           txtUsername.text == "" ||
           txtPassword.text == nil ||
           txtPassword.text == "") {
            isInfoValid = false
        }
        
        print("1 \(isInfoValid)")
        if(txtPassword.text != txtPasswordRepeated.text && isInfoValid == true) {
            isInfoValid = false
        }
        
        print("2 \(isInfoValid)")
        if (isInfoValid == true) {
            addNewAccount(newUsername: txtUsername.text!, newPassword: txtPassword.text!)
        } else {
            lblErrorMessage.isHidden = false
        }
        
        if isInfoValid == true {
            
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let vc : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "Login") as UIViewController
            self.present(vc, animated:true, completion: nil)
            
            return
        }
    }
    
    let imagePicker = UIImagePickerController()
    @IBAction func btnPicture(_ sender: UIButton) {
        openCamera()
    }
    @IBAction func btnGallery(_ sender: UIButton) {
        openPhotoLibrary()
    }
    
    @IBOutlet weak var imgPicture: UIImageView!
    func openCamera() {
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        
        //check if camer is available
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            
            if UIImagePickerController.isCameraDeviceAvailable(.front) {
                imagePicker.cameraDevice = .front
            } else {
                imagePicker.cameraDevice = .rear
            }
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        
        present(imagePicker, animated: true)
    }
    
    func openPhotoLibrary() {
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true)
        self.present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imgPicture.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func addNewAccount(newUsername: String, newPassword: String){
        let newAccount = UserAccounts(context: context)
        
        newAccount.username = newUsername
        newAccount.password = newPassword
        
        if imgPicture.image != nil {
            if let imageData = imgPicture.image?.pngData() {
                newAccount.profilePicture = imageData
            }
        } else {
            newAccount.profilePicture = UIImage(named: "DefaultProfilePicture")?.pngData()
        }
        
        appDelegate.saveContext()
    }
    
}
