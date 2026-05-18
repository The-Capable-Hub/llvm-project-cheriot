# RUN: llvm-mc %s -filetype=obj -o %t.o -triple=riscv64 -mattr=+xcheri,+xcheripurecap 2>&1 \
# RUN:     | not FileCheck %s "--implicit-check-not=warning:" --check-prefix WARNING
# RUN: llvm-readobj -r %t.o | FileCheck %s

## Ported from llvm/test/MC/Mips/cheri/chericap-size-not-known-yet.s
## The warnings from the original test do not appear to be implemented, it is
## unclear if that is by choice or if it just never was.

	.type	lmp_head,@object
	.data
	.globl	lmp_head
lmp_head:
	.chericap	lmp_head-2
	.size	lmp_head, 16

	.globl  external_symbol
	.globl  lmp_head_extern
lmp_head_extern:
	.chericap	external_symbol+1
	.size	lmp_head_extern, 16

.Llmp_head_local:
	.chericap	.Llmp_head_local+1
	.size	.Llmp_head_local, 16

.hidden .Llmp_head_local_unsized
.Llmp_head_local_unsized:
	.chericap	.Llmp_head_local_unsized+1
# WARNING: [[@LINE-1]]:{{[0-9]+}}: warning: creating a R_RISCV_CHERI_CAPABILITY relocation against an unsized defined symbol: .Llmp_head_local_unsized. This will probably result in incorrect values at run time.

.section .otherdata, "aw", %progbits
.Lreloc_text_local:
.chericap .Lfoo_start + 4
# WARNING: [[@LINE-1]]:{{[0-9]+}}: warning: creating a R_RISCV_CHERI_CAPABILITY relocation against an unsized defined symbol: .Lfoo_start. This will probably result in incorrect values at run time.
.Lreloc_text_global:
.chericap foo + 4

.text
.global foo
foo:
  nop
.Lfoo_start:
  nop

# CHECK-LABEL: Relocations [
# CHECK-NEXT:   Section (4) .rela.data {
# CHECK-NEXT:     0x0 R_RISCV_CHERI_CAPABILITY lmp_head 0xFFFFFFFFFFFFFFFE
# CHECK-NEXT:     0x10 R_RISCV_CHERI_CAPABILITY external_symbol 0x1
# CHECK-NEXT:     0x20 R_RISCV_CHERI_CAPABILITY .Llmp_head_local 0x1
# CHECK-NEXT:     0x30 R_RISCV_CHERI_CAPABILITY .Llmp_head_local_unsized 0x1
# CHECK-NEXT:   }
# CHECK-NEXT:   Section (6) .rela.otherdata {
# CHECK-NEXT:     0x0 R_RISCV_CHERI_CAPABILITY .Lfoo_start 0x4
# CHECK-NEXT:     0x10 R_RISCV_CHERI_CAPABILITY foo 0x4
# CHECK-NEXT:   }
