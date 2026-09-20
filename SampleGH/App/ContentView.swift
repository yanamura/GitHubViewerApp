//
//  ContentView.swift
//  SampleGH
//
//  Created by Yasuharu Yanamura on 2026/08/04.
//

import SwiftUI

struct ContentView: View {
  var body: some View {
    TabView {
      Tab("Explore", systemImage: "flame") {
        ExploreView()
      }
      Tab("Search", systemImage: "magnifyingglass") {
        SearchView()
      }
      Tab("Favorites", systemImage: "star") {
        FavoritesView()
      }
    }
  }
}

#Preview {
  ContentView()
}
