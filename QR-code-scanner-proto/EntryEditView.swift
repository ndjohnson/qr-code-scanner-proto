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
    @State var boatBeingEdited:Boat = Boat("")
    
    var body: some View {
        List {
            ForEach (entry.boats) { boat in
                Text("\(boat.id)").onTapGesture {
                    boatBeingEdited = boat
                    showEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            HStack {
                Spacer()
                Text("Boat: \(boatBeingEdited.id) ")
                TextField("Crew: ", text: $boatBeingEdited.crew, prompt: Text("Crew: "))
                    .onSubmit { entry.boat(forId: boatBeingEdited.id)?.crew = boatBeingEdited.crew }
                TextField("Club: ", text: $boatBeingEdited.club, prompt: Text("Club: "))
                    .onSubmit { entry.boat(forId: boatBeingEdited.id)?.club = boatBeingEdited.club }
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
