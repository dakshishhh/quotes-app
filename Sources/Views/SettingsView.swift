import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    var onDismiss: () -> Void
    
    @State private var url: String = ""
    @State private var anonKey: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Supabase Connection")) {
                    TextField("Project URL", text: $url)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    TextField("Anon Key", text: $anonKey)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                Section(footer: Text("The URL should look like 'https://your-project.supabase.co'.")) {
                    Button("Save") {
                        SupabaseService.shared.saveCredentials(url: url, anonKey: anonKey)
                        onDismiss()
                        dismiss()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Cancel") { dismiss() })
            .onAppear {
                url = SupabaseService.shared.getUrl() ?? ""
                anonKey = SupabaseService.shared.getAnonKey() ?? ""
            }
        }
        .preferredColorScheme(.dark)
    }
}
