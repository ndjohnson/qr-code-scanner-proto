//
//  BoatEditView.swift
//  QR-code-scanner-proto
//
//  Created by Nick Johnson on 7/23/23.
//

import SwiftUI

struct BoatEditView: View {
    @Binding var page:ActivePage
    @Binding var boatBeingEdited:Boat
    @EnvironmentObject var entry:Boats

    var body: some View {
        VStack {
            Text("Boat: \(boatBeingEdited.id)")
            TextField("Club: ", text: $boatBeingEdited.club)
            TextField("Crew: ", text: $boatBeingEdited.crew)
        }
        Button("Done") { page = .editEntry }
    }
}

struct BoatEditView_Previews: PreviewProvider {
    static var previews: some View {
        BoatEditView(page: .constant(.editBoat), boatBeingEdited: .constant(Boat("")))
    }
}
