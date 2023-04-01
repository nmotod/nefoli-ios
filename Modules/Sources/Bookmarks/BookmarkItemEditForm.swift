import Database
import SwiftUI
import Theme

public struct BookmarkItemEditForm: View {
    enum Field: Hashable {
        case title
        case url
    }

    let bookmarkManager: BookmarkManager

    var editingItem: BookmarkItem

    @State private var title: String

    @State private var urlString: String

    private var url: URL? { URL(string: urlString) }

    @State private var parentFolder: BookmarkItem

    @FocusState private var focusedField: Field?

    @Environment(\.dismiss) private var dismiss

    private var canSubmit: Bool {
        if title.isEmpty {
            return false
        }

        switch editingItem.kind {
        case .folder:
            return true

        case .bookmark:
            guard let url = URL(string: urlString) else {
                return false
            }

            return url == url.standardized
        }
    }

    private var isChanged: Bool {
        return title != editingItem.title
            || parentFolder.id != editingItem.parent?.id
            || (editingItem.isBookmark && url != editingItem.url)
    }

    private var formTitle: String {
        switch editingItem.kind {
        case .bookmark:
            if editingItem.localizedTitle.isEmpty {
                return "New Bookmark"
            } else {
                return "Edit Bookmark"
            }

        case .folder:
            if editingItem.localizedTitle.isEmpty {
                return "New Folder"
            } else {
                return "Edit Folder"
            }
        }
    }

    init(
        bookmarkManager: BookmarkManager,
        editingItem: BookmarkItem
    ) {
        self.bookmarkManager = bookmarkManager
        self.editingItem = editingItem

        // For some reason, when using @Environment(\.dismiss), State must be explicitly initialized.
        _title = State(initialValue: editingItem.localizedTitle)
        _urlString = State(initialValue: editingItem.url?.absoluteString ?? "")
        _parentFolder = State(initialValue: editingItem.parent
            // ?? bookmarkManager.lastOpenedFolder
            ?? bookmarkManager.favoritesFolder)
    }

    private func backgroundFor(field: Field) -> Color {
//        return Colors.formFieldBackground.swiftUIColor
        if field == focusedField {
            return Colors.formFieldBackgroundFocused.swiftUIColor
        }
        return Colors.formFieldBackground.swiftUIColor
    }

    public var body: some View {
        Form {
            Section("Title") {
                TextField("Title", text: $title)
                    // .submitLabel(.done)
                    // .onSubmit {
                    //     try! saveAndDone()
                    // }
                    .focused($focusedField, equals: .title)
                    .listRowBackground(backgroundFor(field: .title))
            }

            if editingItem.isBookmark {
                Section("URL") {
                    TextEditor(text: Binding(
                        get: { urlString },
                        set: { newValue in
                            if newValue.contains("\n") {
                                urlString = newValue.replacingOccurrences(of: "\n", with: "")
                            } else {
                                urlString = newValue
                            }
                        }
                    ))
                    .submitLabel(.done)
                    .keyboardType(.URL)
                    .focused($focusedField, equals: .url)
                    .listRowBackground(backgroundFor(field: .url))
                }
            }

            Section("Location") {
                NavigationLink(destination: {
                    BookmarkFolderChooser(
                        bookmarkManager: bookmarkManager,
                        selectedFolder: parentFolder,
                        excludedFolderIDs: [editingItem.id],
                        onSelect: {
                            selectedFolder in

                            parentFolder = selectedFolder
                        }
                    )
                }) {
                    HStack {
                        Image(systemName: "folder")
                        Text(parentFolder.localizedTitle)
                    }
                }
            }
            .listRowBackground(Colors.formFieldBackground.swiftUIColor)

            Section {
                Button(action: {
                    try! saveAndDone()
                }) {
                    Text("Done")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(Font.system(.body).bold())
                }
            }
            .listRowBackground(Colors.formFieldBackground.swiftUIColor)
        }
        .themedGroupedList()
        .themedNavigationBar()
        .navigationTitle(formTitle)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: {
                    dismiss()
                })
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Done", action: {
                    try! saveAndDone()
                })
                .disabled(!canSubmit)
            }
        }
        .interactiveDismissDisabled(isChanged)
//        .introspectTableView { tableView in
//            tableView.backgroundColor = Colors.background.color
//        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                focusedField = .title
            }
        }
    }

    private func saveAndDone() throws {
        if !canSubmit {
            return
        }

        try bookmarkManager.bookmarksFolder.realm!.write {
            let editingItem: BookmarkItem

            if self.editingItem.isFrozen {
                editingItem = self.editingItem.thaw()!
            } else {
                editingItem = self.editingItem
            }

            editingItem.title = title

            if editingItem.isBookmark {
                editingItem.url = url
            }

            if let currentParent = editingItem.parent {
                if currentParent.id != parentFolder.id {
                    if let index = currentParent.children.firstIndex(of: editingItem) {
                        currentParent.children.remove(at: index)
                    }

                    parentFolder.children.append(editingItem)
                }
            } else {
                parentFolder.children.append(editingItem)
            }
        }

        dismiss()
    }
}
