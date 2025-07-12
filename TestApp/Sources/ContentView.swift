import SwiftUI
import TrustPinKit

struct ContentView: View {
    @State private var organizationId = ""
    @State private var projectId = ""
    @State private var publicKey = ""

    @State private var testUrl = ""
    @State private var logOutput = "Welcome to TrustPin iOS Sample\nConfigure TrustPin and test connections...\n"
    @State private var statusMessage = "TrustPin not configured"
    @State private var isConfigured = false
    @State private var isTesting = false
    @State private var currentMode: TrustPinMode = .strict
    @State private var showModeAlert = false
    
    private let trustPinDelegate = TrustPinURLSessionDelegate()

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // TrustPin Configuration Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("TrustPin Configuration")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Organization ID")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("Enter your organization ID", text: $organizationId)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Project ID")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("Enter your project ID", text: $projectId)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Public Key")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            if #available(iOS 16.0, *) {
                                TextField("Enter your base64 public key", text: $publicKey, axis: .vertical)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .lineLimit(3...5)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                            } else {
                                TextField("Enter your base64 public key", text: $publicKey)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                            }
                        }
                        
                        Button(action: setupTrustPin) {
                            Text("Setup TrustPin")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        // TrustPin Mode Display
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Pinning Mode")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Text(currentMode == .strict ? "Strict Mode" : "Permissive Mode")
                                    .font(.body)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                Toggle("", isOn: Binding(
                                    get: { currentMode == .strict },
                                    set: { _ in showModeAlert = true }
                                ))
                                .labelsHidden()
                                .disabled(true)
                                .opacity(0.6)
                                .onTapGesture {
                                    showModeAlert = true
                                }
                            }
                            
                            Text(currentMode == .strict ? 
                                "Blocks connections to unregistered domains" : 
                                "Allows connections to unregistered domains")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Connection Testing Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Connection Testing")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Test URL")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("https://api.example.com", text: $testUrl)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                        }
                        
                        HStack(spacing: 12) {
                            Button(action: testConnection) {
                                Text("Test Connection")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(isConfigured ? Color.green : Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .disabled(!isConfigured || isTesting)
                            
                            Button(action: clearLog) {
                                Text("Clear Log")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        
                        HStack {
                            Text("Status: \(statusMessage)")
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(isConfigured ? Color.green : Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(6)
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Log Output Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Log Output")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        
                        ScrollView {
                            ScrollViewReader { proxy in
                                Text(logOutput)
                                    .font(.system(size: 12))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color(.systemGray5))
                                    .cornerRadius(8)
                                    .id("logBottom")
                                    .onChange(of: logOutput) { _ in
                                        withAnimation {
                                            proxy.scrollTo("logBottom", anchor: .bottom)
                                        }
                                    }
                            }
                        }
                        .frame(height: 300)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("TrustPin Sample")
            .onAppear {
                logMessage("📱 TrustPin iOS Sample started")
            }
            .alert("Change Pinning Mode", isPresented: $showModeAlert) {
                Button("OK") { }
            } message: {
                Text("To change the pinning mode, modify the 'mode' parameter in the setupTrustPin() function code:\n\n• .strict for production (blocks unregistered domains)\n• .permissive for development (allows unregistered domains)")
            }
        }
    }
    
    private func setupTrustPin() {
        guard !organizationId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !projectId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !publicKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            logMessage("❌ Configuration failed: Missing required fields")
            return
        }
        
        Task {
            do {
                logMessage("⚙️ Configuring TrustPin...")
                logMessage("   Organization ID: \(organizationId)")
                logMessage("   Project ID: \(projectId)")
                logMessage("   Public Key: \(String(publicKey.prefix(20)))...")
                
                await TrustPin.set(logLevel: .debug)
                try await TrustPin.setup(
                    organizationId: organizationId.trimmingCharacters(in: .whitespacesAndNewlines),
                    projectId: projectId.trimmingCharacters(in: .whitespacesAndNewlines),
                    publicKey: publicKey.trimmingCharacters(in: .whitespacesAndNewlines),
                    mode: currentMode
                )
                
                logMessage("🔒 Mode: \(currentMode == .strict ? "Strict" : "Permissive")")
                
                await MainActor.run {
                    isConfigured = true
                    statusMessage = "TrustPin configured"
                    logMessage("✅ TrustPin configuration successful")
                }
            } catch {
                await MainActor.run {
                    isConfigured = false
                    statusMessage = "TrustPin not configured"
                    logMessage("❌ TrustPin configuration failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func testConnection() {
        guard isConfigured else {
            logMessage("⚠️ Test connection failed: TrustPin not configured")
            return
        }
        
        guard !testUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            logMessage("⚠️ Test connection failed: No URL provided")
            return
        }
        
        Task {
            await MainActor.run {
                isTesting = true
                statusMessage = "Testing connection..."
            }
            
            do {
                logMessage("🌐 Testing connection to: \(testUrl)")
                
                let result = try await performNetworkRequest(url: testUrl.trimmingCharacters(in: .whitespacesAndNewlines))
                
                await MainActor.run {
                    isTesting = false
                    statusMessage = "TrustPin configured"
                    logMessage("✅ Connection test successful!")
                    let preview = String(result.prefix(200))
                    logMessage("   Response: \(preview)\(result.count > 200 ? "..." : "")")
                }
            } catch {
                await MainActor.run {
                    isTesting = false
                    statusMessage = "TrustPin configured"
                    logMessage("🌐 Connection failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func performNetworkRequest(url: String) async throws -> String {
        guard let url = URL(string: url) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("TrustPin-iOS-Sample/1.0", forHTTPHeaderField: "User-Agent")
        
        logMessage("📡 Making HTTP request...")
        logMessage("   Method: GET")
        logMessage("   URL: \(url)")
        logMessage("   User-Agent: TrustPin-iOS-Sample/1.0")
        
        // Create URLSession with TrustPin delegate for SSL pinning validation
        let session = URLSession(configuration: .default, delegate: trustPinDelegate, delegateQueue: nil)
        
        logMessage("🔒 Using TrustPin SSL certificate validation")
        
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            logMessage("📨 Response received:")
            logMessage("   Status: \(httpResponse.statusCode)")
            logMessage("   Headers: \(httpResponse.allHeaderFields.count) headers")
        }
        
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    private func logMessage(_ message: String) {
        let timestamp = dateFormatter.string(from: Date())
        let logEntry = "[\(timestamp)] \(message)\n"
        
        DispatchQueue.main.async {
            logOutput += logEntry
        }
    }
    
    private func clearLog() {
        logOutput = "Welcome to TrustPin iOS Sample\nConfigure TrustPin and test connections...\n"
        logMessage("🧹 Log cleared")
    }
}

#Preview {
    ContentView()
}
