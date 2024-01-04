//
//  ManageModelsView.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 14.10.23.
//

import SwiftUI

struct ManageModelsView: View {
    @EnvironmentObject var viewModel: ManageModelsViewModel

    var body: some View {
        VStack(alignment: .leading){
            Text("Local Models:")
                .font(.headline)
            ModelsListView(viewModel: _viewModel)
            ModelActionsView(viewModel: _viewModel)
            
            Spacer()
            
            if(viewModel.showProgress){
                DownloadProgressView(viewModel: _viewModel)
            }
            
            VStack(alignment: .leading){
                Text("To find the model names to download, checkout: https://ollama.ai/library")
                    .textSelection(.enabled)
                Text("A good starting model is llama2. Simply write the model name in the field above")
            }
            Spacer()
        }
        .padding()
        .frame(minWidth: 400, idealWidth: 500, minHeight: 600, idealHeight: 800)
        .task {
            viewModel.getTags()
        }
        .toolbar{
            ModelToolbar(viewModel: _viewModel)
        }
    }

}

#Preview {
    ManageModelsView()
        .environmentObject(
            ManageModelsViewModel(
                chatService: ChatService(),
                manageModelService: ManageModelService()
            )
        )
}
