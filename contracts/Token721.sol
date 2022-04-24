// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./INTERFACES/artifacts/IERC165.sol";
import "./INTERFACES/artifacts/IERC721.sol";
import "./INTERFACES/artifacts/IERC721Receiver.sol";

contract Token721 is IERC165, IERC721 {
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // -------//

    function supportsInterface(bytes4 interfaceId) public view virtual override returns(bool){
        return interfaceId == type(IERC721).interfaceId;
    }

    // ------//

    function balanceOf(address owner) public view virtual override returns(uint256){
        require(owner != address(0), "ERC721 ERROR : zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns(address){
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721 ERROR: token id does not exist");
        return owner;
    }

    function approve(address to, uint256 tokenId) public virtual payable override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721 ERROR: Destination address must be different");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "ERC721 ERROR: you are not the owner or you dont have permissions");
        _approve(to, tokenId);

    }

    function getApproved(uint256 tokenId) public view virtual override returns(address) {
        require(_exists(tokenId), "ERC721 ERROR: tokeniD does not exist");
        return _tokenApprovals[tokenId];

    }

    function setApprovalForAll(address operator, bool approved) public virtual override{
        require(operator != msg.sender, "ERC721 ERROR: operator address must be different");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function _approve(address to, uint256 tokenId) internal virtual{
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns(bool){
        return _operatorApprovals[owner][operator];
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual payable override{
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual payable override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721 ERROR: you are not the order or you dont have permissions");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual{
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721 ERROR: transfer to non ERC721Receiver implementer");
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual payable override{
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721 ERROR: you are not the owner or you dont have permissions");

        _transfer(from, to, tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual{
        require(ownerOf(tokenId) == from, "ERC721 ERROR: token Id does not exist");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }


    function _safeMint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) public {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721 Error: transfer to non ERC721Receiver implementer");
    }


    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721 ERROR: mint to the zero address");
        require(!_exists(tokenId), "ERC721 ERROR: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

    }

    // -------- // 

    function _checkOnERC721Received(address from, address to, uint256 tokenId,bytes memory _data) private returns (bool){
        if(isContract(to)){
            try IERC721Receiver(to).onERC721Receiver(msg.sender, from, tokenId, _data) returns(bytes4) {
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721 transfer to non ERC721Receiver implementer");
                } else {
                    // solhint-disable-next-line no-inline-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                    
                }

                
            }
        } else {
            return true;
        }
        return true;

    }

    function isContract(address _addr) private view returns(bool){
        uint size; 
        assembly {
            size := extcodesize(_addr)            
        }
        return(size > 0);        
    }

    function _exists(uint256 tokenId) internal view virtual returns(bool){
        return _owners[tokenId] != address(0);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual{ }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns(bool){
        require(_exists(tokenId), "ERC721 ERROR: tokenId does not exist");
        address owner = ownerOf(tokenId);
        return(spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }
} 