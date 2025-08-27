import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
// Import our own ConnectionStatus with a prefix 'ps' to avoid name collision
import '../../domain/entities/connection_status.dart' as ps;
import '../bloc/psiphon_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PsiphonBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Psiphon Flutter Client'),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConnectionStatusDisplay(),
                SizedBox(height: 32),
                ConnectionButton(),
                SizedBox(height: 24),
                ProxyInfoDisplay(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ConnectionStatusDisplay extends StatelessWidget {
  const ConnectionStatusDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PsiphonBloc, PsiphonState, ps.ConnectionState>(
      // Use the prefixed enum: ps.ConnectionState
      selector: (state) => state.status.state,
      builder: (context, connectionState) {
        return Column(
          children: [
            Text(
              'Status: ${connectionState.name.toUpperCase()}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            // Use the prefixed enum here as well
            if (connectionState == ps.ConnectionState.error)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  context.read<PsiphonBloc>().state.status.errorMessage ??
                      'Unknown error',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        );
      },
    );
  }
}

class ConnectionButton extends StatelessWidget {
  const ConnectionButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PsiphonBloc, PsiphonState>(
      builder: (context, state) {
        final status = state.status;
        // Use the prefixed enum for all comparisons
        final bool isConnectingOrStopping =
            status.state == ps.ConnectionState.connecting ||
                status.state == ps.ConnectionState.stopping;

        final bool isConnected = status.state == ps.ConnectionState.connected;

        VoidCallback? onPressed = isConnectingOrStopping
            ? null // Disable button while in transition states
            : () {
          if (isConnected) {
            context.read<PsiphonBloc>().add(StopPsiphonConnection());
          } else {
            context.read<PsiphonBloc>().add(StartPsiphonConnection());
          }
        };

        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isConnected ? Colors.redAccent : Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          ),
          onPressed: onPressed,
          child: isConnectingOrStopping
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
            isConnected ? 'DISCONNECT' : 'CONNECT',
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        );
      },
    );
  }
}

class ProxyInfoDisplay extends StatelessWidget {
  const ProxyInfoDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PsiphonBloc, PsiphonState>(
      builder: (context, state) {
        final httpPort = state.status.httpProxyPort;
        final socksPort = state.status.socksProxyPort;

        if (httpPort == null && socksPort == null) {
          return const SizedBox.shrink(); // Return empty space if no ports
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (httpPort != null)
                  Text('HTTP Proxy: 127.0.0.1:$httpPort'),
                if (socksPort != null)
                  Text('SOCKS Proxy: 127.0.0.1:$socksPort'),
              ],
            ),
          ),
        );
      },
    );
  }
}