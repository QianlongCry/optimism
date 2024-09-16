package forking

import (
	"fmt"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/state"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/ethdb"
	"github.com/ethereum/go-ethereum/trie/utils"
	"github.com/ethereum/go-ethereum/triedb"
)

// ForkDB is a virtual state database: it wraps a forked accounts trie,
// and can maintain a state diff, so we can mutate the forked state,
// and even finalize state changes (so we can accurately measure things like cold storage gas cost).
type ForkDB struct {
	active *ForkedAccountsTrie
}

var _ state.Database = (*ForkDB)(nil)

func NewForkDB(source ForkSource) *ForkDB {
	return &ForkDB{active: &ForkedAccountsTrie{
		stateRoot:   source.StateRoot(),
		src:         source,
		accountDiff: make(map[common.Address]*accountDiff),
		codeDiff:    make(map[common.Hash][]byte),
	}}
}

// fakeRoot is just a marker; every account we load into the fork-db has this storage-root.
// When opening a storage-trie, we sanity-check we have this root, or an empty trie.
// And then just return the same global trie view for storage reads/writes.
var fakeRoot = common.Hash{0: 42}

func (f *ForkDB) OpenTrie(root common.Hash) (state.Trie, error) {
	if f.active.stateRoot != root {
		return nil, fmt.Errorf("active fork is at %s, but tried to open %s", f.active.stateRoot, root)
	}
	return f.active, nil
}

func (f *ForkDB) OpenStorageTrie(stateRoot common.Hash, address common.Address, root common.Hash, trie state.Trie) (state.Trie, error) {
	if f.active.stateRoot != stateRoot {
		return nil, fmt.Errorf("active fork is at %s, but tried to open account %s of state %s", f.active.stateRoot, address, stateRoot)
	}
	if _, ok := trie.(*ForkedAccountsTrie); !ok {
		return nil, fmt.Errorf("ForkDB tried to open non-fork storage-trie %v", trie)
	}
	if root != fakeRoot && root != types.EmptyRootHash {
		return nil, fmt.Errorf("ForkDB unexpectedly was queried with real looking storage root: %s", root)
	}
	return f.active, nil
}

func (f *ForkDB) CopyTrie(trie state.Trie) state.Trie {
	if st, ok := trie.(*ForkedAccountsTrie); ok {
		return st.Copy()
	}
	panic(fmt.Errorf("ForkDB tried to copy non-fork trie %v", trie))
}

func (f *ForkDB) ContractCode(addr common.Address, codeHash common.Hash) ([]byte, error) {
	return f.active.ContractCode(addr, codeHash)
}

func (f *ForkDB) ContractCodeSize(addr common.Address, codeHash common.Hash) (int, error) {
	return f.active.ContractCodeSize(addr, codeHash)
}

func (f *ForkDB) DiskDB() ethdb.KeyValueStore {
	panic("DiskDB() during active Fork is not supported")
}

func (f *ForkDB) PointCache() *utils.PointCache {
	panic("PointCache() is not supported")
}

func (f *ForkDB) TrieDB() *triedb.Database {
	panic("TrieDB() during active Fork is not supported")
}
