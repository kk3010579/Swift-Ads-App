/* =======================

- Classify -

made by FV iMAGINATION ©2015
for CodeCanyon

==========================*/

import UIKit
import Parse

var searchedAdsArray = NSMutableArray()
var favAdsArray = NSMutableArray()//valid in login


class BrowseAds: UITableViewController,
CDSideBarControllerDelegate
{
    
    //sideBar variable declaration
    internal var sideBar: CDSideBarController!
    
    @IBOutlet var navigationCategoryView: UINavigationItem!
    @IBOutlet weak var categoryImage: UIImageView!
    /* Variables */
    var callTAG = 0
    var categoryName = String()
    

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        if let image = UIImage(named: self.categoryName){
            self.categoryImage.image = image
        }
    }
    
override func viewDidLoad() {
        super.viewDidLoad()

     self.title = " Browse Ads"
    
    ///////////////---------Menu bar creating
    var imageList: Array<UIImage> = [UIImage(named: "pin.png") as UIImage!, UIImage(named: "full_fevstar.png") as UIImage!, UIImage(named: "contact_icon.png") as UIImage!, UIImage(named: "tab_icons.png") as UIImage!]
    sideBar = CDSideBarController(images: imageList)
    sideBar.delegate = self
    sideBar.insertMenuButtonOnView(self.view, pointerSize: CGRectMake(self.view.frame.width - 44, SIDEBAR_DY, 44 - 2 * SIDEBAR_DY, 44 - 2 * SIDEBAR_DY))
    
    self.tabBarController?.tabBar.hidden = true

    
}

    @IBAction func backButtonClicked(sender: AnyObject) {
        var homeVC = self.storyboard?.instantiateViewControllerWithIdentifier("homeID") as! Home
        //self.presentViewController(homeVC, animated: true, completion: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }

 
/* MARK: - TABLEVIEW DELEGATES */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedAdsArray.count
    }
    
override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCellWithIdentifier("AdCellID", forIndexPath: indexPath) as! AdCell
    
    var classifClass = PFObject(className: CLASSIF_CLASS_NAME)
    classifClass = searchedAdsArray[indexPath.row] as! PFObject
    
    cell.adTitleLabel.text = "\(classifClass[CLASSIF_TITLE]!)"
    cell.adDescrLabel.text = "\(classifClass[CLASSIF_ADDRESS_STRING]!)" //address
    //cell.addToFavOutlet.tag = indexPath.row
    
    // Get image
    let imageFile = classifClass[CLASSIF_IMAGE1] as? PFFile
    imageFile?.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
        if error == nil {
            if let imageData = imageData {
                cell.adImage.image = UIImage(data:imageData)
            } } }
    cell.tag = indexPath.row
    //set favorite Ad
    if PFUser.currentUser() != nil {
        var favFlag:Bool = false
        for var i = 0; i < favAdsArray.count; ++i{
            var favAdId = favAdsArray[i] as! PFObject
            println("classifClass[CLASSIF_ID] : \(classifClass)")
            println("avAdId[FAV_AD_POINTER] : \(favAdId[FAV_AD_POINTER])")
            if classifClass == favAdId[FAV_AD_POINTER] as! PFObject{
                favFlag = true
                cell.addToFavOutlet.setImage(UIImage(named: "full_fevstar.png"), forState: UIControlState.Normal)
                cell.addToFavOutlet.tag = 2 * indexPath.row
                break
            }
        }
        if favFlag == false{
            cell.addToFavOutlet.setImage(UIImage(named: "fevstar.png"), forState: UIControlState.Normal)
            cell.addToFavOutlet.tag = 2 * indexPath.row + 1
            println("\(cell.addToFavOutlet.tag)")
        }
        favFlag = false
    }
    
return cell
}
 
// SELECTED AN AD -> SHOW IT

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            var classifClass = PFObject(className: CLASSIF_CLASS_NAME)
            classifClass = searchedAdsArray[indexPath.row] as! PFObject
        
            let showAdVC = self.storyboard?.instantiateViewControllerWithIdentifier("ShowSingleAdID") as! ShowSingleAd
            // Pass the Ad ID to the Controller
            showAdVC.singleAdID = classifClass.objectId!
            showAdVC.selfobject = classifClass
        
            self.navigationController?.pushViewController(showAdVC, animated: true)
    }

    
// ADD AD TO FAVORITES BUTTON
@IBAction func addToFavButt(sender: AnyObject) {
    showHUD()
    var button = sender as! UIButton
    button.clipsToBounds = true
    
    if PFUser.currentUser() != nil {
        var classifClass = PFObject(className: CLASSIF_CLASS_NAME)
        classifClass = searchedAdsArray[button.tag / 2] as! PFObject
        
        var favClass = PFObject(className: FAV_CLASS_NAME)
    
        // ADD THIS AD TO FAVORITES
        favClass[FAV_USER] = PFUser.currentUser()
        favClass[FAV_AD_POINTER] = classifClass
        //        println("\(Float(button.tag))")
        
        if button.tag % 2 == 0{//deleteing block
            
            let delQuery = PFQuery(className: FAV_CLASS_NAME)
            // Delete Query
            delQuery.whereKey(FAV_USER, equalTo: PFUser.currentUser()!)
            delQuery.whereKey(FAV_AD_POINTER, equalTo: classifClass)
            delQuery.findObjectsInBackgroundWithBlock{ (objects: [AnyObject]?, error: NSError?) -> Void in
                if error == nil{
                    if let objects = objects as? [PFObject]{
                        for object in objects{
                            object.delete()
                            button.setImage(UIImage(named: "fevstar.png"), forState: UIControlState.Normal)
                        }
                        button.tag += 1
                    }
                    hudView.removeFromSuperview()
                }
                else{
                    hudView.removeFromSuperview()
               }
            }
        }
        else {// Saving block
            favClass.saveInBackgroundWithBlock { (success, error) -> Void in
            if error == nil {
                button.setImage(UIImage(named: "full_fevstar.png"), forState: UIControlState.Normal)
                button.tag -= 1
            } else {
                var alert = UIAlertView(title: APP_NAME,
                    message: "Something went wrong, try again later, or check your internet connection",
                    delegate: nil,
                    cancelButtonTitle: "OK" )
                alert.show()
            }
                
            } // end Saving block
            hudView.removeFromSuperview()
        }
        
    } else {
        var alert = UIAlertView(title: APP_NAME,
        message: "You have to login/signup to favorite ads!",
        delegate: nil,
        cancelButtonTitle: "OK")
        alert.show()
        hudView.removeFromSuperview()
    }


}
 
    
    // menu button Action
    func menuButtonClicked(index: Int32) {
        //TODO
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
          
            
        }else if index == 2{//--Account
            let choiceVC = self.storyboard?.instantiateViewControllerWithIdentifier("naviAccount") as! UINavigationController
          
            del.window?.rootViewController = choiceVC
           
        }else if index == 3{//--Home
            let choiceVC = self.storyboard?.instantiateViewControllerWithIdentifier("naviHome") as! UINavigationController
            del.window?.rootViewController = choiceVC
          
        }else if index == 0{//--Pin Screen ??? i donot know it yet, why?
            
        }
        else{
            
        }
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
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
}
}
