//
//  EntryInputCard.swift
//  OneLine
//
//  Created by Carlos Hernandez Prieto on 24/2/26.
//

import Foundation
import SwiftUI

///Component: Card for input of text with counter.

struct EntryInputCard: View {
    
    @Binding var text: String
    let maxLength: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.small) {
            Text(L10n.entryInputTitle)
                .font(DSTypography.headline)
                .foregroundStyle(DSColors.textPrimary)
            
            TextField(L10n.entryInputPlaceholder, text: $text, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .font(DSTypography.body)
            
            HStack {
                Text("\(text.count)/\(maxLength)")
                    .font(DSTypography.caption)
                    .foregroundStyle(text.count > maxLength ? .red : DSColors.textSecondary)
                
                Spacer()
            }
            
        }
    }
}
