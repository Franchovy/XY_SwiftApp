//
//  ContentView.swift
//  XY_beta
//
//  Created by Simone on 14/11/2020.
//

import SwiftUI
    

struct ContentView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack (alignment: .bottomLeading) {
                
                TabView {
                    
                    homepage()
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }.tag(0)
                    Text("Welcome in XY")
                        .tabItem {
                            Image("Communities_bar_3x")
                            Text("Communities")
                        }.tag(0)
                    Text("Welcome in XY")
                        .tabItem {
                            Image(systemName:"bell.fill")
                            Text("Notification")
                        }.tag(0)
                    Text("Welcome in XY")
                        .tabItem {
                            Image("Icon awesome-shopping-bag")
                            Text("Shop")
                        }.tag(0)
                    Text("Welcome in XY")
                        .tabItem {
                            Image(systemName:"square.fill")
                            Text("Profile")
                        }.tag(0)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
