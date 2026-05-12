import 'package:socket_io_client/socket_io_client.dart' as io;

typedef EventHandler = void Function(dynamic payload);

class SocketService {
  io.Socket? _socket;

  bool get isConnected => _socket?.connected == true;

  void connect({required String url, required String token}) {
    _socket?.disconnect();
    _socket = io.io(
      url,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );
    _socket?.connect();
  }

  void on(String event, EventHandler handler) {
    _socket?.on(event, handler);
  }

  void off(String event) {
    _socket?.off(event);
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  void disconnect() {
    _socket?.disconnect();
  }
}
