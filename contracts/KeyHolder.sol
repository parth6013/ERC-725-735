// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "./ERC725.sol";


 contract KeyHolder is ERC725 {

    uint256 executionNonce;

    struct Execution {
        address to;
        uint256 value;
        bytes data;
        bool approved;
        bool executed;
    }


    mapping (bytes32 => Key) keys;
    mapping (uint256 => bytes32[]) keysByPurpose;
    mapping (uint256 => Execution) executions;

// event to emit if execution failed
event ExecutionFailed(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);


// constructor for key holder which assign caller with key with purpose 1
       function KeyHolder1() public {

        //  use encode pack or encode   
        bytes32  _key = keccak256(abi.encodePacked(msg.sender));
        keys[_key].key = _key;
        keys[_key].purpose = 1;
        keys[_key].keyType = 1;
        keysByPurpose[1].push(_key);
        emit KeyAdded(_key, keys[_key].purpose, 1);
    }

// returns all the informaation about key when provided 32 bit hash key
    function   getKey(bytes32 _key)
        public
        override
        view
        returns(uint256 purpose, uint256 keyType, bytes32 key)
    {
        return (keys[_key].purpose, keys[_key].keyType, keys[_key].key);
    }

// returns purpose of the key
    function getKeyPurpose(bytes32 _key)
        public
        override
        view
        returns(uint256 purpose)
    {
        return (keys[_key].purpose);
    }
// gives array of key of required purpose
    function getKeysByPurpose(uint256 _purpose)
        public
        override
        view
        returns(bytes32[] memory _keys)
    {
        return keysByPurpose[_purpose];
    }
// function to add key
    function addKey(bytes32 _key, uint256 _purpose, uint256 _type)
        public
        override
        returns (bool success)
    {
        require(keys[_key].key != _key, "Key already exists"); // Key should not already exist
        if (msg.sender != address(this)) {
          require(keyHasPurpose(keccak256(abi.encodePacked(msg.sender)), 1), "Sender does not have management key"); // Sender has MANAGEMENT_KEY
        }

        keys[_key].key = _key;
        keys[_key].purpose = _purpose;
        keys[_key].keyType = _type;

        keysByPurpose[_purpose].push(_key);

        emit KeyAdded(_key, _purpose, _type);

        return true;
    }
// function to  approve nonce
    function approve(uint256 _id, bool _approve)
        public
        override
        returns (bool success)
    {
        require(keyHasPurpose(keccak256(abi.encodePacked(msg.sender)), 2), "Sender does not have action key");

        emit Approved(_id, _approve);

        if (_approve == true) {
            executions[_id].approved = true;
            // success = executions[_id].to.call(executions[_id].data);

            success=true;
            if (success) {
                executions[_id].executed = true;
                emit Executed(
                    _id,
                    executions[_id].to,
                    executions[_id].value,
                    executions[_id].data
                );
                return true;
            } else {
                emit ExecutionFailed(
                    _id,
                    executions[_id].to,
                    executions[_id].value,
                    executions[_id].data
                );
                return false;
            }
        } else {
            executions[_id].approved = false;
        }
        return true;
    }
// function to execute nonce
    function execute(address _to, uint256 _value, bytes memory _data)
        public
        override
        returns (uint256 executionId)
    {
        require(!executions[executionNonce].executed, "Already executed");
        executions[executionNonce].to = _to;
        executions[executionNonce].value = _value;
        executions[executionNonce].data = _data;

        emit ExecutionRequested(executionNonce, _to, _value, _data);

        if (keyHasPurpose(keccak256(abi.encodePacked(msg.sender)),1) || keyHasPurpose(keccak256(abi.encodePacked(msg.sender)),2)) {
            approve(executionNonce, true);
        }

        executionNonce++;
        return executionNonce-1;
    }
// function to remove key 
    function removeKey(bytes32 _key)
        public
        returns (bool success)
    {
        require(keys[_key].key == _key, "No such key");
        emit KeyRemoved(keys[_key].key, keys[_key].purpose, keys[_key].keyType);

        /* uint index;
        (index,) = keysByPurpose[keys[_key].purpose.indexOf(_key);
        keysByPurpose[keys[_key].purpose.removeByIndex(index); */

        delete keys[_key];

        return true;
    }
// function to check purpose of key 
    function keyHasPurpose(bytes32 _key, uint256 _purpose)
        public
        view
        returns(bool result)
    {
        bool isThere;
        if (keys[_key].key == 0) return false;
        isThere = keys[_key].purpose <= _purpose;
        return isThere;
    }


}
