//
//  EditView.swift
//  BucketList
//
//  Created by Kok on 11/8/24.
//

import SwiftUI

struct EditView: View {
    enum LoadingState {
        case loading, loaded, failed
    }
    
    @Environment(\.dismiss) var dismiss;
    var location: Location
    
    @State private var name: String
    @State private var description: String
    var onSave: (Location) -> Void
    
    @State private var loadingState = LoadingState.loading;
    @State private var pages: [Page] = [];
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Place name", text: $name)
                    TextField("Place name", text: $description)
                }
                Section("Nearby...") {
                    switch loadingState {
                    case .loading:
                        HStack {
                            ProgressView()
                            Text("Loading...")
                        }
                    case .loaded:
                        ForEach(pages, id: \.pageid) { page in
                            Text(page.title)
                                .font(.headline)
                            + Text(": ")
                            + Text(page.description)
                                .italic()
                        }
                    case .failed:
                        Text("Please try again later.")
                    }
                }
            }
            .navigationTitle("Place details")
            .toolbar {
                Button("Save") {
                    var newLocation = location;
                    newLocation.id = UUID()
                    newLocation.name = self.name;
                    newLocation.description = self.description;
                    onSave(newLocation);
                    dismiss()
                }
            }
            .task {
                await fetchNearbyPlaces()
            }
        }
    }
    
    init(location: Location, onSave: @escaping (Location) -> Void) {
        self.location = location
        self.onSave = onSave
        
        _name = State(initialValue: location.name)
        _description = State(initialValue: location.description)
    }
    
    func fetchNearbyPlaces() async {
        let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(location.latitude)%7C\(location.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json";
        guard let url = URL(string: urlString) else {
            print("Bad URL: \(urlString)");
            return;
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url);
            let items = try JSONDecoder().decode(Result.self, from: data);
            self.pages = items.query.pages.values.sorted {$0.title < $1.title}.sorted();
            self.loadingState = .loaded;
        } catch {
            print(error)
            self.loadingState = .failed
        }
    }
}

#Preview {
    EditView(location: Location.example) { newLocation in
        print(newLocation)
    }
}
