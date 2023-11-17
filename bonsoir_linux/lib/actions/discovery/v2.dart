import 'dart:async';

import 'package:bonsoir_linux/actions/discovery/discovery.dart';
import 'package:bonsoir_linux/avahi/constants.dart';
import 'package:bonsoir_linux/avahi/record_browser.dart';
import 'package:bonsoir_linux/avahi/server2.dart';
import 'package:bonsoir_linux/avahi/service_browser.dart';
import 'package:bonsoir_linux/avahi/service_resolver.dart';
import 'package:bonsoir_linux/bonsoir_linux.dart';
import 'package:bonsoir_linux/error.dart';
import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';
import 'package:dbus/dbus.dart';

/// Uses newer Avahi versions to discover a given service [type].
class AvahiDiscoveryV2 extends AvahiHandler {
  /// The Avahi server instance.
  late final AvahiServer2 _server;

  /// Creates a new Avahi discovery v2 instance.
  AvahiDiscoveryV2({
    required super.busClient,
  });

  @override
  void initialize() {
    _server = AvahiServer2(busClient, AvahiBonsoir.avahi, DBusObjectPath('/'));
  }

  @override
  Future<String> getAvahiServiceBrowserPath(String serviceType) => _server.callServiceBrowserPrepare(
        AvahiIfIndexUnspecified,
        AvahiProtocolUnspecified,
        serviceType,
        '',
        0,
      );

  @override
  Future<AvahiRecordBrowser> createAvahiRecordBrowser(AvahiBonsoirDiscovery discovery, BonsoirService service) async {
    String recordBrowserPath = await _server.callRecordBrowserPrepare(
      AvahiIfIndexUnspecified,
      AvahiProtocolUnspecified,
      service.fqdn,
      0x01,
      0x10,
      0,
    );
    AvahiRecordBrowser recordBrowser = AvahiRecordBrowser(busClient, AvahiBonsoir.avahi, DBusObjectPath(recordBrowserPath));
    discovery.registerSubscription(recordBrowser.itemNew.listen(discovery.onServiceTXTRecordFound));
    return recordBrowser;
  }

  @override
  List<StreamSubscription> getSubscriptions(AvahiBonsoirDiscovery discovery, AvahiServiceBrowser serviceBrowser) => [
        serviceBrowser.itemNew.listen(discovery.onServiceFound),
        serviceBrowser.itemRemove.listen(discovery.onServiceLost),
      ];

  @override
  Future<void> resolveService(AvahiBonsoirDiscovery discovery, BonsoirService service, AvahiServiceBrowserItemNew event) async {
    String serviceResolverPath = await _server.callServiceResolverPrepare(
      event.interfaceValue,
      event.protocol,
      event.serviceName,
      event.type,
      event.domain,
      AvahiProtocolUnspecified,
      0,
    );
    AvahiServiceResolver resolver = AvahiServiceResolver(busClient, AvahiBonsoir.avahi, DBusObjectPath(serviceResolverPath));
    Object? oneOf = await Future.any(
      [resolver.failure.first, resolver.found.first],
    );
    if (oneOf is AvahiServiceResolverFound) {
      discovery.onServiceResolved(oneOf);
    } else if (oneOf is AvahiServiceResolverFailure) {
      discovery.onServiceResolveFailure(oneOf);
    } else {
      discovery.onError(AvahiBonsoirError('Unknown error while resolving the service ${service.description}', oneOf));
    }
  }
}
