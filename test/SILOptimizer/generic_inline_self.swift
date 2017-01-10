// RUN: %target-swift-frontend -emit-sil -primary-file %s | %FileCheck %s

// Test to ensure that mandatory inlining of generics with a dynamic Self
// substitution works correctly with thick_metatype instructions and SIL
// type lowering.

func makeInstance<T: C>(_: T.Type) -> T {
    return T()
}

@_transparent
func makeInstanceTransparent<T: C>(_: T.Type) -> T {
    return T()
}

@_transparent
func makeInstanceTransparentProtocol<T: P>(_: T.Type) -> T {
    return T()
}

protocol P {
  init()
}

class C : P {
  required init() {}

// CHECK-LABEL: sil hidden @_TFC19generic_inline_self1C18returnsNewInstancefT_DS0_ : $@convention(method) (@guaranteed C) -> @owned C
// CHECK:       bb0(%0 : $C):
// CHECK:         [[FN:%.*]] = function_ref @_TF19generic_inline_self12makeInstanceuRxCS_1CrFMxx : $@convention(thin) <τ_0_0 where τ_0_0 : C> (@thick τ_0_0.Type) -> @owned τ_0_0
// CHECK-NEXT:    [[METATYPE:%.*]] = value_metatype $@thick @dynamic_self C.Type, %0 : $C
// CHECK-NEXT:    [[RESULT:%.*]] = apply [[FN]]<@dynamic_self C>([[METATYPE]]) : $@convention(thin) <τ_0_0 where τ_0_0 : C> (@thick τ_0_0.Type) -> @owned τ_0_0
// CHECK-NEXT:    return [[RESULT]] : $C
  func returnsNewInstance() -> Self {
    return makeInstance(type(of: self))
  }

// CHECK-LABEL: sil hidden @_TFC19generic_inline_self1C29returnsNewInstanceTransparentfT_DS0_ : $@convention(method) (@guaranteed C) -> @owned C
// CHECK:       bb0(%0 : $C):
// CHECK:         [[METATYPE:%.*]] = metatype $@thick @dynamic_self C.Type
// CHECK-NEXT:    [[STATIC_METATYPE:%.*]] = upcast [[METATYPE]] : $@thick @dynamic_self C.Type to $@thick C.Type
// CHECK-NEXT:    [[FN:%.*]] = class_method [[STATIC_METATYPE]] : $@thick C.Type, #C.init!allocator.1 : (C.Type) -> () -> C , $@convention(method) (@thick C.Type) -> @owned C
// CHECK-NEXT:    [[RESULT2:%.*]] = apply [[FN]]([[STATIC_METATYPE]]) : $@convention(method) (@thick C.Type) -> @owned C
// CHECK-NEXT:    [[RESULT:%.*]] = unchecked_ref_cast [[RESULT2]] : $C to $C
// CHECK-NEXT:    return [[RESULT]] : $C
  func returnsNewInstanceTransparent() -> Self {
    return makeInstanceTransparent(type(of: self))
  }

// CHECK-LABEL: sil hidden @_TFC19generic_inline_self1C37returnsNewInstanceTransparentProtocolfT_DS0_ : $@convention(method) (@guaranteed C) -> @owned C
// CHECK:       bb0(%0 : $C):
// CHECK:         [[METATYPE:%.*]] = metatype $@thick @dynamic_self C.Type
// CHECK-NEXT:    [[STATIC_METATYPE:%.*]] = upcast [[METATYPE]] : $@thick @dynamic_self C.Type to $@thick C.Type
// CHECK-NEXT:    [[FN:%.*]] = class_method [[STATIC_METATYPE]] : $@thick C.Type, #C.init!allocator.1 : (C.Type) -> () -> C , $@convention(method) (@thick C.Type) -> @owned C
// CHECK-NEXT:    [[RESULT2:%.*]] = apply [[FN]]([[STATIC_METATYPE]]) : $@convention(method) (@thick C.Type) -> @owned C
// CHECK-NEXT:    tuple ()
// CHECK-NEXT:    tuple ()
// CHECK-NEXT:    return %5 : $C
  func returnsNewInstanceTransparentProtocol() -> Self {
    return makeInstanceTransparentProtocol(type(of: self))
  }
}

class D : C {}
