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
            List(viewModel.tags?.models ?? [], id: \.self){ model in
                HStack{
                    VStack(alignment: .leading){
                        Text(model.name)
                        Text("\(model.size / 1024 / 1024 / 1024, specifier: "%.3f") GB")
                    }
                    Spacer()
                    
                    Button{
                        viewModel.removeModel(name: model.name)
                    }label: {
                        Image(systemName: "trash")
                            .frame(width: 20, height: 20, alignment: .center)
                    }
                }
            }
            
            HStack{
                Text("Duplicate Model:")
                        .font(.headline)
                Picker("Duplicate Model:", selection: $viewModel.toDuplicate) {
                    ForEach(viewModel.tags?.models ?? [], id: \.self) {model in
                        Text(model.name).tag(model.name)
                    }
                }
                TextField("New Name", text: $viewModel.newName)
                    .textFieldStyle(.roundedBorder)
                Button{
                    viewModel.duplicateModel(source: viewModel.toDuplicate, destination: viewModel.newName)
                }label: {
                    Image(systemName: "doc.on.doc")
                        .frame(width: 20, height: 20, alignment: .center)
                }
            }
            Spacer()
            HStack{
                Text("Add Model:")
                TextField("Add model:", text: $viewModel.modelName)
                    .textFieldStyle(.roundedBorder)
                Button{
                    viewModel.downloadModel(name: viewModel.modelName)
                }label: {
                    Image(systemName: "arrowshape.down.fill")
                        .frame(width: 20, height: 20, alignment: .center)
                }
            }
            if(viewModel.showProgress){
                HStack{
                    Text("Downloading \(viewModel.modelName)")
                    ProgressView(value: viewModel.completedSoFar, total: viewModel.totalSize)
                    Text("\(Int(viewModel.completedSoFar / 1024 / 1024 ))/ \(Int(viewModel.totalSize / 1024 / 1024)) MB")
                }
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

#Preview {
    ManageModelsView()
        .environmentObject(
            ManageModelsViewModel(
                chatService: ChatService(),
                manageModelService: ManageModelService()
            )
        )
}
