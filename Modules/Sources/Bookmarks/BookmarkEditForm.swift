import Database
import SwiftUI
import Theme
import Utils

struct BookmarkEditForm: View {
    enum Field: Hashable {
        case title
        case url
    }

    var editingItem: BookmarkItem

    private let initialTitle: String
    private let initialUrlString: String
    private let initialParentFolder: BookmarkItem

    let bookmarkStore: BookmarkStore

    @State private var title: String

    @State private var urlString: String

    private var url: URL? { URL(string: urlString) }

    @State private var parentFolder: BookmarkItem

    @FocusState private var focusedField: Field?

    @Environment(\.nfl_dismiss) private var dismiss

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
        if title != initialTitle {
            return true
        } else if parentFolder.id != initialParentFolder.id {
            return true
        } else if editingItem.isBookmark && urlString != initialUrlString {
            return true
        }
        return false
    }

    private var formTitle: String {
        switch editingItem.kind {
        case .bookmark:
            if editingItem.localizedTitle.isEmpty {
                return String(localized: "New Bookmark")
            } else {
                return String(localized: "Edit Bookmark")
            }

        case .folder:
            if editingItem.localizedTitle.isEmpty {
                return String(localized: "New Folder")
            } else {
                return String(localized: "Edit Folder")
            }
        }
    }

    init(
        editingItem: BookmarkItem,
        bookmarkStore: BookmarkStore
    ) {
        self.editingItem = editingItem
        self.bookmarkStore = bookmarkStore
        initialTitle = editingItem.localizedTitle
        initialUrlString = editingItem.url?.absoluteString ?? ""
        // TODO: remember lastOpenedFolder
        initialParentFolder = editingItem.parent
            ?? bookmarkStore.favoritesFolder

        _title = State(initialValue: initialTitle)
        _urlString = State(initialValue: initialUrlString)
        _parentFolder = State(initialValue: initialParentFolder)
    }

    private func backgroundFor(field: Field) -> Color {
//        return Colors.formFieldBackground.swiftUIColor
        if field == focusedField {
            return Colors.formFieldBackgroundFocused.swiftUIColor
        }
        return Colors.formFieldBackground.swiftUIColor
    }

    var body: some View {
        Form {
            Section {
                MultilineTextField("Title", text: $title)
                    .focused($focusedField, equals: .title)
                    .listRowBackground(backgroundFor(field: .title))
                    .submitLabel(.return)

                if editingItem.isBookmark {
                    MultilineTextField("URL", text: $urlString)
                        .listRowBackground(backgroundFor(field: .url))
                        .focused($focusedField, equals: .url)
                        .keyboardType(.URL)
                        .submitLabel(.return)
                }
            }

            Section("Location") {
                NavigationLink(destination: {
                    BookmarkFolderChooser(
                        selectedFolder: parentFolder,
                        excludedFolderIDs: [editingItem.id],
                        bookmarkStore: bookmarkStore,
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

        try bookmarkStore.bookmarksFolder.realm!.write {
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

struct BookmarkItemEditForm_Previews: PreviewProvider {
    static var previews: some View {
        let item = BookmarkItem()

        NavigationStack {
            BookmarkEditForm(
                editingItem: item,
                bookmarkStore: PreviewUtils.bookmarkStore
            )
            .environment(\.nfl_dismiss) {}
        }
    }
}
