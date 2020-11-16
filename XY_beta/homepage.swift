//
//  homepage.swift
//  XY_beta
//
//  Created by Simone on 16/11/2020.
//

import SwiftUI

struct homepage: View {
    var body: some View {
        ScrollView(.vertical) {
            VStack (alignment: .leading,
                spacing: 10) {
                
                ForEach (1...20, id: \.self) {
                    Text("Test \($0)")
                        .foregroundColor(Color.red)
                        .font(.largeTitle)
                }
            }
        }
        
    }
}

struct homepage_Previews: PreviewProvider {
    static var previews: some View {
        homepage()
    }
}
