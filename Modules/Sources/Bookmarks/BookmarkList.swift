import Database
import Foundation
import RealmSwift
import SwiftUI
import Theme
import Utils

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

    @ObservedRealmObject var folder: BookmarkItem

    let bookmarkStore: BookmarkStore

    var onOpen: (BookmarkItem) -> Void

    @StateObject private var itemEditingState = ItemEditingState()

    @State private var editMode: EditMode = .inactive

    @Environment(\.nfl_dismiss) var dismiss

    @State var isPresentedNewFolderForm = false

    var body: some View {
        SwiftUI.List {
            if folder.id == .bookmarks {
                NavigationLink(value: bookmarkStore.favoritesFolder) {
                    BookmarkListItem(item: bookmarkStore.favoritesFolder)
                }
                .listRowBackground(Colors.backgroundDark.swiftUIColor)

            } else if folder.children.isEmpty {
                Text("No Bookmarks")
                    .opacity(0.5)
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 20)
                    .listRowBackground(Colors.backgroundDark.swiftUIColor)
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
                            NavigationLink(value: item) {
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
                        BookmarkEditForm(
                            editingItem: {
                                let folder = BookmarkItem()
                                folder.kind = .folder
                                return folder
                            }(),
                            bookmarkStore: bookmarkStore,
                            onDismiss: {
                                isPresentedNewFolderForm = false
                            }
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
                BookmarkEditForm(
                    editingItem: itemEditingState.item!,
                    bookmarkStore: bookmarkStore,
                    onDismiss: {
                        itemEditingState.done()
                    }
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
