//
//  MenuView.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 08.10.23.
//

import SwiftUI

struct MenuView: View {
    let menuOptions: [Option]
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(menuOptions, id: \.self) { option in
                HStack {
                    Image(systemName: option.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20)
                    
                    Text(option.title)
                }
                .padding(.bottom)
            }
        }
        
        Spacer()
    }
}
