//
//  review.swift
//  Classify
//
//  Created by Argon on 9/15/15.
//  Copyright (c) 2015 FV iMAGINATION. All rights reserved.
//

import Foundation
import UIKit
import Parse
import ParseUI

class Review  : UITableViewController, FloatRatingViewDelegate, UITextFieldDelegate{
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var messagetxt: UITextView!
    @IBOutlet weak var submitBt: UIButton!
    
    @IBOutlet var floatRatingView: FloatRatingView!
    
    var ratingMark:Float = 0
    var adPointer = String()
    var selfObject = PFObject(className: CLASSIF_CLASS_NAME)
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBarHidden = false
        //Initialize ratingMark
        ratingMark = floatRatingView.rating
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Required float rating view params
        self.floatRatingView.emptyImage = UIImage(named: "fevstar.png")
        self.floatRatingView.fullImage = UIImage(named: "full_fevstar.png")
        
        // Optional params
        self.floatRatingView.delegate = self
        self.floatRatingView.contentMode = UIViewContentMode.ScaleAspectFit
        self.floatRatingView.maxRating = 5
        self.floatRatingView.minRating = 1
        self.floatRatingView.rating = 2.5
        self.floatRatingView.editable = true
        self.floatRatingView.halfRatings = true
        self.floatRatingView.floatRatings = false
        
        //navigation bar 
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func dismissKeyboardAction(sender: AnyObject) {
        username.resignFirstResponder()
        messagetxt.resignFirstResponder()
    }
    //the event when clicking <X>
    @IBAction func quitBtClicked(sender: AnyObject) {
        var singleVC = self.storyboard?.instantiateViewControllerWithIdentifier("ShowSingleAdID") as! ShowSingleAd
        //self.presentViewController(singleVC, animated: true, completion: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    //clicking <Submit> //-- transfer the message to Parse DB
    @IBAction func submitButtonClicked(sender: AnyObject) {
        
        //checking data is correct
        if(username.text == "" || messagetxt.text == ""){
            var alert = UIAlertView(title: APP_NAME,
                message: "You must input into username and message!",
                delegate: nil,
                cancelButtonTitle: "OK" )
            alert.show()

            return
        }
        
        //sending data to DB
        if PFUser.currentUser() == nil{
            return
        }
        else{
            showHUD()
            
            var reviewClass = PFObject(className: REVIEW_CLASS_NAME)
            
            reviewClass[REVIEW_USER] = PFUser.currentUser()
            reviewClass[REVIEW_AD] = selfObject
            reviewClass[REVIEW_NAME] = username.text
            reviewClass[REVIEW_TEXT] = messagetxt.text
            reviewClass[REVIEW_MARK] = ratingMark//String(stringInterpolationSegment: ratingMark)
            
            reviewClass.saveInBackgroundWithBlock{ (success, error) -> Void in
                if error == nil {
                    var alert = UIAlertView(title: APP_NAME,
                        message: "Review OK!",
                        delegate: nil,
                        cancelButtonTitle: "OK" )
                    alert.show()
                    
                    hudView.removeFromSuperview()
                }
                else{
                    var alert = UIAlertView(title: APP_NAME,
                        message: "Something went wrong, try again later",
                        delegate: nil,
                        cancelButtonTitle: "OK" )
                    alert.show()
                    
                    hudView.removeFromSuperview()
                }
                //Reloading <ShowSingleAD>
                self.navigationController?.popViewControllerAnimated(true)
            }
            
        }
                
        
        //presentViewController(singleAdVC, animated: true, completion: nil)
    }
    
    
    //---------  processing rating mark
    
    func floatRatingView(ratingView: FloatRatingView, isUpdating rating:Float) {
        ratingMark = floatRatingView.rating
    }
    
    func floatRatingView(ratingView: FloatRatingView, didUpdate rating: Float) {
        ratingMark = floatRatingView.rating
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if(textField == self.username){
            self.username.resignFirstResponder()
            self.messagetxt.becomeFirstResponder()
        }
        else if textField == self.self.messagetxt{
            self.username.resignFirstResponder()
            self.messagetxt.resignFirstResponder()
        }
        return true
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


}