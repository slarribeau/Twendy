# twendy
iOS App for monitoring Twitter Trends


iPAD TODO LIST:
default to home when you first login.
Monstors and Select Region conflict when you return to portrait mode from landscape.
Fix nav bar on right view
Always scroll back to right view first entry when you select a region 
a) Put region in nav bar once selected
b) make sure table entries are highlighted
c) Fix issue when you aren't logged in and you hit cancel
d) Startup in landscape mode is erie. (try math monster as well)
e) Start up when not logged in is bleak -> Jazz it up
f) Should cancel say "Cancel Login"
g) Should Monster say "Show Regions"
h) Login button in right controller at startup
i) make empty table look better at startup!
j) Make web take up whole screen!

BUGS:
Can you stack region strings?

TODO: short term
home should be your nearest geo location.
store test run
cleaner gui
redesign with better data encapsulation
entertain folks when network is slow and startup takes a long time!!!
what if rate limit is exceeded?

MED:
find twitter account and use those credentials
http://stackoverflow.com/questions/13797409/ios-returns-that-there-are-no-twitter-accounts-on-phone-eventhough-there-is-one
http://stackoverflow.com/questions/18486293/ios-twitter-checking-if-accounts-are-available
New name that is store ready
stability


TODO: long term

get number of tweets on each trending topic.
install hockey
advertising

prevent user from having to login over and over
twitter logout


DONE:
show current 
sort country regions.
persistify selections
handle case where you no longer follow a region that was previously selected


UISplitViewController samples:
------------------------------
SPLITVIEWCONTROLLER.DEMO
Master is a list of colors: Detail is a view of said color
http://nshipster.com/uisplitviewcontroller/
src/xcode/UISplitViewControllerDemo-master
Storyboard
Built for 8.1
Swift
ipad/iPhone

NERD VIEW
View master list of BNR books with webview detail
iOS Programming: The big Nerd Ranch Guide
Chapter 22
/Users/macadamian/src/xcode/Solutions/22-UISplitViewController/Nerdfeed
No nib
no storyboard.
Built for 7.0
Objective C
Ipad and Iphone.


MATH MONSTERS
Silly one.
http://www.raywenderlich.com/29469/ipad-for-iphone-developers-101-in-ios-6-uisplitview-tutorial
/Users/macadamian/src/xcode/MathMonsters
Storyboard
Build for 6.0
Objective C
Ipad only


UISplitVIEWControllerDemo
http://devmonologue.com/ios/tutorials/uisplitviewcontroller-tutorial/
src/xcode/UISplitViewControllerDemo
nibs
objective C
ipad and iphone
Built for 5.0
