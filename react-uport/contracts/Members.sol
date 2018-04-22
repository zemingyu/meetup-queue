pragma solidity ^0.4.18;

library Members {
    struct Member {
        bool exists;
        uint index;
        bytes32 name;
        bool governor;
    }
    struct Data {
        bool initialised;
        mapping(address => Member) entries;
        address[] index;
    }

    event MemberAdded(address indexed _address, bytes32 _name, bool _governor, uint totalAfter);
    event MemberRemoved(address indexed _address, bytes32 _name, bool _governor, uint totalAfter);

    function init(Data storage self) public {
        require(!self.initialised);
        self.initialised = true;
    }
    function isMember(Data storage self, address _address) public view returns (bool) {
        return self.entries[_address].exists;
    }
    function isGovernor(Data storage self, address _address) public view returns (bool) {
        return self.entries[_address].governor;
    }
    function add(Data storage self, address _address, bytes32 _name, bool _governor) public {
        require(!self.entries[_address].exists);
        self.index.push(_address);
        self.entries[_address] = Member(true, self.index.length - 1, _name, _governor);
        MemberAdded(_address, _name, _governor, self.index.length);
    }
    function remove(Data storage self, address _address) public {
        require(self.entries[_address].exists);
        uint removeIndex = self.entries[_address].index;
        MemberRemoved(_address, self.entries[_address].name, self.entries[_address].governor, self.index.length - 1);
        uint lastIndex = self.index.length - 1;
        address lastIndexAddress = self.index[lastIndex];
        self.index[removeIndex] = lastIndexAddress;
        self.entries[lastIndexAddress].index = removeIndex;
        delete self.entries[_address];
        if (self.index.length > 0) {
            self.index.length--;
        }
    }
    function length(Data storage self) public view returns (uint) {
        return self.index.length;
    }
}
