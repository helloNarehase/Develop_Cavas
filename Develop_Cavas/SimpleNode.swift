//
//  SimpleNode.swift
//  Develop_Cavas
//
//  Created by 하늘 on 9/30/24.
//

import SwiftUI

struct Simple_Node_Link: Identifiable {
    let id = UUID()
    
    var startNODE: Bool
    var position: CGPoint
    var type: BlockType
    var color: Color
    var nextNode: [Simple_Node_Link.ID] = []
    var dragOffset: CGSize = .zero
    
    var title: String = "hello world"
    var description: String = ""
    
    mutating func addNextNode(nodeID: Node_Link.ID) {
        self.nextNode.append(nodeID)
    }
}


struct SimpleGridHint: View {
    let gridSpacing: CGFloat = 50.0
    let circleSize: CGFloat = 3.50
    
    @State private var clickedPosition: CGPoint? = nil
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            ZStack {
                ForEach(0..<Int(width / gridSpacing), id: \.self) { i in
                    ForEach(0..<Int(height / gridSpacing) + 1, id: \.self) { j in
                        Circle()
                            .fill(Color.gray.opacity(0.25))
                            .frame(width: circleSize, height: circleSize)
                            .position(
                                x: CGFloat(i+1) * gridSpacing,
                                y: CGFloat(j) * gridSpacing
                            )
                            .onTapGesture(perform: {
                                print("\(i), \(j)")
                                
                            })
                            
                    }
                }
            }
        }
    }
}

struct Canvas_node: View {
    @State var nodes: [Simple_Node_Link] = []
    var gridSpacing:CGFloat = 50.0
    var body: some View {
        GeometryReader{ geometry in
            VStack{
                ForEach(0..<nodes.count, id: \.self) { idx in
                    Circle()
                        .fill(.blue)
                        .frame(width: 40, height: 40)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    self.nodes[idx].dragOffset = value.translation
                                }
                                .onEnded { value in
                                    self.nodes[idx].dragOffset = .zero
                                    let newPosition = nearestGridPoint(for: value.location, limit: geometry.size)
                                    self.nodes[idx].position = newPosition

                                }
                        )
                        .position(self.nodes[idx].position + self.nodes[idx].dragOffset)
                }
            }
        }
        .frame(width: .infinity, height: 300)
        .onAppear {
            addTestData()
        }
    }
    
    
    private func nearestGridPoint(for location: CGPoint, limit: CGSize) -> CGPoint {
        let x = round(location.x / gridSpacing) * gridSpacing
        let y = round(location.y / gridSpacing) * gridSpacing
        return CGPoint(x: min(max(x, 0), limit.width - gridSpacing),
                       y: min(max(y, 0), limit.height - gridSpacing))
    }
    
    private func addTestData() {
        var blocks: [Simple_Node_Link] = []
        
        let block1 = Simple_Node_Link(
            startNODE: true,
            position: CGPoint(x: 50, y: 50),
            type: .end,
            color: .red,
            nextNode: []
        )
        
        var block0 = Simple_Node_Link(
            startNODE: true,
            position: CGPoint(x: 50, y: 0),
            type: .end,
            color: .indigo,
            nextNode: []
        )
//
        let block2 = Simple_Node_Link(
            startNODE: false,
            position: CGPoint(x: 150, y: 100),
            type: .decision,
            color: .blue,
            nextNode: [block1.id]
        )
        
        let block3 = Simple_Node_Link(
            startNODE: false,
            position: CGPoint(x: 100, y: 150),
            type: .process,
            color: .green,
            nextNode: [block2.id, block1.id]
        )
        
        let block4 = Simple_Node_Link(
            startNODE: false,
            position: CGPoint(x: 150, y: 150),
            type: .end,
            color: .green,
            nextNode: [block2.id, block1.id, block3.id]
        )
        block0.nextNode.append(block4.id)
        blocks.append(contentsOf: [block0, block1, block2, block3, block4])
        
        // Update the @State variable
        nodes = blocks
    }
}
struct SimpleNode: View {
    var body: some View {
        ZStack {
//            Button(action: {}) {
//                Text("Hello, World!")
//            }
            SimpleGridHint()
            Canvas_node()
            
        }
    }
}

#Preview {
    SimpleNode()
}
