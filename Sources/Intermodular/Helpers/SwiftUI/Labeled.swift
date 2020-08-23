//
// Copyright (c) Vatsal Manot
//

import SwiftUI

public struct Labeled<Label: View, Control: View>: View {
    @usableFromInline
    let label: Label
    
    @usableFromInline
    let control: Control
    
    public var body: some View {
        HStack {
            label
            
            Spacer()
            
            control
        }
    }
}

extension Labeled {
    @inlinable
    public init(
        @ViewBuilder control: () -> Control,
        @ViewBuilder label: () -> Label
    ) {
        self.label = label()
        self.control = control()
    }
}

extension Labeled where Label == Text {
    @inlinable
    public init(
        _ title: Text,
        @ViewBuilder control: () -> Control
    ) {
        self.init(control: control, label: { title })
    }
    
    @inlinable
    public init<S: StringProtocol>(
        _ title: S,
        @ViewBuilder control: () -> Control
    ) {
        self.init(Text(title), control: control)
    }
}