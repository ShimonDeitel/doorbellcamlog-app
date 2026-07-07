import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchaseManager: PurchaseManager
    @State private var showingAdd = false
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var editingItem: DoorbellCamLogItem?

    var body: some View {
        Group {

        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                if store.items.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(store.items) { item in
                            row(for: item)
                                .listRowBackground(Theme.background)
                                .contentShape(Rectangle())
                                .onTapGesture { editingItem = item }
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Theme.background)
                }
            }
            .navigationTitle("Doorbell Cam Log")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                    .foregroundColor(Theme.accent)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                    .foregroundColor(Theme.accent)
                }
            }
            .sheet(isPresented: $showingAdd) {
                EditItemView(item: nil)
            }
            .sheet(item: $editingItem) { item in
                EditItemView(item: item)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
        .tint(Theme.accent)

        }

    }

    private func row(for item: DoorbellCamLogItem) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.title)
                .font(Theme.headlineFont)
                .foregroundColor(Theme.textPrimary)
            Text(item.description)
                .font(Theme.bodyFont)
                .foregroundColor(Theme.textSecondary)
            Text(item.category)
                .font(Theme.captionFont)
                .foregroundColor(Theme.textSecondary)
        }
        .padding(.vertical, 4)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(Theme.accent)
            Text("No Events yet")
                .font(Theme.headlineFont)
                .foregroundColor(Theme.textPrimary)
            Text("Tap + to add your first one.")
                .font(Theme.bodyFont)
                .foregroundColor(Theme.textSecondary)
        }
    }

}

struct EditItemView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss
    var item: DoorbellCamLogItem?

    @State private var title: String = ""
    @State private var description: String = ""
    @State private var category: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("Title", text: $title)
                        .accessibilityIdentifier("fieldTitle")
                }
                Section("Description") {
                    TextField("Description", text: $description)
                        .accessibilityIdentifier("fieldDescription")
                }
                Section("Category") {
                    TextField("Category", text: $category)
                        .accessibilityIdentifier("fieldCategory")
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .navigationTitle(item == nil ? "Add Event" : "Edit Event")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .accessibilityIdentifier("saveButton")
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let item {
                    title = item.title
                    description = item.description
                    category = item.category
                }
            }
        }
    }

    private func save() {
        if var existing = item {
            existing.title = title
            existing.description = description
            existing.category = category
            store.update(existing)
        } else {
            let newItem = DoorbellCamLogItem(title: title, description: description, category: category)
            store.add(newItem)
        }
        dismiss()
    }
}
