//
//  ContentView.swift
//  BucketList
//
//  Created by Kok on 11/7/24.
//

import SwiftUI
import MapKit
import LocalAuthentication

struct ContentView: View {
    let startPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 56, longitude: -3),
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        )
    );
    
    @State private var viewModel = ViewModel();
    
    var body: some View {
        if viewModel.isUnlocked {
            MapReader { proxy in
                Map(initialPosition: startPosition) {
                    ForEach(viewModel.locations) { location in
                        Annotation(location.name, coordinate: location.coordinate) {
                            Image(systemName: "star.circle")
                                .resizable()
                                .foregroundStyle(.red)
                                .frame(width: 44, height: 44)
                                .background(.white)
                                .clipShape(.circle)
                                .onTapGesture {
                                    viewModel.selectedPlace = location;
                                }
                        }
                        
                    }
                }
                    .onTapGesture { position in
                        if let coordinate = proxy.convert(position, from: .local) {
                            viewModel.addLocation(at: coordinate);
                        }
                    }
                    .sheet(item: $viewModel.selectedPlace) { place in
                        EditView(location: place) { newLocation in
                            viewModel.updateLocation(location: newLocation)
                        }
                    }
            }
        } else {
            VStack {
                ContentUnavailableView("Unlock places", systemImage: "lock", description: Text("Use your biometrics to unlock your saved places"))
                Button("Unlock", action: viewModel.authenticate)
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}

#Preview {
    ContentView()
}
