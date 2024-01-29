# ERC721A

1. **How does ERC721A save gas?**
   There are three main optimizations
   a. removes redundancies in the way OZ's ERC721Enumerable stores each token's metadata
   b. in a batch mint it updates an owner's balance once instead of per token in the batch.
   c. updates 'owner' data for a group tokens only once. The first token in a batch stores an owner and the rest do not, instead one can just look backwards through tokens until it finds an owner.

2. **Where does it add cost?**
   Most of the savings mentioned above save gas costs during mints. The catch is these costs are deferred to other transactions. For example if somebody mints a batch of tokens but later wants to sell only one of them then more updates to the state must be happen in order to keep the integrity of the accounting for owners.
