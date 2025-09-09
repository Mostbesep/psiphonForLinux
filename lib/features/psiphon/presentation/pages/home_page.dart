import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
          title: const Text('Psiphon'),
          leading: IconButton(
            tooltip: 'Open Official website',
              onPressed: () {
                sl<PsiphonBloc>().add(OpenWebsite("https://psiphon.ca/"));
              }, icon: Image.asset('assets/logo/psiphonlogo.png')),
          actions: [
            IconButton(
              onPressed: () {
                showAboutDialog(
                    context: context,
                  applicationIcon: Image.asset('assets/logo/psiphonlogo.png', width: 32, height: 32,),
                  children: [
                    Text('Unofficial psiphon gui application for linux users',
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                    SizedBox(height: 8,),
                    Text('Psiphon is a free VPN service that allows you to bypass internet censorship and access blocked websites.',),
                    SizedBox(height: 8,),
                    TextButton(
                        onPressed: () {
                          sl<PsiphonBloc>().add(OpenWebsite("https://psiphon.ca/"));
                        },
                        child: Text("Psiphon official website"),),
                    Divider(),
                    Text('This project is not developed by Psiphon and is an open source project. You can view the source code on GitHub.', style: TextStyle(color: Colors.white, fontSize: 16)),
                    SizedBox(height: 8,),
                    Text('try to help improve the project by contributing to it. You can view the issues and pull requests on GitHub.', style: TextStyle(color: Colors.white, fontSize: 14)),
                    SizedBox(height: 8,),
                    TextButton(
                        onPressed: () {
                          sl<PsiphonBloc>().add(OpenWebsite("https://github.com/Mostbesep/psiphonForLinux"));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("View source code on GitHub"),
                              SvgPicture.asset('assets/svg/github_icon.svg' , width: 35, height: 35,),
                            ],
                          ),
                        ),
                    ),
                    Text('Made with ❤️ by mostbesep', style: TextStyle(color: Colors.white, fontSize: 14)),
                    Divider(),
                    Text('License', style: TextStyle(color: Colors.white, fontSize: 22)),
                    SizedBox(height: 8,),
                    Text(                  '''
MIT License

Copyright (c) 2025 mostbesep

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
'''),
                  ],
                );
              },
              icon: Icon(
                  Icons.info
              ),
            )
          ],
        ),
        body: Container(
          child: Stack(
            children: [
              SvgPicture.asset('assets/svg/header_desktop.svg', fit: BoxFit.cover,),
              const Center(
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
            ],
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
