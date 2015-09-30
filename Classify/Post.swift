/* =======================

- Classify -

made by FV iMAGINATION ©2015
for CodeCanyon

==========================*/


import UIKit
import Parse
import MapKit
import CoreLocation


class Post: UIViewController,
UIPickerViewDataSource,
UIPickerViewDelegate,
UITextFieldDelegate,
UITextViewDelegate,
CLLocationManagerDelegate,
UIAlertViewDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate
{

    /* Views */
    @IBOutlet var categoryContainer: UIView!
    @IBOutlet var categoryPickerView: UIPickerView!
    
    @IBOutlet var titlelabel: UILabel!
    //@IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var titleTxt: UITextField!
    @IBOutlet var categoryTxt: UITextField!
    @IBOutlet var priceTxt: UITextField!
    @IBOutlet var addressTxt: UITextField!
    @IBOutlet var descrTxt: UITextView!
    
    @IBOutlet var mapView: MKMapView!

    @IBOutlet var buttonsImage: [UIButton]!
    var buttTAG = Int()
    @IBOutlet var image1: UIImageView!
    @IBOutlet var image2: UIImageView!
    @IBOutlet var image3: UIImageView!
    @IBOutlet var image4: UIImageView! //new items

    @IBOutlet var postAdOutlet: UIButton!
    
    //@IBOutlet var deleteAdOutlet: UIButton!
    
    
    @IBOutlet weak var tableview: UITableView!
    /* Variables */
    var classifArray = NSMutableArray()
    var locationManager: CLLocationManager!
    
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinView:MKPinAnnotationView!
    var region: MKCoordinateRegion!
    var coordinates: CLLocationCoordinate2D!
    
    var postID = String()

    
  
//    func leftBarItemClicked(){
//        self.navigationController?.popViewControllerAnimated(true)
//    }
    
override func viewDidLoad() {
    super.viewDidLoad()
    
        self.title = "New Listing"
    
    // Show an Alert in case your not logged in
    if PFUser.currentUser() == nil {
        var alert = UIAlertView(title: APP_NAME,
        message: "You must first login/signup to Post an Ad",
        delegate: nil,
        cancelButtonTitle: "OK" )
        alert.show()
    }
    
    
    // Check if you are about to update an Ad
    if postID != "" {
        titlelabel.text = "Edit your Ad"
        println("\(postID)")
        postAdOutlet.setTitle("Update", forState: UIControlState.Normal)
        //deleteAdOutlet.hidden = false
        queryYourAd()
    } else {
        //deleteAdOutlet.hidden = true
    }

    
    // Setup views
    categoryContainer.frame = CGRectMake(0, 1000, self.view.frame.size.width, categoryContainer.frame.size.height)
    categoryContainer.frame.origin.y = view.frame.size.height
    //containerScrollView.contentSize = CGSizeMake(containerScrollView.frame.size.width, 800)
    view.bringSubviewToFront(categoryContainer)

    
    // Setup buttons to load Ad images
    for button in buttonsImage {
        button.addTarget(self, action: "buttImageTapped:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    self.descrTxt.text = "" as String
    
    self.categoryContainer.hidden = true
    self.navigationController?.setNavigationBarHidden(false, animated: false)
    self.navigationController?.navigationBarHidden = false
}
    
override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    
    self.navigationController?.setNavigationBarHidden(false, animated: false)
    self.navigationController?.navigationBarHidden = false
}

override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(true)
    self.navigationController?.navigationBarHidden = true
    
}
    
func queryYourAd() {
    classifArray.removeAllObjects()
    
    var query = PFQuery(className: CLASSIF_CLASS_NAME)
    query.whereKey(CLASSIF_ID, equalTo: postID)
    query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
        if error == nil {
            if let objects = objects as? [PFObject] {
                for object in objects {
                    self.classifArray.addObject(object)
                } }
            // Show your Ad details
            self.showAdDetails()
            
        } else {
            var alert = UIAlertView(title: APP_NAME,
            message: "Something went wrong, try again later or check your internet connection",
            delegate: self,
            cancelButtonTitle: "OK" )
            alert.show()
        }
    }
}				

func showAdDetails() {
    var classifClass = PFObject(className: CLASSIF_CLASS_NAME)
    classifClass = classifArray[0] as! PFObject
    
    titleTxt.text = "\(classifClass[CLASSIF_TITLE]!)"
    categoryTxt.text = "\(classifClass[CLASSIF_CATEGORY]!)"
    priceTxt.text = "\(classifClass[CLASSIF_PRICE]!)"
    descrTxt.text = "\(classifClass[CLASSIF_DESCRIPTION]!)"
    addressTxt.text = "\(classifClass[CLASSIF_ADDRESS_STRING]!)"
    addPinOnMap(addressTxt.text)
    
    // Get image1
    let imageFile1 = classifClass[CLASSIF_IMAGE1] as? PFFile
    imageFile1?.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
        if error == nil {
            if let imageData = imageData {
                self.image1.image = UIImage(data:imageData)
            } } }
    
    // Get image2
    let imageFile2 = classifClass[CLASSIF_IMAGE2] as? PFFile
    imageFile2?.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
        if error == nil {
            if let imageData = imageData {
                self.image2.image = UIImage(data:imageData)
            } } }
    
    // Get image3
    let imageFile3 = classifClass[CLASSIF_IMAGE3] as? PFFile
    imageFile3?.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
        if error == nil {
            if let imageData = imageData {
                self.image3.image = UIImage(data:imageData)
            } } }
    
    // Get image4
    let imageFile4 = classifClass[CLASSIF_IMAGE3] as? PFFile
    imageFile4?.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
        if error == nil {
            if let imageData = imageData {
                self.image4.image = UIImage(data:imageData)
            } } }
}
    
    
    
    
    
// BUTTON FOR IMAGES
func buttImageTapped(sender: UIButton) {
    var button = sender as UIButton
    buttTAG = button.tag
    
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
    
    // OPEN DEVICE'S CAMERA
    if alertView.buttonTitleAtIndex(buttonIndex) == "Take a picture" {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                var imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
                imagePicker.allowsEditing = false
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
            
        
    // PICK A PHOTO FROM LIBRARY
    } else if alertView.buttonTitleAtIndex(buttonIndex) == "Choose from Library" {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
                var imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
                imagePicker.allowsEditing = false
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
            
    // DELETE AD
    } else if alertView.buttonTitleAtIndex(buttonIndex) == "Delete Ad" {
            var classifClass = PFObject(className: CLASSIF_CLASS_NAME)
            classifClass = classifArray[0] as! PFObject
            classifClass.deleteInBackgroundWithBlock {(success, error) -> Void in
                if error == nil {
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    var alert = UIAlertView(title: APP_NAME,
                    message: "Something went wrong, try again later",
                    delegate: nil,
                    cancelButtonTitle: "OK" )
                    alert.show()
                } }
    }
    
}
// ImagePicker Delegate
func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
    
    // Assign Images
    switch buttTAG {
    case 0: image1.image = image;   break
    case 1: image2.image = image;   break
    case 2: image3.image = image;   break
    case 3: image4.image = image;   break
    default: break
    }
    dismissViewControllerAnimated(true, completion: nil)
}
    
    
    
    
// SET CURRENT LOCATION BUTTON
@IBAction func setCurrentLocationButt(sender: AnyObject) {
    // Init LocationManager
    locationManager = CLLocationManager()
    if(CLLocationManager.locationServicesEnabled() == false){
        var errorAlert = UIAlertView(title: APP_NAME,
            message: "LocationService is disabled, try later!",
            delegate: nil,
            cancelButtonTitle: "OK")
        errorAlert.show()

         return
    }
    
    locationManager.delegate = self
    
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    
    locationManager.requestWhenInUseAuthorization()
    if
    locationManager.respondsToSelector("requestWhenInUseAuthorization")
    {
        locationManager.requestAlwaysAuthorization()
    }
    var currentlocation = CLLocation()
    if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways){
        currentlocation = locationManager.location
    }
    

    //locationManager.startUpdatingLocation()
}
    
// MARK - CLLocationManagerDelegate
func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
    locationManager.stopUpdatingLocation()
    
    println("didFailWithError: %@", error)
    
    var errorAlert = UIAlertView(title: APP_NAME,
        message: "Failed to Get Your Location",
        delegate: nil,
        cancelButtonTitle: "OK")
    errorAlert.show()
}
func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {

    locationManager.stopUpdatingLocation()
    
    var geoCoder = CLGeocoder()
    geoCoder.reverseGeocodeLocation(newLocation, completionHandler: { (placemarks, error) -> Void in
        
        let placeArray = placemarks as! [CLPlacemark]
        var placemark: CLPlacemark!
        placemark = placeArray[0]
        
        // Street
        let street = placemark.addressDictionary["Name"] as! String
        // City
        let city = placemark.addressDictionary["City"] as! String
        // Zip code
        let zip = placemark.addressDictionary["ZIP"] as! String
        // State
        let state = placemark.addressDictionary["State"] as! String
        // Country
        let country = placemark.addressDictionary["Country"] as! String

        // Show address on addressTxt
        self.addressTxt.text = "\(street), \(zip), \(city), \(state), \(country)"
        // Add a Pin to the Map
        if self.addressTxt.text != "" {  self.addPinOnMap(self.addressTxt.text)  }
        
    })
    
}

    
// ADD A PIN ON THE MAP
func addPinOnMap(address: String) {

    if mapView.annotations.count != 0 {
        annotation = mapView.annotations[0] as! MKAnnotation
        mapView.removeAnnotation(annotation)
    }
    
    // Make a search on the Map
    localSearchRequest = MKLocalSearchRequest()
    localSearchRequest.naturalLanguageQuery = address
    localSearch = MKLocalSearch(request: localSearchRequest)
    
    localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
    // Place not found or GPS not available
    if localSearchResponse == nil  {
        var alert = UIAlertView(title: APP_NAME,
        message: "Place not found, or GPS not available",
        delegate: nil,
        cancelButtonTitle: "Try again" )
        alert.show()
  
    } else {
    // Add PointAnnonation text and a Pin to the Map
    self.pointAnnotation = MKPointAnnotation()
    self.pointAnnotation.title = self.titleTxt.text
    self.pointAnnotation.subtitle = self.addressTxt.text
    self.pointAnnotation.coordinate = CLLocationCoordinate2D( latitude: localSearchResponse.boundingRegion.center.latitude, longitude:localSearchResponse.boundingRegion.center.longitude)
        
    // Store coordinates (to use later while posting the Ad)
    self.coordinates = self.pointAnnotation.coordinate
        
    self.pinView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
    self.mapView.centerCoordinate = self.pointAnnotation.coordinate
    self.mapView.addAnnotation(self.pinView.annotation)
        
    // Zoom the Map to the location
    self.region = MKCoordinateRegionMakeWithDistance(self.pointAnnotation.coordinate, 1000, 1000);
    self.mapView.setRegion(self.region, animated: true)
    self.mapView.regionThatFits(self.region)
    self.mapView.reloadInputViews()
    }
    
    }
    

}
    
    
    
/* MARK -  TEXTFIELD DELEGATE */
func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
    if textField == categoryTxt {
        showCatPickerView()
        titleTxt.resignFirstResponder()
        priceTxt.resignFirstResponder()
        categoryTxt.resignFirstResponder()
    }
    
return true
}
    
func textFieldDidBeginEditing(textField: UITextField) {
    if textField == categoryTxt {
        showCatPickerView()
        titleTxt.resignFirstResponder()
        priceTxt.resignFirstResponder()
        categoryTxt.resignFirstResponder()
    }
    
}
func textFieldDidEndEditing(textField: UITextField) {
    // Get address for the Map
    if textField == addressTxt {
        if addressTxt.text != "" {  addPinOnMap(addressTxt.text)  }
    }
}
    
func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == titleTxt {  categoryTxt.becomeFirstResponder(); hideCatPickerView()  }
    if textField == priceTxt {  descrTxt.becomeFirstResponder()  }
    
    if textField == addressTxt {  addressTxt.resignFirstResponder()  }
    
return true
}




/* MARK - PICKERVIEW DELEGATES */
func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1;
}

func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return categoriesArray.count
}

func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
    return categoriesArray[row]
}
    
func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    categoryTxt.text = "\(categoriesArray[row])"
}
    
   
    
    
// POST NEW AD / UPDATE AD BUTTON
@IBAction func postAdButt(sender: AnyObject) {
    showHUD()
    println("postID 2: \(postID)")
    
    if image1.image == nil{
        var alert = UIAlertView(title: APP_NAME, message: "The first image is none!\n  If you want to post something, you have to set the first image.", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
        return
    }
    
    // POST A NEW AD ==============================================
    if PFUser.currentUser() != nil  &&  postID == "" {
    var classifClass = PFObject(className: CLASSIF_CLASS_NAME)
 
    // Save PFUser as Pointer (if needed)
    classifClass[CLASSIF_USER] = PFUser.currentUser()
    
    // Save other data
    classifClass[CLASSIF_TITLE] = titleTxt.text
    classifClass[CLASSIF_CATEGORY] = categoryTxt.text
    classifClass[CLASSIF_PRICE] = priceTxt.text
    classifClass[CLASSIF_DESCRIPTION] = descrTxt.text
    classifClass[CLASSIF_DESCRIPTION_LOWERCASE] = descrTxt.text.lowercaseString
    classifClass[CLASSIF_ADDRESS_STRING] = addressTxt.text.lowercaseString
        
    if coordinates != nil {
    var geoPoint = PFGeoPoint(latitude: coordinates.latitude, longitude: coordinates.longitude)
    classifClass[CLASSIF_ADDRESS] = geoPoint
    }
    
 // Save Image1
    if (image1.image != nil) {
        let imageData = UIImageJPEGRepresentation(image1.image,0.5)
        let imageFile = PFFile(name:"img1.jpg", data:imageData)
        classifClass[CLASSIF_IMAGE1] = imageFile
    }
    // Save Image2
    if (image2.image != nil) {
        let imageData = UIImageJPEGRepresentation(image2.image,0.5)
        let imageFile = PFFile(name:"img2.jpg", data:imageData)
        classifClass[CLASSIF_IMAGE2] = imageFile
    }
    // Save Image3
    if (image3.image != nil) {
        let imageData = UIImageJPEGRepresentation(image3.image,0.5)
        let imageFile = PFFile(name:"img3.jpg", data:imageData)
        classifClass[CLASSIF_IMAGE3] = imageFile
    }
        // Save Image4
        if (image4.image != nil) {
            let imageData = UIImageJPEGRepresentation(image4.image,0.5)
            let imageFile = PFFile(name:"img3.jpg", data:imageData)
            classifClass[CLASSIF_IMAGE3] = imageFile
        }
    // Saving block
    classifClass.saveInBackgroundWithBlock { (success, error) -> Void in
        if error == nil {
        var alert = UIAlertView(title: APP_NAME,
        message: "Your Ad has been successfully post!",
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
        

        
        
    // UPDATE SELECTED AD ==============================================
    } else if PFUser.currentUser() != nil  &&  postID != "" {
        var query = PFQuery(className:CLASSIF_CLASS_NAME)
        query.getObjectInBackgroundWithId(postID) { (object, error) -> Void in
            if error != nil { println(error)
            } else if let object = object {
                println("object: \(object)")
                // Save PFUser as Pointer (if needed)
                object[CLASSIF_USER] = PFUser.currentUser()
                
                // Save other data
                object[CLASSIF_TITLE] = self.titleTxt.text
                object[CLASSIF_CATEGORY] = self.categoryTxt.text
                object[CLASSIF_PRICE] = self.priceTxt.text
                object[CLASSIF_DESCRIPTION] = self.descrTxt.text
                object[CLASSIF_DESCRIPTION_LOWERCASE] = self.descrTxt.text.lowercaseString
                object[CLASSIF_ADDRESS_STRING] = self.addressTxt.text.lowercaseString
                
                if self.coordinates != nil {
                    var geoPoint = PFGeoPoint(latitude: self.coordinates.latitude, longitude: self.coordinates.longitude)
                    object[CLASSIF_ADDRESS] = geoPoint
                }
                
                // Save Image1
                if (self.image1.image != nil) {
                    let imageData = UIImageJPEGRepresentation(self.image1.image,0.5)
                    let imageFile = PFFile(name:"img1.jpg", data:imageData)
                    object[CLASSIF_IMAGE1] = imageFile
                }
                // Save Image2
                if (self.image2.image != nil) {
                    let imageData = UIImageJPEGRepresentation(self.image2.image,0.5)
                    let imageFile = PFFile(name:"img2.jpg", data:imageData)
                    object[CLASSIF_IMAGE2] = imageFile
                }
                // Save Image3
                if (self.image3.image != nil) {
                    let imageData = UIImageJPEGRepresentation(self.image3.image,0.5)
                    let imageFile = PFFile(name:"img3.jpg", data:imageData)
                    object[CLASSIF_IMAGE3] = imageFile
                }
                
                // Save Image4
                if (self.image4.image != nil) {
                    let imageData = UIImageJPEGRepresentation(self.image4.image,0.5)
                    let imageFile = PFFile(name:"img4.jpg", data:imageData)
                    object[CLASSIF_IMAGE3] = imageFile
                }
                // Saving block
                object.saveInBackgroundWithBlock { (success, error) -> Void in
                    if error == nil {
                    var alert = UIAlertView(title: APP_NAME,
                    message: "Your Ad has been successfully updated!",
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
                } // end Saving Block
                
            } }
        
    }
    
}
    
    
// DELETE AD BUTTON-----//unused
@IBAction func deleteAdButt(sender: AnyObject) {
    var alert = UIAlertView(title: APP_NAME,
    message: "Are you sure you want to delete this Ad?",
    delegate: self,
    cancelButtonTitle: "No",
    otherButtonTitles: "Delete Ad")
    alert.show()
}
 
    
    
// CANCEL BUTTON
@IBAction func cancelButt(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
}
    
    
    
// PICKERVIEW DONE BUTTON
@IBAction func doneButt(sender: AnyObject) {
    hideCatPickerView()
}
    

// TAP TO DISMISS KEYBOARD
@IBAction func dismissKeyboard(sender: UITapGestureRecognizer) {
    titleTxt.resignFirstResponder()
    categoryTxt.resignFirstResponder()
    priceTxt.resignFirstResponder()
    addressTxt.resignFirstResponder()
    descrTxt.resignFirstResponder()
    hideCatPickerView()
}
    
// SHOW/HIDE CATEGORY PICKERVIEW
func showCatPickerView() {
        self.tableview.contentOffset.y = self.categoryTxt.frame.origin.y + self.categoryTxt.frame.height + 10 - self.view.frame.size.height + self.categoryContainer.frame.size.height
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.categoryContainer.hidden = false
            self.categoryContainer.frame.origin.y = self.categoryTxt.frame.origin.y + self.categoryTxt.frame.size.height + 10
            }, completion: { (finished: Bool) in  });
        self.tableview.scrollEnabled = false

}
func hideCatPickerView() {
    UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
        self.categoryContainer.frame.origin.y = self.postAdOutlet.frame.origin.y + 50
        self.categoryContainer.hidden = true
        self.tableview.contentOffset.y -= self.tableview.contentOffset.y
        }, completion: { (finished: Bool) in
            self.tableview.scrollEnabled = true
    });
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
//===================== Navigation Bar Processing ===================================
    
    @IBAction func backBtClicked(sender: AnyObject) {
        var homeVC = self.storyboard?.instantiateViewControllerWithIdentifier("homeID") as! Home
        //self.presentViewController(homeVC, animated: true, completion: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }

    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
}
}
