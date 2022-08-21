//
//  CartoonView.swift
//  RickMorty
//
//  Created by Cole Richards on 8/20/22.
//

import SwiftUI

struct CartoonView: View {
    var cartoon: Cartoon
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: cartoon.image)) { image in
                image
                    .resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 80.0, height: 80.0)
            .clipShape(Circle())
            .padding(.leading, 16)
            .padding(.trailing, 8)
            
            Text(cartoon.name)
            
            Spacer()
        }
    }
}

struct CartoonView_Previews: PreviewProvider {
    static var previews: some View {
        CartoonView(cartoon: Cartoon(id: 1, name:"Cole Richards", image:"https://rickandmortyapi.com/api/character/avatar/780.jpeg"))
    }
}
