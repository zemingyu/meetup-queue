pragma solidity ^0.4.19;


// Based on https://github.com/axiomzen/cryptokitties-bounty/blob/master/contracts/KittyAccessControl.sol
contract MeetupAccessControl {

  // The addresses of the accounts (or contracts) that can execute actions within each roles.
  address public organiserAddress;
  address public assistantAddress_1;
  address public assistantAddress_2;

  /// Access modifier for organiser-only functionality
  modifier onlyOrganiser() {
      require(msg.sender == organiserAddress);
      _;
  }

  /// Access modifier for organiser-only functionality
  modifier onlyAssistant() {
      require(
        msg.sender == organiserAddress ||
        msg.sender == assistantAddress_1 ||
        msg.sender == assistantAddress_2
      );
      _;
  }

  /// @dev Assigns a new address to act as the assistant. Only available to the current CEO.
  /// @param assistantAddress_1 The address of the new assistant
  function setAssistant_1(address _newAssistant) public onlyAssistant {
      require(_newAssistant != address(0));

      assistantAddress_1 = _newAssistant;
  }

  /// @dev Assigns a new address to act as the assistant. Only available to the current CEO.
  /// @param assistantAddress_2 The address of the new assistant
  function setAssistant_1(address _newAssistant) public onlyAssistant {
      require(_newAssistant != address(0));

      assistantAddress_2 = _newAssistant;
  }


  /// @dev Assigns a new address to act as the organiser. Only available to the current organiser.
  /// @param _newOrganiser The address of the new organiser
  function setOrganiser(address _newOrganiser) public onlyOrganiser {
      require(_newOrganiser != address(0));

      organiserAddress = _newOrganiser;
  }

  /// @dev Modifier to allow actions only when the contract IS NOT paused
  modifier whenNotPaused() {
      require(!paused);
      _;
  }

  /// @dev Modifier to allow actions only when the contract IS paused
  modifier whenPaused {
      require(paused);
      _;
  }

  /// @dev Called by any "assistant" role to pause the contract. Used only when
  ///  a bug or exploit is detected and we need to limit damage.
  function pause() public onlyAssistant whenNotPaused {
      paused = true;
  }

  /// @dev Unpauses the smart contract. Can only be called by the CEO, since
  ///  one reason we may pause the contract is when CFO or COO accounts are
  ///  compromised.
  function unpause() public onlyOrganiser whenPaused {
      // can't unpause if contract was upgraded
      paused = false;
  }

}
