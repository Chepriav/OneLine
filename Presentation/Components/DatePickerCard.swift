//
//  DatePickerCard.swift
//  OneLine
//
//  Created by Carlos Hernandez Prieto on 25/2/26.
//

import Foundation
import SwiftUI

struct DatePickerCard: View {
    
    @Binding var selectedDate: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.small) {
            Text(L10n.datePickerTitle)
                .font(DSTypography.headline)
                .foregroundStyle(DSColors.textPrimary)
            
            DatePicker(L10n.datePickerLabel, selection: $selectedDate, in: ...Date(), displayedComponents: [.date])
                .datePickerStyle(.compact)
        }
    }
}
