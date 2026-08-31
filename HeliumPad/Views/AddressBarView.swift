import SwiftUI

struct AddressBarView: View {
    @ObservedObject var tab: Tab
    @Binding var adBlockEnabled: Bool
    var onNewTab: () -> Void

    @State private var editingText: String = ""
    @State private var isEditing: Bool = false
    @FocusState private var fieldFocused: Bool

    var body: some View {
        HStack(spacing: 14) {
            HStack(spacing: 18) {
                Button(action: tab.goBack) {
                    Image(systemName: "chevron.left")
                }
                .disabled(!tab.canGoBack)

                Button(action: tab.goForward) {
                    Image(systemName: "chevron.right")
                }
                .disabled(!tab.canGoForward)

                Button(action: tab.isLoading ? tab.stop : tab.reload) {
                    Image(systemName: tab.isLoading ? "xmark" : "arrow.clockwise")
                }
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.primary)

            HStack {
                Image(systemName: "lock.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)

                TextField(
                    "Search or enter website",
                    text: Binding(
                        get: { isEditing ? editingText : displayString },
                        set: { editingText = $0 }
                    )
                )
                .focused($fieldFocused)
                .textFieldStyle(.plain)
                .keyboardType(.webSearch)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .onSubmit {
                    tab.load(editingText)
                    isEditing = false
                    fieldFocused = false
                }
                .onTapGesture {
                    if !isEditing {
                        editingText = tab.urlString
                        isEditing = true
                    }
                }
                .onChange(of: fieldFocused) { _, focused in
                    if focused {
                        editingText = tab.urlString
                        isEditing = true
                    } else {
                        isEditing = false
                    }
                }

                if tab.isLoading {
                    ProgressView().scaleEffect(0.7)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))

            Button {
                adBlockEnabled.toggle()
            } label: {
                Image(systemName: adBlockEnabled ? "shield.fill" : "shield.slash")
                    .foregroundStyle(adBlockEnabled ? Color.accentColor : .secondary)
            }
            .accessibilityLabel(adBlockEnabled ? "Ad blocking on" : "Ad blocking off")

            Button(action: onNewTab) {
                Image(systemName: "plus")
            }
            .font(.system(size: 16, weight: .semibold))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var displayString: String {
        tab.urlString
    }
}
