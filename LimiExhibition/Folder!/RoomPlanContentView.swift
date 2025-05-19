//
//  ContentView.swift
//  ForReal Demo
//
//  Created by Vatsal Patel  on 8/17/24.
//

import SwiftUI

struct RoomPlanContentView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToHome = false
    @State private var files: [String] = []

    var body: some View {
        NavigationStack {
            ZStack {
                Color.charlestonGreen.ignoresSafeArea()

                List {
                    ForEach(files, id: \.self) { file in
                        NavigationLink(destination: FileDetailView(fileName: file)) {
                            Text(file)
                        }
                    }
                    .onDelete(perform: deleteFiles)
                }

                if files.isEmpty {
                    VStack {
                        Image("ARLogo")
                            .resizable()
                            .frame(width: 120, height: 24)
                        Image("roomImage3")
                            .resizable()
                            .frame(width: 250, height: 250)
                        Text("You have no existing scans")
                        Text("Make a new scan!")
                    }
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 120)
                }

                // NavigationLink to trigger programmatic navigation to HomeView
                NavigationLink(destination: HomeView(), isActive: $navigateToHome) {
                    EmptyView()
                }
                
            }

            .navigationTitle("Room Scans")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        navigateToHome = true
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.charlestonGreen)
                            Text("Back")
                                .foregroundColor(.charlestonGreen)
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ScanNewRoomView()) {
                        Image(systemName: "plus")
                            .foregroundStyle(Color.alabaster)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.charlestonGreen)
                            .cornerRadius(8)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton().foregroundStyle(Color.charlestonGreen)
                }
            }
            .onAppear {
                refreshFileList()
            }
        }
    }

    private func refreshFileList() {
        files = RoominatorFileManager.shared.listFiles()
    }

    private func deleteFiles(at offsets: IndexSet) {
        for index in offsets {
            let fileName = files[index]
            if RoominatorFileManager.shared.deleteFile(named: fileName) {
                files.remove(at: index)
            }
        }
    }
}

#Preview {
    RoomPlanContentView()
}
