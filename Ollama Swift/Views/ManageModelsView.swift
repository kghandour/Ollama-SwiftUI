//
//  ManageModelsView.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 14.10.23.
//

import SwiftUI

struct ManageModelsView: View {
    @State private var tags: tagsParent?
    @State private var errorModel: ErrorModel = ErrorModel(showError: false, errorTitle: "", errorMessage: "")

    var body: some View {
        VStack(alignment: .leading){
            Text("Models: ")
            List(tags?.models ?? [], id: \.self){ model in
                HStack{
                    Text(model.name)
                    Spacer()
                    Text("\(model.size / 1024 / 1024) MB")
                    Spacer()

                    Button{
                        removeModel(name: model.name)
                    }label: {
                        Image(systemName: "trash")
                            .frame(width: 20, height: 30, alignment: .center)
                    }
                }            }
            .frame(height: 150)
        }
        .padding()
        .frame(minWidth: 400, idealWidth: 700, minHeight: 600, idealHeight: 800)
        .task {
            getTags()
        }
    }
    func getTags(){
        Task{
            do{
                tags = try await getLocalModels()
            } catch NetError.invalidURL (let error){
                errorModel = invalidURLError(error: error)
            } catch NetError.invalidData (let error){
                errorModel = invalidDataError(error: error)
            } catch NetError.invalidResponse (let error){
                errorModel = invalidResponseError(error: error)
            } catch NetError.unreachable (let error){
                errorModel = unreachableError(error: error)
            } catch {
                errorModel = genericError(error: error)
            }
        }
    }
    
    func removeModel(name: String){
        print(name)
    }
}

#Preview {
    ManageModelsView()
}
