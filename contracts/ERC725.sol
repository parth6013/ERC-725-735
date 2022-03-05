// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

abstract contract ERC725{

    // Keys and their purpose

    uint256 constant MANAGEMENT_KEY = 1;
    // 1: MANAGEMENT keys, which can manage the identity
    uint256 constant ACTION_KEY = 2;
     // 2: EXECUTION keys, which perform actions in this identities name (signing, logins, transactions, etc.)
    uint256 constant CLAIM_SIGNER_KEY = 3;
     // 3: CLAIM signer keys, used to sign claims on other identities which need to be revokable.
    uint256 constant ENCRYPTION_KEY = 4;
    // 4: ENCRYPTION keys, used to encrypt data e.g. hold in claims.


    // Events
    event KeyAdded(bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);
    event KeyRemoved(bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);
    event ExecutionRequested(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);
    event Executed(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);
    event Approved(uint256 indexed executionId, bool approved);

// structyre of key  
    struct Key {
        uint256 purpose; //e.g., MANAGEMENT_KEY = 1, ACTION_KEY = 2, etc.
        uint256 keyType; // e.g. 1 = ECDSA, 2 = RSA, etc, for signature algorithm
        bytes32 key;
    }


    // Functions
    function getKey(bytes32 _key) public view virtual returns(uint256 purpose, uint256 keyType, bytes32 key);
    function getKeyPurpose(bytes32 _key) public view virtual returns(uint256 purpose); 
    function getKeysByPurpose(uint256 _purpose) public view virtual returns(bytes32[] memory keys);
    function addKey(bytes32 _key, uint256 _purpose, uint256 _keyType) public virtual returns (bool success);
    function execute(address _to, uint256 _value, bytes memory  _data) public virtual returns (uint256 executionId);
    function approve(uint256 _id, bool _approve) public virtual returns (bool success);    





}