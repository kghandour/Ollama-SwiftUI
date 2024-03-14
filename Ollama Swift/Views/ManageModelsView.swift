//
//  ManageModelsView.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 14.10.23.
//

import SwiftUI

struct ManageModelsView: View {
    @StateObject var manageModelsController = ManageModelsController()

    var body: some View {
        VStack(alignment: .leading){
            Text("Local Models:")
                .font(.headline)
            if(manageModelsController.tags?.models.count == 0){
                HStack{
                    Label("Error", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                    Text("No models downloaded locally. Add a model by typing the name in the field at the bottom of the page.")
                }
            }
            List(manageModelsController.tags?.models ?? [], id: \.self){ model in
                HStack{
                    VStack(alignment: .leading){
                        Text(model.name)
                        Text("\(model.size / 1024 / 1024 / 1024, specifier: "%.3f") GB")
                    }
                    Spacer()
                    
                    Button{
                        manageModelsController.removeModel()
                    }label: {
                        Image(systemName: "trash")
                            .frame(width: 20, height: 20, alignment: .center)
                    }
                }
            }
            
            HStack{
                Text("Duplicate Model:")
                        .font(.headline)
                Picker("Duplicate Model:", selection: $manageModelsController.toDuplicate) {
                    ForEach(manageModelsController.tags?.models ?? [], id: \.self) {model in
                        Text(model.name).tag(model.name)
                    }
                }
                TextField("New Name", text: $manageModelsController.newName)
                    .textFieldStyle(.roundedBorder)
                Button{
                    manageModelsController.duplicateModel()
                }label: {
                    Image(systemName: "doc.on.doc")
                        .frame(width: 20, height: 20, alignment: .center)
                }
            }
            Spacer()
            HStack{
                Text("Add Model:")
                    .font(.headline)
                TextField("Add model:", text: $manageModelsController.modelName)
                    .textFieldStyle(.roundedBorder)
                Button{
                    manageModelsController.downloadModel()
                }label: {
                    Image(systemName: "arrowshape.down.fill")
                        .frame(width: 20, height: 20, alignment: .center)
                }
            }
            if(manageModelsController.showProgress){
                HStack{
                    Text("Downloading \(manageModelsController.modelName)")
                    ProgressView(value: manageModelsController.completedSoFar, total: manageModelsController.totalSize)
                    Text("\(Int(manageModelsController.completedSoFar / 1024 / 1024 ))/ \(Int(manageModelsController.totalSize / 1024 / 1024)) MB")
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
            manageModelsController.getTags()
        }
        .toolbar{
            HStack{
                if(manageModelsController.errorModel.showError){
                        Button {
                            manageModelsController.showingErrorPopover.toggle()
                        } label: {
                            Label("Error", systemImage: "exclamationmark.triangle")
                                .foregroundStyle(.red)
                        }
                        .popover(isPresented: $manageModelsController.showingErrorPopover) {
                            VStack(alignment: .leading) {
                                Text(manageModelsController.errorModel.errorTitle)
                                    .font(.title2)
                                    .textSelection(.enabled)
                                Text(manageModelsController.errorModel.errorMessage)
                                    .textSelection(.enabled)
                            }
                            .padding()
                        }
                }else{
                    Text("Server:")
                    Label("Connected", systemImage: "circle.fill")
                        .foregroundStyle(.green)
                }
                Button{
                    manageModelsController.getTags()
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
}
