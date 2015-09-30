/* =======================

- Classify -

made by FV iMAGINATION ©2015
for CodeCanyon

==========================*/


import UIKit
import Parse
import GoogleMobileAds
import AudioToolbox


class Home: UIViewController,
UITextFieldDelegate,
UIPickerViewDataSource,
UIPickerViewDelegate,
CDSideBarControllerDelegate,
GADInterstitialDelegate
{
    //sideBar variable declaration
    internal var sideBar: CDSideBarController!
    
    @IBOutlet var fieldsView: UIView! //unused
    @IBOutlet var keywordsTxt: UITextField! //unused
    
    @IBOutlet weak var topView: UIView!
    /* Views */
    @IBOutlet var searchOutlet: UIButton! //DIG button
    @IBOutlet var termsOfUseOutlet: UIButton! // Terms of Use
    

    @IBOutlet var whereTxt: UITextField! //locationField
    @IBOutlet var categoryTxt: UITextField! // serviceField
    
    @IBOutlet var categoryContainer: UIView! /// -- MT
    @IBOutlet var categoryPickerView: UIPickerView! /// --MT
    
    @IBOutlet var categoriesScrollView: UIScrollView! // categoriesScrollView
    
    var adMobInterstitial: GADInterstitial!
    
    @IBOutlet weak var postBtn: UIButton!
    @IBOutlet weak var tableview: UITableView!
    
    /* Variables */
    var classifArray = NSMutableArray()
    var catButton = UIButton()
    var catView = UIView()
    var catLabel = UILabel()
    
    //PickerView Datasource
    var pickerDatasource = [String]()
    //new items------MT
    var spotLightArray = NSMutableArray();
    var closeByArray = NSMutableArray();
    //
    //@IBOutlet var categoryScrollView: UIScrollView!
    @IBOutlet var spotlightScrollView: UIScrollView!
    @IBOutlet var closebyScrollView: UIScrollView!
    @IBOutlet weak var toolBar: UIView!
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    //Category Or Cities
    var f = false
    
    //
//    var adLoader = gad

override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
    //categorycontainer setting
    categoryContainer.frame = CGRectMake(0, 800, self.view.frame.size.width, categoryContainer.frame.size.height)
    toolBar.frame = CGRectMake(0, 0, self.view.frame.size.width, toolBar.frame.size.height)
    categoryPicker.frame = CGRectMake(0, 0, self.view.frame.size.width, categoryPicker.frame.size.height)
    
    searchedAdsArray.removeAllObjects()
    
    showHUD()//waiting cursor is enabled(during download data from Parse DB)
    
    //CategoryView, SpotlightView, ClosebyView
    for view in self.categoriesScrollView.subviews{
        view.removeFromSuperview()
    }
    for view in self.spotlightScrollView.subviews{
        view.removeFromSuperview()
    }
    for view in self.closebyScrollView.subviews{
        view.removeFromSuperview()
    }
    
    downloadFavorite()//If you already loged in, you will download your favorite ad
    
    println("self.fieldView.Width : \(self.fieldsView.frame.size.width)")
    println("self.fieldView.Height : \(self.fieldsView.frame.size.height)")
}
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        setupCategoriesScrollView()
        getSpotlightData()
        getCloseByData()
        
    }
    ////////////////////////////////////////////////////////////////
override func viewDidLoad() {
        super.viewDidLoad()
    
    // Init AdMob interstitial
    let delayTime = dispatch_time(DISPATCH_TIME_NOW,
        Int64(3 * Double(NSEC_PER_SEC)))
    adMobInterstitial = GADInterstitial()
    adMobInterstitial.adUnitID = ADMOB_UNIT_ID
    var request = GADRequest()
    
    adMobInterstitial.loadRequest(GADRequest())
    dispatch_after(delayTime, dispatch_get_main_queue()) {
        //self.showInterstitial() // -- Temp
    }
    
    
    // Round views corners about Buttons
    searchOutlet.layer.cornerRadius = CORNER_RADIUS
    termsOfUseOutlet.layer.cornerRadius = CORNER_RADIUS
    postBtn.layer.cornerRadius = CORNER_RADIUS
    
      ///////////////---------Menu bar creating
    var imageList: Array<UIImage> = [UIImage(named: "pin.png") as UIImage!, UIImage(named: "full_fevstar.png") as UIImage!, UIImage(named: "contact_icon.png") as UIImage!, UIImage(named: "tab_icons.png") as UIImage!]
    var ratio : CGFloat = self.view.frame.size.width / self.topView.frame.size.width
    var dx : CGFloat = self.topView.frame.height * ratio / 3
    var dy : CGFloat = self.topView.frame.height * ratio / 3
    sideBar = CDSideBarController(images: imageList)
    sideBar.delegate = self
    sideBar.insertMenuButtonOnView(self.view, pointerSize: CGRectMake(self.view.frame.width - dx * 2, dy, dx, dy))
    
    println("HomeSize : \(self.view.frame.width) : \(self.view.frame.height)")
    println("TopViewSize : \(self.topView.frame.width) : \(self.topView.frame.height)")
    println("MenuButtonPosition : \(self.topView.frame.width - self.topView.frame.size.height) : \(dy)")
    
    self.tabBarController?.tabBar.hidden = true
    
    //----------  categorycontainer setting
    categoryContainer.frame = CGRectMake(0, 800, self.view.frame.size.width, categoryContainer.frame.size.height)
    toolBar.frame = CGRectMake(0, 0, self.view.frame.size.width, toolBar.frame.size.height)
    categoryPicker.frame = CGRectMake(0, 0, self.view.frame.size.width, categoryPicker.frame.size.height)
    
    self.categoryContainer.hidden = true
    
    
}

    
// SETUP CATEGORIES SCROLL VIEW
func setupCategoriesScrollView() {
        var xCoord: CGFloat = 5
        var yCoord: CGFloat = 0
        var width:CGFloat = categoriesScrollView.frame.size.height - 20
        var height: CGFloat = width + 10
        var gapBetweenButtons: CGFloat = 5
        var img = UIImage()
    
        var itemCount = 0
        
        // Loop for creating buttons ========
        for itemCount = 0; itemCount < categoriesArray.count; itemCount++ {
            
            img = UIImage(named: "\(categoriesArray[itemCount])")!
            categoriesScrollView.addSubview(getCellView(xCoord, y: yCoord, wid: width, hei: height, imageicon:img, imgName: "\(categoriesArray[itemCount])", f: true, index:NSInteger(itemCount)))
            xCoord +=  width + gapBetweenButtons
        } // END LOOP ================================
    
        // Place Buttons into the ScrollView =====
        categoriesScrollView.contentSize = CGSizeMake( (width+5) * CGFloat(itemCount), yCoord)
}
//downloading addata(posting) from Parse DB in ScrollView(Category, Spotlight, Closeby)
    func getCellView(x:CGFloat, y:CGFloat, wid:CGFloat, hei:CGFloat, imageicon:UIImage, imgName:String, f:Bool, index:NSInteger) -> UIView{
        var myView = UIView(frame: CGRectMake(x, y, wid, hei))
        //create Button
        var myButton = UIButton()
        var myImage = UIImageView()
        
        myImage.image = imageicon
       
       
        
        myButton.clipsToBounds = true
        myImage.clipsToBounds = true
        
        myButton.showsTouchWhenHighlighted = true
        
        myImage.image = imageicon
        
        myButton.contentMode = UIViewContentMode.Top
        
        if f == true{
            myButton.frame = CGRectMake(0, 0, wid, wid)
             myImage.frame = CGRectMake(0, 0, wid, wid)
            myImage.contentMode = UIViewContentMode.ScaleAspectFill
            myButton.addTarget(self, action: "catButtTapped:", forControlEvents: UIControlEvents.TouchUpInside)
            //myButton.backgroundColor = UIColor.blackColor()
        }
        else{
            
            myButton.frame = CGRectMake(0, 0, wid - 7, wid)
             myImage.frame = CGRectMake(0, 0, wid - 7, wid)
            myImage.contentMode = UIViewContentMode.ScaleAspectFit
            myButton.addTarget(self, action: "adButton:", forControlEvents: UIControlEvents.TouchUpInside)
            
        }
        myButton.tag = index
        //create Label
        var mylabel = UILabel()
        if f == true{//CategoryView
            mylabel.frame = CGRectMake(0, wid, wid, hei - wid)
            mylabel.textColor = UIColor.grayColor()
        }
        else{//CLoseBy and Spotlight
            mylabel.frame = CGRectMake(wid / 2, 2 * wid - hei, wid / 2, (hei - wid) * 2)
            mylabel.backgroundColor = UIColor(red: 143/255, green: 226/255, blue: 83/255, alpha: 1)
            mylabel.layer.cornerRadius = CORNER_RADIUS
            mylabel.textColor = UIColor.whiteColor()
        }
        mylabel.textAlignment = .Center
        mylabel.text = imgName
        
        mylabel.clipsToBounds = true
        mylabel.font = UIFont(name: mylabel.font.fontName, size: 12)
        
        myButton.backgroundColor = UIColor.clearColor()
        
        myView.addSubview(myImage)
        myView.addSubview(myButton)
        myView.addSubview(mylabel)
        
        myView.clipsToBounds = true
        return myView
    }
    
    
///////////////////////////////////////////////-------In the Spotlight ScrollView
    
    func getSpotlightData() {
        //get from parse
        spotLightArray.removeAllObjects()
        
        var query = PFQuery(className: CLASSIF_CLASS_NAME)

        query.orderByAscending(CLASSIF_UPDATED_AT)
        query.limit = 15
        query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
            if error == nil {
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        self.spotLightArray.addObject(object)
                    }
                }
                println("Spot By Array count : \(self.spotLightArray.count)")
                if self.spotLightArray.count > 0 {
                    self.setupSpotlightScrollView()
                }
                
            }else{
                return
            }
        }

        
    }
    ///////////////////////////////////////////------In the CloseBy ScrollView
    func getCloseByData() {
        //get from parse
        closeByArray.removeAllObjects()
        
        var query = PFQuery(className: CLASSIF_CLASS_NAME)
        query.orderByDescending(CLASSIF_UPDATED_AT)
        query.limit = 15
        query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
            if error == nil {
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        self.closeByArray.addObject(object)
                        
                        //println("Close By Array count : \(self.closeByArray.count)")
                                            } }
                if self.closeByArray.count > 0 {
                    
                    println(self.closeByArray)
                    println("Close By Array count : \(self.closeByArray.count)")
                    self.setupCloseByScrollView()
                }
                hudView.removeFromSuperview()
                
            } else {
                hudView.removeFromSuperview()
                return
            }
        }
        
    }
    //var spot_x:CGFloat = 0
    //var close_x:CGFloat = 0
    
func setupSpotlightScrollView() {
    var xCoord:CGFloat = 5
    var yCoord:CGFloat = 5
    var width:CGFloat = spotlightScrollView.frame.size.height - 20
    var height: CGFloat = width + 10
    var gapBetweenButtons: CGFloat = 15
    
    var itemCount = 0
    
    xCoord -= width
    // Loop for creating buttons ========
    for itemCount = 0; itemCount < self.spotLightArray.count; itemCount++ {
        var item: PFObject = spotLightArray[itemCount] as! PFObject
        
        let bgImg = item[CLASSIF_IMAGE1] as! PFFile
        bgImg.getDataInBackgroundWithBlock({ (imageData:NSData?, error:NSError?) -> Void in
            if(error == nil){
                let image = UIImage(data:imageData!)
                xCoord +=  width + gapBetweenButtons
                self.spotlightScrollView.addSubview(self.getCellView(xCoord, y: yCoord, wid: width, hei: height, imageicon:image!, imgName: "$\(item[CLASSIF_PRICE] as! String)", f: false, index:NSInteger(itemCount)))
            }
        })
        
        
        // Add Buttons & Labels based on xCood
        
        spotlightScrollView.addSubview(catButton)
    } // END LOOP ================================
    
    // Place Buttons into the ScrollView =====
    spotlightScrollView.contentSize = CGSizeMake( (width + 15) * CGFloat(itemCount), yCoord)

}
    
func setupCloseByScrollView() {  //Close By Scroll View
    var xCoord: CGFloat = 5
    var yCoord: CGFloat = 5
    var width:CGFloat = closebyScrollView.frame.size.height - 20
    var height: CGFloat = width + 10
    var gapBetweenButtons: CGFloat = 15
    
    var itemCount = 0
    
    xCoord -= width
    // Loop for creating buttons ========
    for itemCount = 0; itemCount < self.closeByArray.count; itemCount++ {
        var item: PFObject = closeByArray[itemCount] as! PFObject
        
        // download image data from Parse DB
        
        let bgImg = item[CLASSIF_IMAGE1] as! PFFile
        bgImg.getDataInBackgroundWithBlock({ (imageData:NSData?, error:NSError?) -> Void in
            if(error == nil){
                let image = UIImage(data:imageData!)
                xCoord +=  width + gapBetweenButtons
                self.closebyScrollView.addSubview(self.getCellView(xCoord, y: yCoord, wid: width, hei: height, imageicon:image!, imgName: "$\(item[CLASSIF_PRICE] as! String)", f: false, index:NSInteger(itemCount)))
            }
        })
        // Add Buttons & Labels based on xCood
        
        closebyScrollView.addSubview(catButton)
    } // END LOOP ================================
    
    // Place Buttons into the ScrollView =====
    closebyScrollView.contentSize = CGSizeMake( (width + 15) * CGFloat(itemCount), yCoord)

}
///////////////////////////////////////////////
    
/* ADMOB DELEGATES */
func showInterstitial() {
    // Show AdMob interstitial
    if adMobInterstitial.isReady {
        adMobInterstitial.presentFromRootViewController(self)
        println("present Interstitial")
    }
}
    
    
// CATEGORY BUTTON TAPPED
func catButtTapped(sender: UIButton) {
    var button = sender as UIButton
    var categoryStr = categoriesArray[sender.tag]
    searchedAdsArray.removeAllObjects()
    
    var query = PFQuery(className: CLASSIF_CLASS_NAME)
    query.whereKey(CLASSIF_CATEGORY, equalTo: categoryStr)
    query.orderByAscending(CLASSIF_UPDATED_AT)
    query.limit = 30
    query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
        if error == nil {
            if let objects = objects as? [PFObject] {
                for object in objects {
                    searchedAdsArray.addObject(object)
            } }
            // Go to Browse Ads VC
            let baVC = self.storyboard?.instantiateViewControllerWithIdentifier("MyAdsID") as! MyAds
            baVC.categoryName = categoryStr
            currentList = checkList.Browse
            self.navigationController?.pushViewController(baVC, animated: true)
            //self.presentViewController(baVC, animated: true, completion: nil)
            
            
        } else {
            var alert = UIAlertView(title: APP_NAME,
            message: "Something went wrong, try again later or check your internet connection",
            delegate: self,
            cancelButtonTitle: "OK" )
            alert.show()
        }
    }

    
}
///////////////////////////////////////////the event generated from SpotlightScrollView or CloseByScrollView
func adButton(sender: UIButton) {
        
}
    
 func downloadFavorite()
 {
    //check the favAds If you already loged in
    if PFUser.currentUser() != nil{
        favAdsArray.removeAllObjects()
        
        var favQuery = PFQuery(className: FAV_CLASS_NAME)
        //query.whereKey(CLASSIF_DESCRIPTION_LOWERCASE, containsString: "\(keywordsArray[0])") -----MT
        favQuery.whereKey(FAV_USER, equalTo: PFUser.currentUser()!)
        favQuery.limit = 30
        favQuery.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
            if error == nil {
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        favAdsArray.addObject(object)
                    }
                }
            }
        }
    }
}
    
// DIG BUTTON
@IBAction func searchButt(sender: AnyObject) {
    searchedAdsArray.removeAllObjects()

    //var keywordsArray = ["ad", "test"]//---MT  keywordsTxt.text.componentsSeparatedByString(" ") as NSArray
    showHUD()//Waiting Animation

    //-----------
    var query = PFQuery(className: CLASSIF_CLASS_NAME)
    //query.whereKey(CLASSIF_DESCRIPTION_LOWERCASE, containsString: "\(keywordsArray[0])") -----MT
    query.whereKey(CLASSIF_CATEGORY, equalTo: categoryTxt.text!)
    query.whereKey(CLASSIF_ADDRESS_STRING, containsString: whereTxt.text.lowercaseString)
    query.orderByAscending(CLASSIF_UPDATED_AT)
    query.limit = 30
    query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
        if error == nil {
            if let objects = objects as? [PFObject] {
                for object in objects {
                    searchedAdsArray.addObject(object)
                } }
            if searchedAdsArray.count > 0 {
            // Go to Browse Ads VC
             let baVC = self.storyboard?.instantiateViewControllerWithIdentifier("BrowseAds") as! BrowseAds
                self.navigationController?.pushViewController(baVC, animated: true)
                //self.presentViewController(baVC, animated: true, completion: nil)
          
            } else {
            var alert = UIAlertView(title: APP_NAME,
            message: "Nothing found with your search keywords, try different location or category",
            delegate: nil,
            cancelButtonTitle: "OK" )
            alert.show()
            }
            
            
        } else {
            var alert = UIAlertView(title: APP_NAME,
            message: "Something went wrong, try again later or check your internet connection",
            delegate: nil,
            cancelButtonTitle: "OK" )
            alert.show()
        }
        hudView.removeFromSuperview()
    }
    

}

    
    //var flag : Bool = false

/* MARK -  TEXTFIELD DELEGATE */
func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
    if textField == categoryTxt {
        f = true
        categoryTxt.resignFirstResponder()
        pickerDatasource = categoriesArray
        
        showCatPickerView(true)
        
    }
    else if textField == whereTxt{
        f = false
        whereTxt.resignFirstResponder()
        pickerDatasource = citiesArray
        
        showCatPickerView(false)
        
    }
    
    categoryPickerView.dataSource = self
    categoryPickerView.delegate = self
        
return true
}
    
func textFieldDidBeginEditing(textField: UITextField) {
    if textField == categoryTxt {
        f = true
        pickerDatasource = categoriesArray
        //flag = true
        showCatPickerView(true)
        categoryTxt.resignFirstResponder()
    }
    else if textField == whereTxt{
        f = false
        pickerDatasource = citiesArray
        //flag = false
        showCatPickerView(false)
        whereTxt.resignFirstResponder()
    }
    
    categoryPickerView.dataSource = self
    categoryPickerView.delegate = self

}
    
func textFieldShouldReturn(textField: UITextField) -> Bool {

    //if textField == whereTxt {  categoryTxt.becomeFirstResponder()  }

    return true
}
    
    
    
/* MARK - PICKERVIEW DELEGATES */
func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1;
}

func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    //if flag == true {//category
    return pickerDatasource.count
}
    
func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
    //if flag == true {//categorry
    return pickerDatasource[row]
}

func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    //if flag == true{//category
    if f == true {
    categoryTxt.text = "\(pickerDatasource[row])"
    }
    else {
    whereTxt.text = "\(pickerDatasource[row])"
    }
}

    
// POST A NEW AD BUTTON
@IBAction func postAdButt(sender: AnyObject) {
    if(PFUser.currentUser() == nil){
        var alert = UIAlertView(title: APP_NAME,
            message: "You must login/signup into your Account to post ad",
            delegate: nil,
            cancelButtonTitle: "OK" )
        alert.show()
        return
    }
    else{
        let postVC = self.storyboard?.instantiateViewControllerWithIdentifier("Post") as! Post
        postVC.postID = ""
        //presentViewController(postVC, animated: true, completion: nil)
        self.navigationController?.pushViewController(postVC, animated: true)
    }
//    presentViewController(postVC, animated: true, completion: nil)
}

    
// PICKERVIEW DONE BUTTON -- MT
@IBAction func doneButt(sender: AnyObject) {
        hideCatPickerView()
}
    
    
// DISMISS KEYBOARD ON TAP
@IBAction func dismissKeyboardOnTap(sender: UITapGestureRecognizer) {
    whereTxt.resignFirstResponder()
    categoryTxt.resignFirstResponder()
    hideCatPickerView()
}
    
    
// SHOW/HIDE CATEGORY PICKERVIEW
    func showCatPickerView(flag : Bool) {
        if flag == true {//CategoryText
            self.tableview.contentOffset.y = self.categoryTxt.frame.origin.y + self.categoryTxt.frame.height + 10 - self.view.frame.size.height + self.categoryContainer.frame.size.height
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
                self.categoryContainer.hidden = false
                self.categoryContainer.frame.origin.y = self.categoryTxt.frame.origin.y + self.categoryTxt.frame.size.height + 10
                }, completion: { (finished: Bool) in  });
            self.tableview.scrollEnabled = false
        }
        else {//whereText
            self.tableview.contentOffset.y = self.whereTxt.frame.origin.y + self.whereTxt.frame.height + 10 - self.view.frame.size.height + self.categoryContainer.frame.size.height
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
                self.categoryContainer.hidden = false
                self.categoryContainer.frame.origin.y = self.whereTxt.frame.origin.y + self.whereTxt.frame.size.height + 10
                }, completion: { (finished: Bool) in  });
            self.tableview.scrollEnabled = false

        }
}
func hideCatPickerView() {
    UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
        self.categoryContainer.frame.origin.y = self.termsOfUseOutlet.frame.origin.y + 50
        self.categoryContainer.hidden = true
        self.tableview.contentOffset.y -= 100
    }, completion: { (finished: Bool) in
        self.tableview.scrollEnabled = true
    });
}
    
    
    
//SHOW TERMS OF USE
@IBAction func termsOfUseButt(sender: AnyObject) {
    let touVC = self.storyboard?.instantiateViewControllerWithIdentifier("TermsOfUse") as! TermsOfUse
    presentViewController(touVC, animated: true, completion: nil)
    //self.navigationController?.pushViewController(touVC, animated: true)
}
// menu button Action
func menuButtonClicked(index: Int32) {
    
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
    }
    else if index == 2{//--Account
        if(PFUser.currentUser() != nil){
            //let del = UIApplication.sharedApplication().delegate as! AppDelegate
            let choiceVC = self.storyboard?.instantiateViewControllerWithIdentifier("naviAccount") as! UINavigationController
            del.window?.rootViewController = choiceVC
        }
        else{
            let choiceVC = self.storyboard?.instantiateViewControllerWithIdentifier("naviAccount") as! UINavigationController
            del.window?.rootViewController = choiceVC
        }
    }
    else if index == 3{//--Home
        let choiceVC = self.storyboard?.instantiateViewControllerWithIdentifier("naviHome") as! UINavigationController
        del.window?.rootViewController = choiceVC
    }
    else if index == 0{//--Pin Screen ??? i donot know it yet, why?
    
    }
    else{
    
    }
}
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
}
    // Show HUD ========================================================
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

    //NavigationBar Processing =========================
    
}
