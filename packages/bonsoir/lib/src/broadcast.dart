import 'package:bonsoir/src/action_handler.dart';
import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';

/// Allows to broadcast a service on the network.
class BonsoirBroadcast extends BonsoirActionHandler<BonsoirBroadcastEvent> {
  /// The service to broadcast.
  final BonsoirService service;

  /// Creates a new Bonsoir broadcast instance.
  BonsoirBroadcast({
    bool printLogs = false,
    required this.service,
  }) : super(
          action: BonsoirPlatformInterface.instance.createBroadcastAction(
            service,
            printLogs: printLogs,
          ),
        );
}
