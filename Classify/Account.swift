/* =======================

- Classify -

made by FV iMAGINATION ©2015
for CodeCanyon

==========================*/


import UIKit
import Parse
import GoogleMobileAds
import AudioToolbox


class Account: UITableViewController,
UITextFieldDelegate,
UIAlertViewDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
    GADInterstitialDelegate
{

    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var avatarImage: UIImageView!
    @IBOutlet var fullnameTxt: UITextField!
    @IBOutlet var emailTxt: UITextField!
    @IBOutlet var phoneTxt: UITextField!
    @IBOutlet var websiteTxt: UITextField!
    @IBOutlet var saveProfileOutlet: UIButton!
    @IBOutlet var myAdsOutlet: UIButton!
    //new items
    @IBOutlet var postServiceOutlet: UIButton!
    @IBOutlet var avatarButton: UIButton!
    
    /* Variables */
    var userArray = NSMutableArray()
    
     var adMobInterstitial: GADInterstitial!
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        if PFUser.currentUser() != nil{
            var del = UIApplication.sharedApplication().delegate as! AppDelegate
            let choiceVC = self.storyboard?.instantiateViewControllerWithIdentifier("naviHome") as! UINavigationController
            del.window?.rootViewController = choiceVC
        }
        else{
        
            self.navigationController?.popViewControllerAnimated(true)
        }
        //self.presentViewController(loginVC, animated: true, completion: nil)
    }
override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated);
    println("reloadUser: \(reloadUser)")
    
    if PFUser.currentUser() == nil {
        let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("Login") as! Login
        //self.presentViewController(loginVC, animated: true, completion: nil)
        self.navigationController?.pushViewController(loginVC, animated: true)
   
    } else {
        if reloadUser == true {
            loadUserDetails()
            reloadUser = false
        }
    }
    
    self.navigationController?.setNavigationBarHidden(false, animated: false)
    self.navigationController?.navigationBarHidden = false
    
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
    
     if PFUser.currentUser() != nil {
        loadUserDetails()
    }
    
    // Round views corners
    avatarImage.layer.cornerRadius = avatarImage.bounds.size.width/2
    avatarImage.clipsToBounds = true
    // Round Button corners
    saveProfileOutlet.layer.cornerRadius = CORNER_RADIUS
    myAdsOutlet.layer.cornerRadius = CORNER_RADIUS
    postServiceOutlet.layer.cornerRadius = CORNER_RADIUS
    
    self.navigationController?.navigationBarHidden = false
    self.navigationController?.setNavigationBarHidden(false, animated: false)

    
}

    
func loadUserDetails() {
    userArray.removeAllObjects()
    
    var query = PFUser.query()
    query!.whereKey(USER_USERNAME, equalTo: PFUser.currentUser()!.username!)
    
    query?.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
        if error == nil {
            if let objects = objects as? [PFObject] {
                for object in objects {
                    self.userArray.addObject(object)
                } }
            // Pupolate TextFiled
            self.showUserDetails()
            
        } else {
            var alert = UIAlertView(title: APP_NAME,
            message: "Something went wrong, try again later or check your internet connection",
            delegate: self,
            cancelButtonTitle: "OK" )
            alert.show()
        }
    }
}

    
func showUserDetails() {
    var userClass = PFObject(className: USER_CLASS_NAME)
    userClass = userArray.objectAtIndex(0) as! PFObject
    
    usernameLabel.text = "\(userClass[USER_USERNAME]!)"
    emailTxt.text = "\(userClass[USER_EMAIL]!)"
    
    if userClass[USER_FULLNAME] != nil {
        fullnameTxt.text = "\(userClass[USER_FULLNAME]!)"
    } else { fullnameTxt.text = "" }
    
    if userClass[USER_PHONE] != nil {
        phoneTxt.text = "\(userClass[USER_PHONE]!)"
    } else { phoneTxt.text = "" }
    
    if userClass[USER_WEBSITE] != nil {
        websiteTxt.text = "\(userClass[USER_WEBSITE]!)"
    } else { websiteTxt.text = "" }
    
     // Get Avatar image
    let imageFile = userClass[USER_AVATAR] as? PFFile
    imageFile?.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
        if error == nil {
            if let imageData = imageData {
                self.avatarImage.image = UIImage(data:imageData)
            } } }
    
}
    
    
/* MARK - TEXTFIELD DELEGATE */
func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == fullnameTxt {  emailTxt.becomeFirstResponder()  }
    if textField == emailTxt {  phoneTxt.becomeFirstResponder()  }
    if textField == phoneTxt {  websiteTxt.becomeFirstResponder()  }
    if textField == websiteTxt {  websiteTxt.resignFirstResponder()  }

return true
}

    
// CHANGE IMAGE BUTTON
@IBAction func changeImageButt(sender: AnyObject) {
    var alert = UIAlertView(title: APP_NAME,
    message: "Add a Photo",
    delegate: self,
    cancelButtonTitle: "Cancel",
    otherButtonTitles:
            "Take a picture",
            "Choose from Library"
    )
    alert.show()
    
}
// AlertView delegate
func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.buttonTitleAtIndex(buttonIndex) == "Take a picture" {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                var imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
                imagePicker.allowsEditing = true
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
            
            
        } else if alertView.buttonTitleAtIndex(buttonIndex) == "Choose from Library" {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
                var imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
                imagePicker.allowsEditing = true
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
        }
}
// ImagePicker Delegate
func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
    avatarImage.image = image
    dismissViewControllerAnimated(true, completion: nil)
}
    
    

// SAVE PROFILE BUTTON
@IBAction func saveProfileButt(sender: AnyObject) {
    showHUD()
    var currentUser = PFUser.currentUser()
    
    currentUser?[USER_FULLNAME] = fullnameTxt.text
    currentUser?[USER_EMAIL] = emailTxt.text
    currentUser?[USER_PHONE] = phoneTxt.text
    currentUser?[USER_WEBSITE] = websiteTxt.text

 // Save Image (if exists)
    if avatarImage.image != nil {
        let imageData = UIImageJPEGRepresentation(avatarImage.image,0.2)
        let imageFile = PFFile(name:"avatar.jpg", data:imageData)
        currentUser?[USER_AVATAR] = imageFile
    }
    
    currentUser!.saveInBackgroundWithBlock { (success, error) -> Void in
        if error == nil {
            var alert = UIAlertView(title: APP_NAME,
            message: "Your Profile has been updated!",
            delegate: nil,
            cancelButtonTitle: "OK" )
            alert.show()
        hudView.removeFromSuperview()
        } else {
            var alert = UIAlertView(title: APP_NAME,
            message: "Something went wrong, try again later",
            delegate: nil,
            cancelButtonTitle: "OK" )
            alert.show()
        hudView.removeFromSuperview()
        }
    }

    
}

    
// POST Listing Button
@IBAction func postAdButt(sender: AnyObject) {
    let postVC = self.storyboard?.instantiateViewControllerWithIdentifier("Post") as! Post
    self.navigationController?.pushViewController(postVC, animated: true)
    //presentViewController(postVC, animated: true, completion: nil)
}
    
    
// MY ADS BUTTON(My Listing)
@IBAction func myAdsButt(sender: AnyObject) {
    let myAdsVC = self.storyboard?.instantiateViewControllerWithIdentifier("MyAdsID") as! MyAds
    
    currentList = checkList.Mylist
    self.navigationController?.pushViewController(myAdsVC, animated: true)
    //presentViewController(myAdsVC, animated: true, completion: nil)
}
    
    
// LOGOUT BUTTON
@IBAction func logoutButt(sender: AnyObject) {
    PFUser.logOut()
    
    let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("Login") as! Login
    //self.presentViewController(loginVC, animated: true, completion: nil)
    self.navigationController?.pushViewController(loginVC, animated: true)
}
  

    
// TAP TO DISMISS KEYBOARD
@IBAction func dismissKeyboard(sender: UITapGestureRecognizer) {
    fullnameTxt.resignFirstResponder()
    emailTxt.resignFirstResponder()
    phoneTxt.resignFirstResponder()
    websiteTxt.resignFirstResponder()
}
    
// Show HUD ========================================================
func showHUD() {
    fullnameTxt.resignFirstResponder()
    emailTxt.resignFirstResponder()
    phoneTxt.resignFirstResponder()
    websiteTxt.resignFirstResponder()
    
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
    
    /* ADMOB DELEGATES */
    func showInterstitial() {
        // Show AdMob interstitial
        if adMobInterstitial.isReady {
            adMobInterstitial.presentFromRootViewController(self)
            println("present Interstitial")
        }
    }
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
