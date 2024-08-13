package program

import (
	"bytes"
	"debug/elf"
	"fmt"
	"io"

	"github.com/ethereum-optimism/optimism/cannon/mipsevm64"
)

const HEAP_START = 0x10_00_00_00_00_00_00_00

type CreateInitialFPVMState[T mipsevm64.FPVMState] func(pc, heapStart uint64) T

func LoadELF[T mipsevm64.FPVMState](f *elf.File, initState CreateInitialFPVMState[T]) (T, error) {
	var empty T
	s := initState(f.Entry, HEAP_START)

	for i, prog := range f.Progs {
		if prog.Type == 0x70000003 { // MIPS_ABIFLAGS
			continue
		}

		r := io.Reader(io.NewSectionReader(prog, 0, int64(prog.Filesz)))
		if prog.Filesz != prog.Memsz {
			if prog.Type == elf.PT_LOAD {
				if prog.Filesz < prog.Memsz {
					r = io.MultiReader(r, bytes.NewReader(make([]byte, prog.Memsz-prog.Filesz)))
				} else {
					return empty, fmt.Errorf("invalid PT_LOAD program segment %d, file size (%d) > mem size (%d)", i, prog.Filesz, prog.Memsz)
				}
			} else {
				return empty, fmt.Errorf("program segment %d has different file size (%d) than mem size (%d): filling for non PT_LOAD segments is not supported", i, prog.Filesz, prog.Memsz)
			}
		}

		if prog.Vaddr+prog.Memsz >= HEAP_START {
			return empty, fmt.Errorf("program %d overlaps with heap: %x - %x (size: %x). The heap start offset must be reconfigured", i, prog.Vaddr, prog.Vaddr+prog.Memsz, prog.Memsz)
		}
		if err := s.GetMemory().SetMemoryRange(prog.Vaddr, r); err != nil {
			return empty, fmt.Errorf("failed to read program segment %d: %w", i, err)
		}
	}

	return s, nil
}