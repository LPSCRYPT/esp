/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import { Signer, utils, Contract, ContractFactory, Overrides } from "ethers";
import { Provider, TransactionRequest } from "@ethersproject/providers";
import type { LocalLatticeGameLocator, LocalLatticeGameLocatorInterface } from "../LocalLatticeGameLocator";

const _abi = [
  {
    inputs: [],
    name: "localLatticeGameAddress",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "localLatticeGameAddr",
        type: "address",
      },
    ],
    name: "setLocalLatticeGameAddress",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
];

const _bytecode =
  "0x608060405234801561001057600080fd5b5061014e806100206000396000f3fe608060405234801561001057600080fd5b50600436106100365760003560e01c8063906182f01461003b578063eef3f4eb14610084575b600080fd5b60005461005b9073ffffffffffffffffffffffffffffffffffffffff1681565b60405173ffffffffffffffffffffffffffffffffffffffff909116815260200160405180910390f35b6100d96100923660046100db565b600080547fffffffffffffffffffffffff00000000000000000000000000000000000000001673ffffffffffffffffffffffffffffffffffffffff92909216919091179055565b005b6000602082840312156100ed57600080fd5b813573ffffffffffffffffffffffffffffffffffffffff8116811461011157600080fd5b939250505056fea26469706673582212204811835b8b6cacd32d908f3b4d222259f9905fc5625f1b379d1065f2f3abe42464736f6c634300080d0033";

type LocalLatticeGameLocatorConstructorParams = [signer?: Signer] | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: LocalLatticeGameLocatorConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class LocalLatticeGameLocator__factory extends ContractFactory {
  constructor(...args: LocalLatticeGameLocatorConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
    this.contractName = "LocalLatticeGameLocator";
  }

  deploy(overrides?: Overrides & { from?: string | Promise<string> }): Promise<LocalLatticeGameLocator> {
    return super.deploy(overrides || {}) as Promise<LocalLatticeGameLocator>;
  }
  getDeployTransaction(overrides?: Overrides & { from?: string | Promise<string> }): TransactionRequest {
    return super.getDeployTransaction(overrides || {});
  }
  attach(address: string): LocalLatticeGameLocator {
    return super.attach(address) as LocalLatticeGameLocator;
  }
  connect(signer: Signer): LocalLatticeGameLocator__factory {
    return super.connect(signer) as LocalLatticeGameLocator__factory;
  }
  static readonly contractName: "LocalLatticeGameLocator";
  public readonly contractName: "LocalLatticeGameLocator";
  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): LocalLatticeGameLocatorInterface {
    return new utils.Interface(_abi) as LocalLatticeGameLocatorInterface;
  }
  static connect(address: string, signerOrProvider: Signer | Provider): LocalLatticeGameLocator {
    return new Contract(address, _abi, signerOrProvider) as LocalLatticeGameLocator;
  }
}
