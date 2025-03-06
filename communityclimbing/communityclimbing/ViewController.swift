//
//  ViewController.swift
//  communityclimbing
//
//  Created by Turing on 11/26/23.
//

import UIKit

class ViewController: UIViewController {

    var snapPoints: [CGPoint] = []
    var availableSnapPoints: [CGPoint] = []
    var occupiedSnapPoints: [String: CGPoint] = [:]
    
    var snapPointsString: String = ""
    var availableSnapPointsString:String = ""
    var occupiedSnapPointsString:String = ""
    
    var viewIDCounter = 0
    var recentHolds: [Hold] = []
    var targetView: UIView!
    var wallHeight: Int = 335
    var wallWidth: Int = 240
    
    var preSaveOccupiedString = ""
    var preSaveAvailableString = ""
    
    @IBOutlet weak var bottomMenuBar: UIView!
    
    
    @IBOutlet weak var viewPublish: UIView!
    
    @IBOutlet weak var lblPublish_GymName: UILabel!
    @IBOutlet weak var lblPublish_HoldCount: UILabel!
    @IBOutlet weak var txtPublish_ProjectName: UITextField!
    
    func closePublishWindow(){
        viewPublish.isHidden = true
        txtPublish_ProjectName.text = ""
        lblPublish_HoldCount.text = "# Of Holds: "
        lblPublish_GymName.text = "Gym Name: "
    }
    
    @IBAction func btnPublish_Close(_ sender: UIButton) {
        closePublishWindow()
    }
    @IBAction func btnPublish_SendToCoreData(_ sender: UIButton) {
        
        if(snapPoints.count != 0 && availableSnapPointsString.count != 0){
            let newProject = ProjectData(context: context)
            
            newProject.name = txtPublish_ProjectName.text
            newProject.creator = activeUser
            newProject.gym = selectedGym
            newProject.occupiedSnapPoints = occupiedSnapPointsString
            newProject.availableSnapPoints = availableSnapPointsString
            newProject.snapPoints = snapPointsString
            newProject.wallWidth = Int16(wallWidth)
            newProject.wallHeight = Int16(wallHeight)
            
            appDelegate.saveContext()
            
            closePublishWindow()
            
            let alertController = UIAlertController(title: "Congrats", message: "Your project, \(newProject.name ?? "null") has been published!", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Nice!", style: .default)
            alertController.addAction(okayAction)
            present(alertController, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Congrats", message: "Your project, \(txtPublish_ProjectName.text ?? "null") has been published!", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Nice!", style: .default)
            alertController.addAction(okayAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    @IBAction func btnPublish(_ sender: UIButton) {
        
        convertSnapPointsToString()
        
        guard preSaveOccupiedString != occupiedSnapPointsString && preSaveAvailableString != availableSnapPointsString else {
            let alertController = UIAlertController(title: "ERROR", message: "You made no changes.", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(okayAction)
            present(alertController, animated: true, completion: nil)
            return
        }
        
        view.bringSubviewToFront(viewPublish)
        lblPublish_GymName.text?.append("\(selectedGym)")
        lblPublish_HoldCount.text?.append("\(occupiedSnapPoints.count)")
        viewPublish.isHidden = false
        
        
        /*if let viewController = storyboard?.instantiateViewController(identifier: "Publish") as? PublishViewController {
            viewController.availableSnapPoints = availableSnapPointsString
            viewController.occupiedSnapPoints = occupiedSnapPointsString
            viewController.snapPoints = snapPointsString
            viewController.wallWidth = wallWidth
            viewController.wallHeight = wallHeight
            self.present(viewController, animated: true, completion: nil)
           }*/
    }
    @IBAction func infodump(_ sender: Any) {
        let correctSnapPointCount = snapPoints.count == availableSnapPoints.count + occupiedSnapPoints.count
        print("Snap Points:\n\(snapPoints)")
        print("Correct snap point count? \(correctSnapPointCount)")
        print("Occupied Snap Points (size:\(occupiedSnapPoints.count))\n \(occupiedSnapPoints)")
        print()
        print("Available Snap Points (size:\(availableSnapPoints.count))\n \(availableSnapPoints)")
        print()
        print("Views")
        for weiner in view.subviews {
            if(weiner.restorationIdentifier != nil){
                print(weiner.restorationIdentifier!)
            } else {
                print("null ID")
            }
        }
        print()
        print("Bottom Menu Contents:")
        for weiner in bottomMenu.subviews{
            print(weiner.restorationIdentifier ?? "fart")
        }
        print()
        print("Recent Holds: \(recentHolds)")
        
    }
    
    @IBAction func clear(_ sender: UIButton) {
        clearWall()
    }
    
    func clearWall() {
        for pair in occupiedSnapPoints {
            print("removing \(pair)")
            view.subviews.first(where: {$0.restorationIdentifier == pair.key})?.removeFromSuperview()
            availableSnapPoints.append(pair.value)
            occupiedSnapPoints.removeValue(forKey: pair.key)
        }
    }
    @IBAction func save(_ sender: UIButton) {
        convertSnapPointsToString()
    }
    @IBAction func load(_ sender: UIButton) {
        clearWall()
        occupiedSnapPoints = convertOccupiedSnapPointsStringToDictionary(occupiedSnapPointsString)
        availableSnapPoints = convertStringToCGPointArray(availableSnapPointsString)
        regenerateWall()
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
    
    override func viewDidLoad() {
        
        print("the app has opened")
        
        super.viewDidLoad()
        
        view.backgroundColor = ColorScheme.shared.background
        
        bottomMenu.layer.cornerRadius = 35
        bottomMenu.layer.masksToBounds = true
        bottomMenuBar.layer.cornerRadius = 5
        
        targetView = UIView(frame: CGRect(x: 80, y: 250, width: wallWidth, height: wallHeight))
        targetView.backgroundColor = UIColor.cyan
        targetView.restorationIdentifier = "target"
        
        view.addSubview(targetView)
        
        view.sendSubviewToBack(targetView)
        
        generateSnapPoints(for: targetView)
        
        originalFrame = bottomMenu.frame
        
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeUpGesture.direction = .up
        bottomMenu.addGestureRecognizer(swipeUpGesture)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeDownGesture.direction = .down
        bottomMenu.addGestureRecognizer(swipeDownGesture)
        
        generateRecentHoldOptions(dropArea: bottomMenu)
        
        if occupiedSnapPointsString.count != 0 && availableSnapPointsString.count != 0 {
            preSaveOccupiedString = occupiedSnapPointsString
            preSaveAvailableString = availableSnapPointsString
            occupiedSnapPoints = convertOccupiedSnapPointsStringToDictionary(occupiedSnapPointsString)
            availableSnapPoints = convertStringToCGPointArray(availableSnapPointsString)
        }
        
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
        
        snapPoints = newSnapPoints
        availableSnapPoints = snapPoints
    }
    
    // deals with the functionality of moving a draggable view
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        var draggedView = gesture.view!
        
        switch gesture.state {
        case .began:
            print("erm we moving \(draggedView.restorationIdentifier ?? "")")
            draggedView.superview?.bringSubviewToFront(draggedView)
            
            // checks the occupied snap points dictionary to see if a key exists for the draggable view, if so it releases the snappoint back to available snap points, if false nothing happens
            if(occupiedSnapPoints.keys.contains(draggedView.restorationIdentifier ?? "null")){
                print("snap point released")
                let formerSnapPoint = occupiedSnapPoints[draggedView.restorationIdentifier ?? "null"]
                occupiedSnapPoints.removeValue(forKey: draggedView.restorationIdentifier ?? "null")
                availableSnapPoints.append(formerSnapPoint ?? CGPoint())
            } else {
                print("no snap point related to this guy")
            }
            
            if(occupiedSnapPoints.values.contains(CGPoint())){
                print("WARNING: THERE'S A (0,0) CGPoint WHEN THERE SHOULDN'T BE!!!!")
            }
            
            // if the draggable view is within the bottomMenu view, it creats a duplicate that is added to the parent view and performs the appropriate calculatiosn to have the duplicate appear a the same location as the orignal one
            if(bottomMenu.contains(draggedView)){
                print("touched in bottom menu at \(view.convert(draggedView.center, to: view))")
                
                let duped = draggedView
                duped.center = gesture.location(in: view)
                print("dupe sent to \(duped.center)")
                view.addSubview(duped)
                draggedView = duped
            }
            shrinkBottomMenu()
            
        case .changed:
            // moves the draggable view according to the gesture
            let translation = gesture.translation(in: self.view)
            draggedView.center = CGPoint(x: draggedView.center.x + translation.x, y: draggedView.center.y + translation.y)
            gesture.setTranslation(.zero, in: self.view)
        case .ended:
            let convertedCenter = view.convert(draggedView.center, to: bottomMenu)
            // if the location of when the draggable view is dropped is located within the bottom menu bounds, the view is deleted and its snap points are freed.
            // if else, its moved to the nearest snap point
            if bottomMenu.bounds.contains(convertedCenter){
                draggedView.center = convertedCenter
                print("died")
                
                let freedSnapPoint = occupiedSnapPoints[draggedView.restorationIdentifier ?? "null"]
                
                availableSnapPoints.append(freedSnapPoint ?? CGPoint())
                
                occupiedSnapPoints.removeValue(forKey: draggedView.restorationIdentifier ?? "null")
                
                draggedView.removeFromSuperview()
            } else {
                let newView = draggedView
                let closestSnapPoint = findClosestSnapPoint(to: draggedView.center)
                
                UIView.animate(withDuration: 0.35){
                    newView.center = closestSnapPoint
                }
                
                occupiedSnapPoints[newView.restorationIdentifier ?? "null"] = closestSnapPoint
                availableSnapPoints.remove(at: availableSnapPoints.lastIndex(of: closestSnapPoint) ?? 0)
                
                draggedView.removeFromSuperview()
                view.addSubview(newView)
            }
            
            let holdID = draggedView.restorationIdentifier ?? "holdID: fart"
            var holdType = holdID
            if let separatorIndex = holdType.firstIndex(of: "_") {
                let indexValue = holdType.distance(from: holdType.startIndex, to: separatorIndex)
                
                for _ in indexValue...holdType.count-1 {
                    holdType.removeLast()
                }
            }
            
            var holdCount: Int = 0
            for i in bottomMenu.subviews {
                let string = i.restorationIdentifier ?? "bottomMenuSubview: fart"
                string.contains(holdType) ? holdCount += 1 : nil
            }
            
            if holdCount == 1 {
                let newHold = holdsList.first(where: {$0.name == holdType})
                
                if recentHolds.count < 4 {
                    recentHolds.append(newHold ?? Hold(name: "", imageName: ""))
                } else {
                    recentHolds.removeFirst()
                    recentHolds.append(newHold ?? Hold(name: "", imageName: ""))
                    
                }
                
                if newHold != nil {
                    let newHoldImgView = createHoldImageView(hold: newHold ?? Hold(name: "", imageName: ""))
                    
                    let targetView = bottomMenu.subviews.first(where: {$0.restorationIdentifier == holdType}) ?? nil
                    
                    let targetLocation = targetView?.center
                    
                    newHoldImgView.center = CGPoint(x: targetLocation?.x ?? 0, y: targetLocation?.y ?? 0)
                    
                    print("created shit at \(targetView?.restorationIdentifier ?? "HoldImgViewLocation: fart") (\(String(describing: targetLocation)))")
                    
                    bottomMenu.addSubview(newHoldImgView)
                } else {
                    print("something aint right")
                }
                print("added a new \(newHold?.name ?? "NewHoldName: fart")")
            } else if holdCount == 2 {
                // do nothing
            } else {
                print("incorrect holdCount of \(holdCount)! should only be 1 or 2")
            }
            
            holdCount = 0
            for i in bottomMenu.subviews {
                let string = i.restorationIdentifier ?? "BottomMenuSubview: fart"
                string.contains(holdType) ? holdCount += 1 : nil
            }
            print("\(holdType) count: \(holdCount)")
            
            //generateRecentHoldOptions(dropArea: bottomMenu)
        default:
            break
        }
    }
    
    // finds the closest snappoint to where a draggable view is dropped
    func findClosestSnapPoint(to location: CGPoint) -> CGPoint {
        var closestPoint = CGPoint.zero
        var smallestDistance = CGFloat.greatestFiniteMagnitude
        
        for snapPoint in availableSnapPoints {
            let distance = distanceBetween(point1: location, and: snapPoint)
            if distance < smallestDistance{
                smallestDistance = distance
                closestPoint = snapPoint
            }
        }
        
        print("Dropped item at: \(closestPoint)")
        
        return closestPoint
    }
    
    // determines the distance between two snap points
    func distanceBetween(point1: CGPoint, and point2:CGPoint) -> CGFloat {
        let xDist = point2.x - point1.x
        let yDist = point2.y - point1.y
        return sqrt((xDist * xDist) + (yDist * yDist))
    }
    
    let bottomMenuHeight: CGFloat = 100
    @IBOutlet weak var bottomMenu: UIView!
    var originalFrame: CGRect = .zero
    
    // deals with the functionality of swiping the bottom menu up and down
    // when swiping up, the menu increases in size and draggable views are created
    // when going down, the views are deleted and the menu is shrunken
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .up:
            print("its dinner time")
            
            
            view.bringSubviewToFront(bottomMenu)
            let expandedHeight: CGFloat = 400
            
            UIView.animate(withDuration: 0.5) {
                self.bottomMenu.frame = CGRect(x: 0, y: self.view.frame.height - expandedHeight, width: self.view.frame.width, height: expandedHeight)
            }
            
            let holdXCord = 50
            let holdYCord = Int(bottomMenuBar.frame.maxY) + 25
            let holdXCordDifference = Int(bottomMenu.frame.maxX) / 4
            let holdYCordDifference = 50
            
            var xCount = 0
            var yCount = 1
            
            var yCord = holdYCord
            for hold in holdsList {
                let optionHoldImgName = hold.imageName
                let optionHoldImg = UIImage(named: optionHoldImgName)
                let optionHoldImgView = UIImageView(image: optionHoldImg!)
                optionHoldImgView.restorationIdentifier = hold.name
                optionHoldImgView.frame.size = CGSize(width: 25, height: 25)
                optionHoldImgView.tag = 1

                var xCord = holdXCord + holdXCordDifference * xCount
                //var yCord = holdYCord
                
                if xCord > Int(bottomMenu.frame.maxX) {
                    print("outabounds!!")
                    xCord = holdXCord
                    yCord = holdYCord + holdYCordDifference * yCount
                    yCount += 1
                    xCount = 0
                }

                xCount += 1

                let holdImgView = createHoldImageView(hold: hold)

                holdImgView.center = CGPoint(x: xCord, y: yCord)
                print("\(xCord), \(yCord)")
                bottomMenu.addSubview(holdImgView)
            }
        case .down:
            print("going down!!!")
            shrinkBottomMenu()
        default:
            break
        }
    }
    
    // sets the bottom menu to shrink at the botto
    func shrinkBottomMenu() {
        UIView.animate(withDuration: 0.5){
            self.bottomMenu.frame = self.originalFrame
        }
        
        let yThreshold = bottomMenuBar.frame.maxY
        
        for subview in bottomMenu.subviews {
            if subview.frame.minY > yThreshold {
                subview.removeFromSuperview()
            }
        }
    }

    func createHoldImageView(hold: Hold) -> UIImageView {
        let holdImg = UIImage(named: hold.imageName)
        let holdImgView = UIImageView(image: holdImg)
        
        holdImgView.frame.size = CGSize(width: 25, height: 25)
        
        viewIDCounter += 1
        holdImgView.restorationIdentifier = "\(hold.name)_\(viewIDCounter)"
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        holdImgView.addGestureRecognizer(panGesture)
        
        holdImgView.isUserInteractionEnabled = true
        
        return holdImgView
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
    
    func generateRecentHoldOptions(dropArea: UIView) {
        recentHolds = Array(holdsList.prefix(4))
        
        let option1X = dropArea.bounds.maxX * 0.20
        let option2X = dropArea.bounds.maxX * 0.40
        let option3X = dropArea.bounds.maxX * 0.60
        let option4X = dropArea.bounds.maxX * 0.80
        
        let optionXArray = [option1X, option2X, option3X, option4X]
        
        let holdYCord = dropArea.bounds.maxY / 2.5

        //print("Bottom Menu Max Bounds: X(\(dropArea.bounds.maxX)), Y(\(dropArea.bounds.maxY))")
        
        var i = 0

        for hold in recentHolds {
            let optionHoldImgName = hold.imageName
            let optionHoldImg = UIImage(named: optionHoldImgName)
            let optionHoldImgView = UIImageView(image: optionHoldImg!)
            optionHoldImgView.restorationIdentifier = hold.name
            optionHoldImgView.frame.size = CGSize(width: 25, height: 25)
            optionHoldImgView.tag = 1

            let xCord = optionXArray[i]
            let yCord = holdYCord

            i += 1

            let holdImgView = createHoldImageView(hold: hold)

            //print("hold option coords \(xCord), \(yCord)")
            holdImgView.center = CGPoint(x: xCord, y: yCord)
            optionHoldImgView.center = CGPoint(x: xCord, y: yCord)

            bottomMenu.addSubview(holdImgView)
            bottomMenu.addSubview(optionHoldImgView)
        }


        for holdView in bottomMenu.subviews {
            print("we made a \(holdView.restorationIdentifier ?? "")")
        }
        
    }
    
    func convertSnapPointsToString() {
        var snapPointsArrayAsString: String = ""
        print("Saving snappoints...")
        var count = 0
        for snapPoint in snapPoints {
            print("adding \(snapPoint.x),\(snapPoint.y)")
            snapPointsArrayAsString.append("\(snapPoint.x),\(snapPoint.y),")
            count += 1
        }
        print("added \(count) points to snappoints string")
        snapPointsArrayAsString.removeLast()
        print("OG: snapPoint.count=\(snapPoints.count)\nValue being saved.count=\(snapPointsArrayAsString.components(separatedBy: ",").count/2)")
        
        var occupiedSnapPointsAsString: String = ""
        for pair in occupiedSnapPoints {
            occupiedSnapPointsAsString.append("\(pair.key):\(pair.value.x),\(pair.value.y)|")
        }
        if(occupiedSnapPointsAsString.count > 0){
            occupiedSnapPointsAsString.removeLast()
        }
        
        var availableSnapPointsAsString: String = ""
        for point in availableSnapPoints {
            availableSnapPointsAsString.append("\(point.x),\(point.y),")
        }
        if(availableSnapPointsAsString.count > 0){
            availableSnapPointsAsString.removeLast()
        }
        
        print("Saved:")
        print("SnapPoints\n\(snapPointsArrayAsString)")
        print("OccupiedSnapPoints\n\(occupiedSnapPointsAsString)")
        print("AvailableSnapPoints\n\(availableSnapPointsAsString)")
        
        snapPointsString = snapPointsArrayAsString
        occupiedSnapPointsString = occupiedSnapPointsAsString
        availableSnapPointsString = availableSnapPointsAsString
    }
    
    func convertStringToCGPointArray(_ pointsString: String) -> [CGPoint] {
        let pointComponents = pointsString.components(separatedBy: ",")
        print(pointComponents)
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
        print(count)
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
        print(count)
        
        return occupiedPoints
    }
}
