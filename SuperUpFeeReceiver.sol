pragma solidity 0.8.4;
import '@openzeppelin/contracts/access/Ownable.sol';

abstract contract SuperUP {
    uint public marketingFee;
}

contract SuperUpFeeReceiver is Ownable {
    address public _superUpToken = 0x2B912f87E72A7ec9F303e5315f7A297132Ebd8FD; //SuperUP address
    address public _donationAddress = 0x8B99F3660622e21f2910ECCA7fBe51d654a1517D; //Binance charity Mainnet
    address public _marketingAddress = 0xf1DE7ed4a1A9C0dAe1365279Ffbf18a7a0C2e36E; //SuperUP marketing wallet
    address public _buybackAddress = 0xb0dBd2F14c1A1cf5C6b3F937263F0060239aa710; //SuperUP buyaback wallet
    
    uint public _donationFee = 1;
    uint public _buybackFee = 2;
    uint public donations;
    
    event Donation(uint);
    
    constructor () {
    }
    
    function setDonationWallet(address donationAddress) external onlyOwner() {
        _donationAddress = donationAddress;
    }
    
    function setMarketingWallet(address marketingAddress) external onlyOwner() {
        _marketingAddress = marketingAddress;
    }
    
    function setBuybackWallet(address buybackAddress) external onlyOwner() {
        _buybackAddress = buybackAddress;
    }
    
    function setTokenAddress(address tokenAddress) external onlyOwner() {
        _superUpToken = tokenAddress;
    }
    
    function setDonationFee(uint donationFee) external onlyOwner() {
        _donationFee = donationFee;
    }
    
    function setBuybackFee(uint buybackFee) external onlyOwner() {
        _buybackFee = buybackFee;
    }
    
    function resetDonations() external onlyOwner() {
        donations = 0;
    }
    
    receive() external payable {
        uint marketingFee = SuperUP(_superUpToken).marketingFee();
    
        uint donation = msg.value / marketingFee * _donationFee;
        uint buyback = msg.value / marketingFee * _buybackFee;
        uint rest = msg.value - donation - buyback;
        donations = donations + donation;
        
        payable(_donationAddress).call{ value: donation }('');
        payable(_buybackAddress).call{ value: buyback }('');
        payable(_marketingAddress).call{ value: rest }('');
        
        emit Donation(donation);
    }
    
    // Withdraw ETH that gets stuck in contract by accident.
    function emergencyWithdraw() external onlyOwner() {
        uint balance = address(this).balance;
        payable(_marketingAddress).call{ value: balance }('');
    }
}
