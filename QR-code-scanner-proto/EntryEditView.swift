//
//  EntryEditView.swift
//  QR-code-scanner-proto
//
//  Created by Nick Johnson on 7/20/23.
//

import SwiftUI

struct EntryEditView: View {
    @Binding var page:ActivePage
    @EnvironmentObject var entry:Boats
    @State var showEditSheet = false
    @State var boatBeingEdited:String = ""
    @State var crew:String = ""
    @State var club:String = ""
    
    var body: some View {
        List {
            ForEach (entry.boats) { boat in
                Text("\(boat.id)").onTapGesture {
                    boatBeingEdited = boat.id
                    crew = boat.crew ?? ""
                    club = boat.club ?? ""
                    showEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            HStack {
                Spacer()
                Text("Boat: \(boatBeingEdited) ")
                TextField("Crew: ", text: $crew, prompt: Text("Crew: "))
                    .onSubmit { entry.update(forId: boatBeingEdited, crew: crew, club: club)}
                TextField("Club: ", text: $club, prompt: Text("Club: "))
                    .onSubmit { entry.update(forId: boatBeingEdited, crew: crew, club: club)}
                Spacer()
            }
            Button("Done") { showEditSheet = false }
            //else
            //{
            //    showEditSheet = false
            //}
        }
        Button("done") { page = .home }
    }
}

struct EntryEditView_Previews: PreviewProvider {
    static var previews: some View {
        EntryEditView(page: .constant(.editEntry))
    }
}
