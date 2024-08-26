//
//  ContentView.swift
//  GentooSDKExampleSwiftUI
//
//  Created by USER on 8/26/24.
//

import SwiftUI
import GentooSDK

struct ContentView: View {
    
    @State
    private var itemId: String? = "752"
    
    @State 
    private var contentType: GentooSDK.ContentType = .normal
    
    @State
    private var showsChatView: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TableView(contentType: $contentType)
                .edgesIgnoringSafeArea(.all)
            
            GentooFloatingButtonView(itemId: $itemId, contentType: $contentType) {
                self.showsChatView = true
            }
            .frame(width: 300, height: 54)
            .padding(.trailing, 20)
            .padding(.bottom, 50)
        }
        .sheet(isPresented: $showsChatView) {
            GentooChatView(itemId: itemId!, contentType: contentType)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
    }
    
}

struct TableView: UIViewRepresentable {
    @Binding var contentType: GentooSDK.ContentType
    
    func makeUIView(context: Context) -> UITableView {
        let tableView = UITableView()
        tableView.delegate = context.coordinator
        tableView.dataSource = context.coordinator
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }
    
    func updateUIView(_ uiView: UITableView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
        
        var parent: TableView
        
        init(_ parent: TableView) {
            self.parent = parent
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 50
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = "\(indexPath.row + 1)"
            return cell
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let scrollViewHeight = scrollView.frame.size.height
            
            let percentageScrolled = offsetY / (contentHeight - scrollViewHeight)
            
            // 스크롤 가능 영역의 70% 이상 스크롤 시 ContentType 변경
            if percentageScrolled >= 0.7 {
                parent.contentType = .recommendation
            }
        }
    }
}

#Preview {
    ContentView()
}
