//
//  ViewProjectViewController.swift
//  communityclimbing
//
//  Created by Turing on 12/3/23.
//

import UIKit

class ViewProjectViewController: UIViewController {

    @IBOutlet weak var imgProfilePicture: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCreator: UILabel!
    
    
    
    var project: Project = Project(name: "", creator: "", availableSnapPoints: "", occupiedSnapPoints: "", gym: "", snapPoints: "", wallWidth: 0, wallHeight: 0)
    var availableSnapPoints: [CGPoint] = []
    var occupiedSnapPoints: [String:CGPoint] = [:]
    var selectedUserProfilePicture: UIImage = UIImage()
    
    @IBAction func btnEdit(_ sender: UIButton) {
        if let viewController = storyboard?.instantiateViewController(identifier: "Create") as? ViewController {
            viewController.availableSnapPointsString = project.availableSnapPoints
            viewController.occupiedSnapPointsString = project.occupiedSnapPoints
            viewController.wallWidth = project.wallWidth
            viewController.wallHeight = project.wallHeight
            viewController.regenerateWall()
            self.present(viewController, animated: true, completion: nil)
           }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorScheme.shared.background
        lblName.text = "Project Name: \(project.name)"
        lblCreator.text = "Created by: \(project.creator)"
        
        
        
        imgProfilePicture.contentMode = .scaleAspectFill
        imgProfilePicture.layer.cornerRadius = imgProfilePicture.frame.size.width / 2
        
        if selectedUserProfilePicture != UIImage() {
            imgProfilePicture.image = selectedUserProfilePicture
        } else {
            print("error: user pfp did not pass over to new view correctly")
        }
        
        
        availableSnapPoints = convertStringToCGPointArray(project.availableSnapPoints)
        occupiedSnapPoints = convertOccupiedSnapPointsStringToDictionary(project.occupiedSnapPoints)
        
        var targetView: UIView!
        targetView = UIView(frame: CGRect(x: 80, y: 250, width: project.wallWidth, height: project.wallHeight))
        targetView.backgroundColor = UIColor.cyan
        targetView.restorationIdentifier = "target"
        
        view.addSubview(targetView)
        view.bringSubviewToFront(targetView)
        for subview in view.subviews {
            print(subview.restorationIdentifier ?? "noID")
        }
        generateSnapPoints(for: targetView)
        regenerateWall()
    }
    
    func generateSnapPoints(for dropArea: UIView) {
        guard dropArea.bounds != CGRect.zero else {
            return
        }
        
        let dropFrame = dropArea.frame
        let gridSize: CGFloat = 50
        let circleRadius: CGFloat = 3
        
        var startingX = dropFrame.minX + 15
        let startingY = dropFrame.minY + 20
           
        var newSnapPoints: [CGPoint] = []
        
        var level = 0
        
        
        //print("generating snappoints...")
        for y in stride(from: startingY, through: dropFrame.maxY, by: gridSize) {
            if level % 2 == 0 {
                startingX += 25
            } else {
                startingX = dropFrame.minX + 15
            }
            
            //print("level \(level), startng x: \(startingX)")
            for x in stride(from: startingX, through: dropFrame.maxX, by: gridSize) {
                //print("\tY: \(y), X: \(x)")
                let point = CGPoint(x: x, y: y)
                
                let convertedPoint = dropArea.convert(point, from: dropArea.superview)
                
                if dropFrame.contains(point){
                    newSnapPoints.append(point)
                    
                    let circleView = UIView(frame: CGRect(x: convertedPoint.x - circleRadius, y: convertedPoint.y - circleRadius, width: circleRadius * 2, height: circleRadius * 2))
                    
                    circleView.backgroundColor = UIColor.black
                    
                    circleView.layer.cornerRadius = circleRadius
                    
                    dropArea.addSubview(circleView)
                }
            }
            level += 1
        }
    }
    func regenerateWall() {
        print("regenerating wall...")
        for pair in occupiedSnapPoints {
            print("adding \(pair)")
            let holdImgView = createHoldImageView(hold: getHoldFromID(holdID: pair.key))
            holdImgView.restorationIdentifier = pair.key
            holdImgView.center = pair.value
            view.addSubview(holdImgView)
        }
    }
    func getHoldFromID(holdID: String) -> Hold {
        let holdIDComponents = holdID.components(separatedBy: "_")
        let holdType = holdIDComponents[0]
        var desiredHold: Hold = Hold(name: "", imageName: "")
        for hold in holdsList {
            if hold.name == holdType {
                desiredHold = hold
            }
        }
        
        return desiredHold
    }
    var viewIDCounter = 0
    func createHoldImageView(hold: Hold) -> UIImageView {
        let holdImg = UIImage(named: hold.imageName)
        let holdImgView = UIImageView(image: holdImg)
        
        holdImgView.frame.size = CGSize(width: 25, height: 25)
        
        viewIDCounter += 1
        holdImgView.restorationIdentifier = "\(hold.name)_\(viewIDCounter)"
        
        return holdImgView
    }
    func convertStringToCGPointArray(_ pointsString: String) -> [CGPoint] {
        let pointComponents = pointsString.components(separatedBy: ",")
        var points: [CGPoint] = []
        
        /*if pointComponents.count % 2 != 0 {
            print("incorrent amount of points :O")
        }*/
        
        guard pointComponents.count % 2 == 0 else {
            return points
        }
        
        var count = 0
        for i in stride(from: 0, to: pointComponents.count, by: 2) {
            guard let x = Double(pointComponents[i]) else {
                print("invalid component at index \(i)")
                return points
            }
            guard let y = Double(pointComponents[i+1]) else {
                print("invalid component at index \(i+1)")
                return points
            }
            count += 1
            points.append(CGPoint(x: CGFloat(x), y: CGFloat(y)))
        }
        return points
    }
    func convertOccupiedSnapPointsStringToDictionary(_ pointsString: String) -> [String:CGPoint] {
        guard pointsString != "" else {
            return [:]
        }
        
        let pointComponents = pointsString.components(separatedBy: "|")
        var occupiedPoints: [String:CGPoint] = [:]
        
        var count = 0
        for pair in pointComponents {
            let pairComponents = pair.components(separatedBy: ":")
            let name = pairComponents[0]
            
            let coordinatesString = pairComponents[1].components(separatedBy: ",")
            let x = CGFloat(Double(coordinatesString[0]) ?? 0)
            let y = CGFloat(Double(coordinatesString[1]) ?? 0)
            
            let coordinates = CGPoint(x: x, y: y)
            
            occupiedPoints[name] = coordinates
            count += 1
        }
        return occupiedPoints
    }
}
