//
//  ContentView.swift
//  RickMorty
//
//  Created by Cole Richards on 8/19/22.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var vm: CartoonViewModel = CartoonViewModel()
    
    var body: some View {
        VStack {
            Text("Rick and Morty Characters")
                .font(.headline)
            ScrollView{
                LazyVStack{
                    ForEach(vm.cartoons.indices, id: \.self ){ idx in
                        CartoonView(cartoon: vm.cartoons[idx])
                            .onAppear{
                                if idx == vm.cartoons.count - 1 {
                                    vm.loadMore()
                                }
                            }
                    }
                }
            }
        }.onAppear{
            vm.loadMore()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
