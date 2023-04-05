import Database
import Foundation
import RealmSwift
import SwiftUI
import Theme

struct BookmarkList: View {
    private class ItemEditingState: ObservableObject {
        // Must be settable externally
        @Published var isEditing = false
        private(set) var item: BookmarkItem?

        func edit(item: BookmarkItem) {
            self.item = item
            isEditing = true
        }

        func done() {
            isEditing = false
            item = nil
        }
    }

    @StateObject private var itemEditingState = ItemEditingState()

    @State private var editMode: EditMode = .inactive

    var bookmarkManager: BookmarkManager

    @ObservedRealmObject var folder: BookmarkItem

    var onOpen: (BookmarkItem) -> Void

    @State var isPresentedNewFolderForm = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        SwiftUI.List {
            if folder.id == .bookmarks {
                NavigationLink(destination: {
                    BookmarkList(
                        bookmarkManager: bookmarkManager,
                        folder: bookmarkManager.favoritesFolder,
                        onOpen: onOpen
                    )
                }) {
                    BookmarkListItem(item: bookmarkManager.favoritesFolder)
                }
                .listRowBackground(Colors.backgroundDark.swiftUIColor)
            }

            if folder.children.isEmpty {
                Text("No Bookmarks")
                    .listRowBackground(Colors.background.swiftUIColor)
            }

            ForEach(folder.children) { (item: BookmarkItem) in
                HStack {
                    if editMode == .active {
                        Button(action: {
                            itemEditingState.edit(item: item)
                        }) {
                            BookmarkListItem(item: item)
                        }

                    } else {
                        if item.isFolder {
                            NavigationLink(destination: {
                                BookmarkList(
                                    bookmarkManager: bookmarkManager,
                                    folder: item,
                                    onOpen: onOpen
                                )
                            }) {
                                BookmarkListItem(item: item)
                            }
                        } else {
                            Button(action: {
                                onOpen(item)
                                dismiss()
                            }) {
                                BookmarkListItem(item: item)
                            }
                        }
                    }
                }
                .contextMenu {
                    buildContextMenu(item: item)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            }
            .onDelete(perform: $folder.children.remove)
            .onMove(perform: $folder.children.move)
            .listRowBackground(Colors.backgroundDark.swiftUIColor)
        }
        .themedNavigationBar()
        .listStyle(.plain)
        .listRowBackground(Colors.backgroundDark.swiftUIColor)
        .background(Colors.backgroundDark.swiftUIColor)
        .foregroundColor(Colors.textNormal.swiftUIColor)
        .navigationTitle(folder.localizedTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if editMode != .active {
                    Button("Done", action: {
                        dismiss()
                    })
                }
            }

            ToolbarItem(placement: .bottomBar) {
                Button("New Folder", action: {
                    isPresentedNewFolderForm.toggle()
                })
                .sheet(isPresented: $isPresentedNewFolderForm) {
                    NavigationView {
                        BookmarkItemEditForm(
                            bookmarkManager: bookmarkManager,
                            editingItem: {
                                let folder = BookmarkItem()
                                folder.kind = .folder
                                return folder
                            }()
                        )
                    }
                }
            }

            ToolbarItem(placement: .bottomBar) {
                // Do not use EditButton
                // Because EditButton does not work after closing edit modal.
                if editMode == .active {
                    Button("Done", action: {
                        withAnimation {
                            editMode = .inactive
                        }
                    })
                } else {
                    Button("Edit", action: {
                        withAnimation {
                            editMode = .active
                        }
                    })
                }
            }
        }
        .tint(Color(Colors.tint.color))
        .environment(\.editMode, $editMode)
        .sheet(isPresented: $itemEditingState.isEditing) {
            NavigationView {
                BookmarkItemEditForm(
                    bookmarkManager: bookmarkManager,
                    editingItem: itemEditingState.item!
                )
            }
        }
    }

    @ViewBuilder
    private func buildContextMenu(item: BookmarkItem) -> some View {
        Button(action: {
            onOpen(item)
            dismiss()
        }) {
            HStack {
                Text("Open in New Tab")
                Image(systemName: "plus.square.on.square")
            }
        }

        Divider()

        Button(action: {
            itemEditingState.edit(item: item)
        }) {
            HStack {
                Text("Edit")
                Image(systemName: "square.and.pencil")
            }
        }

        Button(role: .destructive, action: {
            if let index = folder.children.firstIndex(where: { $0.id == item.id }) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        $folder.children.remove(at: index)
                    }
                }
            }
        }) {
            HStack {
                Text("Delete")
                Image(systemName: "trash")
            }
        }
    }
}
