import 'dart:convert';
import 'dart:io';
import 'utils.dart';

const String HOST_KEY = "host";
const String PORT_KEY = "port";
const String DATA_KEY = "data";

const String DEFAULT_HOST = "127.0.0.1";
const int DEFAULT_PORT = 2526;

const String RESP_404 = """
{
  "message": "not found"
}
""";

class JsonServer {
  Map<String, dynamic> options = Map();
  Map<String, dynamic> database = Map();

  bool initialized = false;

  JsonServer({options}) {
    this.options = options;
  }

  dynamic getOption(String optionKey) {
    return this.options[optionKey];
  }

  Future init() async {
    if (!options.containsKey(DATA_KEY)) {
      return Future.error("Missing option: data");
    }

    var dataPath = options[DATA_KEY];
    this.database = jsonDecode(File(dataPath).readAsStringSync());

    if (!options.containsKey(HOST_KEY)) {
      this.options[HOST_KEY] = DEFAULT_HOST;
    }
    if (!options.containsKey(PORT_KEY)) {
      this.options[PORT_KEY] = DEFAULT_PORT;
    }

    this.initialized = true;
  }

  Future start() async {
    if (!this.initialized) {
      throw Exception("Servet is not initialized.");
    }

    HttpServer server = await HttpServer.bind(this.options[HOST_KEY], this.options[PORT_KEY], v6Only: false);
    Log.info("Server is started at http://${options[HOST_KEY]}:${options[PORT_KEY]}");

    await for (HttpRequest req in server) {
      req.response..headers.contentType = ContentType("application", "json", charset: "utf-8");

      try {
        var requestPath = req.requestedUri.path;

        if (!this.database.containsKey(requestPath)) {
          req.response.statusCode = HttpStatus.notFound;
          req.response.write(RESP_404);
        } else {
          req.response.write(jsonEncode(this.database[requestPath]));
        }

        await req.response.close();
      } catch (e) {
        Log.error("Handle request failed: ${e}");
      }
    }
  }
}
