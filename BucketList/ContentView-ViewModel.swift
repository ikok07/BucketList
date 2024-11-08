//
//  ContentView-ViewModel.swift
//  BucketList
//
//  Created by Kok on 11/8/24.
//

import Foundation
import MapKit
import CoreLocation
import LocalAuthentication

extension ContentView {
    @Observable
    class ViewModel {
        private(set) var locations: [Location];
        var selectedPlace: Location?
        var isUnlocked = false;
        
        let savePath = URL.documentsDirectory.appending(path: "SavedPlaces");
        
        init() {
            do {
                let data = try Data(contentsOf: savePath);
                self.locations = try JSONDecoder().decode([Location].self, from: data);
            } catch {
                self.locations = [];
            }
        }
        
        func save() {
            do {
                let data = try JSONEncoder().encode(self.locations)
                try data.write(to: savePath, options: [.atomic, .completeFileProtection])
            } catch {
                print("Unable to save data. \(error.localizedDescription)")
            }
        }
        
        func addLocation(at point: CLLocationCoordinate2D) {
            let newLocation = Location(id: UUID(), name: "New Location", description: "", latitude: point.latitude, longitude: point.longitude)
            locations.append(newLocation)
            self.save();
        }
        
        func updateLocation(location: Location) {
            guard let selectedPlace else {return}
            
            if let index = self.locations.firstIndex(of: selectedPlace) {
                self.locations[index] = location;
                self.save()
            }
        }
        
        func authenticate() {
            let context = LAContext();
            var error: NSError?;
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Please authenticate yourself to unlock your places.";
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                    if (success) {
                        self.isUnlocked = true;
                    } else {
                        // error
                    }
                }
            } else {
                // no biometrics
            }
        }
    }
}

