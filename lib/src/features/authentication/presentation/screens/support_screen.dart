import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/core/network/dio_error.dart';
import 'package:lms_mobile_app/src/features/authentication/data/support_api.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key, required this.privacy});
  final bool privacy;

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  late final SupportApi _api = SupportApi(ServiceLocator().locator<Dio>());
  late Future<Map<String, dynamic>> _content = _load();

  Future<Map<String, dynamic>> _load() =>
      widget.privacy ? _api.privacyPolicy() : _api.customerService();

  void _retry() => setState(() => _content = _load());

  String _s(dynamic value) => value is String ? value.trim() : '';
  Map _map(dynamic value) => value is Map ? value : const {};
  List _list(dynamic value) => value is List ? value : const [];

  Future<void> _open(dynamic value) async {
    final uri = Uri.tryParse(_s(value));
    var opened = false;
    if (uri != null &&
        {'https', 'http', 'mailto', 'tel'}.contains(uri.scheme)) {
      try {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        opened = false;
      }
    }
    if (!opened) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tautan tidak dapat dibuka.')),
        );
      }
    }
  }

  Widget _text(dynamic value, {TextStyle? style}) {
    final string = _s(value);
    return string.isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(string, style: style),
          );
  }

  Widget _link(dynamic label, dynamic url) {
    if (_s(url).isEmpty) return const SizedBox.shrink();
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(_s(label).isEmpty ? _s(url) : _s(label)),
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap: () => _open(url),
    );
  }

  Widget _heading(dynamic value) => _text(
    value,
    style: Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
  );

  bool _hasContent(Map data) {
    if (widget.privacy) {
      final policy = _map(data['policy']);
      return _s(policy['title']).isNotEmpty ||
          _s(policy['intro']).isNotEmpty ||
          _map(policy['sections']).isNotEmpty;
    }
    return _s(data['title']).isNotEmpty ||
        _s(data['description']).isNotEmpty ||
        _list(data['contacts']).isNotEmpty ||
        _list(data['faq']).isNotEmpty ||
        _list(data['links']).isNotEmpty;
  }

  Widget _privacy(Map data) {
    final policy = _map(data['policy']);
    final sections = _map(policy['sections']);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _text(policy['eyebrow']),
        _heading(policy['title']),
        _text(policy['description']),
        _text(policy['updated']),
        _text(policy['intro']),
        for (final section in sections.values) ...[
          const SizedBox(height: 12),
          _heading(_map(section)['title']),
          for (final paragraph in _list(_map(section)['paragraphs']))
            _text(paragraph),
          for (final item in _list(_map(section)['items']))
            _text('• ${_s(item)}'),
        ],
        const SizedBox(height: 12),
        _heading(policy['contact_title']),
        _text(policy['contact_text']),
        if (_s(data['contact_email']).isNotEmpty)
          _link(data['contact_email'], 'mailto:${_s(data['contact_email'])}'),
        _link('Buka kebijakan di web', data['url']),
      ],
    );
  }

  Widget _service(Map data) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _heading(data['title']),
      _text(data['subtitle']),
      _text(data['description']),
      for (final contact in _list(data['contacts']))
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _text(_map(contact)['eyebrow']),
                _heading(_map(contact)['label']),
                _text(_map(contact)['description']),
                _text(_map(contact)['value']),
                _link(_map(contact)['action_label'], _map(contact)['url']),
              ],
            ),
          ),
        ),
      const SizedBox(height: 12),
      _heading(_map(data['service_hours'])['label']),
      _text(_map(data['service_hours'])['timezone']),
      _text(_map(data['service_hours'])['note']),
      _heading(_map(data['request_guidance'])['title']),
      _text(_map(data['request_guidance'])['description']),
      for (final item in _list(_map(data['request_guidance'])['items']))
        _text('• ${_s(item)}'),
      _text(_map(data['request_guidance'])['warning']),
      if (_list(data['faq']).isNotEmpty) _heading('Pertanyaan umum'),
      for (final faq in _list(data['faq']))
        ExpansionTile(
          title: Text(_s(_map(faq)['question'])),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _text(_map(faq)['answer']),
                  _link(
                    _map(_map(faq)['link'])['label'],
                    _map(_map(faq)['link'])['url'],
                  ),
                ],
              ),
            ),
          ],
        ),
      for (final link in _list(data['links']))
        _link(_map(link)['label'], _map(link)['url']),
    ],
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.privacy ? 'Kebijakan Privasi' : 'Pusat Bantuan'),
    ),
    body: FutureBuilder<Map<String, dynamic>>(
      future: _content,
      builder: (context, snapshot) {
        if (!snapshot.hasData && !snapshot.hasError) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          final error = snapshot.error;
          final message = error is DioException
              ? friendlyDioMessage(error, 'Konten gagal dimuat.')
              : 'Konten gagal dimuat. Coba lagi.';
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message),
                TextButton(onPressed: _retry, child: const Text('Coba lagi')),
              ],
            ),
          );
        }
        final data = snapshot.data!;
        if (!_hasContent(data)) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Konten belum tersedia.'),
                TextButton(onPressed: _retry, child: const Text('Muat ulang')),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            _retry();
            await _content;
          },
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [widget.privacy ? _privacy(data) : _service(data)],
          ),
        );
      },
    ),
  );
}
