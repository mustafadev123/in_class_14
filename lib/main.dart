import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'firebase_options.dart';
import 'services/fcm_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(const CloudCourierApp());
}

class CloudCourierApp extends StatelessWidget {
  const CloudCourierApp({super.key, this.startMessaging = true});

  final bool startMessaging;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloud Courier',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF006C75)),
        useMaterial3: true,
      ),
      home: CloudCourierHome(startMessaging: startMessaging),
    );
  }
}

class CloudCourierHome extends StatefulWidget {
  const CloudCourierHome({super.key, required this.startMessaging});

  final bool startMessaging;

  @override
  State<CloudCourierHome> createState() => _CloudCourierHomeState();
}

class _CloudCourierHomeState extends State<CloudCourierHome> {
  late final FCMService _fcmService;

  @override
  void initState() {
    super.initState();
    _fcmService = FCMService()..addListener(_onServiceChanged);
    if (widget.startMessaging) {
      _fcmService.initialize();
    }
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _fcmService
      ..removeListener(_onServiceChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final permission = _fcmService.authorizationStatus?.name ?? 'checking';
    final messageId = _fcmService.messageId ?? 'Not available';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Courier'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              _fcmService.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Image.asset(
                  _fcmService.asset.assetPath,
                  key: ValueKey(_fcmService.asset.assetPath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fcmService.diagnostic,
                      key: const Key('diagnostic'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _StatusRow(
                      label: 'Last handler',
                      value: _fcmService.lastHandler,
                    ),
                    _StatusRow(
                      label: 'Receipts this launch',
                      value: '${_fcmService.receiptCount}',
                    ),
                    _StatusRow(label: 'Message ID', value: messageId),
                    _StatusRow(label: 'Permission', value: permission),
                    _StatusRow(
                      label: 'Current token',
                      value: _fcmService.tokenAvailable
                          ? 'Available (hidden)'
                          : 'Not available',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _fcmService.token == null
                  ? null
                  : () async {
                      await Clipboard.setData(
                        ClipboardData(text: _fcmService.token!),
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Current token copied securely.'),
                        ),
                      );
                    },
              icon: const Icon(Icons.copy),
              label: const Text('Copy current token'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Supported data: action=update_ui and asset=default or promo.',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 145, child: Text('$label:')),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
