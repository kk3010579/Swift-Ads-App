/* =======================

- Classify -

made by FV iMAGINATION ©2015
for CodeCanyon

==========================*/


import Foundation
import UIKit


// HUD View
var hudView = UIView(frame: CGRectMake(0, 0, 80, 80))
var indicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 80, 80))


var APP_NAME = "Classify"


var categoriesArray = [
    "DJ",
    "Photographer",
    "Photo Booth",
    "Hire",
    "Venue",
    "Supplies",
    "Limo",
    "Security",
    "Time for Print",
    "Model",
    "Make-Up",
    "Hair",
    "Stylist"
    
    // You can add more Categories here....
]

var citiesArray = [
    "Sydney",
    "Cessnock",
    "Orange",
    "Albury",
    "Dubbo",
    "Parramatta",
    "Armidale",
    "Goulbrun",
    "Penrith",
    "Bathurst",
    "Grafton",
    "Queanbeyan",
    "Blue Mountains",
    "Lithgow",
    "Tamworth",
    "Broken Hill",
    "Liverpool",
    "Wagga Wagga",
    "Hobart",
    "Townsville",
    "Mooroopna",
    "Whyalla",
    "Geelong",
    "Shepparton",
    "Ballarat",
    "Fremantle",
    "Mackay",
    "Kalgoorlie",
    "Murray Bridge",
    "Lake Macquarie City",
    "Port Augusta",
    "City of Adelaide",
    "Hervey Bay",
    "Port Pirie",
    "Maitland",
    "Port Lincoln",
    "Bathurst",
    "Toowoomba",
    "Broken Hill",
    "Logan City",
    "Bunbury",
    "Warmambool",
    "Port Macquaria",
    "Barmera",
    "Ardrossan",
]



// IMPORTANT: Change the red string below with the path where you've stored the sendReply.php file (in this case we've stored it into a directory in our website called "classify")
var PATH_TO_PHP_FILE = "http://www.fvimagination.com/classify/"

// IMPORTANT: You must replace the red email address below with the one you'll dedicate to Report emails from Users, in order to also agree with EULA Terms (Required by Apple)
let MY_REPORT_EMAIL_ADDRESS = "report@example.com"

// IMPORTANT: Replace the red string below with your own AdMob INTERSTITIAL's Unit ID
var ADMOB_UNIT_ID = "ca-app-pub-9733347540588953/3763024822"




/* PARSE KEYS (replace the 2 red strings below with your own keys on Parse)  */
var PARSE_APP_KEY = "WRJxymGifu8GCSWUaCsxBHWt5kkcdIarWiGl7fV0"
var PARSE_CLIENT_KEY = "UJdDjuBOurYUvHWhEUPbkKMTvDfFxXa0zQy5oIYU"
/*===============================================*/

/* USER CLASS */
var USER_CLASS_NAME = "User"
var USER_ID = "objectId"
var USER_USERNAME = "username"
var USER_FULLNAME = "fullName"
var USER_PHONE = "phone"
var USER_EMAIL = "email"
var USER_WEBSITE = "website"
var USER_AVATAR = "avatar"

/* CLASSIFIEDS CLASS */
var CLASSIF_CLASS_NAME = "Classifieds"
var CLASSIF_ID = "objectId"
var CLASSIF_USER = "user" // User Pointer
var CLASSIF_TITLE = "title"
var CLASSIF_CATEGORY = "category"
var CLASSIF_ADDRESS = "address" // GeoPoint
var CLASSIF_ADDRESS_STRING = "addressString"
var CLASSIF_PRICE = "price"
var CLASSIF_DESCRIPTION = "description"
var CLASSIF_DESCRIPTION_LOWERCASE = "descriptionLowercase"
var CLASSIF_IMAGE1 = "image1" // File
var CLASSIF_IMAGE2 = "image2" // File
var CLASSIF_IMAGE3 = "image3" // File
var CLASSIF_CREATED_AT = "createdAt"
var CLASSIF_UPDATED_AT = "updatedAt"

/* FAVORITES CLASS */
var FAV_CLASS_NAME = "Favorites"
var FAV_USERNAME = "username" //pointer //------MT
var FAV_AD_POINTER = "adPointer" // Pointer
var FAV_USER = "user" //pointer <- User Class

/* REVIEW CLASS */
var REVIEW_CLASS_NAME = "Review"
var REVIEW_USER = "userID" //pointer
var REVIEW_AD = "adPointer"  //pointer
var REVIEW_NAME = "username"  //
var REVIEW_TEXT = "text"   //
var REVIEW_MARK = "mark"

/*Button Corner Radius*/
var CORNER_RADIUS : CGFloat = 8

/* Menu */
var SIDEBAR_DX : CGFloat = 40
var SIDEBAR_DY : CGFloat = 10

/* Ad List */
enum checkList: Int{
    case Favorite = 0
    case Mylist = 1
    case Browse = 2
}
var currentList = checkList.Favorite//indicate the current list(Browse, Favorite, Mylisting)
