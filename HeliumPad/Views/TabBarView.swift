import SwiftUI

struct TabBarView: View {
    @Binding var tabs: [Tab]
    @Binding var activeTabID: Tab.ID?
    var onNewTab: () -> Void
    var onClose: (Tab) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(tabs) { tab in
                    TabChip(
                        tab: tab,
                        isActive: tab.id == activeTabID,
                        onSelect: { activeTabID = tab.id },
                        onClose: { onClose(tab) }
                    )
                }

                Button(action: onNewTab) {
                    Image(systemName: "plus")
                        .frame(width: 32, height: 32)
                }
                .padding(.leading, 4)
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)
        }
        .frame(height: 44)
        .background(.bar)
    }
}

private struct TabChip: View {
    @ObservedObject var tab: Tab
    let isActive: Bool
    let onSelect: () -> Void
    let onClose: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Text(tab.title.isEmpty ? "New Tab" : tab.title)
                .font(.system(size: 13))
                .lineLimit(1)
                .frame(maxWidth: 160, alignment: .leading)

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isActive ? Color(.secondarySystemBackground) : .clear)
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onSelect)
    }
}
