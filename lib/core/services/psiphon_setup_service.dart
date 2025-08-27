import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';


class PsiphonPaths {
  final String binaryPath;
  final String configPath;

  PsiphonPaths({required this.binaryPath, required this.configPath});
}

class PsiphonSetupService {
  // URL
  final String _binaryUrl =
      'https://raw.githubusercontent.com/Psiphon-Labs/psiphon-tunnel-core-binaries/master/linux/psiphon-tunnel-core-x86_64';


  final String _configContent = '''
{
"LocalHttpProxyPort":8086,
"LocalSocksProxyPort":1081,
"EgressRegion":"NL",
"PropagationChannelId":"FFFFFFFFFFFFFFFF",
"RemoteServerListDownloadFilename":"remote_server_list",
"RemoteServerListSignaturePublicKey":"MIICIDANBgkqhkiG9w0BAQEFAAOCAg0AMIICCAKCAgEAt7Ls+/39r+T6zNW7GiVpJfzq/xvL9SBH5rIFnk0RXYEYavax3WS6HOD35eTAqn8AniOwiH+DOkvgSKF2caqk/y1dfq47Pdymtwzp9ikpB1C5OfAysXzBiwVJlCdajBKvBZDerV1cMvRzCKvKwRmvDmHgphQQ7WfXIGbRbmmk6opMBh3roE42KcotLFtqp0RRwLtcBRNtCdsrVsjiI1Lqz/lH+T61sGjSjQ3CHMuZYSQJZo/KrvzgQXpkaCTdbObxHqb6/+i1qaVOfEsvjoiyzTxJADvSytVtcTjijhPEV6XskJVHE1Zgl+7rATr/pDQkw6DPCNBS1+Y6fy7GstZALQXwEDN/qhQI9kWkHijT8ns+i1vGg00Mk/6J75arLhqcodWsdeG/M/moWgqQAnlZAGVtJI1OgeF5fsPpXu4kctOfuZlGjVZXQNW34aOzm8r8S0eVZitPlbhcPiR4gT/aSMz/wd8lZlzZYsje/Jr8u/YtlwjjreZrGRmG8KMOzukV3lLmMppXFMvl4bxv6YFEmIuTsOhbLTwFgh7KYNjodLj/LsqRVfwz31PgWQFTEPICV7GCvgVlPRxnofqKSjgTWI4mxDhBpVcATvaoBl1L/6WLbFvBsoAUBItWwctO2xalKxF5szhGm8lccoc5MZr8kfE0uxMgsxz4er68iCID+rsCAQM=",
"RemoteServerListUrl":"https://s3.amazonaws.com//psiphon/web/mjr4-p23r-puwl/server_list_compressed",
"SponsorId":"FFFFFFFFFFFFFFFF",
"UseIndistinguishableTLS":true
}
''';


  Future<PsiphonPaths> checkAndPrepare() async {
    try {

      final dir = await getApplicationDocumentsDirectory();
      final String binaryPath = '${dir.path}/psiphon-tunnel-core-x86_64';
      final String configPath = '${dir.path}/psiphon.config';

      final binaryFile = File(binaryPath);
      final configFile = File(configPath);


      if (!await binaryFile.exists()) {
        print('downloading binary file...');
        await _downloadBinary(binaryFile);
        print('downloaded binary file complete');


        if (Platform.isLinux || Platform.isMacOS) {
          print('make binary file executable ...');
          await _makeFileExecutable(binaryPath);
          print('make binary file executable complete');
        }
      } else {
        print('binary file already exists');
      }


      if (!await configFile.exists()) {
        print('making config file ...');
        await configFile.writeAsString(_configContent);
        print('making config file complete');
      } else {
        print('config file already exists');
      }

      return PsiphonPaths(binaryPath: binaryPath, configPath: configPath);
    } catch (e) {
      print('Error while setting up Psiphon: $e');
      // در یک برنامه واقعی باید این خطا رو بهتر مدیریت کنید
      rethrow;
    }
  }

  Future<void> _downloadBinary(File file) async {
    final response = await http.get(Uri.parse(_binaryUrl));
    if (response.statusCode == 200) {
      await file.writeAsBytes(response.bodyBytes);
    } else {
      throw Exception(
          'Error while downloading binary file: ${response.statusCode}');
    }
  }

  Future<void> _makeFileExecutable(String path) async {
    final result = await Process.run('chmod', ['+x', path]);
    if (result.exitCode != 0) {
      throw Exception(
          'Error while making file executable: ${result.stderr}');
    }
  }
}