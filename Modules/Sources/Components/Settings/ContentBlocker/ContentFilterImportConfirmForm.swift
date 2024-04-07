import ContentBlocker
import Foundation
import SwiftUI
import ThemeSystem

struct ContentFilterImportConfirmForm: View {
    enum FormState {
        case initial
        case importing
        case completedSuccessfully
        case completedWithErrors
    }

    enum RowState {
        case initial
        case succeeded
        case failed(Error)
    }

    struct RowData: Identifiable {
        var filter: ContentFilter
        var state: RowState = .initial
        var isSelected = true

        var id: String { filter.id }
    }

    let contentFilterManager: ContentFilterManager

    var onDone: () -> Void

    @State private var formState = FormState.initial

    @State private var rows: [RowData] = []

    init(
        contentFilterManager: ContentFilterManager,
        filters: [ContentFilter],
        onDone: @escaping () -> Void
    ) {
        self.contentFilterManager = contentFilterManager
        self.onDone = onDone

        _rows = State(initialValue: filters.map { RowData(filter: $0) })
    }

    var body: some View {
        List(rows.indices, id: \.self) { i in
            let row = rows[i]

            Button {
                rows[i].isSelected.toggle()

            } label: {
                HStack(alignment: .top) {
                    Group {
                        switch row.state {
                        case .initial:
                            if formState == .initial {
                                Group {
                                    if row.isSelected {
                                        Image(systemName: "checkmark.circle.fill")
                                    } else {
                                        Image(systemName: "circle")
                                    }
                                }
                                .foregroundColor(.accentColor)

                            } else if row.isSelected {
                                ProgressView()
                            } else {
                                Image(systemName: "circle")
                                    .opacity(0)
                            }

                        case .succeeded:
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(uiColor: .systemGreen))

                        case .failed:
                            Image(systemName: "xmark.circle")
                                .foregroundColor(Color(uiColor: .systemRed))
                        }
                    }
                    .frame(width: 30)

                    VStack(alignment: .leading) {
                        Text(row.filter.name)
                            .foregroundColor(.primary)

                        if case let .failed(error) = row.state {
                            Text(String("\(error)"))
                                .foregroundColor(.secondary)
                                .padding(.top, 1)
                        }
                    }
                }
            }
            .themedGroupedListContent()
        }
        .themedGroupedList()
        .navigationTitle("Select Filters")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(formState != .initial)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if formState == .initial {
                    let firstSelectedIndex = rows.firstIndex { $0.isSelected }

                    Button("Save", action: save)
                        .disabled(firstSelectedIndex == nil)

                } else if formState == .completedWithErrors {
                    Button("Done", action: onDone)
                }
            }
        }
    }

    private func save() {
        formState = .importing

        rows = rows.filter(\.isSelected)

        let filters = rows
            .map(\.filter)

        Task { @MainActor in
            let results = try! await contentFilterManager.import(filters: filters)

            for (i, result) in results.enumerated() {
                switch result {
                case .success:
                    rows[i].state = .succeeded

                case let .failure(error):
                    rows[i].state = .failed(error)
                }
            }

            if results.isEmpty {
                formState = .completedSuccessfully
            } else {
                formState = .completedWithErrors
            }
        }
    }
}

struct ContentFilterImportConfirmForm_Previews: PreviewProvider {
    struct Wrapper: View {
        @State var path = NavigationPath()

        @Environment(\.dismiss) var dismiss

        var body: some View {
            let filters = [
                ContentFilter(setting: .init(
                    name: "Filter 1"
                ), encodedContentRuleList: """
                [
                  {
                    "action": {
                      "type": "css-display-none",
                      "selector": ".testfilter1"
                    },
                    "trigger": {
                      "url-filter": ".*"
                    }
                  }
                ]
                """),
                ContentFilter(setting: .init(
                    name: "Filter 2"
                ), encodedContentRuleList: "[]"),
                ContentFilter(setting: .init(
                    name: "Filter 3"
                ), encodedContentRuleList: "[]"),
            ]

            NavigationStack(path: $path) {
                Button("Next", action: {
                    path.append(0)
                })
                .navigationTitle("Import Filters")
                .navigationDestination(for: Int.self) { _ in
                    ContentFilterImportConfirmForm(
                        contentFilterManager: PreviewUtils.contentFilterManager,
                        filters: filters,
                        onDone: { dismiss() }
                    )
                }
                .onAppear {
                    path.append(0)
                }
            }
            .colorScheme(.dark)
        }
    }

    struct Parent: View {
        @State var isPresented = false

        var body: some View {
            Button("Import") {
                isPresented = true
            }
            .onAppear {
                isPresented = true
            }
            .sheet(isPresented: $isPresented) {
                Wrapper()
            }
            .colorScheme(.dark)
        }
    }

    static var previews: some View {
        Parent()
    }
}
