# CoffeeShops
creating CoffeeShops App
CoffeeSwift App

ABSTRACT:

The app monitors users location in a 500 by 500 meter region, and fetches venue data from Foursquare and lists the coffee shops nearby. We are using a MKMapView to locate the coffeeshop on Mapview and also use UITableView to list the coffee shop details. Here we are using CocoaPods in our project. 
We’ll use 2 external libraries for this project: Realm and Das Quadrant, a Swift library for the Foursquare REST API.

Prerequisites:

We need to install cocoa pods by typing following in the terminal:

$pod install

BUILD REQUIREMENTS:

iOS 8.0 SDK or later

================================================================================
RUNTIME REQUIREMENTS:

iOS 8.0 or later

=============================================================================
PACKAGING LIST:


ViewController.swift

Displays list of Coffee shops discovered in the TableView and also locates them in MKMapView.
The table view also contains a search to filter the records based on the names of coffee shops.
This class receives notification when location data from Foursquare is received and updates the MapView and TableView

CoffeeAPI.swift
This class requests data from Foursquare API by providing Client ID and Client secret ID . Realm is used to store data 

Venue.swift
This class declares all the parameters such as name, location, address to store for a Venue Object 

CoffeeAnnotation.swift
CoffeeAnnotation that inherits from NSObject and implements the MKAnnotation protocol to create a annotation on MKMapView
