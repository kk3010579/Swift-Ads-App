/* =======================

- Classify -

made by FV iMAGINATION ©2015
for CodeCanyon

==========================*/


import UIKit
import Parse
import MapKit
import GoogleMobileAds
import AudioToolbox
import MessageUI


class ShowSingleAd: UIViewController,
    UITableViewDelegate,
UIAlertViewDelegate,
UIScrollViewDelegate,
UITextFieldDelegate,
    CDSideBarControllerDelegate,
GADInterstitialDelegate,
MFMailComposeViewControllerDelegate
    
{
    @IBOutlet weak var tableView: UITableView!
    
    //sideBar variable declaration
    internal var sideBar: CDSideBarController!

    @IBOutlet weak var titleLabel: UILabel!
    /* Views *///FirstCell : AD information
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var adTitleLabel: UILabel!
    
    @IBOutlet var imagesScrollView: UIScrollView!
    @IBOutlet var pageControl: UIPageControl!
    //@IBOutlet var image1: UIImageView!
    //@IBOutlet var image2: UIImageView!
    //@IBOutlet var image3: UIImageView!
    
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var adDescrTxt: UITextView!
    //@IBOutlet var adURL: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var usernameURL: UILabel!
    @IBOutlet var adStatus: UILabel!
    @IBOutlet var messageBt: UIButton! //Message Button
    
    //@IBOutlet var mapView: MKMapView!
    
    
    /////////--SecondCell : navigation Cell
    @IBOutlet weak var bestSortBt: UIButton!
    @IBOutlet weak var worstSortBt: UIButton!
    
    
    @IBOutlet var sendOutlet: UIButton!
//    var reportButt = UIButton()
    
    var adMobInterstitial: GADInterstitial!
    
    
    /* Variables */
    var singleAdArray = NSMutableArray()
    var reviewArray = NSMutableArray()
    
    var singleAdID = String()
    
    var dataURL = NSData()
    var reqURL = NSURL()
    var request = NSMutableURLRequest()
    var receiverEmail = ""
    var postTitle = ""
    
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinView:MKPinAnnotationView!
    var region: MKCoordinateRegion!
    
    var selfobject = PFObject(className: CLASSIF_CLASS_NAME)
    
    //SideBar(Menu) variable declaration
    //internal var sideBar: CDSideBarController!
   
    //Review Cell Property 
    let reviewCellID = "reviewCellID"
    //Ad Property
    let naviCellID = "naviCellID"
    
    //task property
    let adInfoCellID = "adInfoCellID"
    
    ///////////////////////
    
//  Methods  =================================================
    
override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    showHUD()//waiting until download detail data from Parse DB
    // Query the selected Ad to get its details
    //singleAdArray.removeAllObjects()
    
    querySingleAd()
    queryReview()
    
    messageBt.layer.cornerRadius = CORNER_RADIUS
    
    self.navigationController?.setNavigationBarHidden(true, animated: true)
}
    
override func viewDidLoad() {
        super.viewDidLoad()
    
    // Init AdMob interstitial
    let delayTime = dispatch_time(DISPATCH_TIME_NOW,
        Int64(5 * Double(NSEC_PER_SEC)))
    adMobInterstitial = GADInterstitial()
    adMobInterstitial.adUnitID = ADMOB_UNIT_ID
    var request = GADRequest()
    // request.testDevices = [""]
    adMobInterstitial.loadRequest(GADRequest())
    dispatch_after(delayTime, dispatch_get_main_queue()) {
            //self.showInterstitial()
    }
    
    
    // Reset variables for Reply
    receiverEmail = ""
    postTitle = ""
        
        //image1.frame.origin.x = 0
    //image2.frame.origin.x = imagesScrollView.frame.size.width
    //image3.frame.origin.x = imagesScrollView.frame.size.width*2
    
    // Round views corners
    //sendOutlet.layer.cornerRadius = CORNER_RADIUS
    
    ///////////////---------Menu bar creating
    var imageList: Array<UIImage> = [UIImage(named: "pin.png") as UIImage!, UIImage(named: "full_fevstar.png") as UIImage!, UIImage(named: "contact_icon.png") as UIImage!, UIImage(named: "tab_icons.png") as UIImage!]
    sideBar = CDSideBarController(images: imageList)
    sideBar.delegate = self
    sideBar.insertMenuButtonOnView(self.view, pointerSize: CGRectMake(self.view.frame.width - 44, SIDEBAR_DY, 44 - 2 * SIDEBAR_DY, 44 - 2 * SIDEBAR_DY))
    
}
    
    
func querySingleAd() {
    println("SINGLE AD ID: \(singleAdID)")

    var query = PFQuery(className: CLASSIF_CLASS_NAME)
    query.whereKey(CLASSIF_ID, equalTo: singleAdID)
    query.includeKey(CLASSIF_USER)
    query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
            if error == nil {
                self.singleAdArray.removeAllObjects()
                if let objects = objects as? [PFObject] {
                for object in objects {
                    self.singleAdArray.addObject(object)
                }
            }
            // Show Ad details
            self.showAdDetails()
                
            } else {
                var alert = UIAlertView(title: APP_NAME,
                message: "Something went wrong, try again later or check your internet connection",
                delegate: nil,
                cancelButtonTitle: "OK" )
                alert.show()
            }
        //hudView.removeFromSuperview()
    }
    
    var queryUser = PFUser.query()//PFQuery(className: USER_CLASS_NAME)
   
    queryUser!.whereKey(USER_ID, equalTo: PFUser.currentUser()!.objectId!)
  
    queryUser!.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
        if error == nil{
            if let objects = objects as? [PFObject] {
                for object in objects{
                    self.usernameURL.text = object[USER_WEBSITE] as? String
                }
            }
            
        } else {
            var alert = UIAlertView(title: APP_NAME,
                message: "Something went wrong, try again later or check your internet connection",
                delegate: nil,
                cancelButtonTitle: "OK" )
            alert.show()
            self.usernameURL.text = ""
        }

    }
}
    func queryReview()
    {
        var query_review = PFQuery(className: REVIEW_CLASS_NAME)
        query_review.whereKey(REVIEW_AD, equalTo: self.selfobject)
        query_review.includeKey("createdAt")
        query_review.orderByAscending("createdAt")
        query_review.limit = 10
        query_review.findObjectsInBackgroundWithBlock{(objects, error) -> Void in
            if error == nil{
                self.reviewArray.removeAllObjects()
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        self.reviewArray.addObject(object)
                        println("reviewName : \(object[REVIEW_NAME] as? String)")
                    }
                    println("self.reviewArray.count : \(self.reviewArray.count)")
                    // Show Review
                    self.tableView.reloadData()
                    
                    //status information
                    
                    var average: Float = self.avg(self.reviewArray.valueForKeyPath(REVIEW_MARK) as! [Float])
                    self.adStatus.text = "\(average) /5    \(self.reviewArray.count) reviews"
                }
                else{
                    
                }
            }
            else{
                var alert = UIAlertView(title: APP_NAME,
                    message: "Something went wrong, try again later or check your internet connection",
                    delegate: nil,
                    cancelButtonTitle: "OK" )
                alert.show()
            }
            hudView.removeFromSuperview()
        }
    }
    
    func avg(objects: [Float]) -> Float{
        var count: Float = 0
        var total: Float = 0
        for object in objects{
            total += object
        }
        count = Float(objects.count)
        if count == 0{
            count = 1
        }
        return total / count
    }
    
func showAdDetails() {
    var classif = PFObject(className: CLASSIF_CLASS_NAME)
    classif = singleAdArray[0] as! PFObject
    //selfobject = classif
    
    // Get Ad Title
    adTitleLabel.text = "\(classif[CLASSIF_TITLE]!)"
    //the title of ShowSingleAd Screen
    titleLabel.text = "\(classif[CLASSIF_TITLE]!)"
    
    //resolve image size in ImageScrollview
    var wid : CGFloat = self.imagesScrollView.frame.width * 2 / 3
    var hei : CGFloat = self.imagesScrollView.frame.height - 10
    
    //In ImageScrollView the position of Images
    var xCoord : CGFloat = 5
    var yCoord : CGFloat = 5
    var interSpace : CGFloat = 5
    
     // Get image1
    let imageFile1 = classif[CLASSIF_IMAGE1] as? PFFile
    imageFile1?.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
        if error == nil {
            if let imageData = imageData {
                var image = UIImageView()
                image.contentMode = UIViewContentMode.ScaleAspectFill
                image.clipsToBounds = true
                image.image = UIImage(data: imageData)
                image.frame = CGRect(x: xCoord, y: yCoord, width: wid, height: hei)
                
                self.imagesScrollView.addSubview(image)
                self.pageControl.numberOfPages = 1
                xCoord += wid + interSpace
        } } }
    
    // Get image2
    let imageFile2 = classif[CLASSIF_IMAGE2] as? PFFile
    imageFile2?.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
        if error == nil {
            if let imageData = imageData {
                
                var image = UIImageView()
                image.contentMode = UIViewContentMode.ScaleAspectFill
                image.clipsToBounds = true
                image.image = UIImage(data: imageData)
                image.frame = CGRect(x: xCoord, y: yCoord, width: wid, height: hei)
                self.imagesScrollView.addSubview(image)
                self.pageControl.numberOfPages = 2
                xCoord += wid + interSpace
        } } }
    
    // Get image3
    let imageFile3 = classif[CLASSIF_IMAGE3] as? PFFile
    imageFile3?.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
        if error == nil {
            if let imageData = imageData {
                
                var image = UIImageView()
                image.contentMode = UIViewContentMode.ScaleAspectFill
                image.clipsToBounds = true
                image.image = UIImage(data: imageData)
                image.frame = CGRect(x: xCoord, y: yCoord, width: wid, height: hei)
                self.imagesScrollView.addSubview(image)
                self.pageControl.numberOfPages = 3
                xCoord += wid + interSpace
        } } }
    // Setup images ScrollView
    self.imagesScrollView.contentSize = CGSizeMake(wid*3, imagesScrollView.frame.size.height)
    // Get Ad Price
    priceLabel.text = "$\(classif[CLASSIF_PRICE]!)"
    
    // Get Ad Description
    adDescrTxt.text = "\(classif[CLASSIF_DESCRIPTION]!)"
    
    // Get Ad Address
    //addressLabel.text = "\(classif[CLASSIF_ADDRESS_STRING]!)"
    //addPinOnMap(addressLabel.text!)

    // Get username
    var user = classif[CLASSIF_USER] as! PFUser
    user.fetchIfNeeded()
    usernameLabel.text = user.username!
    
    hudView.removeFromSuperview()
    
}
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            return self.reviewArray.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
//
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //
        var myCell = tableView.dequeueReusableCellWithIdentifier("reviewCell", forIndexPath: indexPath) as! ReviewCell
        
           var reviewObject = reviewArray[indexPath.row] as! PFObject
        
            println("reviewObject:\(reviewObject)")
        
            myCell.userName.text = reviewObject[REVIEW_NAME] as? String
        
            let formatter = NSDateFormatter()
            formatter.dateFormat = "MM-dd-yyyy"
            myCell.dateLabel.text = formatter.stringFromDate(reviewObject.createdAt!)
        
            var mark = reviewObject[REVIEW_MARK] as! Float
            myCell.markLabel.text = "\(mark)"
            println("\(myCell.markLabel.text)")
        
            myCell.contentText.text = reviewObject[REVIEW_TEXT] as? String
        
            myCell.frame.size.height = 250

            return myCell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 250
    }
    
/* MARK - ADMOB DELEGATES */
func showInterstitial() {
    // Show AdMob interstitial
    if adMobInterstitial.isReady {
        adMobInterstitial.presentFromRootViewController(self)
        println("present Interstitial")
    }
}
    
    

/* MARK - SCROLLVIEW DELEGATE */
func scrollViewDidScroll(scrollView: UIScrollView) {
    // switch pageControl to current page
    let pageWidth = imagesScrollView.frame.size.width
    let page = Int(floor((imagesScrollView.contentOffset.x * 2 + pageWidth) / (pageWidth * 2)))
    pageControl.currentPage = page
}
    
// SEND REPLY BUTTON
@IBAction func sendReplyButt(sender: AnyObject) {
    var classifClass = PFObject(className: CLASSIF_CLASS_NAME)
    classifClass = singleAdArray[0] as! PFObject
    var user = classifClass[CLASSIF_USER] as! PFUser
    user.fetchIfNeeded()
    
    receiverEmail = user.email!
    postTitle = adTitleLabel.text!
    println("\(receiverEmail)")
    
    
}
    
    // menu button Action
    func menuButtonClicked(index: Int32) {
        //TODO
        //var rootViewController = self.storyboard!.rootViewController as UITabBarController
        var del = UIApplication.sharedApplication().delegate as! AppDelegate
        if index == 1{//--Favorite
            if(PFUser.currentUser() == nil){
                var alert = UIAlertView(title: APP_NAME,
                    message: "You must login/signup into your Account to add Favorites",
                    delegate: nil,
                    cancelButtonTitle: "OK" )
                alert.show()
                return
            }
            currentList = checkList.Favorite
            let choiceVC = self.storyboard?.instantiateViewControllerWithIdentifier("naviFavorite") as! UINavigationController
            del.window?.rootViewController = choiceVC
            //self.navigationController?.pushViewController(choiceVC, animated: true)
            //presentViewController(choiceVC, animated: true, completion: nil)
        }else if index == 2{//--Account
            let choiceVC = self.storyboard?.instantiateViewControllerWithIdentifier("naviAccount") as! UINavigationController
            del.window?.rootViewController = choiceVC
            //self.navigationController?.pushViewController(choiceVC, animated: true)            //presentViewController(choiceVC, animated: true, completion: nil)
        }else if index == 3{//--Home
            let choiceVC = self.storyboard?.instantiateViewControllerWithIdentifier("naviHome") as! UINavigationController
            del.window?.rootViewController = choiceVC
            //self.navigationController?.pushViewController(choiceVC, animated: true)
            //presentViewController(choiceVC, animated: true, completion: nil)
        }else if index == 0{//--Pin Screen ??? i donot know it yet, why?
            
        }
        else{
            
        }
    }

    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showHUD() {
        hudView.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2)
        hudView.backgroundColor = UIColor.darkGrayColor()
        hudView.alpha = 0.9
        hudView.layer.cornerRadius = hudView.bounds.size.width/2
        
        indicatorView.center = CGPointMake(hudView.frame.size.width/2, hudView.frame.size.height/2)
        indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        hudView.addSubview(indicatorView)
        view.addSubview(hudView)
        indicatorView.startAnimating()
    }
    
    
    //the event when you clicked messageButton, and then displaying screen <Review>
    @IBAction func messageBtClicked(sender: AnyObject) {
        
        //presentViewController(reviewVC, animated: true, completion: nil)
    }
    
    
    @IBAction func backBtClicked(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    ////////////////////////*************** <Review>
    
    @IBAction func reviewBtClicked(sender: AnyObject) {
        var reviewVC = self.storyboard?.instantiateViewControllerWithIdentifier("ReviewID") as! Review
        
        reviewVC.selfObject = selfobject
        reviewVC.adPointer = singleAdID
        
        self.navigationController?.pushViewController(reviewVC, animated: true)
    }
   
    @IBAction func bestBtClicked(sender: AnyObject) {
        showHUD()
        
        println("first.............\(reviewArray)")
        var descriptor: NSSortDescriptor = NSSortDescriptor(key: REVIEW_MARK, ascending: false)
        var array: NSArray = reviewArray.sortedArrayUsingDescriptors([descriptor])
        reviewArray = NSMutableArray(array: array)
        
        println("second.........\(array)")
        self.tableView.reloadData()
        
        hudView.removeFromSuperview()
    }
    
    
    @IBAction func worstBtClicked(sender: AnyObject) {
        showHUD()
        
        println("first.............\(reviewArray)")
        var descriptor: NSSortDescriptor = NSSortDescriptor(key: REVIEW_MARK, ascending: true)
        var array: NSArray = reviewArray.sortedArrayUsingDescriptors([descriptor])
        reviewArray = NSMutableArray(array: array)
        
        println("second.........\(array)")
        self.tableView.reloadData()
        
        hudView.removeFromSuperview()

    }
    
    @IBAction func mostRecentBtClcked(sender: AnyObject) {
        showHUD()
        
        println("first.............\(reviewArray)")
        var descriptor: NSSortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
        var array: NSArray = reviewArray.sortedArrayUsingDescriptors([descriptor])
        reviewArray = NSMutableArray(array: array)
        
        println("second.........\(array)")
        self.tableView.reloadData()
        
        hudView.removeFromSuperview()
    }
    
    ///////////////////////************************* <Bottom View>
    
    @IBAction func favoriteBtClicked(sender: AnyObject) {
        println("clicked favoritebutton...............")
    }
    
    @IBAction func addReviewBtClicked(sender: AnyObject) {
        println("clicked reviewButton.................")
        var reviewVC = self.storyboard?.instantiateViewControllerWithIdentifier("ReviewID") as! Review
        
        reviewVC.selfObject = selfobject
        reviewVC.adPointer = singleAdID
        
        self.navigationController?.pushViewController(reviewVC, animated: true)
    }
    
    @IBAction func shareBtClicked(sender: AnyObject) {
       
    }
    
}
