import SwiftUI
import SwiftData

struct HomeView: View {
    
    @State private var viewModel: HomeViewModel
    @Environment(\.modelContext) private var modelContext  // ← NUEVO
    
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
                        L10n.buttonSave,
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
            .navigationTitle(L10n.homeTitle)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        EntryListView(viewModel: makeEntryListViewModel())
                    } label: {
                        Image(systemName: "list.bullet")
                    }
                }
            }
            .alert(L10n.commonError, isPresented: $viewModel.showError) {
                Button(L10n.commonOK, role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "")
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
            Text(L10n.homeHeader)
                .font(DSTypography.title)
                .foregroundColor(DSColors.textPrimary)
            
            Text(L10n.homeSubtitle)
                .font(DSTypography.body)
                .foregroundColor(DSColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Factory Methods
    
    @MainActor
    private func makeEntryListViewModel() -> EntryListViewModel {
        let dataSource = LocalSwiftDataSource(modelContext: modelContext)  // ← Usa @Environment
        let repository = DayEntryRepositoryImpl(dataSource: dataSource)
        
        let fetchUseCase = FetchAllEntriesUseCase(repository: repository)
        let deleteUseCase = DeleteDayEntryUseCase(repository: repository)
        
        return EntryListViewModel(
            fetchUseCase: fetchUseCase,
            deleteUseCase: deleteUseCase
        )
    }
}
