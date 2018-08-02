//
//  PostController.swift
//  Hour
//
//  Created by Moses Oh on 2/19/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import GeoFire

class PostController: UIViewController {

    var geoFire: GeoFire!
    var ref: DatabaseReference!
    
    var feedController: FeedController?
    var loginController: LoginController?
    var childUpdates: [String: Any] = [:]
    var numberOfPeople: Int = 0
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(handlePost))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white

        ref = Database.database().reference()
        geoFire = GeoFire(firebaseRef: ref.child("posts_location"))
    
        setupViews()
    }
    
    let activityContainer: UIView = {
        let ac = UIView()
        ac.backgroundColor = UIColor.white
        ac.translatesAutoresizingMaskIntoConstraints = false
//        ac.layer.cornerRadius = 5
//        ac.layer.masksToBounds = true
        return ac
    }()
    
    let activityTextField: UITextField = {
        let atv = UITextField()
        atv.placeholder = " Activity"
        atv.font = UIFont.init(name: "Helvetica Neue", size: 18)
        atv.textColor = UIColor.gray
        atv.translatesAutoresizingMaskIntoConstraints = false
        return atv
    }()
    
    let descriptionContainer: UIView = {
        let dc = UIView()
        dc.backgroundColor = UIColor.white
        dc.translatesAutoresizingMaskIntoConstraints = false
        dc.layer.cornerRadius = 5
        dc.layer.masksToBounds = true
        return dc
    }()
    
    let descriptionTextField: UITextView = {
        let dtf = UITextView()
        dtf.font = UIFont.init(name: "Helvetica Neue", size: 18)
        dtf.textColor = UIColor.gray
        dtf.placeholder = " Description"
        dtf.isScrollEnabled = true
        dtf.translatesAutoresizingMaskIntoConstraints = false
        return dtf
    }()
    
    let dateAndTimeContainer: UIView = {
        let dc = UIView()
        dc.backgroundColor = UIColor.white
        dc.translatesAutoresizingMaskIntoConstraints = false
//        dc.layer.cornerRadius = 5
//        dc.layer.masksToBounds = true
        return dc
    }()
    
    let dateAndTimeLabel: UIButton = {
        let datl = UIButton(type: .system)
        datl.setTitle(" Date and Time", for: .normal)
        datl.setTitleColor(UIColor(red: 199/255, green:199/255, blue: 205/255, alpha: 1), for: .normal)
        datl.titleLabel?.font = UIFont.init(name: "Helvetica Neue", size: 18)!
        datl.addTarget(self, action: #selector(handleDateAndTimeView), for: .touchUpInside)
        datl.translatesAutoresizingMaskIntoConstraints = false
        return datl
    }()
    
    let locationContainer: UIView = {
        let lc = UIView()
        lc.backgroundColor = UIColor.white
        lc.translatesAutoresizingMaskIntoConstraints = false
//        lc.layer.cornerRadius = 5
//        lc.layer.masksToBounds = true
        return lc
    }()
    
    let locationLabel: UIButton = {
        let ll = UIButton(type: .system)
        ll.setTitle(" Location", for: .normal)
        ll.setTitleColor(UIColor(red: 199/255, green:199/255, blue: 205/255, alpha: 1), for: .normal)
        ll.titleLabel?.font = UIFont.init(name: "Helvetica Neue", size: 18)!
        ll.addTarget(self, action: #selector(handleLocationView), for: .touchUpInside)
        ll.translatesAutoresizingMaskIntoConstraints = false
        return ll
    }()
    
    //Category
    
    var listOfButtons = [UIButton]()
    
    let categoryContainer: UIView = {
        let cc = UIView()
        cc.backgroundColor = UIColor.white
        cc.translatesAutoresizingMaskIntoConstraints = false
//        cc.layer.cornerRadius = 5
//        cc.layer.masksToBounds = true
        return cc
    }()
    
    let categoryLabel: UILabel = {
        let cl = UILabel()
        cl.textColor = UIColor(red: 199/255, green:199/255, blue: 205/255, alpha: 1)
        cl.text = " Category"
        cl.font = UIFont.init(name: "Helvetica Neue", size: 18)
        cl.translatesAutoresizingMaskIntoConstraints = false
        return cl
    }()
    
    let tripsButton: CategoryButton = {
        let tb = CategoryButton()
        tb.setTitle("Trips", for: .normal)
//        tb.addTarget(self, action: pressed, for: UIControlEvents.allTouchEvents)
        return tb
    }()

    let natureButton: CategoryButton = {
        let nb = CategoryButton()
        nb.setTitle("Nature", for: .normal)
        return nb
    }()
    
    let foodDrinkButton: CategoryButton = {
        let fdb = CategoryButton()
        fdb.setTitle("Food & Drink", for: .normal)
        return fdb
    }()
    
    let concertsButton: CategoryButton = {
        let cb = CategoryButton()
        cb.setTitle(" Concerts", for: .normal)
        return cb
    }()
    
    let nightlifeButton: CategoryButton = {
        let nlb = CategoryButton()
        nlb.setTitle(" Nightlife", for: .normal)
        return nlb
    }()
    
    let carpoolButton: CategoryButton = {
        let cb = CategoryButton()
        cb.setTitle(" Carpool", for: .normal)
        return cb
    }()
    
    let sportsButton: CategoryButton = {
        let sb = CategoryButton()
        sb.setTitle(" Sports", for: .normal)
        return sb
    }()
    
    let workButton: CategoryButton = {
        let wb = CategoryButton()
        wb.setTitle(" Work", for: .normal)
        return wb
    }()
    
    
    // number of people
    let numberOfPeopleContainer: UIView = {
        let nopc = UIView()
        nopc.backgroundColor = UIColor.white
        nopc.translatesAutoresizingMaskIntoConstraints = false
        nopc.layer.cornerRadius = 5
        nopc.layer.masksToBounds = true
        return nopc
    }()
    
    let numberOfPeopleLabel: UILabel = {
        let nopl = UILabel()
        nopl.textColor = UIColor(red: 199/255, green:199/255, blue: 205/255, alpha: 1)
        nopl.text = " Number of People"
        nopl.font = UIFont.init(name: "Helvetica Neue", size: 18)
        nopl.translatesAutoresizingMaskIntoConstraints = false
        return nopl
    }()
    
    var number: UILabel = {
        let no = UILabel()
        no.text = "0"
        no.textColor = UIColor.gray
        no.font = UIFont.init(name: "Helvetica Neue", size: 20)
        no.translatesAutoresizingMaskIntoConstraints = false
        return no
    }()
    
    let addButton: BounceButton = {
        let ab = BounceButton()
        ab.setTitle("+", for: .normal)
        ab.addTarget(self, action: #selector(addOnePerson), for: .touchUpInside)
        return ab
    }()
    
    let deleteButton: BounceButton = {
        let db = BounceButton()
        db.setTitle("-", for: .normal)
        db.addTarget(self, action: #selector(deleteOnePerson), for: .touchUpInside)
        return db
    }()
    
    let enableChatContainer: UIView = {
        let nopc = UIView()
        nopc.backgroundColor = UIColor.white
        nopc.translatesAutoresizingMaskIntoConstraints = false
        nopc.layer.cornerRadius = 5
        nopc.layer.masksToBounds = true
        return nopc
    }()
    
    let enableChatLabel: UILabel = {
        let ecl = UILabel()
        ecl.text = "Enable Group Chat"
        ecl.textColor = UIColor(red: 199/255, green:199/255, blue: 205/255, alpha: 1)
        ecl.font = UIFont.init(name: "Helvetica Neue", size: 18)
        ecl.translatesAutoresizingMaskIntoConstraints = false
        return ecl
    }()
    
    let enableChatSwitch : UISwitch = {
        let ecs = UISwitch()
        ecs.addTarget(self, action: #selector(enableGroupChat), for: .valueChanged)
        ecs.translatesAutoresizingMaskIntoConstraints = false
        return ecs
    }()
    
    let enableChatTitleView: UIView = {
        let ac = UIView()
        ac.backgroundColor = UIColor.white
        ac.translatesAutoresizingMaskIntoConstraints = false
        //        ac.layer.cornerRadius = 5
        //        ac.layer.masksToBounds = true
        return ac
    }()
    
    let enableChatTitleText: UITextField = {
        let atv = UITextField()
        atv.placeholder = " Group Chat Title"
        atv.font = UIFont.init(name: "Helvetica Neue", size: 18)
        atv.textColor = UIColor.gray
        atv.translatesAutoresizingMaskIntoConstraints = false
        return atv
    }()
    
    @objc func enableGroupChat() {
//        enableChatTitleViewHeightAnchor?.constant = enableChatSwitch.isOn == true ? 50 : 0
//        enableChatTitleTextHeightAnchor = enableChatTitleText.centerYAnchor.constraint(equalTo: enableChatTitleView.centerYAnchor)
        
    }
    
    func setupViews() {
        
        /** ScrollView Setup **/
        let scrollView = UIScrollView(frame: view.bounds)
        scrollView.isScrollEnabled = true
        scrollView.contentSize = CGSize(width:self.view.frame.size.width, height: self.view.frame.size.height + 230)
        
        view.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: view.topAnchor)
        scrollView.heightAnchor.constraint(equalTo: view.heightAnchor)
        scrollView.systemLayoutSizeFitting(UILayoutFittingExpandedSize)
        
        /** Activity Setup **/
        scrollView.addSubview(activityContainer)
        activityContainer.SetContainer(otherContainer: scrollView, top: 10, height: 50)
        activityContainer.addSubview(activityTextField)
        activityTextField.centerYAnchor.constraint(equalTo: activityContainer.centerYAnchor).isActive = true
        activityTextField.leftAnchor.constraint(equalTo: activityContainer.leftAnchor, constant: 10).isActive = true
        activityTextField.widthAnchor.constraint(equalTo: activityContainer.widthAnchor, constant: -10).isActive = true
        
        /** Description Setup**/
        scrollView.addSubview(descriptionContainer)
        descriptionContainer.SetContainer(otherContainer: activityContainer, top: 5, height: 150)
        descriptionContainer.addSubview(descriptionTextField)
        descriptionTextField.topAnchor.constraint(equalTo: descriptionContainer.topAnchor, constant: 10).isActive = true
        descriptionTextField.heightAnchor.constraint(equalTo: descriptionContainer.heightAnchor, constant: 10).isActive = true
        descriptionTextField.leftAnchor.constraint(equalTo: descriptionContainer.leftAnchor, constant: 5).isActive = true
        descriptionTextField.widthAnchor.constraint(equalTo: descriptionContainer.widthAnchor, constant: -10).isActive = true

        /** Date and Time Setup **/
        scrollView.addSubview(dateAndTimeContainer)
        dateAndTimeContainer.SetContainer(otherContainer: descriptionContainer, top: 5, height: 50)
        dateAndTimeContainer.addSubview(dateAndTimeLabel)
        dateAndTimeLabel.centerYAnchor.constraint(equalTo: dateAndTimeContainer.centerYAnchor).isActive = true
        dateAndTimeLabel.leftAnchor.constraint(equalTo: dateAndTimeContainer.leftAnchor, constant: 10).isActive = true

        /** Location Setup **/
        scrollView.addSubview(locationContainer)
        locationContainer.SetContainer(otherContainer: dateAndTimeContainer, top: 5, height: 50)
        locationContainer.addSubview(locationLabel)
        locationLabel.centerYAnchor.constraint(equalTo: locationContainer.centerYAnchor).isActive = true
        locationLabel.leftAnchor.constraint(equalTo: locationContainer.leftAnchor, constant: 10).isActive = true

        /** Category Setup **/
        scrollView.addSubview(categoryContainer)
        categoryContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        categoryContainer.topAnchor.constraint(equalTo: locationContainer.bottomAnchor, constant: 5).isActive = true
        categoryContainer.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        categoryContainer.addSubview(categoryLabel)
        categoryLabel.topAnchor.constraint(equalTo: categoryContainer.topAnchor, constant: 10).isActive = true
        categoryLabel.leftAnchor.constraint(equalTo: categoryContainer.leftAnchor, constant: 10).isActive = true

        categoryContainer.addSubview(tripsButton)
        tripsButton.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 20).isActive = true
        tripsButton.leftAnchor.constraint(equalTo: categoryContainer.leftAnchor, constant: 40).isActive = true
        tripsButton.widthAnchor.constraint(equalTo: categoryContainer.widthAnchor, multiplier: 1/3).isActive = true
        tripsButton.heightAnchor.constraint(equalTo: categoryContainer.heightAnchor, multiplier: 1/7).isActive = true

        categoryContainer.addSubview(natureButton)
        natureButton.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 20).isActive = true
        natureButton.leftAnchor.constraint(equalTo: tripsButton.rightAnchor, constant: 40).isActive = true
        natureButton.widthAnchor.constraint(equalTo: categoryContainer.widthAnchor, multiplier: 1/3).isActive = true
        natureButton.heightAnchor.constraint(equalTo: categoryContainer.heightAnchor, multiplier: 1/7).isActive = true

        categoryContainer.addSubview(foodDrinkButton)
        foodDrinkButton.topAnchor.constraint(equalTo: tripsButton.bottomAnchor, constant: 20).isActive = true
        foodDrinkButton.leftAnchor.constraint(equalTo: categoryContainer.leftAnchor, constant: 40).isActive = true
        foodDrinkButton.widthAnchor.constraint(equalTo: categoryContainer.widthAnchor, multiplier: 1/3).isActive = true
        foodDrinkButton.heightAnchor.constraint(equalTo: categoryContainer.heightAnchor, multiplier: 1/7).isActive = true

        categoryContainer.addSubview(concertsButton)
        concertsButton.topAnchor.constraint(equalTo: natureButton.bottomAnchor, constant: 20).isActive = true
        concertsButton.leftAnchor.constraint(equalTo: foodDrinkButton.rightAnchor, constant: 40).isActive = true
        concertsButton.widthAnchor.constraint(equalTo: categoryContainer.widthAnchor, multiplier: 1/3).isActive = true
        concertsButton.heightAnchor.constraint(equalTo: categoryContainer.heightAnchor, multiplier: 1/7).isActive = true

        categoryContainer.addSubview(nightlifeButton)
        nightlifeButton.topAnchor.constraint(equalTo: foodDrinkButton.bottomAnchor, constant:20).isActive = true
        nightlifeButton.leftAnchor.constraint(equalTo: categoryContainer.leftAnchor, constant: 40).isActive = true
        nightlifeButton.widthAnchor.constraint(equalTo: categoryContainer.widthAnchor, multiplier: 1/3).isActive = true
        nightlifeButton.heightAnchor.constraint(equalTo: categoryContainer.heightAnchor, multiplier: 1/7).isActive = true

        categoryContainer.addSubview(carpoolButton)
        carpoolButton.topAnchor.constraint(equalTo: concertsButton.bottomAnchor, constant: 20).isActive = true
        carpoolButton.leftAnchor.constraint(equalTo: nightlifeButton.rightAnchor, constant: 40).isActive = true
        carpoolButton.widthAnchor.constraint(equalTo: categoryContainer.widthAnchor, multiplier: 1/3).isActive = true
        carpoolButton.heightAnchor.constraint(equalTo: categoryContainer.heightAnchor, multiplier: 1/7).isActive = true

        categoryContainer.addSubview(sportsButton)
        sportsButton.topAnchor.constraint(equalTo: nightlifeButton.bottomAnchor, constant:20).isActive = true
        sportsButton.leftAnchor.constraint(equalTo: categoryContainer.leftAnchor, constant: 40).isActive = true
        sportsButton.widthAnchor.constraint(equalTo: categoryContainer.widthAnchor, multiplier: 1/3).isActive = true
        sportsButton.heightAnchor.constraint(equalTo: categoryContainer.heightAnchor, multiplier: 1/7).isActive = true

        categoryContainer.addSubview(workButton)
        workButton.topAnchor.constraint(equalTo: carpoolButton.bottomAnchor, constant:20).isActive = true
        workButton.leftAnchor.constraint(equalTo: sportsButton.rightAnchor, constant: 40).isActive = true
        workButton.widthAnchor.constraint(equalTo: categoryContainer.widthAnchor, multiplier: 1/3).isActive = true
        workButton.heightAnchor.constraint(equalTo: categoryContainer.heightAnchor, multiplier: 1/7).isActive = true
        
        categoryContainer.bottomAnchor.constraint(equalTo: workButton.bottomAnchor, constant: 20).isActive = true

        /** Number of People Setup **/
        scrollView.addSubview(numberOfPeopleContainer)
        numberOfPeopleContainer.SetContainer(otherContainer: categoryContainer, top: 5, height: 120)
        numberOfPeopleContainer.addSubview(numberOfPeopleLabel)
        numberOfPeopleLabel.topAnchor.constraint(equalTo: numberOfPeopleContainer.topAnchor, constant: 10).isActive = true
        numberOfPeopleLabel.leftAnchor.constraint(equalTo: numberOfPeopleContainer.leftAnchor, constant: 10).isActive = true

        numberOfPeopleContainer.addSubview(number)
        number.topAnchor.constraint(equalTo: numberOfPeopleLabel.topAnchor, constant: 20).isActive = true
        number.centerXAnchor.constraint(equalTo: numberOfPeopleContainer.centerXAnchor).isActive = true
        number.centerYAnchor.constraint(equalTo: numberOfPeopleContainer.centerYAnchor).isActive = true
        
        numberOfPeopleContainer.addSubview(addButton)
        addButton.centerXAnchor.constraint(equalTo: numberOfPeopleContainer.centerXAnchor, constant: 70).isActive = true
        addButton.centerYAnchor.constraint(equalTo: numberOfPeopleContainer.centerYAnchor).isActive = true
        
        numberOfPeopleContainer.addSubview(deleteButton)
        deleteButton.centerXAnchor.constraint(equalTo: numberOfPeopleContainer.centerXAnchor, constant: -70).isActive = true
        deleteButton.centerYAnchor.constraint(equalTo: numberOfPeopleContainer.centerYAnchor).isActive = true
        
        /** Enable Chat Setup **/
        scrollView.addSubview(enableChatContainer)
        enableChatContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        enableChatContainer.topAnchor.constraint(equalTo: numberOfPeopleContainer.bottomAnchor, constant: 5).isActive = true
        enableChatContainer.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        enableChatContainerHeightAnchor = enableChatContainer.heightAnchor.constraint(equalToConstant: 50)
        enableChatContainerHeightAnchor?.isActive = true
        
        enableChatContainer.addSubview(enableChatLabel)
        enableChatLabel.topAnchor.constraint(equalTo: enableChatContainer.topAnchor, constant: 10).isActive = true
        enableChatLabel.leftAnchor.constraint(equalTo: enableChatContainer.leftAnchor, constant: 10).isActive = true
        
        enableChatContainer.addSubview(enableChatSwitch)
        enableChatSwitch.topAnchor.constraint(equalTo: enableChatContainer.topAnchor, constant: 10).isActive = true
        enableChatSwitch.rightAnchor.constraint(equalTo: enableChatContainer.rightAnchor, constant: -80).isActive = true
        
        scrollView.addSubview(enableChatTitleView)
        enableChatTitleView.topAnchor.constraint(equalTo: enableChatContainer.bottomAnchor, constant: 5).isActive = true
        enableChatTitleView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        enableChatTitleViewHeightAnchor = enableChatTitleView.heightAnchor.constraint(equalToConstant: 0)
        enableChatTitleViewHeightAnchor?.isActive = true
        
//        enableChatTitleView.addSubview(enableChatTitleText)
//        enableChatTitleTextHeightAnchor = enableChatTitleText.centerYAnchor.constraint(equalTo: enableChatTitleView.centerYAnchor)
//        enableChatTitleTextHeightAnchor?.isActive = true
//        enableChatTitleText.leftAnchor.constraint(equalTo: enableChatTitleView.leftAnchor, constant: 10).isActive = true
//        enableChatTitleText.widthAnchor.constraint(equalTo: enableChatTitleView.widthAnchor, constant: -10).isActive = true
        
    }
    
    var enableChatTitleViewHeightAnchor: NSLayoutConstraint?
    var enableChatTitleTextHeightAnchor: NSLayoutConstraint?
    var enableChatContainerHeightAnchor: NSLayoutConstraint?
    
    //UI Functions
    
    @objc func addOnePerson(sender: UIButton!) {
        numberOfPeople += 1
        number.text = "\(numberOfPeople)"
    }
    
    @objc func deleteOnePerson() {
        if(numberOfPeople > 0)
        {
            numberOfPeople -= 1
        }
        number.text = "\(numberOfPeople)"
    }
    
    @objc func handleDateAndTimeView() {
        print(childUpdates)
        let dateAndTimeController = DateAndTimeController()
        let navController = UINavigationController(rootViewController: dateAndTimeController)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    @objc func handleLocationView() {
        let locationController = LocationController()
        locationController.postController = self
        locationController.feedController = self.feedController
        let navController = UINavigationController(rootViewController: locationController)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    //Database Functions
    
    @objc func handlePost(){
        if activityTextField.text != ""
        {
            let key = ref.child("posts").childByAutoId().key
            let userID = Auth.auth().currentUser?.uid
            ref.child("users").child(userID!).observeSingleEvent(of: .value) { (snapshot) in
                if(self.enableChatSwitch.isOn)
                {
                    MessagesController(nibName: nil, bundle: nil).createChat([HUser(snapshot: snapshot)], name: self.activityTextField.text!)
                }
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let dateFormatter:DateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM-dd-yyyy hh:mm a"
                    let usersUid = [userID!: -1] as [String: Int]
                    let post = ["name": dictionary["name"] ?? "noname",
                                "uid": dictionary["uid"] ?? "nouid",
                                "activity": self.activityTextField.text!,
                                "description": self.descriptionTextField.text,
                                "time": ServerValue.timestamp(),
                                "location": self.locationLabel.title(for: .normal)!,
                                "groupCount": self.numberOfPeople,
                                "usersUid": usersUid] as [String : Any]
                    let child = ["/posts/\(key)": post]
                    let userPosts = [key: true]
                    
                    //update FireBase posts
                    let ref = Database.database().reference().child("users").child(userID!).child("posts")
                    ref.updateChildValues(userPosts) {(err,ref) in
                        if err != nil{
                            print(err ?? "error")
                            return
                        }
                    }
                    
                    self.ref.updateChildValues(child) { (err, ref) in
                        if err != nil{
                            print(err ?? "error")
                            return
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.feedController?.determineMyCurrentLocation()
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                    
                    //convert string address to CLLocation and set GeoFire location
                    let address = self.locationLabel.title(for: .normal)
                    let geoCoder = CLGeocoder()
                    geoCoder.geocodeAddressString(address!) { (placemarks, error) in
                        guard
                            let placemarks = placemarks,
                            let location = placemarks.first?.location
                            else {
                                // handle no location found
                                return
                        }
                        self.geoFire.setLocation(location, forKey: "\(key)")
                    }
                }
            }
            print("posted")
        }
        
    }
    
    
    
    
//    func timeAgoSinceDate(_ date:Date, numericDates:Bool = false) -> String {
//        
//        let calendar = NSCalendar.current
//        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
//        let now = Date()
//        let earliest = now < date ? now : date
//        let latest = (earliest == now) ? date : now
//        let components = calendar.dateComponents(unitFlags, from: earliest,  to: latest)
//        
//        if (components.year! >= 2) {
//            return "\(components.year!) years ago"
//        } else if (components.year! >= 1){
//            if (numericDates){
//                return "1 year ago"
//            } else {
//                return "Last year"
//            }
//        } else if (components.month! >= 2) {
//            return "\(components.month!) months ago"
//        } else if (components.month! >= 1){
//            if (numericDates){
//                return "1 month ago"
//            } else {
//                return "Last month"
//            }
//        } else if (components.weekOfYear! >= 2) {
//            return "\(components.weekOfYear!) weeks ago"
//        } else if (components.weekOfYear! >= 1){
//            if (numericDates){
//                return "1 week ago"
//            } else {
//                return "Last week"
//            }
//        } else if (components.day! >= 2) {
//            return "\(components.day!) days ago"
//        } else if (components.day! >= 1){
//            if (numericDates){
//                return "1 day ago"
//            } else {
//                return "Yesterday"
//            }
//        } else if (components.hour! >= 2) {
//            return "\(components.hour!) hours ago"
//        } else if (components.hour! >= 1){
//            if (numericDates){
//                return "1 hour ago"
//            } else {
//                return "An hour ago"
//            }
//        } else if (components.minute! >= 2) {
//            return "\(components.minute!) minutes ago"
//        } else if (components.minute! >= 1){
//            if (numericDates){
//                return "1 minute ago"
//            } else {
//                return "A minute ago"
//            }
//        } else if (components.second! >= 3) {
//            return "\(components.second!) seconds ago"
//        } else {
//            return "Just now"
//        }
//        
//    }

}

extension UIView {
    func SetContainer(otherContainer: UIView, top: CGFloat, height: CGFloat) {
        self.centerXAnchor.constraint(equalTo: otherContainer.centerXAnchor).isActive = true
        self.topAnchor.constraint(equalTo: otherContainer.bottomAnchor, constant: top).isActive = true
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.widthAnchor.constraint(equalTo: otherContainer.widthAnchor).isActive = true
    }
    
    func SetContainer(topContainer: UIView, otherContainer: UIView, top: CGFloat, left: CGFloat, widthMult: CGFloat, heightMult: CGFloat)
    {
        self.topAnchor.constraint(equalTo: topContainer.bottomAnchor, constant: top).isActive = true
        self.leftAnchor.constraint(equalTo: otherContainer.leftAnchor, constant: left).isActive = true
        self.widthAnchor.constraint(equalTo: otherContainer.widthAnchor, multiplier: widthMult).isActive = true
        self.heightAnchor.constraint(equalTo: otherContainer.heightAnchor, multiplier: heightMult).isActive = true
    }
    
}

extension PostController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard))
    
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}

