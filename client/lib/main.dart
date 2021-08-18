import 'package:flutter/material.dart';

import 'package:grpc/grpc.dart' as grpc;
import 'package:home_dashboard_client/src/protos/hello.pbgrpc.dart';
import 'package:home_dashboard_client/src/protos/hello.pb.dart';

Future<HelloReply> connect(String name) async {
  final channel = grpc.ClientChannel('localhost',
      port: 50051,
      options: grpc.ChannelOptions(
        credentials: grpc.ChannelCredentials.insecure(),
      ));
  final stub = GreeterClient(channel);

  try {
    final response = await stub.hello(HelloRequest()..name = name);
    print("Greeter client received: ${response.message}");
    return Future.value(response);
  } catch (e) {
    print("Caught error $e");
    return Future.error(e);
  } finally {
    await channel.shutdown();
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: PrintGreetings());
  }
}

class PrintGreetings extends StatefulWidget {
  @override
  _PrintGreetingsState createState() => _PrintGreetingsState();
}

class _PrintGreetingsState extends State<PrintGreetings> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HelloReply>(
      future: connect('hey!'),
      builder: (BuildContext context, AsyncSnapshot<HelloReply> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            'Loading...',
            textDirection: TextDirection.ltr,
          );
        } else {
          if (snapshot.hasError)
            return Text(
              'Error: ${snapshot.error}',
              textDirection: TextDirection.ltr,
            );
          else
            return Text(
              snapshot.data?.message ?? 'Hello There',
              textDirection: TextDirection.ltr,
            );
        }
      },
    );
  }
}
