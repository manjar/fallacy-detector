//
//  ListCell.swift
//  FallacyDetectorNonVibe
//
//  Created by Eli Manjarrez on 4/25/25.
//

import SwiftUI

struct ListCell: View {
    let item: Item
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(item.inputText)
                .lineLimit(1)
                .truncationMode(.tail)
            Text(item.timestamp.formatted(date: .abbreviated, time: .standard))
                .font(.caption)
        }
        .padding()
    }
}

#Preview {
    ListCell(item: Item(timestamp: Date(), inputText: "Hello World"))
}
