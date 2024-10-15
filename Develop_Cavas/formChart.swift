//
//  formChart.swift
//  Develop_Cavas
//
//  Created by 하늘 on 9/23/24.
//

import SwiftUI

struct BlockModelWithLink: Identifiable {
    let id = UUID()
    
    var position: CGPoint
    
    var type: BlockType
    var color : Color
    var nextNode: [BlockModelWithLink.ID] = []
}

struct LinkView: View {
    var blockList: [BlockModelWithLink]

    var body: some View {
        ZStack {
            ForEach(0..<blockList.count, id: \.self) { idx in
                LinkViews(blocks: blockList, index: idx)
            }
        
        }
    }
}

// Custom view to draw lines between blocks
struct Line: Shape {
    var start: CGPoint
    var end: CGPoint

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: start)
        path.addLine(to: end)
        return path
    }
}
struct LinkViews: View {
    @State var blocks: [BlockModelWithLink]
    @State var index : Int
    @State private var dragOffset: CGSize = .zero
    @State private var isNearGrid: Bool = false
    @State private var dragOff: CGPoint = .zero
    @State private var gridSpacing: CGFloat = 50.0


    var body: some View {
        ZStack {
            let block = blocks[index]
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                
                ZStack {
                    
                    // 블록의 모양
                    switch block.type {
                    case .process:
                        RoundedRectangle(cornerRadius: 2.5)
                            .fill(block.color)
                            .frame(width: 80, height: 40)
                    case .decision:
                        DiamondShape()
                            .fill(block.color)
                            .frame(width: 80, height: 80)
                    case .start, .end:
                        Circle()
                            .fill(block.color)
                            .frame(width: 40, height: 40)
                    case .link:
                        RoundedRectangle(cornerRadius: 22.5)
                            .fill(block.color)
                            .frame(width: 80, height: 40)
                    case .point:
                        RoundedRectangle(cornerRadius: 2.5)
                            .fill(block.color)
                            .frame(width: 80, height: 40)
                    }
                }
                // block.position과 dragOffset을 더해 블록의 위치를 조정
                .position(block.position + dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation
    //                        isNearGrid = isCloseToGrid(value.location)
                            dragOff = value.location
                        }
                        .onEnded { value in
                            
                            dragOffset = .zero
                            let levelX = Int(value.location.x / gridSpacing)
                            let levelY = Int(value.location.y / gridSpacing)
                            if levelX < Int(width / gridSpacing) ||
                                levelY < Int(height / gridSpacing) ||
                                levelX > 1 ||
                                levelY > 1 {
                                
                                let newPosition = nearestGridPoint(for: value.location, limit: geometry.size)
                                // 그리드 위치로 블록 위치 업데이트
                                self.blocks[index].position = newPosition
                                isNearGrid = false
                            }
                        }
                )
            }
        }
    }
    
    
    // 가장 가까운 그리드 포인트 계산
    private func nearestGridPoint(for location: CGPoint, limit:CGSize) -> CGPoint {
        
        let x = round(location.x / gridSpacing) > round(limit.width / gridSpacing) - 1 ? round(limit.width / gridSpacing) - 1 : round(location.x / gridSpacing)
        
        let y = round(location.y / gridSpacing) > round(limit.height / gridSpacing) - 1 ? round(limit.height / gridSpacing) - 1 : round(location.y / gridSpacing)
        
        return CGPoint(x: x < 1 ? gridSpacing : x*gridSpacing, y: y < 1 ? 1 : y*gridSpacing)
    }
}

struct formChart: View {
    @State var blockList: [BlockModelWithLink] = []

    var body: some View {
        ZStack {
            GridHintView()
            LinkView(blockList: blockList)
                .onAppear {
                    // Initialize blockList with test data
                    addTestData()
                }
        }
    }

    private func addTestData() {
        let block1 = BlockModelWithLink(
            position: CGPoint(x: 50, y: 50),
            type: .end,
            color: .red,
            nextNode: []
        )
        
        let block2 = BlockModelWithLink(
            position: CGPoint(x: 150, y: 100),
            type: .end,
            color: .blue,
            nextNode: [block1.id]
        )
        
        let block3 = BlockModelWithLink(
            position: CGPoint(x: 100, y: 150),
            type: .end,
            color: .green,
            nextNode: [block2.id]
        )
        
        let block4 = BlockModelWithLink(
            position: CGPoint(x: 150, y: 150),
            type: .end,
            color: .green,
            nextNode: [block2.id, block1.id]
        )
        
        // Add blocks to the dictionary
        blockList.append(block1)
        blockList.append(block2)
        blockList.append(block3)
        blockList.append(block4)
    }
}

#Preview {
    formChart()
}
