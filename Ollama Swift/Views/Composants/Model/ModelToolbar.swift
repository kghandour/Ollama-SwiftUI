//
//  ModelToolbar.swift
//  Ollama Swift
//
//  Created by Otourou Da Costa on 04/01/2024.
//

import Foundation
import SwiftUI

struct ModelToolbar: ToolbarContent {
    @EnvironmentObject var viewModel: ManageModelsViewModel
    
    @ToolbarContentBuilder
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .automatic){
            HStack{
                if(viewModel.errorModel.showError){
                    VStack (alignment: .leading) {
                        Text(viewModel.errorModel.errorTitle)
                            .textSelection(.enabled)
                            .font(.title2)
                        Text(viewModel.errorModel.errorMessage)
                            .textSelection(.enabled)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(5)
                    .background(.red)
                    .cornerRadius(10)
                    .foregroundStyle(.white)
                }else{
                    Text("Server:")
                    Label("Connected", systemImage: "circle.fill")
                        .foregroundStyle(.green)
                }
                Button{
                    viewModel.getTags()
                }label: {
                    Image(systemName: "arrow.clockwise")
                        .frame(width: 20, height: 20, alignment: .center)
                }
            }
        }
    }
}
