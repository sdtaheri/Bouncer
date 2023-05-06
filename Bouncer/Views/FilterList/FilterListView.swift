//
//  FilterListView.swift
//  Bouncer
//

import SwiftUI
import UniformTypeIdentifiers
import os.log

struct FilterListView: View {
    var filters: [Filter]
    let onDelete: (IndexSet) -> Void
    let onImport: ([Filter]) -> Void
    let importFiltersFromURL: (URL) -> Void
    let openSettings: () -> Void
    let showError: (FilterError) -> Void
    @Binding var shouldShowImportList: Bool

    @State var showingSettings = false
    @State var showingFilterDetail = false
    @State var showingInApp = false
    @State var showingFileImporter = false


    var body: some View {
        ZStack {
            BackgroundView()
            NavigationView {
                filterList
                    .navigationBarTitle("LIST_VIEW_TITLE")
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            menu
                        }
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            addButton
                        }
                    }
            }
        }
    }
}

struct FilterListView_Previews: PreviewProvider {
    static var previews: some View {
        FilterListView(filters: [],
                       onDelete: {_ in },
                       onImport: {_ in },
                       importFiltersFromURL: { _ in },
                       openSettings: {},
                       showError: { _ in },
                       shouldShowImportList: .constant(false)
        )
    }
}

extension FilterListView {
    
    var filterList: some View {
        Group {
            if(filters.count > 0) {
                List {
                    ForEach(filters) { filter in
                        NavigationLink(destination: FilterDetailContainerView(interactionType: .update,
                                                                              filter: filter)) {
                            FilterRowView(filter: filter)
                        }
                    }.onDelete(perform: onDelete)
                }
                .listStyle(PlainListStyle())
            }
            else {
                VStack(alignment: .center) {
                    Group() {
                        Text("EMPTY_LIST_TITLE").font(.title2).bold().padding()
                        Group {
                            Text("EMPTY_LIST_MESSAGE")
                            HStack(spacing: 0) {
                                Text("TAP_SPACE")
                                Image(systemName: "plus.circle")
                                Text("TO_ADD_A_FILTER_SPACE")
                            }
                        }.frame(width: 260)
                    }
                    .foregroundColor(Color("TextDefaultColor"))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)
                }.padding(.bottom, 200)
            }
        }
        .fileImporter(isPresented: $showingFileImporter, allowedContentTypes: [.json]) { result in
            switch result {
            case .success(let url):
                do {
                    importFiltersFromURL(url)
                }
            case .failure(let error):
                showError(.unknownError(error.localizedDescription))
            }
        }
        .sheet(isPresented: $shouldShowImportList) {
            ImportFilterListContainerView()
        }.sheet(isPresented: $showingSettings) {
            TutorialContainerView()
        }
    

    }
    
    var helpButton: some View {
        Group {
            Button(action: { showingSettings = true }) {
                Label("HELP", systemImage: SYSTEM_IMAGES.HELP.image).imageScale(.large)
            }
        }
    }
    
    var addButton: some View {
        Group {
            Button(
                action: { showingFilterDetail = true }) {
                Image(systemName: SYSTEM_IMAGES.ADD.image).imageScale(.large)
            }.sheet(isPresented: $showingFilterDetail) {
                FilterDetailContainerView()
            }
        }
    }
    
    var menu: some View {
        Menu {
            Button(action: { showingFileImporter = true }) {
                Label("IMPORT_BLOCK_LIST", systemImage: SYSTEM_IMAGES.IMPORT.image).imageScale(.large)
            }
            if let filterStoreFileURL = FilterStoreFile.fileURL {
                ShareLink(item: filterStoreFileURL) {
                    Label("EXPORT_BLOCK_LIST", systemImage: SYSTEM_IMAGES.EXPORT.image).imageScale(.large)
                }
            }
            Divider()
            helpButton            
        } label: {
            Image(systemName: SYSTEM_IMAGES.IMPORT_EXPORT_MENU.image).imageScale(.large)
        }
    }
}
