import Foundation
import NFLContentBlocker
import NFLDatabase
import NFLThemeSystem
import SwiftUI

struct ContentFilterImportModal: View {
    enum FormState {
        case initial
        case downloading
        case error(Error)

        var isDownloading: Bool {
            if case .downloading = self {
                return true
            }
            return false
        }
    }

    @Environment(\.dismiss) private var dismiss

    let contentFilterManager: ContentFilterManager

    @State var inputURLString: String = ""

    @State private var path = NavigationPath()

    @State private var formState = FormState.initial

    @FocusState private var urlFieldIsFocused: Bool

    var body: some View {
        NavigationStack(path: $path) {
            Form {
                Section {
                    let urlField = TextField("URL", text: $inputURLString)
                        .disabled(formState.isDownloading)
                        .focused($urlFieldIsFocused)

                    if case .error = formState {
                        urlField.listRowBackground(Color.red.opacity(0.2))
                    } else {
                        urlField
                    }

                } header: {
                    Text("URL")
                } footer: {
                    if case let .error(error) = formState {
                        Text(error.localizedDescription)
                    }
                }
                .themedGroupedListContent()
            }
            .themedGroupedList()
            .navigationTitle("Import Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    if case .downloading = formState {
                        ProgressView()

                    } else {
                        let url = URL(string: inputURLString)

                        Button("Next", action: {
                            if let url {
                                download(url: url)
                            }
                        })
                        .fontWeight(.bold)
                        .disabled(url == nil)
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: { dismiss() })
                }
            }
            .navigationDestination(for: [ContentFilter].self) { filters in

                ContentFilterImportConfirmForm(
                    contentFilterManager: contentFilterManager,
                    filters: filters,
                    onDone: {
                        dismiss()
                    }
                )
            }
            .onAppear {
                urlFieldIsFocused = true
            }
        }
        .preferredColorScheme(.dark)
    }

    private func download(url: URL) {
        formState = .downloading

        Task { @MainActor in
            do {
                let filter = try await ContentFilterDownloader().download(url: url)

                formState = .initial

                path.append(filter)

            } catch {
                formState = .error(error)
            }
        }
    }
}

struct ContentFilterImportModal_Previews: PreviewProvider {
    static var previews: some View {
        ContentFilterImportModal(
            contentFilterManager: PreviewUtils.contentFilterManager,
            inputURLString: "http://localhost:5000/filters/valid.1blockpkg"
        )
        .previewDisplayName("Valid")

        ContentFilterImportModal(
            contentFilterManager: PreviewUtils.contentFilterManager,
            inputURLString: "http://localhost:5000/filters/notfound.1blockpkg"
        )
        .previewDisplayName("Not found")

        ContentFilterImportModal(
            contentFilterManager: PreviewUtils.contentFilterManager,
            inputURLString: "http://localhost:5000/filters/notfound.1blockpkg"
        )
        .previewDisplayName("Empty rules")
    }
}
