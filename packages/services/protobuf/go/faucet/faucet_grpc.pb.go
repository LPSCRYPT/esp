// Code generated by protoc-gen-go-grpc. DO NOT EDIT.
// versions:
// - protoc-gen-go-grpc v1.2.0
// - protoc             v3.21.3
// source: proto/faucet.proto

package faucet

import (
	context "context"
	grpc "google.golang.org/grpc"
	codes "google.golang.org/grpc/codes"
	status "google.golang.org/grpc/status"
)

// This is a compile-time assertion to ensure that this generated file
// is compatible with the grpc package it is being compiled against.
// Requires gRPC-Go v1.32.0 or later.
const _ = grpc.SupportPackageIsVersion7

// FaucetServiceClient is the client API for FaucetService service.
//
// For semantics around ctx use and closing/ending streaming RPCs, please refer to https://pkg.go.dev/google.golang.org/grpc/?tab=doc#ClientConn.NewStream.
type FaucetServiceClient interface {
	Drip(ctx context.Context, in *DripRequest, opts ...grpc.CallOption) (*DripResponse, error)
	DripDev(ctx context.Context, in *DripDevRequest, opts ...grpc.CallOption) (*DripResponse, error)
	DripVerifyTweet(ctx context.Context, in *DripRequest, opts ...grpc.CallOption) (*DripResponse, error)
	TimeUntilDrip(ctx context.Context, in *DripRequest, opts ...grpc.CallOption) (*TimeUntilDripResponse, error)
	GetLinkedTwitters(ctx context.Context, in *GetLinkedTwittersRequest, opts ...grpc.CallOption) (*GetLinkedTwittersResponse, error)
	GetLinkedTwitterForAddress(ctx context.Context, in *LinkedTwitterForAddressRequest, opts ...grpc.CallOption) (*LinkedTwitterForAddressResponse, error)
	GetLinkedAddressForTwitter(ctx context.Context, in *LinkedAddressForTwitterRequest, opts ...grpc.CallOption) (*LinkedAddressForTwitterResponse, error)
	// Admin utility endpoints for modifying state. Requires a signature with faucet private key.
	SetLinkedTwitter(ctx context.Context, in *SetLinkedTwitterRequest, opts ...grpc.CallOption) (*SetLinkedTwitterResponse, error)
}

type faucetServiceClient struct {
	cc grpc.ClientConnInterface
}

func NewFaucetServiceClient(cc grpc.ClientConnInterface) FaucetServiceClient {
	return &faucetServiceClient{cc}
}

func (c *faucetServiceClient) Drip(ctx context.Context, in *DripRequest, opts ...grpc.CallOption) (*DripResponse, error) {
	out := new(DripResponse)
	err := c.cc.Invoke(ctx, "/faucet.FaucetService/Drip", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *faucetServiceClient) DripDev(ctx context.Context, in *DripDevRequest, opts ...grpc.CallOption) (*DripResponse, error) {
	out := new(DripResponse)
	err := c.cc.Invoke(ctx, "/faucet.FaucetService/DripDev", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *faucetServiceClient) DripVerifyTweet(ctx context.Context, in *DripRequest, opts ...grpc.CallOption) (*DripResponse, error) {
	out := new(DripResponse)
	err := c.cc.Invoke(ctx, "/faucet.FaucetService/DripVerifyTweet", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *faucetServiceClient) TimeUntilDrip(ctx context.Context, in *DripRequest, opts ...grpc.CallOption) (*TimeUntilDripResponse, error) {
	out := new(TimeUntilDripResponse)
	err := c.cc.Invoke(ctx, "/faucet.FaucetService/TimeUntilDrip", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *faucetServiceClient) GetLinkedTwitters(ctx context.Context, in *GetLinkedTwittersRequest, opts ...grpc.CallOption) (*GetLinkedTwittersResponse, error) {
	out := new(GetLinkedTwittersResponse)
	err := c.cc.Invoke(ctx, "/faucet.FaucetService/GetLinkedTwitters", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *faucetServiceClient) GetLinkedTwitterForAddress(ctx context.Context, in *LinkedTwitterForAddressRequest, opts ...grpc.CallOption) (*LinkedTwitterForAddressResponse, error) {
	out := new(LinkedTwitterForAddressResponse)
	err := c.cc.Invoke(ctx, "/faucet.FaucetService/GetLinkedTwitterForAddress", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *faucetServiceClient) GetLinkedAddressForTwitter(ctx context.Context, in *LinkedAddressForTwitterRequest, opts ...grpc.CallOption) (*LinkedAddressForTwitterResponse, error) {
	out := new(LinkedAddressForTwitterResponse)
	err := c.cc.Invoke(ctx, "/faucet.FaucetService/GetLinkedAddressForTwitter", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *faucetServiceClient) SetLinkedTwitter(ctx context.Context, in *SetLinkedTwitterRequest, opts ...grpc.CallOption) (*SetLinkedTwitterResponse, error) {
	out := new(SetLinkedTwitterResponse)
	err := c.cc.Invoke(ctx, "/faucet.FaucetService/SetLinkedTwitter", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

// FaucetServiceServer is the server API for FaucetService service.
// All implementations must embed UnimplementedFaucetServiceServer
// for forward compatibility
type FaucetServiceServer interface {
	Drip(context.Context, *DripRequest) (*DripResponse, error)
	DripDev(context.Context, *DripDevRequest) (*DripResponse, error)
	DripVerifyTweet(context.Context, *DripRequest) (*DripResponse, error)
	TimeUntilDrip(context.Context, *DripRequest) (*TimeUntilDripResponse, error)
	GetLinkedTwitters(context.Context, *GetLinkedTwittersRequest) (*GetLinkedTwittersResponse, error)
	GetLinkedTwitterForAddress(context.Context, *LinkedTwitterForAddressRequest) (*LinkedTwitterForAddressResponse, error)
	GetLinkedAddressForTwitter(context.Context, *LinkedAddressForTwitterRequest) (*LinkedAddressForTwitterResponse, error)
	// Admin utility endpoints for modifying state. Requires a signature with faucet private key.
	SetLinkedTwitter(context.Context, *SetLinkedTwitterRequest) (*SetLinkedTwitterResponse, error)
	mustEmbedUnimplementedFaucetServiceServer()
}

// UnimplementedFaucetServiceServer must be embedded to have forward compatible implementations.
type UnimplementedFaucetServiceServer struct {
}

func (UnimplementedFaucetServiceServer) Drip(context.Context, *DripRequest) (*DripResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method Drip not implemented")
}
func (UnimplementedFaucetServiceServer) DripDev(context.Context, *DripDevRequest) (*DripResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method DripDev not implemented")
}
func (UnimplementedFaucetServiceServer) DripVerifyTweet(context.Context, *DripRequest) (*DripResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method DripVerifyTweet not implemented")
}
func (UnimplementedFaucetServiceServer) TimeUntilDrip(context.Context, *DripRequest) (*TimeUntilDripResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method TimeUntilDrip not implemented")
}
func (UnimplementedFaucetServiceServer) GetLinkedTwitters(context.Context, *GetLinkedTwittersRequest) (*GetLinkedTwittersResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method GetLinkedTwitters not implemented")
}
func (UnimplementedFaucetServiceServer) GetLinkedTwitterForAddress(context.Context, *LinkedTwitterForAddressRequest) (*LinkedTwitterForAddressResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method GetLinkedTwitterForAddress not implemented")
}
func (UnimplementedFaucetServiceServer) GetLinkedAddressForTwitter(context.Context, *LinkedAddressForTwitterRequest) (*LinkedAddressForTwitterResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method GetLinkedAddressForTwitter not implemented")
}
func (UnimplementedFaucetServiceServer) SetLinkedTwitter(context.Context, *SetLinkedTwitterRequest) (*SetLinkedTwitterResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method SetLinkedTwitter not implemented")
}
func (UnimplementedFaucetServiceServer) mustEmbedUnimplementedFaucetServiceServer() {}

// UnsafeFaucetServiceServer may be embedded to opt out of forward compatibility for this service.
// Use of this interface is not recommended, as added methods to FaucetServiceServer will
// result in compilation errors.
type UnsafeFaucetServiceServer interface {
	mustEmbedUnimplementedFaucetServiceServer()
}

func RegisterFaucetServiceServer(s grpc.ServiceRegistrar, srv FaucetServiceServer) {
	s.RegisterService(&FaucetService_ServiceDesc, srv)
}

func _FaucetService_Drip_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(DripRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(FaucetServiceServer).Drip(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/faucet.FaucetService/Drip",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(FaucetServiceServer).Drip(ctx, req.(*DripRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _FaucetService_DripDev_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(DripDevRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(FaucetServiceServer).DripDev(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/faucet.FaucetService/DripDev",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(FaucetServiceServer).DripDev(ctx, req.(*DripDevRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _FaucetService_DripVerifyTweet_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(DripRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(FaucetServiceServer).DripVerifyTweet(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/faucet.FaucetService/DripVerifyTweet",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(FaucetServiceServer).DripVerifyTweet(ctx, req.(*DripRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _FaucetService_TimeUntilDrip_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(DripRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(FaucetServiceServer).TimeUntilDrip(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/faucet.FaucetService/TimeUntilDrip",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(FaucetServiceServer).TimeUntilDrip(ctx, req.(*DripRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _FaucetService_GetLinkedTwitters_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(GetLinkedTwittersRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(FaucetServiceServer).GetLinkedTwitters(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/faucet.FaucetService/GetLinkedTwitters",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(FaucetServiceServer).GetLinkedTwitters(ctx, req.(*GetLinkedTwittersRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _FaucetService_GetLinkedTwitterForAddress_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(LinkedTwitterForAddressRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(FaucetServiceServer).GetLinkedTwitterForAddress(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/faucet.FaucetService/GetLinkedTwitterForAddress",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(FaucetServiceServer).GetLinkedTwitterForAddress(ctx, req.(*LinkedTwitterForAddressRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _FaucetService_GetLinkedAddressForTwitter_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(LinkedAddressForTwitterRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(FaucetServiceServer).GetLinkedAddressForTwitter(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/faucet.FaucetService/GetLinkedAddressForTwitter",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(FaucetServiceServer).GetLinkedAddressForTwitter(ctx, req.(*LinkedAddressForTwitterRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _FaucetService_SetLinkedTwitter_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(SetLinkedTwitterRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(FaucetServiceServer).SetLinkedTwitter(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/faucet.FaucetService/SetLinkedTwitter",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(FaucetServiceServer).SetLinkedTwitter(ctx, req.(*SetLinkedTwitterRequest))
	}
	return interceptor(ctx, in, info, handler)
}

// FaucetService_ServiceDesc is the grpc.ServiceDesc for FaucetService service.
// It's only intended for direct use with grpc.RegisterService,
// and not to be introspected or modified (even as a copy)
var FaucetService_ServiceDesc = grpc.ServiceDesc{
	ServiceName: "faucet.FaucetService",
	HandlerType: (*FaucetServiceServer)(nil),
	Methods: []grpc.MethodDesc{
		{
			MethodName: "Drip",
			Handler:    _FaucetService_Drip_Handler,
		},
		{
			MethodName: "DripDev",
			Handler:    _FaucetService_DripDev_Handler,
		},
		{
			MethodName: "DripVerifyTweet",
			Handler:    _FaucetService_DripVerifyTweet_Handler,
		},
		{
			MethodName: "TimeUntilDrip",
			Handler:    _FaucetService_TimeUntilDrip_Handler,
		},
		{
			MethodName: "GetLinkedTwitters",
			Handler:    _FaucetService_GetLinkedTwitters_Handler,
		},
		{
			MethodName: "GetLinkedTwitterForAddress",
			Handler:    _FaucetService_GetLinkedTwitterForAddress_Handler,
		},
		{
			MethodName: "GetLinkedAddressForTwitter",
			Handler:    _FaucetService_GetLinkedAddressForTwitter_Handler,
		},
		{
			MethodName: "SetLinkedTwitter",
			Handler:    _FaucetService_SetLinkedTwitter_Handler,
		},
	},
	Streams:  []grpc.StreamDesc{},
	Metadata: "proto/faucet.proto",
}
