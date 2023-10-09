import Database
import SwiftUI
import Theme

struct BookmarkListItem: View {
    var item: BookmarkItem

    var depth: Int = 0

    var checked = false

    var body: some View {
        HStack {
            let symbolFont = Font.body.weight(.light)

            Group {
                if item.isFolder {
                    if item.id == .favorites {
                        Image(systemName: "star")
                            .font(symbolFont)
                    } else {
                        Image(systemName: "folder")
                            .font(symbolFont)
                    }
                } else {
                    Image(systemName: "book")
                        .font(symbolFont)
                }
            }
            .padding(.trailing, 5)

            if item.isFolder {
                Text(item.localizedTitle)
                    .lineLimit(1)
            } else {
                VStack(alignment: .leading) {
                    Text(item.localizedTitle)
                        .lineLimit(1)

                    Text(item.url?.absoluteString ?? "")
                        .lineLimit(1)
                        .foregroundColor(Colors.textNormal.swiftUIColor.opacity(0.7))
                        .font(.system(size: 13))
                }
            }

            if checked {
                Spacer()
                Image(systemName: "checkmark")
                    .tint(.accentColor)
            }
        }
        .padding(EdgeInsets(
            top: 2,
            leading: CGFloat(depth) * 15,
            bottom: 2,
            trailing: 0
        ))
    }
}
