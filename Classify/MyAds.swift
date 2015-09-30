/* =======================

- Classify -

made by FV iMAGINATION ©2015
for CodeCanyon

==========================*/

import UIKit
import Parse
//import MyAdCell

class MyAds: UIViewController,
    CDSideBarControllerDelegate,
UITableViewDataSource,
UITableViewDelegate{

    //sideBar variable declaration
    internal var sideBar: CDSideBarController!
    
    //---- Property
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryImage: UIImageView!
    
    /* Variables */
    var classifArray = NSMutableArray()
    var categoryName = String()
    
    //var favoritesArray = NSMutableArray()
    // the button checking favourite ad
    //@IBOutlet weak var checkFavBt: UIButton!
    
     let myCellID = "myAdCellID"
    
override func viewWillAppear(animated: Bool) {
    self.navigationController?.setNavigationBarHidden(true, animated: true)
    
    if currentList == checkList.Favorite && PFUser.currentUser() != nil {//Favorite
        titleLabel.text = "My Favorite"
        categoryImage.hidden = true
        queryFavAds()
    }
    else if currentList == checkList.Mylist && PFUser.currentUser() != nil{//        Mylisting
        titleLabel.text = "Mylisting"
        categoryImage.hidden = true
        queryMylisting()
    }
    else if currentList == checkList.Browse{//Browse Ad
        categoryImage.hidden = false
        categoryImage.image = UIImage(named: categoryName)
        makeBrowseArray()
    }
}
    
override func viewDidLoad() {
        super.viewDidLoad()
    
    ///////////////---------Menu bar creating
//    var imageList: Array<UIImage> = [UIImage(named: "pin.png") as UIImage!, UIImage(named: "full_fevstar.png") as UIImage!, UIImage(named: "contact_icon.png") as UIImage!, UIImage(named: "tab_icons.png") as UIImage!]
//    sideBar = CDSideBarController(images: imageList)
//    sideBar.delegate = self
//    sideBar.insertMenuButtonOnView(self.view, pointerSize: CGRectMake(self.view.frame.width - 44, SIDEBAR_DY, 44 - 2 * SIDEBAR_DY, 44 - 2 * SIDEBAR_DY))
    
    self.navigationController?.navigationBarHidden = true
}
    //*******  download mylisting data from ParseDB

    func queryMylisting(){
        var query = PFQuery(className: CLASSIF_CLASS_NAME)
        query.whereKey(CLASSIF_USER, equalTo: PFUser.currentUser()!)
        query.orderByDescending(CLASSIF_UPDATED_AT)
        query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
            if error == nil {
                self.classifArray.removeAllObjects()
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        self.classifArray.addObject(object)
                    } }
                // Pupolate the TableView
                self.tableView.reloadData()
                
            } else {
                var alert = UIAlertView(title: APP_NAME,
                    message: "Something went wrong, try again later or check your internet connection",
                    delegate: nil,
                    cancelButtonTitle: "OK" )
                alert.show()
            }
        }

    }
   //******* download favorite data form Parse DB
    
    func queryFavAds()  {
        classifArray.removeAllObjects()
        
        var query = PFQuery(className: FAV_CLASS_NAME)
        query.whereKey(FAV_USER, equalTo: PFUser.currentUser()!)
        query.includeKey(FAV_AD_POINTER)
        query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
            if error == nil {
                if let objects = objects as? [PFObject] {
                    if objects.count > 0 {
                        for object in objects {
                            self.classifArray.addObject(object)
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
    
    func makeBrowseArray(){
        self.classifArray.removeAllObjects()
        for object in searchedAdsArray{
            self.classifArray.addObject(object)
        }
        println("searcharray............\(searchedAdsArray)")
        println("classifarray............\(self.classifArray)")
        self.tableView.reloadData()
    }

    
    @IBAction func backButtonClicked(sender: AnyObject) {
        if currentList == checkList.Mylist || currentList == checkList.Browse{
            self.navigationController?.popViewControllerAnimated(true)
        }
        else if currentList == checkList.Favorite{
            var del = UIApplication.sharedApplication().delegate as! AppDelegate
            let choiceVC = self.storyboard?.instantiateViewControllerWithIdentifier("naviHome") as! UINavigationController
            del.window?.rootViewController = choiceVC
        }
        //self.presentViewController(myAdVC, animated: true, completion: nil)
    }
    
    
    
/* MARK: - TABLE VIEW DELEGATES */
func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
}

func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classifArray.count
}

func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(myCellID, forIndexPath: indexPath) as! MyAdCell
    if currentList == checkList.Mylist || currentList == checkList.Browse{
        myListingCell(cell, indexPath: indexPath)
    }
    else if currentList == checkList.Favorite{
        favoriteCell(cell, indexPath: indexPath)
    }
//    else if currentList == checkList.Browse{
//        browseCell(cell, indexPath: indexPath)
//    }
    
        return cell
}
    /* MARK: - My Functions*/
 //--------- Set the Mylisting Cell
    func myListingCell(myCell: MyAdCell, indexPath: NSIndexPath) -> MyAdCell{
        // SHOW ALL YOUR ADS
        var classifClass = PFObject(className: CLASSIF_CLASS_NAME)
        classifClass = classifArray[indexPath.row] as! PFObject
        
        // Get image
        let imageFile = classifClass[CLASSIF_IMAGE1] as? PFFile
        imageFile?.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                if let imageData = imageData {
                    if let image = myCell.adImage{
                        image.image = UIImage(data:imageData)
                    } } }}
        
        if let label = myCell.adTitleLabel{
            label.text = "\(classifClass[CLASSIF_TITLE]!)"
        }
        
        if let label = myCell.adDescrLabel{
            label.text = "\(classifClass[CLASSIF_ADDRESS_STRING]!)"
        }
        myCell.tag = indexPath.row
        
        //set favorite Ad
        if PFUser.currentUser() != nil && (currentList == checkList.Browse || currentList == checkList.Mylist){
            var favFlag:Bool = false
            for var i = 0; i < favAdsArray.count; ++i{
                var favAdId = favAdsArray[i] as! PFObject
                if classifClass == favAdId[FAV_AD_POINTER] as! PFObject{
                    favFlag = true
                    myCell.checkFavoriteBt.setImage(UIImage(named: "full_fevstar.png"), forState: UIControlState.Normal)
                    myCell.checkFavoriteBt.tag = 2 * indexPath.row
                    break
                }
            }
            if favFlag == false{
                myCell.checkFavoriteBt.setImage(UIImage(named: "fevstar.png"), forState: UIControlState.Normal)
                myCell.checkFavoriteBt.tag = 2 * indexPath.row + 1
                println("\(myCell.checkFavoriteBt.tag)")
            }
            favFlag = false
        }

        return myCell
    }

    //-------- Set the Favorite Cell
    func favoriteCell(myCell: MyAdCell, indexPath: NSIndexPath) -> MyAdCell{
        var favClass = PFObject(className: FAV_CLASS_NAME)
        favClass = classifArray[indexPath.row] as! PFObject
        // Get Ads as a Pointer
        var adPointer = favClass[FAV_AD_POINTER] as! PFObject
        
        myCell.adTitleLabel.text = "\(adPointer[CLASSIF_TITLE]!)"
        myCell.adDescrLabel.text = "\(adPointer[CLASSIF_ADDRESS_STRING]!)"//address
        
        // Get image
        let imageFile = adPointer[CLASSIF_IMAGE1] as? PFFile
        imageFile?.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                if let imageData = imageData {
                    myCell.adImage.image = UIImage(data:imageData)
                } } }
        myCell.checkFavoriteBt.setImage(UIImage(named: "full_fevstar.png"), forState: UIControlState.Normal)
        myCell.checkFavoriteBt.tag = 2 * indexPath.row

        return myCell
    }
    
    //-------- Set the Browse Cell
    func browseCell(myCell: MyAdCell, indexPath: NSIndexPath) -> MyAdCell{
        return myCell
    }

    // to <ShowSingleAd>Screen by RowCellClicked
func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    // Show the Detail about Single Advertise
    let singleAdVC = self.storyboard?.instantiateViewControllerWithIdentifier("ShowSingleAdID") as! ShowSingleAd
    
    if currentList == checkList.Favorite{
//        var classifClass = PFObject(className: FAV_CLASS_NAME)
//        classifClass = classifArray[indexPath.row] as! PFObject
//
////        singleAdVC.singleAdID = classifClass[FAV_AD_POINTER] as! String
//        singleAdVC.selfobject = classifClass[FAV_AD_POINTER] as! PFObject
        return
    }
    else { //Mylisting Or Browse
        var classifClass = PFObject(className: CLASSIF_CLASS_NAME)
        classifClass = classifArray[indexPath.row] as! PFObject

        singleAdVC.singleAdID = classifClass.objectId!
        singleAdVC.selfobject = classifClass
    }
    
    self.navigationController?.pushViewController(singleAdVC, animated: true)
    //presentViewController(singleAdVC, animated: true, completion: nil)

}
    // Show HUD ========================================================
    @IBAction func checkBtClicked(sender: AnyObject) {
        if currentList == checkList.Favorite{
            return
        }
        showHUD()
        var button = sender as! UIButton
        button.clipsToBounds = true
        
        if PFUser.currentUser() != nil {
            var classifClass = PFObject(className: CLASSIF_CLASS_NAME)
            
            println("button.tag:\(button.tag)")
            println("searchedarray:\(searchedAdsArray.count)")
            classifClass = classifArray[button.tag / 2] as! PFObject
            
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
                            self.downloadFavorite()
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
                        self.downloadFavorite()
                    } else {
                        var alert = UIAlertView(title: APP_NAME,
                            message: "Something went wrong, try again later, or check your internet connection",
                            delegate: nil,
                            cancelButtonTitle: "OK" )
                        alert.show()
                    }
                    hudView.removeFromSuperview()
                } // end Saving block
                
            }
            //-- refresh favorite ad data
            
        } else {
            var alert = UIAlertView(title: APP_NAME,
                message: "You have to login/signup to favorite ads!",
                delegate: nil,
                cancelButtonTitle: "OK")
            alert.show()
            hudView.removeFromSuperview()
        }

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
    //========================================================

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
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
}
}
