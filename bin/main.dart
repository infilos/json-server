import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:dcli/dcli.dart';
import 'package:json_server/json_server.dart';
import 'package:json_server/src/utils.dart';

main(List<String> args) async {
  ArgParser parser = ArgParser();
  parser..addOption('host', abbr: 'h', defaultsTo: "127.0.0.1");
  parser..addOption('port', abbr: 'p', defaultsTo: "2526");
  parser..addOption('data', abbr: 'd');
  parser..addFlag('help', defaultsTo: false, negatable: false);

  ArgResults results = parser.parse(args);
  var host = results['host'] as String;
  var port = results['port'] as String;
  var data = results['data'] as String?;
  var help = results['help'] as bool;

  print(host);
  print(port);
  print(data);
  print(help);

  if (help) {
    stdout.write("""
    Launch a JSON API server from a source.
    
    Usage: jserve --data <json_file>
        , --help            Print this usage information.
      -d, --data            Path to JSON file. Required.
      -h, --host            Server address. Default: 127.0.0.1
      -p, --port            Specify port to use. Default: 2526
    
    Example:
      \$ jserve --data ~/server/api.json
      \$ jserve -d ~/api.json -h 127.0.0.1 -p 9999
    """);
    exit(0);
  }

  if (data == null) {
    Log.error("Option 'data' missing.");
    exit(1);
  }

  File path = File(data);
  if (!path.existsSync()) {
    Log.error("Data file '$data' not exists.");
    exit(1);
  }

  try {
    Map<String, dynamic> database = jsonDecode(path.readAsStringSync());
    if (database.length == 0) {
      Log.error("Data file '$data' is empty.");
      exit(1);
    }
  } catch (e) {
    Log.error("Data file '$data' parse failed: ${e}");
    exit(1);
  }

  try {
    int.parse(port);
  } catch (e) {
    Log.error("Port value $port is invalid.");
    exit(1);
  }

  try {
    Map<String, dynamic> options = Map();
    options["host"] = host;
    options["port"] = int.parse(port);
    options["data"] = data;

    JsonServer server = JsonServer(options: options);
    await server.init();
    await server.start();
  } catch (e) {
    Log.error('Start json server failed: ${e}\n');
    exit(1);
  }
}
