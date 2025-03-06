//
//  MapGymSelectionViewController.swift
//  communityclimbing
//
//  Created by Turing on 12/3/23.
//

import UIKit
import MapKit
import CoreLocation

class MapGymSelectionViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapLocations: MKMapView!
    
    var locationManager = CLLocationManager()
    @IBOutlet weak var lblGymName: UILabel!
    @IBOutlet weak var lblGymAddress: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = ColorScheme.shared.background
        view.inputViewController?.tabBarItem.badgeColor = ColorScheme.shared.accentPrimary 
        
        for gym in gyms {
            addAnnotationToMap(coordinate: CLLocationCoordinate2DMake(gym.latitude, gym.longitude), title: gym.name, to: mapLocations)
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        mapLocations.delegate = self
    }
    
    func addAnnotationToMap(coordinate: CLLocationCoordinate2D, title: String, to mapView: MKMapView) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        mapView.addAnnotation(annotation)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        
        locationManager.stopUpdatingLocation()
        
        let here = MKPointAnnotation()
        here.coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude)
        here.title = "i be here"
        
        mapLocations.addAnnotation(here)
        
        let myRegion = MKCoordinateRegion(center: here.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        
        mapLocations.setRegion(myRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotationTitle = view.annotation?.title {
            let pickedGym = gyms.first(where: {$0.name == annotationTitle ?? ""})
            
            lblGymName.text = pickedGym?.name
            lblGymAddress.text = "\(pickedGym?.streetAddress ?? ""), \(pickedGym?.city ?? ""), \(pickedGym?.state ?? "")"
            
            selectedGym = pickedGym?.name ?? ""
            
            lblGymName.isHidden = false
            lblGymAddress.isHidden = false
            btnSelect.isHidden = false
        }
    }
    
    @IBOutlet weak var btnSelect: UIButton!
    @IBAction func btnSelect(_ sender: UIButton) {
        if let viewController = storyboard?.instantiateViewController(identifier: "GymSubmissionsForum") as? UITabBarController {
            self.present(viewController, animated: true, completion: nil)
           }
    }
}
