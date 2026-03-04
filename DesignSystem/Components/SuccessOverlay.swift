//
//  SuccessOverlay.swift
//  OneLine
//
//  Created by Carlos Hernandez Prieto on 25/2/26.
//

import Foundation
import SwiftUI

struct SuccessOverlay: View {
    
    let message: String
    
    init(_ message: String? = nil) {
        self.message = message ?? L10n.successSaved  // ← Default localizado
    }
    
    var body: some View {
        VStack(spacing: DSSpacing.medium) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text(message)
                .font(DSTypography.title)
                .foregroundColor(DSColors.textPrimary)
        }
        .padding(DSSpacing.extraLarge)
        .background(DSColors.background.opacity(0.95))
        .cornerRadius(16)
        .shadow(radius: 10)
        .transition(.scale.combined(with: .opacity))
    }
}
