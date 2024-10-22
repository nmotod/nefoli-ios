import Database
import SwiftUI
import ThemeSystem

struct BookmarkEditForm: View {
    enum Field: Hashable {
        case title
        case url
    }

    var editingItem: BookmarkItem

    let bookmarkStore: BookmarkStore

    var onDismiss: () -> Void

    private let initialTitle: String
    private let initialUrlString: String
    private let initialParentFolder: BookmarkItem

    @State private var title: String

    @State private var urlString: String

    private var url: URL? { URL(string: urlString) }

    @State private var parentFolder: BookmarkItem

    @FocusState private var focusedField: Field?

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
        bookmarkStore: BookmarkStore,
        onDismiss: @escaping () -> Void
    ) {
        self.editingItem = editingItem
        self.bookmarkStore = bookmarkStore
        self.onDismiss = onDismiss

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
            return ThemeColors.formFieldBackgroundFocused.swiftUIColor
        }
        return ThemeColors.formFieldBackground.swiftUIColor
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
            .listRowBackground(ThemeColors.formFieldBackground.swiftUIColor)

            Section {
                Button(action: {
                    try! saveAndDone()
                }) {
                    Text("Done")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(Font.system(.body).bold())
                }
            }
            .listRowBackground(ThemeColors.formFieldBackground.swiftUIColor)
        }
        .themedGroupedList()
        .themedNavigationBar()
        .navigationTitle(formTitle)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: {
                    onDismiss()
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

        onDismiss()
    }
}

struct BookmarkItemEditForm_Previews: PreviewProvider {
    static var previews: some View {
        let item = BookmarkItem()

        NavigationStack {
            BookmarkEditForm(
                editingItem: item,
                bookmarkStore: PreviewUtils.bookmarkStore,
                onDismiss: {}
            )
        }
    }
}
