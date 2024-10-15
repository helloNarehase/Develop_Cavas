//
//  Node.swift
//  Develop_Cavas
//
//  Created by 하늘 on 9/23/24.
//

import SwiftUI

extension View {
    // 메뉴 스타일 추가
    func menuButtonStyle() -> some View {
        self.background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .shadow(radius: 5)
    }
    
    // 팝업 메뉴 구성
    func menu(showMenu: Binding<Bool>) -> some View {
        ZStack {
            self
            if showMenu.wrappedValue {
                VStack {
                    Menu {
                        Button(action: { /* 메뉴 액션 1 */ }) {
                            Label("Action 1", systemImage: "star")
                        }
                        Button(action: { /* 메뉴 액션 2 */ }) {
                            Label("Action 2", systemImage: "heart")
                        }
                        Button(action: { /* 메뉴 액션 3 */ }) {
                            Label("Action 3", systemImage: "flag")
                        }
                    } label: {
                        Text("Menu")
                    }
                    .frame(width: 200, height: 150)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                }
            }
        }
    }
    func singleTapGesture(action: @escaping () -> Void) -> some View {
        self.gesture(TapGesture(count: 1).onEnded { _ in action() })
    }
    
    func doubleTapGesture(action: @escaping () -> Void) -> some View {
        self.gesture(TapGesture(count: 2).onEnded { _ in action() })
    }
    
    func longPressGesture(action: @escaping () -> Void) -> some View {
        self.gesture(LongPressGesture().onEnded { _ in action() })
    }
}

// CGPoint + CGSize 연산을 위한 확장 메서드
extension CGPoint {
    static func +(lhs: CGPoint, rhs: CGSize) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
    }
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    
    static func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
    
    func normalized() -> CGPoint {
        let length = sqrt(x * x + y * y)
        return length > 0 ? CGPoint(x: x / length, y: y / length) : .zero
    }
}

struct Node_Link: Identifiable {
    let id = UUID()
    
    var startNODE: Bool
    var position: CGPoint
    var type: BlockType
    var color: Color
    var nextNode: [Node_Link.ID] = []
    var dragOffset: CGSize = .zero
    
    var title: String = "hello world"
    var description: String = ""
    
    mutating func addNextNode(nodeID: Node_Link.ID) {
        self.nextNode.append(nodeID)
    }
}

struct GridHintView: View {
    let gridSpacing: CGFloat = 30
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
struct NodeView: View {
    @Binding var blockList: [Node_Link]
    @Binding var selectedNode: Node_Link.ID?
    var func_var: () -> Void
    var func_var_L: (Bool) -> Void
    @State private var gridSpacing: CGFloat = 30
    @State private var edit_mode: Bool = false
    @State var selectID: Node_Link.ID? = nil
    @State var selectID_m: Int = 0
    @State var progressList: [UUID: [UUID: CGFloat]] = [:] // 노드 ID별, 연결된 노드 ID별 progress 저장

    var body: some View {
        GeometryReader { geometry in
//            let width = geometry.size.width
//            let height = geometry.size.height
            
            ZStack {
                GridHintView()
                
                // 선 그리기 로직 분리
                drawLines()
                drawArrow()
                
                // 블록 그리기 로직 분리
                drawBlocks(geometry: geometry)
            }
        }
    }
    private func drawArrow() -> some View {
        let fixedArrowLength: CGFloat = 100 // 화살표의 고정 길이

        return ForEach(blockList.indices, id: \.self) { idx in
            ForEach($blockList[idx].nextNode, id: \.self) { $nextID in
                if let nextNode = blockList.first(where: { $0.id == nextID }) {
                    let startPosition: CGPoint = blockList[Int(idx)].position + blockList[Int(idx)].dragOffset
                    let endPosition: CGPoint = nextNode.position + nextNode.dragOffset
                    
                    let vector: CGPoint = endPosition - startPosition
                    let vectorLength = hypot(vector.x, vector.y)
                    
                    // 벡터의 중간점을 구함
                    let midpoint: CGPoint = CGPoint(x: (startPosition.x + endPosition.x) / 2,
                                                    y: (startPosition.y + endPosition.y) / 2)
                    
                    // 고정된 길이로 비율을 조정
                    let scale = fixedArrowLength / vectorLength
                    let scaledVector = CGPoint(x: vector.x * scale, y: vector.y * scale)
                    let newStartPosition = CGPoint(x: midpoint.x - scaledVector.x / 2, y: midpoint.y - scaledVector.y / 2)
                    let newEndPosition = CGPoint(x: midpoint.x + scaledVector.x / 2, y: midpoint.y + scaledVector.y / 2)
                    
                    let newVector: CGPoint = newEndPosition - newStartPosition
                    let perpendicularVector: CGPoint = computePerpendicularVector(from: newVector)
                    
                    let center: CGPoint = nearByPoint(from: newStartPosition, to: newEndPosition, point: 0.75)
                    let center2: CGPoint = nearByPoint(from: newStartPosition, to: newEndPosition, point: 0.85)
                    let (perpendicularStart, perpendicularEnd): (CGPoint, CGPoint) = computePerpendicularPoints(center: center, vector: perpendicularVector)
                    
                    // Path 생성
                    let path = Path { path in
                        path.move(to: perpendicularStart)
                        path.addLine(to: perpendicularEnd)
                        path.addLine(to: center2)
                    }
                    
                    // Path를 사용하는 뷰
                    path
                        .fill(blockList[idx].color)
//                        .stroke(blockList[idx].color, lineWidth: 2)
                }
            }
        }
    }
    private func drawLines() -> some View {
        ForEach(blockList.indices, id: \.self) { idx in
            ForEach($blockList[idx].nextNode, id: \.self) { $nextID in
                if let nextNode = blockList.first(where: { $0.id == nextID }) {
                    let startPosition: CGPoint = blockList[Int(idx)].position + blockList[Int(idx)].dragOffset
                    let endPosition: CGPoint = nextNode.position + nextNode.dragOffset
//
                    // 두 점 사이의 벡터
                    let vector: CGPoint = endPosition - startPosition
                    let perpendicularVector: CGPoint = computePerpendicularVector(from: vector)

                    let center: CGPoint = nearByPoint(from: startPosition, to: endPosition, point: 0.65)
                    
                    let progress = progressList[blockList[Int(idx)].id]?[Int(nextID)] ?? 0.0
                    let blockId = blockList[Int(idx)].id

                    let progressValue = progressList[blockId]?[nextID]

                    let trimmedProgress = progressValue ?? 0.0
                    let clampedProgress = min(max(trimmedProgress, 0.0), 1.0)
                    
                    
                    // Path 생성
                    let path = Path { path in
                        // 원래 선
                        path.move(to: startPosition)
                        path.addLine(to: endPosition)
                        path.closeSubpath()
                    }
                    .trim(from: 0, to: clampedProgress)

                    // Path를 사용하는 뷰
                    path
//                        .fill(blockList[idx].color)
                        .stroke(blockList[idx].color, lineWidth: 2)
                        .gesture(
                            TapGesture(count: 2)
                                .onEnded({ _ in
                                    print("remove : \(idx)")
                                    if let nextIndex = self.blockList[idx].nextNode.firstIndex(of: nextID) {
                                        self.progressList[blockList[idx].id]?.removeValue(forKey: nextID) // 해당 연결 progress 삭제
                                        self.blockList[idx].nextNode.remove(at: nextIndex)
                                    }
                                })
                        )
                        .onAppear {
                            // 각 노드와 연결에 대해 개별적으로 애니메이션 적용
                            if progressList[blockList[Int(idx)].id] == nil {
                                self.progressList[blockList[Int(idx)].id] = [:] // 해당 노드 ID에 대해 progress 초기화
                            }
                            self.progressList[blockList[Int(idx)].id]?[nextID] = 0.0 // 해당 연결 progress 초기화

                            withAnimation(.easeInOut(duration: 0.45)) {
                                self.progressList[blockList[Int(idx)].id]?[nextID] = 1.0 // 개별 연결에 대해 애니메이션 실행
                            }
                        }
                }
            }
        }
    }

    // 수직 벡터 계산 함수
    private func computePerpendicularVector(from vector: CGPoint) -> CGPoint {
        return CGPoint(x: -vector.y, y: vector.x).normalized() * CGFloat(20.0)
    }

    // 수직선의 시작과 끝 점을 계산하는 함수
    private func computePerpendicularPoints(center: CGPoint, vector: CGPoint) -> (CGPoint, CGPoint) {
        let halfVector: CGPoint = vector / CGFloat(2.0)
        let perpendicularStart: CGPoint = center + halfVector
        let perpendicularEnd: CGPoint = center - halfVector
        return (perpendicularStart, perpendicularEnd)
    }

    private func nearByPoint(from end: CGPoint, to start: CGPoint, point: CGFloat) -> CGPoint {
        let x: CGFloat = end.x + (start.x - end.x) * point
        let y: CGFloat = end.y + (start.y - end.y) * point
        return CGPoint(x: x, y: y)
    }

    // 블록 그리기
    private func drawBlocks(geometry: GeometryProxy) -> some View {
        ForEach(0..<blockList.count, id: \.self) { idx in
            ZStack{
                switch blockList[idx].type {
                case .start, .end:
                    blockShape(blockList[idx])
                    Text(blockList[idx].title)
                        .padding([.leading, .trailing], 5)
                        .background(Color(.lightGray).opacity(0.4))
                        .background(.white)
                        .cornerRadius(20)
                        .offset(x: 0.0, y: 32.0)
                case .decision:
                    blockShape(blockList[idx])
                    Text(blockList[idx].title)
                        .padding([.leading, .trailing], 5)
                        .background(Color(.lightGray).opacity(0.35))
                        .background(.white)
                        .cornerRadius(20)
                        .offset(x: 74.0, y: 0.0)
                case .link:
                    blockShape(blockList[idx])
//                    Text(blockList[idx].title)
                case .point:
                    blockShape(blockList[idx])
//                    Text(blockList[idx].title)
                case .process:
                    blockShape(blockList[idx])
                    Text(blockList[idx].title)
                        .padding([.leading, .trailing], 5)
                        .background(Color(.lightGray).opacity(0.35))
                        .background(.white)
                        .cornerRadius(20)

                }
            
            }
                .position(blockList[idx].position + blockList[idx].dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            self.blockList[idx].dragOffset = value.translation
                        }
                        .onEnded { value in
                            self.blockList[idx].dragOffset = .zero
                            let newPosition = nearestGridPoint(for: value.location, limit: geometry.size)
                            self.blockList[idx].position = newPosition
                        }
                )
                .singleTapGesture {
                    print("Selected, \(self.blockList[idx].id)")
                    if edit_mode {
                        edit_mode = false
                        
                        if self.blockList[selectID_m].nextNode.contains(blockList[idx].id) {
                            func_var_L(false)
                            print("이미 졵")
                            
                        } else {
                            func_var_L(false)
                            if selectID_m != idx {
                                self.blockList[selectID_m].nextNode.append(blockList[idx].id)
                            }
                        }
                        
                        
                    } else {
                        self.selectedNode = self.blockList[idx].id
                        func_var()
                    }
                }
                .longPressGesture {
                    func_var_L(true)
                    print("long press : \(idx)")
                    edit_mode = true
                    self.selectID_m = idx
                }
                .doubleTapGesture {
                    print("double tap : \(idx)")
                    var nlink = Node_Link(startNODE: false, position: blockList[idx].position, type: .process, color: .yellow)
                    nlink.addNextNode(nodeID: blockList[idx].id)
                    self.blockList.append(
                        nlink
                    )
                }
        }
    }

    // 블록의 모양 결정
    private func blockShape(_ block: Node_Link) -> some View {
        switch block.type {
        case .process:
            return AnyView(RoundedRectangle(cornerRadius: 2.5).fill(block.color).frame(width: 95, height: 40))
        case .decision:
            return AnyView(DiamondShape().fill(block.color).frame(width: 50, height: 50))
        case .start, .end:
            return AnyView(Circle().fill(block.color).frame(width: 40, height: 40))
        case .link:
            return AnyView(RoundedRectangle(cornerRadius: 22.5).fill(block.color).frame(width: 40, height: 40))
        case .point:
            return AnyView(Circle().fill(block.color).frame(width: 15, height: 15))
        }
    }

    private func nearestGridPoint(for location: CGPoint, limit: CGSize) -> CGPoint {
        let x = round(location.x / gridSpacing) * gridSpacing
        let y = round(location.y / gridSpacing) * gridSpacing
        return CGPoint(x: min(max(x, 0), limit.width - gridSpacing),
                       y: min(max(y, 0), limit.height - gridSpacing))
    }
}

struct Sheet_view: View {
    @Binding var title: String
    @Binding var text: String
    
    var func_: (String, String) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Title", text: $title)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(15)
                .background(Color(.lightGray).opacity(0.2))
                .cornerRadius(10)
                .padding([.top], 60)
                .padding([.horizontal], 40)
            Spacer()
            TextField("Description", text: $text)
                .textEditorStyle(.automatic)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(minHeight:100, maxHeight:340)
                .padding(10)
//                    .background(Color.blue.opacity(0.2))
                .cornerRadius(10)
                .overlay( /// apply a rounded border
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.blue, lineWidth: 1)
                )
                .padding([.horizontal], 40)
            Spacer()
            Button(action: {
                func_(title, text)
            }) {
                Text("Done")
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(5)
                    .padding([.horizontal], 40)
            }
            .padding([.bottom], 40)
            
        }
    }
}
struct Node: View {
    @State private var blockList: [Node_Link] = []
    @State private var selectedNode: Node_Link.ID?
    @State private var is_hidden_Menu: Bool = false
    @State private var is_hidden_c: Bool = false
    @State private var alert: Bool = false
    
    
    @State private var title: String = ""
    @State private var text: String = ""
    
    var body: some View {
        VStack {
        
            HStack {
                Spacer()
                Button(action: {
                    
                }) {
                    Text("Connect")
                        .fontWeight(.semibold)
                        .padding([.top, .bottom], 4)
                        .padding([.trailing, .leading], 18)
                        .background(Color(.red))
                        .foregroundStyle(.white)
                        .cornerRadius(20)
                }
                .padding([.trailing], 16)
                .opacity(is_hidden_c ? 1.0 : 0.0)
                .animation(.spring(), value: is_hidden_c)  // 스프링 애니메이션 적용
                Spacer()
                Text("Iphone")
                    .padding()
                    .opacity(0.0)
                Spacer()
                Button(action: {
                    is_hidden_Menu = false
                    selectedNode = nil
                }) {
                    Text("Done")
                        .fontWeight(.semibold)
                        .padding([.top, .bottom], 4)
                        .padding([.trailing, .leading], 18)
                        .background(Color(.yellow))
                        .foregroundStyle(.black)
                        .cornerRadius(20)
                }
//                .padding([.leading], 16)
                .opacity(is_hidden_Menu ? 1.0 : 0.0)
                .animation(.spring(), value: is_hidden_Menu)  // 스프링 애니메이션 적용
            
                Spacer()
            }
            .padding(.top, 8)
//            .transition(.move(edge: .top))  // 위에서 아래로 내려오는 애니메이션

            NodeView(blockList: $blockList, selectedNode : $selectedNode, func_var: {
                is_hidden_Menu = true
            }, func_var_L: { is_if in
                self.is_hidden_c = is_if
            })
                .onAppear {
                    addTestData()
                }
            
            HStack {
                
                Spacer()
                Button(action: {
                    print(selectedNode ?? "No Node Selected")
                    if selectedNode != nil {
                        for idx in 0..<blockList.count {
                            if blockList[idx].id == selectedNode{
                                self.blockList[idx].type = .process
                                break
                            }
                        }
                    }
                }) {
                    Text("Square")
                }
                Spacer()
                Button("Circle", action: {
                    for idx in 0..<blockList.count {
                        if blockList[idx].id == selectedNode{
                            self.blockList[idx].type = .start
                            break
                        }
                    }
                })
                Spacer()
                Button("Diamond", action: {
                    for idx in 0..<blockList.count {
                        if blockList[idx].id == selectedNode{
                            self.blockList[idx].type = .decision
                            break
                        }
                    }
//                    selectedNode?.type = .decision
                })
                Spacer()
                Button("joint", action: {
                    for idx in 0..<blockList.count {
                        if blockList[idx].id == selectedNode{
                            self.blockList[idx].type = .point
                            break
                        }
                    }
               })
                Spacer()
                
                Button(action: {
                    
                    
                    for idx in 0..<blockList.count {
                        if blockList[idx].id == selectedNode{
                            title = blockList[idx].title
                            text = blockList[idx].description
                            self.alert.toggle()
                            break
                        }
                    }
                    
                    
                }) {
                    Image(systemName: "doc.text.fill")
                }
                .sheet(isPresented: $alert) {
//                    Text("sheet view")
                    Sheet_view(title: $title, text: $text) {title, description in
                        // 액션 버튼 클릭 시 실행할 함수
                        var id = 0
                        for idx in 0..<blockList.count {
                            if blockList[idx].id == selectedNode{
                                id = idx
                                break
                            }
                        }
                        self.blockList[id].title = title
                        self.blockList[id].description = description
                    }
                }
                
                Spacer()
                Menu {
                    Button("red") {
                        for idx in 0..<blockList.count {
                            if blockList[idx].id == selectedNode{
                                self.blockList[idx].color = .red
                                break
                            }
                        }
                    }
                    Button("green") {
                        for idx in 0..<blockList.count {
                            if blockList[idx].id == selectedNode{
                                self.blockList[idx].color = .green
                                break
                            }
                        }
                    }
                    Button("blue") {
                        for idx in 0..<blockList.count {
                            if blockList[idx].id == selectedNode{
                                self.blockList[idx].color = .blue
                                break
                            }
                        }
                    }
                    
                                
                } label: {
                    
                    Circle()
                    .fill(.gray.opacity(0.15))
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: "paintbrush.pointed")
                            .font(.system(size: 13.0, weight: .semibold))
                            .foregroundColor(.pink)
                            .padding()
                    }

//                    Circle()
//                        .fill(.gray.opacity(0.15))
//                        .frame(width: 30, height: 30)
//                        .overlay {
//                            Image(systemName: "ellipsis")
//                                .font(.system(size: 13.0, weight: .semibold))
//                                .foregroundColor(.pink)
//                                .padding()
//                        }
                }
//                .foregroundStyle(.black)
//                .padding([.top, .bottom], 5)
//                .padding([.leading, .trailing], 12)
//                .background(Color.yellow)
//                .cornerRadius(20.0)
                Spacer()
           }
            .padding([.bottom], 20)
        }
        .ignoresSafeArea()
        .statusBarHidden(true)
//        .ignoresSafeArea(edges: is_hidden_Menu ? .all : .init())
//        .statusBarHidden(is_hidden_Menu)
    }

    private func addTestData() {
        var blocks: [Node_Link] = []
        
        let block1 = Node_Link(
            startNODE: true,
            position: CGPoint(x: 50, y: 50),
            type: .end,
            color: .red,
            nextNode: []
        )
        
        var block0 = Node_Link(
            startNODE: true,
            position: CGPoint(x: 50, y: 0),
            type: .end,
            color: .indigo,
            nextNode: []
        )
//
        let block2 = Node_Link(
            startNODE: false,
            position: CGPoint(x: 150, y: 100),
            type: .decision,
            color: .blue,
            nextNode: [block1.id]
        )
        
        let block3 = Node_Link(
            startNODE: false,
            position: CGPoint(x: 100, y: 150),
            type: .process,
            color: .green,
            nextNode: [block2.id, block1.id]
        )
        
        let block4 = Node_Link(
            startNODE: false,
            position: CGPoint(x: 150, y: 150),
            type: .end,
            color: .green,
            nextNode: [block2.id, block1.id, block3.id]
        )
        block0.nextNode.append(block4.id)
        blocks.append(contentsOf: [block0, block1, block2, block3, block4])
        
        // Update the @State variable
        blockList = blocks
    }
}


#Preview {
    Node()
}
