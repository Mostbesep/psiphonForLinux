import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/connection_status.dart' as ps;
import '../bloc/psiphon_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
                SizedBox(height: 24),
                ConnectionButton(),
                SizedBox(height: 24),
                RegionSelector(),
                SizedBox(height: 16),
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
  const ConnectionStatusDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PsiphonBloc, PsiphonState, ps.ConnectionState>(
      selector: (state) => state.status.state,
      builder: (context, connectionState) {
        return Column(
          children: [
            Text(
              'Status: ${connectionState.name.toUpperCase()}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
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
  const ConnectionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PsiphonBloc, PsiphonState>(
      builder: (context, state) {
        final status = state.status;
        final bool isConnectingOrStopping =
            status.state == ps.ConnectionState.connecting ||
                status.state == ps.ConnectionState.stopping;

        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: state.serviceIsRunning ? Colors.redAccent : Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          ),
          onPressed: () {
            if (state.serviceIsRunning) {
              context.read<PsiphonBloc>().add(StopPsiphonConnection());
            } else {
              if (isConnectingOrStopping) {
                context.read<PsiphonBloc>().add(StartPsiphonConnection());
              } else {
                context.read<PsiphonBloc>().add(StartPsiphonConnection());
              }
            }
          },
          child:Text(
            state.serviceIsRunning==true ?
            isConnectingOrStopping? 'Cancel': 'Stop':
            'Start',
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        );
      },
    );
  }
}


class RegionSelector extends StatelessWidget {
  const RegionSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PsiphonBloc, PsiphonState>(
      builder: (context, state) {
        final status = state.status;
        final availableRegions = status.availableRegions;
        final selectedRegion = status.selectedEgressRegion;

        final bool isBusy = status.state == ps.ConnectionState.connecting ||
            status.state == ps.ConnectionState.stopping ||
            status.state == ps.ConnectionState.connected;

        return Card(
          child: ListTile(
            leading: const Icon(Icons.public),
            title: const Text('Server Location'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selectedRegion != null) Text(selectedRegion),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
            onTap: isBusy
                ? null
            // Pass the context that has access to the Bloc
                : () => _showRegionSelectionDialog(context, availableRegions),
          ),
        );
      },
    );
  }

  void _showRegionSelectionDialog(
      BuildContext context, List<String> regions) {
    // Get the Bloc instance from the correct context BEFORE showing the dialog.
    final bloc = context.read<PsiphonBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Select a Region'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: regions.length,
              itemBuilder: (context, index) {
                final region = regions[index];
                return ListTile(
                  title: Text(region),
                  onTap: () {
                    // Use the bloc instance we captured earlier.
                    bloc.add(SelectRegion(region));
                    Navigator.of(dialogContext).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class ProxyInfoDisplay extends StatelessWidget {
  const ProxyInfoDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PsiphonBloc, PsiphonState>(
      builder: (context, state) {
        final httpPort = state.status.httpProxyPort;
        final socksPort = state.status.socksProxyPort;

        if (httpPort == null && socksPort == null) {
          return const SizedBox.shrink();
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
