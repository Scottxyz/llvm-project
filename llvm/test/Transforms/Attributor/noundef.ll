; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --check-attributes
; RUN: opt -attributor -enable-new-pm=0 -attributor-manifest-internal  -attributor-max-iterations-verify -attributor-annotate-decl-cs -attributor-max-iterations=1 -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_CGSCC_NPM,NOT_CGSCC_OPM,NOT_TUNIT_NPM,IS__TUNIT____,IS________OPM,IS__TUNIT_OPM
; RUN: opt -aa-pipeline=basic-aa -passes=attributor -attributor-manifest-internal  -attributor-max-iterations-verify -attributor-annotate-decl-cs -attributor-max-iterations=1 -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_CGSCC_OPM,NOT_CGSCC_NPM,NOT_TUNIT_OPM,IS__TUNIT____,IS________NPM,IS__TUNIT_NPM
; RUN: opt -attributor-cgscc -enable-new-pm=0 -attributor-manifest-internal  -attributor-annotate-decl-cs -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_TUNIT_NPM,NOT_TUNIT_OPM,NOT_CGSCC_NPM,IS__CGSCC____,IS________OPM,IS__CGSCC_OPM
; RUN: opt -aa-pipeline=basic-aa -passes=attributor-cgscc -attributor-manifest-internal  -attributor-annotate-decl-cs -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_TUNIT_NPM,NOT_TUNIT_OPM,NOT_CGSCC_OPM,IS__CGSCC____,IS________NPM,IS__CGSCC_NPM

declare void @unknown()

declare void @bar(i32*)

define void @foo() {
; CHECK-LABEL: define {{[^@]+}}@foo() {
; CHECK-NEXT:    [[X:%.*]] = alloca i32, align 4
; CHECK-NEXT:    call void @unknown()
; CHECK-NEXT:    call void @bar(i32* noundef nonnull align 4 dereferenceable(4) [[X]])
; CHECK-NEXT:    ret void
;
  %x = alloca i32
  call void @unknown()
  call void @bar(i32* %x)
  ret void
}

define internal i8* @returned_dead() {
; CHECK-LABEL: define {{[^@]+}}@returned_dead() {
; CHECK-NEXT:    call void @unknown()
; CHECK-NEXT:    ret i8* undef
;
  call void @unknown()
  ret i8* null
}

define void @caller1() {
; CHECK-LABEL: define {{[^@]+}}@caller1() {
; CHECK-NEXT:    [[TMP1:%.*]] = call i8* @returned_dead()
; CHECK-NEXT:    ret void
;
  call i8* @returned_dead()
  ret void
}

define internal void @argument_dead_callback_callee(i8* %c) {
; CHECK-LABEL: define {{[^@]+}}@argument_dead_callback_callee
; CHECK-SAME: (i8* noalias nocapture nofree readnone align 536870912 [[C:%.*]]) {
; CHECK-NEXT:    call void @unknown()
; CHECK-NEXT:    ret void
;
  call void @unknown()
  ret void
}

define void @callback_caller() {
; IS__TUNIT____-LABEL: define {{[^@]+}}@callback_caller() {
; IS__TUNIT____-NEXT:    call void @callback_broker(void (i8*)* noundef @argument_dead_callback_callee, i8* noalias nocapture nofree readnone align 536870912 undef)
; IS__TUNIT____-NEXT:    ret void
;
; IS__CGSCC____-LABEL: define {{[^@]+}}@callback_caller() {
; IS__CGSCC____-NEXT:    call void @callback_broker(void (i8*)* noundef @argument_dead_callback_callee, i8* noalias nocapture nofree noundef readnone align 536870912 null)
; IS__CGSCC____-NEXT:    ret void
;
  call void @callback_broker(void (i8*)* @argument_dead_callback_callee, i8* null)
  ret void
}

declare !callback !0 void @callback_broker(void (i8*)*, i8*)
!1 = !{i64 0, i64 1, i1 false}
!0 = !{!1}
