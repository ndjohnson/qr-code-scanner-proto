//
//  EntryEditView.swift
//  QR-code-scanner-proto
//
//  Created by Nick Johnson on 7/20/23.
//

import SwiftUI

struct EntryEditView: View {
    @Binding var page:ActivePage
    @Binding var boatBeingEdited:Boat
    @EnvironmentObject var entry:Boats
    
    var body: some View {
        List {
            ForEach (entry.boats) { boat in
                Text("\(boat.id)").onTapGesture {
                    boatBeingEdited = boat
                    page = .editBoat
                }
            }
        }
        Button("done") { page = .home }
    }
    
    func dismissSheet() {
        
    }
}

struct EntryEditView_Previews: PreviewProvider {
    static var previews: some View {
        EntryEditView(page: .constant(.editEntry), boatBeingEdited: .constant(Boat("")))
    }
}
