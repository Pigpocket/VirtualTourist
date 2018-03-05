# VirtualTourist
App that downloads Flickr images based on a map annotation and persists them via Core Data

## Build
This app was built in Swift 4.0 and XCode 9.2 for deployment in iOS 11.0

## Features
This app utilizes a pin drop to query Flickr's API for publically available images within a defined radius of the pin's location, and displays them in a separate CollectionViewController. The app utilizes multi-threading to allow background fetching of UIImage data while cells are being displayed. Images are persisted according to pin entities in Core Data, and tap functionality on the CollectionViewController allows removal of items from the view controller and Core Data.

## Purpose
This app fulfills Udacity's requirement of successfully implementing networking and persistence in preparation for the course's capstone project.
