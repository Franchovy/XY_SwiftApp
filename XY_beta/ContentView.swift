//
//  ContentView.swift
//  XY_beta
//
//  Created by Simone on 14/11/2020.
//

import SwiftUI
    

struct ContentView: View {
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor.black
        UITabBar.appearance().isTranslucent = true
       
    }
    

    
    var body: some View {
        TabView {
            Text("Home")
                .tabItem {
                    Image(systemName:"house.fill")
                    Text("Home")
                }
            Text("Communities")
                .tabItem {
                    Image(systemName:"person.3.fill")
                    Text("Communities")
                }
            Text("Notifications")
                .tabItem {
                    Image(systemName:"bell.fill")
                    Text("Notifications")
                    
                }
            Text("XYshop")
                .tabItem {
                    Image(systemName:"bag.fill")
                    Text("XYshop")
                }
            Text("Profile")
                .tabItem {
                    Image(systemName:"square.fill")
                    Text("Profile")
                    
                }
            
        }
        .accentColor(.white)
        
            
    }
}
        

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


