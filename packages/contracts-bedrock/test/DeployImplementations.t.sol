// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { Test, stdStorage, StdStorage } from "forge-std/Test.sol";

import { DelayedWETH } from "src/dispute/DelayedWETH.sol";
import { PreimageOracle } from "src/cannon/PreimageOracle.sol";
import { MIPS } from "src/cannon/MIPS.sol";
import { DisputeGameFactory } from "src/dispute/DisputeGameFactory.sol";

import { SuperchainConfig } from "src/L1/SuperchainConfig.sol";
import { ProtocolVersions } from "src/L1/ProtocolVersions.sol";
import { OPStackManager } from "src/L1/OPStackManager.sol";
import { OptimismPortal2 } from "src/L1/OptimismPortal2.sol";
import { SystemConfig } from "src/L1/SystemConfig.sol";
import { L1CrossDomainMessenger } from "src/L1/L1CrossDomainMessenger.sol";
import { L1ERC721Bridge } from "src/L1/L1ERC721Bridge.sol";
import { L1StandardBridge } from "src/L1/L1StandardBridge.sol";
import { OptimismMintableERC20Factory } from "src/universal/OptimismMintableERC20Factory.sol";
import { ProxyAdmin } from "src/universal/ProxyAdmin.sol";
import { Proxy } from "src/universal/Proxy.sol";

import {
    DeployImplementationsInput,
    DeployImplementations,
    DeployImplementationsInterop,
    DeployImplementationsOutput
} from "scripts/DeployImplementations.s.sol";

contract DeployImplementationsInput_Test is Test {
    DeployImplementationsInput dii;

    uint256 withdrawalDelaySeconds = 100;
    uint256 minProposalSizeBytes = 200;
    uint256 challengePeriodSeconds = 300;
    uint256 proofMaturityDelaySeconds = 400;
    uint256 disputeGameFinalityDelaySeconds = 500;
    string release = "non-standard-release"; // this means implementation contracts will be deployed
    SuperchainConfig superchainConfigProxy = SuperchainConfig(makeAddr("superchainConfigProxy"));
    ProtocolVersions protocolVersionsProxy = ProtocolVersions(makeAddr("protocolVersionsProxy"));

    function setUp() public {
        dii = new DeployImplementationsInput();
    }

    function test_getters_whenNotSet_revert() public {
        vm.expectRevert("DeployImplementationsInput: not set");
        dii.withdrawalDelaySeconds();

        vm.expectRevert("DeployImplementationsInput: not set");
        dii.minProposalSizeBytes();

        vm.expectRevert("DeployImplementationsInput: not set");
        dii.challengePeriodSeconds();

        vm.expectRevert("DeployImplementationsInput: not set");
        dii.proofMaturityDelaySeconds();

        vm.expectRevert("DeployImplementationsInput: not set");
        dii.disputeGameFinalityDelaySeconds();

        vm.expectRevert("DeployImplementationsInput: not set");
        dii.release();

        vm.expectRevert("DeployImplementationsInput: not set");
        dii.superchainConfigProxy();

        vm.expectRevert("DeployImplementationsInput: not set");
        dii.protocolVersionsProxy();

        vm.expectRevert("DeployImplementationsInput: not set");
        dii.superchainProxyAdmin();
    }

    function test_superchainProxyAdmin_whenNotSet_reverts() public {
        vm.expectRevert("DeployImplementationsInput: not set");
        dii.superchainProxyAdmin();

        dii.set(dii.superchainConfigProxy.selector, address(superchainConfigProxy));
        vm.expectRevert();
        dii.superchainProxyAdmin();

        Proxy noAdminProxy = new Proxy(address(0));
        dii.set(dii.superchainConfigProxy.selector, address(noAdminProxy));
        vm.expectRevert("DeployImplementationsInput: not set");
        dii.superchainProxyAdmin();
    }

    function test_superchainProxyAdmin_succeeds() public {
        Proxy proxyWithAdminSet = new Proxy(msg.sender);
        dii.set(dii.superchainConfigProxy.selector, address(proxyWithAdminSet));
        ProxyAdmin proxyAdmin = dii.superchainProxyAdmin();
        assertEq(address(msg.sender), address(proxyAdmin), "100");
    }
}

contract DeployImplementationsOutput_Test is Test {
    DeployImplementationsOutput dio;

    function setUp() public {
        dio = new DeployImplementationsOutput();
    }

    function test_set_succeeds() public {
        Proxy proxy = new Proxy(address(0));
        address opsmImpl = address(makeAddr("opsmImpl"));
        vm.prank(address(0));
        proxy.upgradeTo(opsmImpl);

        OPStackManager opsmProxy = OPStackManager(address(proxy));
        OptimismPortal2 optimismPortalImpl = OptimismPortal2(payable(makeAddr("optimismPortalImpl")));
        DelayedWETH delayedWETHImpl = DelayedWETH(payable(makeAddr("delayedWETHImpl")));
        PreimageOracle preimageOracleSingleton = PreimageOracle(makeAddr("preimageOracleSingleton"));
        MIPS mipsSingleton = MIPS(makeAddr("mipsSingleton"));
        SystemConfig systemConfigImpl = SystemConfig(makeAddr("systemConfigImpl"));
        L1CrossDomainMessenger l1CrossDomainMessengerImpl =
            L1CrossDomainMessenger(makeAddr("l1CrossDomainMessengerImpl"));
        L1ERC721Bridge l1ERC721BridgeImpl = L1ERC721Bridge(makeAddr("l1ERC721BridgeImpl"));
        L1StandardBridge l1StandardBridgeImpl = L1StandardBridge(payable(makeAddr("l1StandardBridgeImpl")));
        OptimismMintableERC20Factory optimismMintableERC20FactoryImpl =
            OptimismMintableERC20Factory(makeAddr("optimismMintableERC20FactoryImpl"));
        DisputeGameFactory disputeGameFactoryImpl = DisputeGameFactory(makeAddr("disputeGameFactoryImpl"));

        vm.etch(address(opsmProxy), address(opsmProxy).code);
        vm.etch(address(opsmImpl), hex"01");
        vm.etch(address(optimismPortalImpl), hex"01");
        vm.etch(address(delayedWETHImpl), hex"01");
        vm.etch(address(preimageOracleSingleton), hex"01");
        vm.etch(address(mipsSingleton), hex"01");
        vm.etch(address(systemConfigImpl), hex"01");
        vm.etch(address(l1CrossDomainMessengerImpl), hex"01");
        vm.etch(address(l1ERC721BridgeImpl), hex"01");
        vm.etch(address(l1StandardBridgeImpl), hex"01");
        vm.etch(address(optimismMintableERC20FactoryImpl), hex"01");
        vm.etch(address(disputeGameFactoryImpl), hex"01");
        dio.set(dio.opsmProxy.selector, address(opsmProxy));
        dio.set(dio.optimismPortalImpl.selector, address(optimismPortalImpl));
        dio.set(dio.delayedWETHImpl.selector, address(delayedWETHImpl));
        dio.set(dio.preimageOracleSingleton.selector, address(preimageOracleSingleton));
        dio.set(dio.mipsSingleton.selector, address(mipsSingleton));
        dio.set(dio.systemConfigImpl.selector, address(systemConfigImpl));
        dio.set(dio.l1CrossDomainMessengerImpl.selector, address(l1CrossDomainMessengerImpl));
        dio.set(dio.l1ERC721BridgeImpl.selector, address(l1ERC721BridgeImpl));
        dio.set(dio.l1StandardBridgeImpl.selector, address(l1StandardBridgeImpl));
        dio.set(dio.optimismMintableERC20FactoryImpl.selector, address(optimismMintableERC20FactoryImpl));
        dio.set(dio.disputeGameFactoryImpl.selector, address(disputeGameFactoryImpl));

        assertEq(address(opsmProxy), address(dio.opsmProxy()), "50");
        assertEq(address(optimismPortalImpl), address(dio.optimismPortalImpl()), "100");
        assertEq(address(delayedWETHImpl), address(dio.delayedWETHImpl()), "200");
        assertEq(address(preimageOracleSingleton), address(dio.preimageOracleSingleton()), "300");
        assertEq(address(mipsSingleton), address(dio.mipsSingleton()), "400");
        assertEq(address(systemConfigImpl), address(dio.systemConfigImpl()), "500");
        assertEq(address(l1CrossDomainMessengerImpl), address(dio.l1CrossDomainMessengerImpl()), "600");
        assertEq(address(l1ERC721BridgeImpl), address(dio.l1ERC721BridgeImpl()), "700");
        assertEq(address(l1StandardBridgeImpl), address(dio.l1StandardBridgeImpl()), "800");
        assertEq(address(optimismMintableERC20FactoryImpl), address(dio.optimismMintableERC20FactoryImpl()), "900");
        assertEq(address(disputeGameFactoryImpl), address(dio.disputeGameFactoryImpl()), "950");
    }

    function test_getters_whenNotSet_revert() public {
        bytes memory expectedErr = "DeployUtils: zero address";

        vm.expectRevert(expectedErr);
        dio.optimismPortalImpl();

        vm.expectRevert(expectedErr);
        dio.delayedWETHImpl();

        vm.expectRevert(expectedErr);
        dio.preimageOracleSingleton();

        vm.expectRevert(expectedErr);
        dio.mipsSingleton();

        vm.expectRevert(expectedErr);
        dio.systemConfigImpl();

        vm.expectRevert(expectedErr);
        dio.l1CrossDomainMessengerImpl();

        vm.expectRevert(expectedErr);
        dio.l1ERC721BridgeImpl();

        vm.expectRevert(expectedErr);
        dio.l1StandardBridgeImpl();

        vm.expectRevert(expectedErr);
        dio.optimismMintableERC20FactoryImpl();

        vm.expectRevert(expectedErr);
        dio.disputeGameFactoryImpl();
    }

    function test_getters_whenAddrHasNoCode_reverts() public {
        address emptyAddr = makeAddr("emptyAddr");
        bytes memory expectedErr = bytes(string.concat("DeployUtils: no code at ", vm.toString(emptyAddr)));

        dio.set(dio.optimismPortalImpl.selector, emptyAddr);
        vm.expectRevert(expectedErr);
        dio.optimismPortalImpl();

        dio.set(dio.delayedWETHImpl.selector, emptyAddr);
        vm.expectRevert(expectedErr);
        dio.delayedWETHImpl();

        dio.set(dio.preimageOracleSingleton.selector, emptyAddr);
        vm.expectRevert(expectedErr);
        dio.preimageOracleSingleton();

        dio.set(dio.mipsSingleton.selector, emptyAddr);
        vm.expectRevert(expectedErr);
        dio.mipsSingleton();

        dio.set(dio.systemConfigImpl.selector, emptyAddr);
        vm.expectRevert(expectedErr);
        dio.systemConfigImpl();

        dio.set(dio.l1CrossDomainMessengerImpl.selector, emptyAddr);
        vm.expectRevert(expectedErr);
        dio.l1CrossDomainMessengerImpl();

        dio.set(dio.l1ERC721BridgeImpl.selector, emptyAddr);
        vm.expectRevert(expectedErr);
        dio.l1ERC721BridgeImpl();

        dio.set(dio.l1StandardBridgeImpl.selector, emptyAddr);
        vm.expectRevert(expectedErr);
        dio.l1StandardBridgeImpl();

        dio.set(dio.optimismMintableERC20FactoryImpl.selector, emptyAddr);
        vm.expectRevert(expectedErr);
        dio.optimismMintableERC20FactoryImpl();
    }
}

contract DeployImplementations_Test is Test {
    using stdStorage for StdStorage;

    DeployImplementations deployImplementations;
    DeployImplementationsInput dii;
    DeployImplementationsOutput dio;

    // Define default inputs for testing.
    uint256 withdrawalDelaySeconds = 100;
    uint256 minProposalSizeBytes = 200;
    uint256 challengePeriodSeconds = 300;
    uint256 proofMaturityDelaySeconds = 400;
    uint256 disputeGameFinalityDelaySeconds = 500;
    SuperchainConfig superchainConfigProxy = SuperchainConfig(makeAddr("superchainConfigProxy"));
    ProtocolVersions protocolVersionsProxy = ProtocolVersions(makeAddr("protocolVersionsProxy"));

    function setUp() public virtual {
        deployImplementations = new DeployImplementations();
        (dii, dio) = deployImplementations.etchIOContracts();
    }

    // By deploying the `DeployImplementations` contract with this virtual function, we provide a
    // hook that child contracts can override to return a different implementation of the contract.
    // This lets us test e.g. the `DeployImplementationsInterop` contract without duplicating test code.
    function createDeployImplementationsContract() internal virtual returns (DeployImplementations) {
        return new DeployImplementations();
    }

    function hash(bytes32 _seed, uint256 _i) internal pure returns (bytes32) {
        return keccak256(abi.encode(_seed, _i));
    }

    function test_deployImplementation_succeeds() public {
        string memory deployContractsRelease = "non-standard-release";
        dii.set(dii.release.selector, deployContractsRelease);
        deployImplementations.deploySystemConfigImpl(dii, dio);
        assertTrue(address(0) != address(dio.systemConfigImpl()));
    }

    function test_reuseImplementation_succeeds() public {
        // All hardcoded addresses below are taken from the superchain-registry config:
        // https://github.com/ethereum-optimism/superchain-registry/blob/be65d22f8128cf0c4e5b4e1f677daf86843426bf/validation/standard/standard-versions.toml#L11
        string memory testRelease = "op-contracts/v1.6.0";
        dii.set(dii.release.selector, testRelease);

        deployImplementations.deploySystemConfigImpl(dii, dio);
        address srSystemConfigImpl = address(0xF56D96B2535B932656d3c04Ebf51baBff241D886);
        vm.etch(address(srSystemConfigImpl), hex"01");
        assertEq(srSystemConfigImpl, address(dio.systemConfigImpl()));

        address srL1CrossDomainMessengerImpl = address(0xD3494713A5cfaD3F5359379DfA074E2Ac8C6Fd65);
        vm.etch(address(srL1CrossDomainMessengerImpl), hex"01");
        deployImplementations.deployL1CrossDomainMessengerImpl(dii, dio);
        assertEq(srL1CrossDomainMessengerImpl, address(dio.l1CrossDomainMessengerImpl()));

        address srL1ERC721BridgeImpl = address(0xAE2AF01232a6c4a4d3012C5eC5b1b35059caF10d);
        vm.etch(address(srL1ERC721BridgeImpl), hex"01");
        deployImplementations.deployL1ERC721BridgeImpl(dii, dio);
        assertEq(srL1ERC721BridgeImpl, address(dio.l1ERC721BridgeImpl()));

        address srL1StandardBridgeImpl = address(0x64B5a5Ed26DCb17370Ff4d33a8D503f0fbD06CfF);
        vm.etch(address(srL1StandardBridgeImpl), hex"01");
        deployImplementations.deployL1StandardBridgeImpl(dii, dio);
        assertEq(srL1StandardBridgeImpl, address(dio.l1StandardBridgeImpl()));

        address srOptimismMintableERC20FactoryImpl = address(0xE01efbeb1089D1d1dB9c6c8b135C934C0734c846);
        vm.etch(address(srOptimismMintableERC20FactoryImpl), hex"01");
        deployImplementations.deployOptimismMintableERC20FactoryImpl(dii, dio);
        assertEq(srOptimismMintableERC20FactoryImpl, address(dio.optimismMintableERC20FactoryImpl()));

        address srOptimismPortalImpl = address(0xe2F826324b2faf99E513D16D266c3F80aE87832B);
        vm.etch(address(srOptimismPortalImpl), hex"01");
        deployImplementations.deployOptimismPortalImpl(dii, dio);
        assertEq(srOptimismPortalImpl, address(dio.optimismPortalImpl()));

        address srDelayedWETHImpl = address(0x71e966Ae981d1ce531a7b6d23DC0f27B38409087);
        vm.etch(address(srDelayedWETHImpl), hex"01");
        deployImplementations.deployDelayedWETHImpl(dii, dio);
        assertEq(srDelayedWETHImpl, address(dio.delayedWETHImpl()));

        address srPreimageOracleSingleton = address(0x9c065e11870B891D214Bc2Da7EF1f9DDFA1BE277);
        vm.etch(address(srPreimageOracleSingleton), hex"01");
        deployImplementations.deployPreimageOracleSingleton(dii, dio);
        assertEq(srPreimageOracleSingleton, address(dio.preimageOracleSingleton()));

        address srMipsSingleton = address(0x16e83cE5Ce29BF90AD9Da06D2fE6a15d5f344ce4);
        vm.etch(address(srMipsSingleton), hex"01");
        deployImplementations.deployMipsSingleton(dii, dio);
        assertEq(srMipsSingleton, address(dio.mipsSingleton()));

        address srDisputeGameFactoryImpl = address(0xc641A33cab81C559F2bd4b21EA34C290E2440C2B);
        vm.etch(address(srDisputeGameFactoryImpl), hex"01");
        deployImplementations.deployDisputeGameFactoryImpl(dii, dio);
        assertEq(srDisputeGameFactoryImpl, address(dio.disputeGameFactoryImpl()));
    }

    function test_deployAtNonExistentRelease_reverts() public {
        string memory unknownRelease = "op-contracts/v0.0.0";
        dii.set(dii.release.selector, unknownRelease);

        bytes memory expectedErr =
            bytes(string.concat("DeployImplementations: failed to deploy release ", unknownRelease));

        vm.expectRevert(expectedErr);
        deployImplementations.deploySystemConfigImpl(dii, dio);

        vm.expectRevert(expectedErr);
        deployImplementations.deployL1CrossDomainMessengerImpl(dii, dio);

        vm.expectRevert(expectedErr);
        deployImplementations.deployL1ERC721BridgeImpl(dii, dio);

        vm.expectRevert(expectedErr);
        deployImplementations.deployL1StandardBridgeImpl(dii, dio);

        vm.expectRevert(expectedErr);
        deployImplementations.deployOptimismMintableERC20FactoryImpl(dii, dio);

        // TODO: Uncomment the code below when OPContractsManager is deployed based on release. Superchain-registry
        // doesn't contain OPContractsManager yet.
        // dii.set(dii.superchainConfigProxy.selector, address(superchainConfigProxy));
        // dii.set(dii.protocolVersionsProxy.selector, address(protocolVersionsProxy));
        // vm.etch(address(superchainConfigProxy), hex"01");
        // vm.etch(address(protocolVersionsProxy), hex"01");
        // vm.expectRevert(expectedErr);
        // deployImplementations.deployOPContractsManagerImpl(dii, dio);

        dii.set(dii.proofMaturityDelaySeconds.selector, 1);
        dii.set(dii.disputeGameFinalityDelaySeconds.selector, 2);
        vm.expectRevert(expectedErr);
        deployImplementations.deployOptimismPortalImpl(dii, dio);

        dii.set(dii.withdrawalDelaySeconds.selector, 1);
        vm.expectRevert(expectedErr);
        deployImplementations.deployDelayedWETHImpl(dii, dio);

        dii.set(dii.minProposalSizeBytes.selector, 1);
        dii.set(dii.challengePeriodSeconds.selector, 2);
        vm.expectRevert(expectedErr);
        deployImplementations.deployPreimageOracleSingleton(dii, dio);

        address preImageOracleSingleton = makeAddr("preImageOracleSingleton");
        vm.etch(address(preImageOracleSingleton), hex"01");
        dio.set(dio.preimageOracleSingleton.selector, preImageOracleSingleton);
        vm.expectRevert(expectedErr);
        deployImplementations.deployMipsSingleton(dii, dio);

        vm.expectRevert(expectedErr); // fault proof contracts don't exist at this release
        deployImplementations.deployDisputeGameFactoryImpl(dii, dio);
    }

    function test_noContractExistsAtRelease_reverts() public {
        string memory unknownRelease = "op-contracts/v1.3.0";
        dii.set(dii.release.selector, unknownRelease);
        bytes memory expectedErr =
            bytes(string.concat("DeployImplementations: failed to deploy release ", unknownRelease));

        vm.expectRevert(expectedErr); // fault proof contracts don't exist at this release
        deployImplementations.deployDisputeGameFactoryImpl(dii, dio);
    }

    function testFuzz_run_memory_succeeds(bytes32 _seed) public {
        withdrawalDelaySeconds = uint256(hash(_seed, 0));
        minProposalSizeBytes = uint256(hash(_seed, 1));
        challengePeriodSeconds = bound(uint256(hash(_seed, 2)), 0, type(uint64).max);
        proofMaturityDelaySeconds = uint256(hash(_seed, 3));
        disputeGameFinalityDelaySeconds = uint256(hash(_seed, 4));
        string memory release = string(bytes.concat(hash(_seed, 5)));
        protocolVersionsProxy = ProtocolVersions(address(uint160(uint256(hash(_seed, 7)))));

        // Must configure the ProxyAdmin contract which is used to upgrade the OPSM's proxy contract.
        ProxyAdmin superchainProxyAdmin = new ProxyAdmin(msg.sender);
        superchainConfigProxy = SuperchainConfig(address(new Proxy(payable(address(superchainProxyAdmin)))));

        SuperchainConfig superchainConfigImpl = SuperchainConfig(address(uint160(uint256(hash(_seed, 6)))));
        vm.prank(address(superchainProxyAdmin));
        Proxy(payable(address(superchainConfigProxy))).upgradeTo(address(superchainConfigImpl));

        vm.etch(address(superchainProxyAdmin), address(superchainProxyAdmin).code);
        vm.etch(address(superchainConfigProxy), address(superchainConfigProxy).code);
        vm.etch(address(protocolVersionsProxy), hex"01");

        dii.set(dii.withdrawalDelaySeconds.selector, withdrawalDelaySeconds);
        dii.set(dii.minProposalSizeBytes.selector, minProposalSizeBytes);
        dii.set(dii.challengePeriodSeconds.selector, challengePeriodSeconds);
        dii.set(dii.proofMaturityDelaySeconds.selector, proofMaturityDelaySeconds);
        dii.set(dii.disputeGameFinalityDelaySeconds.selector, disputeGameFinalityDelaySeconds);
        dii.set(dii.release.selector, release);
        dii.set(dii.superchainConfigProxy.selector, address(superchainConfigProxy));
        dii.set(dii.protocolVersionsProxy.selector, address(protocolVersionsProxy));

        deployImplementations.run(dii, dio);

        // Assert that individual input fields were properly set based on the inputs.
        assertEq(withdrawalDelaySeconds, dii.withdrawalDelaySeconds(), "100");
        assertEq(minProposalSizeBytes, dii.minProposalSizeBytes(), "200");
        assertEq(challengePeriodSeconds, dii.challengePeriodSeconds(), "300");
        assertEq(proofMaturityDelaySeconds, dii.proofMaturityDelaySeconds(), "400");
        assertEq(disputeGameFinalityDelaySeconds, dii.disputeGameFinalityDelaySeconds(), "500");
        assertEq(release, dii.release(), "525");
        assertEq(address(superchainConfigProxy), address(dii.superchainConfigProxy()), "550");
        assertEq(address(protocolVersionsProxy), address(dii.protocolVersionsProxy()), "575");
        assertEq(address(superchainProxyAdmin), address(dii.superchainProxyAdmin()), "580");

        // Architecture assertions.
        assertEq(address(dio.mipsSingleton().oracle()), address(dio.preimageOracleSingleton()), "600");

        // Ensure that `checkOutput` passes. This is called by the `run` function during execution,
        // so this just acts as a sanity check. It reverts on failure.
        dio.checkOutput(dii);
    }

    function testFuzz_run_largeChallengePeriodSeconds_reverts(uint256 _challengePeriodSeconds) public {
        // Set the defaults.
        dii.set(dii.withdrawalDelaySeconds.selector, withdrawalDelaySeconds);
        dii.set(dii.minProposalSizeBytes.selector, minProposalSizeBytes);
        dii.set(dii.challengePeriodSeconds.selector, challengePeriodSeconds);
        dii.set(dii.proofMaturityDelaySeconds.selector, proofMaturityDelaySeconds);
        dii.set(dii.disputeGameFinalityDelaySeconds.selector, disputeGameFinalityDelaySeconds);
        string memory release = "non-standard-release";
        dii.set(dii.release.selector, release);
        dii.set(dii.superchainConfigProxy.selector, address(superchainConfigProxy));
        dii.set(dii.protocolVersionsProxy.selector, address(protocolVersionsProxy));

        // Set the challenge period to a value that is too large, using vm.store because the setter
        // method won't allow it.
        challengePeriodSeconds = bound(_challengePeriodSeconds, uint256(type(uint64).max) + 1, type(uint256).max);
        uint256 slot =
            stdstore.enable_packed_slots().target(address(dii)).sig(dii.challengePeriodSeconds.selector).find();
        vm.store(address(dii), bytes32(slot), bytes32(challengePeriodSeconds));

        vm.expectRevert("DeployImplementationsInput: challengePeriodSeconds too large");
        deployImplementations.run(dii, dio);
    }
}

contract DeployImplementationsInterop_Test is DeployImplementations_Test {
    function createDeployImplementationsContract() internal override returns (DeployImplementations) {
        return new DeployImplementationsInterop();
    }
}
