//
//  PrimaryButton.swift
//  OneLine
//
//  Created by Carlos Hernandez Prieto on 25/2/26.
//

import Foundation
import SwiftUI

struct PrimaryButton: View {
    
    let title: String
    let isLoading: Bool
    let isEnabled: Bool
    let action: () -> Void
    
    init(
        _ title: String,
        isLoading: Bool = false,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(title)
                        .font(DSTypography.headline)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(DSSpacing.medium)
            .background(isEnabled ? DSColors.accent : DSColors.accent.opacity(0.5))
            .cornerRadius(12)
        }
        .disabled(!isEnabled || isLoading)
    }
}
