// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {CrowdFund} from "../src/CrowdFund.sol";
import {MockToken} from "../src/Mock.sol";


contract CrowdFundTest is Test {
    CrowdFund public cf;
    MockToken public mock;
    address random2 = makeAddr("random2");
    address creator = makeAddr("creator");

    function setUp() public {
        cf = new CrowdFund();

        vm.prank(random2);
        mock = new MockToken("Mock1","M1");
        console2.log("MOCK ADDRESS :", address(mock)); //0xE962c58ACdf0B69f33390a783ad1231994aA460B

        cf.createCampaign("deneme1", creator, 500, 600, 25);
        vm.deal(creator, 1 ether);
    }

    function test_contrubuteCampaign() public {
        vm.deal(random2, 1 ether);
        vm.prank(random2);
        cf.contrubuteCampaign{value: 2 wei}(0);

        assertEq(cf.getMoney(0), 2);
        assertEq(cf.getStatus(0), true);
       
       // skip(400);
        vm.expectRevert();
        cf.contrubuteCampaign{value: 0 wei}(0);
        
        skip(400);
        vm.prank(creator);
        cf.finishCampaign(0);
    
        vm.expectRevert();
        cf.contrubuteCampaign{value: 11 wei}(0);
}
    
    function test_finishCampaign() public {
        vm.deal(random2, 1 ether);
        vm.prank(random2);
        console2.log("CREATOR BALANCE  ONCE:", address(creator).balance);

        cf.contrubuteCampaign{value: 555 wei}(0);
        skip(26);
        cf.finishCampaign(0);

        console2.log("CREATOR BALANCE SONRA :", address(creator).balance);
    }

    function test_paybackCampaign() public {
        vm.deal(random2, 1 ether);

        vm.prank(random2);
        cf.contrubuteCampaign{value: 155 wei}(0);

        vm.prank(random2);
        console2.log(
            "random2 contrubuted amount  :",
            cf.getContrubutedAmount(0)
        );

        console2.log("random2 BALANCE  :", address(random2).balance);

        skip(100);
        vm.prank(creator);
        cf.finishCampaign(0);
        console2.log("CROWDFUND STATUS : ");
        console2.logBool(cf.getStatus(0));
        uint256 balance = cf.balanceof();
        console2.log("CONTRACT BALANCE  :", balance);

        vm.prank(random2);
        cf.paybackCampaign(0);
        console2.log("random2 BALANCE SONRA :", address(random2).balance);
    }

}
