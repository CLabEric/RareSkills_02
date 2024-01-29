# Markdown file 3: Revisit the solidity events tutorial. How can OpenSea quickly determine which NFTs an address owns if most NFTs don’t use #ERC721 enumerable? Explain how you would accomplish this if you were creating an NFT marketplace

A marketplace can write a script to get the transfer events associated with this address. They can also write a listener script for when new transfer events get emitted going forward.

Alternatively can use multicall contract.
