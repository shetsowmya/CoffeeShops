//
//  ViewController.swift
//  CoffeeSwift
//
//  Created by Nidhi on 6/05/2016.
//  Copyright © 2016 ShetCo. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift


class PlacesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var address: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}
    
class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var mapView:MKMapView?
    @IBOutlet var tableView:UITableView?
    var locationManager:CLLocationManager?
    let distanceSpan:Double = 500
    let searchController = UISearchController(searchResultsController: nil)

    
    var lastLocation:CLLocation?
    var venues:[Venue]?
    var filteredVenues:[Venue]?
    
    func filterContextForSearchText(searchText:String, scope: String = "All"){  //function to filter results based on text in SearhBar
        filteredVenues = venues?.filter { venue in
            return venue.name.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        tableView?.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("onVenuesUpdated:"), name: API.notifications.venuesUpdated, object: nil)
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView?.tableHeaderView = searchController.searchBar

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        if let mapView = self.mapView
        {
            mapView.delegate = self                    //setting mapView delegate to self
        }
        if let tableView = self.tableView
        {
            tableView.delegate = self                  //setting tableview delegate and datasource methods
            tableView.dataSource = self
        }
    }
    
    override func viewDidAppear(animated: Bool)
    {
        if locationManager == nil {
            locationManager = CLLocationManager()
            
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager!.requestAlwaysAuthorization()   //asking for permission to use the GPS location data.
            locationManager!.distanceFilter = 50 // Don't send location updates with a distance smaller than 50 meters between them
            locationManager!.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        if let mapView = self.mapView {
            let region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, distanceSpan, distanceSpan)
            mapView.setRegion(region, animated: true)    //create a rectangular region with newLocation coordinate in center
            refreshVenues(newLocation, getDataFromFoursquare: true)
        }
    }
    func refreshVenues(location: CLLocation?, getDataFromFoursquare:Bool = false)
    {
        if location != nil
        {
            lastLocation = location
        }
        
        if let location = lastLocation
        {
            if getDataFromFoursquare == true
            {
                CoffeeAPI.sharedInstance.getCoffeeShopsWithLocation(location)
            }
            
            let (start, stop) = calculateCoordinatesWithRegion(location)
            
            let predicate = NSPredicate(format: "latitude < %f AND latitude > %f AND longitude > %f AND longitude < %f", start.latitude, stop.latitude, start.longitude, stop.longitude)
            
            let realm = try! Realm()
            
            venues = realm.objects(Venue).sort{
            location.distanceFromLocation($0.coordinate) < location.distanceFromLocation($1.coordinate)
            }
            
            for venue in venues!
            {
                print(venue);
                let annotation = CoffeeAnnotation(title: venue.name, subtitle: venue.address, coordinate: CLLocationCoordinate2D(latitude: Double(venue.latitude), longitude: Double(venue.longitude)))
                
                mapView?.addAnnotation(annotation)
                tableView?.reloadData()
            }
        }
    }
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?
    {

        if annotation.isKindOfClass(MKUserLocation)
        {
            return nil
        }
        
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier("annotationIdentifier")
        
        if view == nil
        {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotationIdentifier")
        }
        
        view?.canShowCallout = true
        
        return view
    }
    func onVenuesUpdated(notification:NSNotification)
    {
        refreshVenues(nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredVenues!.count
        }
        return venues?.count ?? 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellIdentifier", forIndexPath: indexPath) as!PlacesTableViewCell
        
        
        let selectedVenue:Venue
        
        if searchController.active && searchController.searchBar.text != "" {
            selectedVenue = filteredVenues![indexPath.row];
            print(selectedVenue)
        }else{
            selectedVenue = venues![indexPath.row]
        }
        

        cell.address.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.address.numberOfLines = 2
        
        let distanceStr = String(format: "%.f%@", selectedVenue.distance," m");
        cell.name.text = selectedVenue.name
        cell.address.text = selectedVenue.address
        cell.distance.text = distanceStr
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if let venue = venues?[indexPath.row]
        {
            let region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: Double(venue.latitude), longitude: Double(venue.longitude)), distanceSpan, distanceSpan)
            mapView?.setRegion(region, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 80.0;//Choose your custom row height
    }
    
    func calculateCoordinatesWithRegion(location:CLLocation) -> (CLLocationCoordinate2D, CLLocationCoordinate2D)
    {
        let region = MKCoordinateRegionMakeWithDistance(location.coordinate, distanceSpan, distanceSpan)
        
        var start:CLLocationCoordinate2D = CLLocationCoordinate2D()
        var stop:CLLocationCoordinate2D = CLLocationCoordinate2D()
        
        start.latitude  = region.center.latitude  + (region.span.latitudeDelta  / 2.0)
        start.longitude = region.center.longitude - (region.span.longitudeDelta / 2.0)
        stop.latitude   = region.center.latitude  - (region.span.latitudeDelta  / 2.0)
        stop.longitude  = region.center.longitude + (region.span.longitudeDelta / 2.0)
        
        return (start, stop)
    }
}

extension ViewController:UISearchResultsUpdating{
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContextForSearchText(searchController.searchBar.text!)
    }
}

