//
//  EntryListView.swift
//  OneLine
//
//  Created by Carlos Hernandez Prieto on 4/3/26.
//

import SwiftUI

struct EntryListView: View {
    
    @State private var viewModel: EntryListViewModel
    @State private var entryToDelete: DayEntry?
    
    init(viewModel: EntryListViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.entries.isEmpty {
                emptyView
            } else {
                entriesList
            }
        }
        .navigationTitle(L10n.entryListTitle)
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadEntries()
        }
        .alert(L10n.commonError, isPresented: $viewModel.showError) {
            Button(L10n.commonOK, role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .confirmationDialog(
            L10n.entryListDeleteConfirmation,
            isPresented: Binding(
                get: { entryToDelete != nil },
                set: { if !$0 { entryToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button(L10n.commonDelete, role: .destructive) {
                if let entry = entryToDelete {
                    Task {
                        await viewModel.delete(entry)
                    }
                    entryToDelete = nil
                }
            }
            Button(L10n.commonCancel, role: .cancel) {
                entryToDelete = nil
            }
        }
    }
    
    // MARK: - Subviews
    
    private var emptyView: some View {
        VStack(spacing: DSSpacing.medium) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(DSColors.textSecondary)
            
            Text(L10n.entryListEmpty)
                .font(DSTypography.title)
                .foregroundColor(DSColors.textPrimary)
            
            Text(L10n.entryListEmptySubtitle)
                .font(DSTypography.body)
                .foregroundColor(DSColors.textSecondary)
        }
        .padding(DSSpacing.extraLarge)
    }
    
    private var entriesList: some View {
        List {
            ForEach(viewModel.entries, id: \.id) { entry in
                EntryRow(entry: entry)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            entryToDelete = entry
                        } label: {
                            Label(L10n.commonDelete, systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.plain)
    }
}

// MARK: - Entry Row

struct EntryRow: View {
    let entry: DayEntry
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.small) {
            Text(entry.text)
                .font(DSTypography.body)
                .foregroundColor(DSColors.textPrimary)
                .lineLimit(isExpanded ? nil : 2)
                .animation(.easeInOut(duration: 0.2), value: isExpanded)

            HStack {
                Text(entry.createdAt, style: .date)
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.textSecondary)

                Spacer()

                if !isExpanded && entry.text.count > 80 {
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(DSColors.textSecondary)
                } else if isExpanded {
                    Image(systemName: "chevron.up")
                        .font(.caption)
                        .foregroundColor(DSColors.textSecondary)
                }
            }
        }
        .padding(.vertical, DSSpacing.extraSmall)
        .contentShape(Rectangle())
        .onTapGesture {
            isExpanded.toggle()
        }
    }
}
