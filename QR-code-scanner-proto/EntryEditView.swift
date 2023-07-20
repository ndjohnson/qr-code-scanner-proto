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
    
    var body: some View {
        List {
            ForEach (entry.boats) { boat in
                Text("\(boat.id)").onTapGesture {
                    showEditSheet = true
                    boatBeingEdited = boat.id
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            TextField("Boat id", text: $boatBeingEdited)
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
