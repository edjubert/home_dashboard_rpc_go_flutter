package main

import (
	"context"
	"log"
	"net"
	"os"

	pb "home_dashboard_server/protos"

	"google.golang.org/grpc"
)

const (
	port = ":50051"
)

const (
	OK         = iota
	ERROR_EXIT = iota
)

type server struct {
	pb.UnimplementedGreeterServer
}

func Check(e error) {
	if e != nil {
		log.Fatalf("%v", e)
		os.Exit(ERROR_EXIT)
	}
}

func (s *server) Hello(ctx context.Context, in *pb.HelloRequest) (*pb.HelloReply, error) {
	log.Printf("Received: %v", in.GetName())
	return &pb.HelloReply{Message: "Hello there, Obi Wan " + in.GetName()}, nil
}

func main() {
	lis, err := net.Listen("tcp", port)

	Check(err)
	s := grpc.NewServer()
	pb.RegisterGreeterServer(s, &server{})

	err = s.Serve(lis)
	Check(err)
}
