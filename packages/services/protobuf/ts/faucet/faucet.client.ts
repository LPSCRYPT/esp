/* eslint-disable */
// @generated by protobuf-ts 2.8.1 with parameter eslint_disable
// @generated from protobuf file "faucet.proto" (package "faucet", syntax proto3)
// tslint:disable
import type { RpcTransport } from "@protobuf-ts/runtime-rpc";
import type { ServiceInfo } from "@protobuf-ts/runtime-rpc";
import { FaucetService } from "./faucet";
import type { LinkedAddressForTwitterResponse } from "./faucet";
import type { LinkedAddressForTwitterRequest } from "./faucet";
import type { LinkedTwitterForAddressResponse } from "./faucet";
import type { LinkedTwitterForAddressRequest } from "./faucet";
import type { GetLinkedTwittersResponse } from "./faucet";
import type { GetLinkedTwittersRequest } from "./faucet";
import { stackIntercept } from "@protobuf-ts/runtime-rpc";
import type { VerifyTweetResponse } from "./faucet";
import type { VerifyTweetRequest } from "./faucet";
import type { UnaryCall } from "@protobuf-ts/runtime-rpc";
import type { RpcOptions } from "@protobuf-ts/runtime-rpc";
/**
 * The Faucet Service definition.
 *
 * @generated from protobuf service faucet.FaucetService
 */
export interface IFaucetServiceClient {
  /**
   * @generated from protobuf rpc: VerifyTweet(faucet.VerifyTweetRequest) returns (faucet.VerifyTweetResponse);
   */
  verifyTweet(input: VerifyTweetRequest, options?: RpcOptions): UnaryCall<VerifyTweetRequest, VerifyTweetResponse>;
  /**
   * @generated from protobuf rpc: GetLinkedTwitters(faucet.GetLinkedTwittersRequest) returns (faucet.GetLinkedTwittersResponse);
   */
  getLinkedTwitters(
    input: GetLinkedTwittersRequest,
    options?: RpcOptions
  ): UnaryCall<GetLinkedTwittersRequest, GetLinkedTwittersResponse>;
  /**
   * @generated from protobuf rpc: GetLinkedTwitterForAddress(faucet.LinkedTwitterForAddressRequest) returns (faucet.LinkedTwitterForAddressResponse);
   */
  getLinkedTwitterForAddress(
    input: LinkedTwitterForAddressRequest,
    options?: RpcOptions
  ): UnaryCall<LinkedTwitterForAddressRequest, LinkedTwitterForAddressResponse>;
  /**
   * @generated from protobuf rpc: GetLinkedAddressForTwitter(faucet.LinkedAddressForTwitterRequest) returns (faucet.LinkedAddressForTwitterResponse);
   */
  getLinkedAddressForTwitter(
    input: LinkedAddressForTwitterRequest,
    options?: RpcOptions
  ): UnaryCall<LinkedAddressForTwitterRequest, LinkedAddressForTwitterResponse>;
}
/**
 * The Faucet Service definition.
 *
 * @generated from protobuf service faucet.FaucetService
 */
export class FaucetServiceClient implements IFaucetServiceClient, ServiceInfo {
  typeName = FaucetService.typeName;
  methods = FaucetService.methods;
  options = FaucetService.options;
  constructor(private readonly _transport: RpcTransport) {}
  /**
   * @generated from protobuf rpc: VerifyTweet(faucet.VerifyTweetRequest) returns (faucet.VerifyTweetResponse);
   */
  verifyTweet(input: VerifyTweetRequest, options?: RpcOptions): UnaryCall<VerifyTweetRequest, VerifyTweetResponse> {
    const method = this.methods[0],
      opt = this._transport.mergeOptions(options);
    return stackIntercept<VerifyTweetRequest, VerifyTweetResponse>("unary", this._transport, method, opt, input);
  }
  /**
   * @generated from protobuf rpc: GetLinkedTwitters(faucet.GetLinkedTwittersRequest) returns (faucet.GetLinkedTwittersResponse);
   */
  getLinkedTwitters(
    input: GetLinkedTwittersRequest,
    options?: RpcOptions
  ): UnaryCall<GetLinkedTwittersRequest, GetLinkedTwittersResponse> {
    const method = this.methods[1],
      opt = this._transport.mergeOptions(options);
    return stackIntercept<GetLinkedTwittersRequest, GetLinkedTwittersResponse>(
      "unary",
      this._transport,
      method,
      opt,
      input
    );
  }
  /**
   * @generated from protobuf rpc: GetLinkedTwitterForAddress(faucet.LinkedTwitterForAddressRequest) returns (faucet.LinkedTwitterForAddressResponse);
   */
  getLinkedTwitterForAddress(
    input: LinkedTwitterForAddressRequest,
    options?: RpcOptions
  ): UnaryCall<LinkedTwitterForAddressRequest, LinkedTwitterForAddressResponse> {
    const method = this.methods[2],
      opt = this._transport.mergeOptions(options);
    return stackIntercept<LinkedTwitterForAddressRequest, LinkedTwitterForAddressResponse>(
      "unary",
      this._transport,
      method,
      opt,
      input
    );
  }
  /**
   * @generated from protobuf rpc: GetLinkedAddressForTwitter(faucet.LinkedAddressForTwitterRequest) returns (faucet.LinkedAddressForTwitterResponse);
   */
  getLinkedAddressForTwitter(
    input: LinkedAddressForTwitterRequest,
    options?: RpcOptions
  ): UnaryCall<LinkedAddressForTwitterRequest, LinkedAddressForTwitterResponse> {
    const method = this.methods[3],
      opt = this._transport.mergeOptions(options);
    return stackIntercept<LinkedAddressForTwitterRequest, LinkedAddressForTwitterResponse>(
      "unary",
      this._transport,
      method,
      opt,
      input
    );
  }
}
