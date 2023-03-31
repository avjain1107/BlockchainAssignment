// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC20.sol";

contract Coins is IERC20 {

    mapping(address => uint256) private balance;

    mapping(address =>mapping(address=>uint256)) private allowed;

    uint256  private totalToken;

    address private owner;

    constructor (){
        owner = msg.sender;
        balance[owner]=1000;
    }

    function mint( address _to) external {
        require(msg.sender == owner,"Not the owner of contract");
        balance[_to]=balance[_to]+1;
        totalToken+=1;
    }

    function totalSupply() external view returns (uint256){
          return totalToken;
    }

    function balanceOf(address _account) external view returns (uint256){
        return balance[_account];
    }

    function transfer(address _to, uint256 _amount) external returns (bool){
        require(_amount<= balance[msg.sender]);
        balance[msg.sender]= balance[msg.sender]- _amount;
        balance[_to]= balance[_to]+ _amount;
        emit Transfer(msg.sender,_to,_amount);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256){
        return allowed[_owner][_spender];

    }

    function approve(address _spender, uint256 _amount) external returns (bool){
        address _owner= msg.sender;
        require(balance[_owner]>=_amount);
        allowed[_owner][_spender] = _amount;
        emit Approval(_owner,_spender,_amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool){
        address spender= msg.sender;
        require(_amount <= balance[_from]);
        require(_amount <= allowed[_from][spender]);
        balance[_from] = balance[_from] - _amount;
        allowed[_from][spender] = allowed[_from][spender] - _amount;
        balance[_to]= balance[_to] + _amount;
        emit Transfer(_from,_to,_amount);
        return true;
    }
 
   
}

contract Assets is IERC721{
  
    uint256 public tokenCount;

    // mapping (TokenID->Address)
    mapping(uint256=>address)private _ownerOf;

    // mapping (Address->Balance)
    mapping(address=>uint256) private _balances;

    //mapping (tokenId->ApprovedAddress)
    mapping(uint256=>address) private _tokenApproval;

    //mapping(Owner=>(toAddress=>(true/false)))
    mapping(address=>mapping(address=>bool)) private _operatorApproval;

    //mapping(tokenCound-> tokenPrice)
    mapping(uint256=>uint256) public _price;
    

   

    function mint(uint tokenPrice) public returns(uint256) {
        tokenCount+=1;
        _ownerOf[tokenCount]=msg.sender;
        _balances[msg.sender]+=1;
        _price[tokenCount]=tokenPrice;
        return tokenCount;
        
    }

    function balanceOf(address owner) public view returns(uint256){
        require(owner != address(0),"Address zero is not valid");
        return _balances[owner];

    }

    function ownerOf(uint tokenId) public view returns (address){
        address owner= _ownerOf[tokenId];
        require(owner != address(0),"Invalid token id");
        return owner;
    }

    function transferFrom(address from,address to,uint256 _tokenId) public {
        address owner = _ownerOf[_tokenId];
        require(owner != address(0),"Invalid token Id");
        require(msg.sender == owner || _tokenApproval[_tokenId]==msg.sender|| _operatorApproval[owner][msg.sender]==true,"called is not owner or not approved");
        require ( owner==from,"given from address is not the owner of tokenId");
        require(to != address(0),"cannot transfer to zero address");
        delete _tokenApproval[_tokenId];
        _balances[from]-=1;
        _balances[to]+=1;
        _ownerOf[_tokenId]=to;
        emit Transfer(from,to,_tokenId);

    }
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) public {
        transferFrom(from,to,tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {
         transferFrom(from,to,tokenId);
    }

    function approve(address to,uint256 _tokenId) public {
        address owner = _ownerOf[_tokenId];
        require( to != owner,"approved to current owner");
        require(msg.sender==owner|| isApprovedForAll(owner,msg.sender),"Caller is not owner or approved");
        _tokenApproval[_tokenId]=to;
        emit Approval(msg.sender,to,_tokenId);
    }

    function setApprovalForAll(address operator,bool approved) public {
        address owner= msg.sender;
        require(owner != operator,"approved to owner");
        _operatorApproval[owner][operator]=approved;
        emit ApprovalForAll(owner,operator,approved);
    }

    function getApproved(uint256 _deed) public view returns(address operator){
        require(_ownerOf[_deed]!=address(0),"Invalid Token ID");
        return _tokenApproval[_deed];
    }

    function isApprovedForAll(address owner,address operator) public view returns(bool){
        return _operatorApproval[owner][operator];
    }

    function getTokenPrice(uint256 tokenId) public view returns (uint256){
        require(_ownerOf[tokenId]!=address(0),"Token Id is invalid");
        return _price[tokenId];
    }

}

contract tokenSwap {
    address public coinsCon;
    address public assetsCon;
    address public owner;
    uint256  public tokenId;
    uint256 public tokenPrice;
    constructor ( address _assetsCon, address _coinsCon, uint256 _tokenId,uint256 _tokenPrice){
        coinsCon=_coinsCon;
        assetsCon=_assetsCon;
        tokenId=_tokenId;
        tokenPrice=_tokenPrice;
        owner =msg.sender;
    }
    IERC20 coin =IERC20(coinsCon);
    IERC721 asset= IERC721(assetsCon);
   

    function approveAssests()public {
        asset.approve(owner,tokenId);

    }
    function approveCoins()public {
        coin.approve(owner,tokenPrice);
    }

    function swapToken(address coinOwner,address assestOwner)public {
        coin.transferFrom(coinOwner,assestOwner,tokenPrice);
        asset.transferFrom(assestOwner,coinOwner,tokenId);
    }

}
