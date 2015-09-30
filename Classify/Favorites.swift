/* =======================

 - Classify -

made by FV iMAGINATION ©2015
for CodeCanyon

==========================*/

import UIKit
import Parse
import GoogleMobileAds
import AudioToolbox


class Favorites: UITableViewController,
    CDSideBarControllerDelegate,
    GADInterstitialDelegate
{

    //sideBar variable declaration
    internal var sideBar: CDSideBarController!

    /* Variables */
    var favoritesArray = NSMutableArray()
    
    //
    var adMobInterstitial: GADInterstitial!


    
override func viewWillAppear(animated: Bool) {
    if PFUser.currentUser() != nil {
        queryFavAds()
    } else {
        var alert = UIAlertView(title: APP_NAME,
        message: "You must login/signup into your Account to add Favorites",
        delegate: nil,
        cancelButtonTitle: "OK" )
        alert.show()
    }
    
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

}
    
override func viewDidLoad() {
        super.viewDidLoad()

    ///////////////---------Menu bar creating
    var imageList: Array<UIImage> = [UIImage(named: "pin.png") as UIImage!, UIImage(named: "full_fevstar.png") as UIImage!, UIImage(named: "contact_icon.png") as UIImage!, UIImage(named: "tab_icons.png") as UIImage!]
    sideBar = CDSideBarController(images: imageList)
    sideBar.delegate = self
    sideBar.insertMenuButtonOnView(self.view, pointerSize: CGRectMake(self.view.frame.width - 44, SIDEBAR_DY, 44 - 2 * SIDEBAR_DY, 44 - 2 * SIDEBAR_DY))
    
    self.navigationController?.navigationBarHidden = true

}

func queryFavAds()  {
    favoritesArray.removeAllObjects()
    
    var query = PFQuery(className: FAV_CLASS_NAME)
    query.whereKey(FAV_USER, equalTo: PFUser.currentUser()!)
    query.includeKey(FAV_AD_POINTER)
    query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
        if error == nil {
            if let objects = objects as? [PFObject] {
                if objects.count > 0 {
                    for object in objects {
                        self.favoritesArray.addObject(object)
                        self.tableView.reloadData()
                        //self.tableView.allowsSelection = true
                    }
                }
                else{
                    var alert = UIAlertView(title: APP_NAME,
                        message: "There is none you wanna see the favorite data!",
                        delegate: self,
                        cancelButtonTitle: "OK" )
                    alert.show()
                }
            }
            // Show details (or reload a TableView)
       
            
        } else {
            var alert = UIAlertView(title: APP_NAME,
            message: "Something went wrong, try again later or check your internet connection",
            delegate: self,
            cancelButtonTitle: "OK" )
            alert.show()
        }
    }

}


/* MARK: - TABLEVIEW DELEGATES */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritesArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("myFavCell", forIndexPath: indexPath) as! FavoritesCell
        
        var favClass = PFObject(className: FAV_CLASS_NAME)
        favClass = favoritesArray[indexPath.row] as! PFObject
        // Get Ads as a Pointer
        var adPointer = favClass[FAV_AD_POINTER] as! PFObject
        
        cell.adTitleLabel.text = "\(adPointer[CLASSIF_TITLE]!)"
        cell.adDescrLabel.text = "\(adPointer[CLASSIF_ADDRESS_STRING]!)"//address
        
        // Get image
        let imageFile = adPointer[CLASSIF_IMAGE1] as? PFFile
        imageFile?.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                if let imageData = imageData {
                    cell.adImage.image = UIImage(data:imageData)
            } } }
        
        
return cell
}
    
// SELECT AN AD -> SHOW IT

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var favClass = PFObject(className: FAV_CLASS_NAME)
        favClass = favoritesArray[indexPath.row] as! PFObject
        // Get favorite Ads as a Pointer
        var adPointer = favClass[FAV_AD_POINTER] as! PFObject
        
        let showAdVC = self.storyboard?.instantiateViewControllerWithIdentifier("ShowSingleAd") as! ShowSingleAd
        // Pass the Ad ID to the Controller
        showAdVC.singleAdID = adPointer.objectId!
        self.navigationController?.pushViewController(showAdVC, animated: true)
        //self.presentViewController(showAdVC, animated: true, completion: nil)
    }

// REMOVE THIS AD FROM YOUR FAVORITES
override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
}
override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            // Delete selected Ad
            var favClass = PFObject(className: FAV_CLASS_NAME)
            favClass = favoritesArray[indexPath.row] as! PFObject
            
            favClass.deleteInBackgroundWithBlock {(success, error) -> Void in
                if error == nil {
                    
                } else {
                    var alert = UIAlertView(title: APP_NAME,
                    message: "Something went wrong, try again later",
                    delegate: nil,
                    cancelButtonTitle: "OK" )
                    alert.show()
                } }

            // Remove record in favoritesArray and the tableView's row
            self.favoritesArray.removeObjectAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    
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
            //presentViewController(choiceVC, animated: true, completion: nil)
            //self.navigationController?.pushViewController(choiceVC, animated: true)
        }
        else if index == 2{//--Account
            if(PFUser.currentUser() != nil){
                let choiceVC = self.storyboard?.instantiateViewControllerWithIdentifier("naviAccount") as! UINavigationController
                del.window?.rootViewController = choiceVC
                //presentViewController(choiceVC, animated: true, completion: nil)
                //self.navigationController?.pushViewController(choiceVC, animated: true)
            }
            else{
                let choiceVC = self.storyboard?.instantiateViewControllerWithIdentifier("naviAccount") as! UINavigationController
                del.window?.rootViewController = choiceVC
                //presentViewController(choiceVC, animated: true, completion: nil)
                //self.navigationController?.pushViewController(choiceVC, animated: true)
            }
        }
        else if index == 3{//--Home
            let choiceVC = self.storyboard?.instantiateViewControllerWithIdentifier("naviHome") as! UINavigationController
            del.window?.rootViewController = choiceVC
            //presentViewController(choiceVC, animated: true, completion: nil)
            //self.navigationController?.pushViewController(choiceVC, animated: true)
        }
        else if index == 0{//--Pin Screen ??? i donot know it yet, why?
            
        }
        else{
            
        }
    }

    
    @IBAction func tapCell(sender: UITapGestureRecognizer) {
        print("tap cell..........")
    }
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
}
    
    /* ADMOB DELEGATES */
    func showInterstitial() {
        // Show AdMob interstitial
        if adMobInterstitial.isReady {
            adMobInterstitial.presentFromRootViewController(self)
            println("present Interstitial")
        }
    }
}
