//
//  Flow_form.swift
//  Develop_Cavas
//
//  Created by 하늘 on 9/23/24.
//

import SwiftUI

struct BlockModel: Identifiable {
    let id = UUID()
    var position: CGPoint
    var type: BlockType
    var color : Color
    
    var Connection: [Int : [BlockModel.ID]] = [:]
    
    var InNodes: [BlockModel.ID] = []
    var OutNode: [BlockModel.ID] = []
    
    //    0 <- top, 1 <- left, 2 <- right, 3 <- bottom

    var isSingNode:Bool = false
}
struct Block_Collaction: Identifiable {
    let id = UUID()
    var Body: [BlockModel.ID : BlockModel] = [:]
}

enum BlockType {
    case process, decision, start, end, link, point
}

// Custom shape for decision block
struct DiamondShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

struct concentricCircles:View {
    var position: CGPoint
    var circleSize: CGFloat = 5.0
    var r:CGFloat = 20.0
    
    var body: some View{
        ZStack {
            ForEach(1..<6) { k in
                Circle()
                    .stroke(Color.blue, lineWidth: 1)
                    .frame(width: circleSize * CGFloat(k * 2), height: circleSize * CGFloat(k * 2))
                    .position(position)
            }
        }
    }
}

struct BlockView: View {
    @Binding var block: BlockModel
    @State private var dragOffset: CGSize = .zero
    @State private var isNearGrid: Bool = false
    @State private var dragOff: CGPoint = .zero
    @State private var gridSpacing: CGFloat = 50.0


    var body: some View {
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
                            self.block.position = newPosition
                            isNearGrid = false
                        }
                    }
            )
        }
    }

    // 가장 가까운 그리드 포인트 계산
    private func nearestGridPoint(for location: CGPoint, limit:CGSize) -> CGPoint {
        
        let x = round(location.x / gridSpacing) > round(limit.width / gridSpacing) - 1 ? round(limit.width / gridSpacing) - 1 : round(location.x / gridSpacing)
        
        let y = round(location.y / gridSpacing) > round(limit.height / gridSpacing) - 1 ? round(limit.height / gridSpacing) - 1 : round(location.y / gridSpacing)
        
        return CGPoint(x: x < 1 ? gridSpacing : x*gridSpacing, y: y < 1 ? 1 : y*gridSpacing)
    }

//    // 그리드 가까이에 있는지 확인
//    private func isCloseToGrid(_ location: CGPoint) -> Bool {
//        let gridPoint = nearestGridPoint(for: location)
//        let distance = hypot(location.x - gridPoint.x, location.y - gridPoint.y)
//        return distance < 1020 // 그리드 가까이에 있을 때 힌트 표시
//    }
}
struct Nodes: View {
    @Binding var blocks: [BlockModel.ID : BlockModel]
    
    var body: some View {
        ZStack {
            GridHintView()
            
            ForEach(blocks.keys.sorted(), id: \.self) { key in
                if let block = blocks[key] {
                    ForEach(block.InNodes, id: \.self) { node_uuid in
                        if let sPosition = blocks[node_uuid]?.position {
                            // 실시간으로 위치 업데이트
                            Path { path in
                                path.move(to: block.position)
                                path.addLine(to: sPosition)
                            }
                            .stroke(Color.blue, lineWidth: 2)
                            .animation(.easeInOut(duration: 0.2), value: block.position) // 실시간으로 따라가도록 애니메이션 추가
                        }
                    }
                }
            }
            
            ForEach(blocks.keys.sorted(), id: \.self) { key in
                if let block = blocks[key] {
                    BlockView(block: Binding(get: {
                        block
                    }, set: { newBlock in
                        blocks[key] = newBlock
                    }))
                }
            }
        }
    }
}

struct testV: View {
    @State private var blocks: [BlockModel] = []
    @State private var blockc: [BlockModel.ID :BlockModel] = [:]

    var body: some View {
        ZStack {
            Nodes(blocks: $blockc)
        }
        .onAppear {
            // Initialize blocks here
            var mb = BlockModel(position: CGPoint(x: 50, y: 50), type: .start, color: .green)
            
            for i in 2...4 {
                let sb = BlockModel(position: CGPoint(x: 50, y: 50 * CGFloat(i)), type: .start, color: .green, InNodes: [mb.id])
                blocks.append(sb)
                mb = sb
            }
            
            blocks.forEach { block in
                blockc[block.id] = block
            }
        }
    }
}

#Preview {
    testV()
}
