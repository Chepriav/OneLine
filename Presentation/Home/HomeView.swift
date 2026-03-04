//
//  HomeView.swift
//  OneLine
//
//  Created by Carlos Hernandez Prieto on 25/2/26.
//

import Foundation
import SwiftUI

struct HomeView: View {
    
    @Bindable private var viewModel: HomeViewModel
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DSSpacing.large) {
                    
                    header
                    
                    EntryInputCard(
                        text: $viewModel.newEntryText,
                        maxLength: 280
                    )
                    
                    DatePickerCard(
                        selectedDate: $viewModel.selectedDate
                    )
                    
                    PrimaryButton(
                        L10n.buttonSave,  // ← Localizado
                        isLoading: viewModel.isLoading,
                        isEnabled: viewModel.canSave
                    ) {
                        Task {
                            await viewModel.saveEntry()
                        }
                    }
                    
                    Spacer()
                }
                .padding(DSSpacing.medium)
            }
            .navigationTitle(L10n.homeTitle)  // ← Localizado
            .navigationBarTitleDisplayMode(.large)
            .alert(L10n.commonError, isPresented: $viewModel.showError) {  // ← Localizado
                Button(L10n.commonOK, role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? L10n.errorUnknown(message: ""))
            }
            .overlay {
                if viewModel.showSuccess {
                    SuccessOverlay()
                }
            }
        }
    }
    
    private var header: some View {
        VStack(spacing: DSSpacing.small) {
            Text(L10n.homeHeader)  // ← Localizado
                .font(DSTypography.title)
                .foregroundColor(DSColors.textPrimary)
            
            Text(L10n.homeSubtitle)  // ← Localizado
                .font(DSTypography.body)
                .foregroundColor(DSColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
