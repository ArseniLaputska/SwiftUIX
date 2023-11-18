//
// Copyright (c) Vatsal Manot
//

import SwiftUI

@frozen
public struct _VariadicViewAdapter<Source: View, Content: View>: View {
    private struct Root: _VariadicView.MultiViewRoot {
        var content: (_TypedVariadicView<Source>) -> Content
        
        func body(children: _VariadicView.Children) -> some View {
            content(_TypedVariadicView(children))
        }
    }
    
    private let source: Source
    private let content: (_TypedVariadicView<Source>) -> Content
    
    public init(
        _ source: Source,
        @ViewBuilder content: @escaping (_TypedVariadicView<Source>) -> Content
    ) {
        self.source = source
        self.content = content
    }
    
    public init(
        @ViewBuilder _ source: () -> Source,
        @ViewBuilder content: @escaping (_TypedVariadicView<Source>) -> Content
    ) {
        self.init(source(), content: content)
    }
    
    public init<Subview: View>(
        enumerating source: Source,
        @ViewBuilder subview: @escaping (Int, _VariadicViewChildren.Subview) -> Subview
    ) where Content == _ForEachSubview<Source, AnyHashable, Subview> {
        self.init(source) { content in
            _ForEachSubview(enumerating: content, enumerating: subview)
        }
    }
    
    public var body: some View {
        _VariadicView.Tree(Root(content: content)) {
            source
        }
    }
}

@frozen
public struct _TypedVariadicView<Content: View>: View {
    public var children: _VariadicViewChildren
    
    public var isEmpty: Bool {
        children.isEmpty
    }
    
    init(_ children: _VariadicView.Children) {
        self.children = _VariadicViewChildren(erasing: children)
    }
    
    public var body: some View {
        children
    }
}

extension _TypedVariadicView {
    public subscript<Key: _ViewTraitKey, Value>(
        _ key: Key.Type
    ) -> Value? where Key.Value == Optional<Value> {
        for child in children {
            if let result = child[key] {
                return result
            }
        }
        
        return nil
    }

    public subscript<Key: _ViewTraitKey, Value>(
        trait key: KeyPath<_ViewTraitKeys, Key.Type>
    ) -> Value? where Key.Value == Optional<Value> {
        self[_ViewTraitKeys()[keyPath: key]]
    }
}