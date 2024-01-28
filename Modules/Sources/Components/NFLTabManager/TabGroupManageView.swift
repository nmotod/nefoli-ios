import Foundation
import NFLDatabase
import NFLThemeSystem
import SwiftUI

extension Tab: Identifiable {}

struct TabGroupManageView: View {
    @ObservedRealmObject var group: TabGroup

    var body: some View {
        NavigationView {
            List {
                ForEach(group.children) { _ in
                }
                .onMove { _, _ in
                }
            }

            List(group.children) { tab in
                HStack(alignment: .center) {
                    Button(action: {
                        print("Select!!!!!!")
                    }) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(tab.current?.title ?? "no title")
                                .lineLimit(1)
                                .font(Font.system(size: 16, weight: .medium))

                            Text(tab.current?.url?.absoluteString ?? "")
                                .lineLimit(1)
                                .font(Font.system(size: 14))
                                .foregroundColor(Color.gray)
                        }
                    }
                    .buttonStyle(.borderless)

                    Spacer()

                    Button(action: {
                        print("Close!!!!!!!")
                    }) {
                        Image(systemName: "xmark")
                            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
                    }
                    .buttonStyle(.borderless)
                    .frame(maxHeight: .infinity)
                }
                .themedGroupedListContent()
            }
//            .listStyle(.plain)
            .navigationBarTitle("Tabs")
            .themedNavigationBar()
            .themedGroupedList()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: {})
                }
            }
        }
    }
}

struct TabGroupManageView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TabGroupManageView(group: PreviewUtils.group)
        }
        .previewLayout(.device)
    }
}
