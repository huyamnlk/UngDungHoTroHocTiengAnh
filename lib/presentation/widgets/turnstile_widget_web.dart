// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';

int _nextTurnstileViewId = 0;

class TurnstileWidget extends StatefulWidget {
  final String siteKey;
  final ValueChanged<String> onToken;
  final ValueChanged<String>? onError;

  const TurnstileWidget({
    super.key,
    required this.siteKey,
    required this.onToken,
    this.onError,
  });

  @override
  State<TurnstileWidget> createState() => _TurnstileWidgetState();
}

class _TurnstileWidgetState extends State<TurnstileWidget> {
  late final String _viewType;
  html.DivElement? _element;
  StreamSubscription<html.Event>? _tokenSubscription;

  @override
  void initState() {
    super.initState();
    _viewType = 'english-buddy-turnstile-${_nextTurnstileViewId++}';
    _tokenSubscription = html.window.on[_eventName].listen((event) {
      if (event is html.CustomEvent && event.detail is String && mounted) {
        final detail = event.detail as String;
        if (detail.startsWith('!error:')) {
          widget.onError?.call(detail.substring(7));
        } else if (detail == '!expired') {
          widget.onError?.call('Mã chống bot đã hết hạn. Hãy xác minh lại.');
        } else {
          widget.onToken(detail);
        }
      }
    });
    ui.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final element = html.DivElement()
        ..id = _viewType
        ..style.width = '100%'
        ..style.minHeight = '65px';
      _element = element;
      _renderWhenReady();
      return element;
    });
  }

  String get _eventName => 'english-buddy-turnstile-token-$_viewType';

  void _renderWhenReady() {
    final siteKey = jsonEncode(widget.siteKey);
    final elementId = jsonEncode(_viewType);
    final eventName = jsonEncode(_eventName);
    final script = html.ScriptElement()
      ..text =
          '''
        (function() {
          let attempts = 0;
          function render() {
            const host = document.getElementById($elementId);
            if (host && window.turnstile && !host.dataset.widgetId) {
              const widgetId = window.turnstile.render(host, {
                sitekey: $siteKey,
                theme: 'auto',
                action: 'auth',
                callback: token => window.dispatchEvent(
                  new CustomEvent($eventName, {detail: token})),
                'error-callback': code => window.dispatchEvent(
                  new CustomEvent($eventName, {detail: '!error:' + String(code)})),
                'expired-callback': () => window.dispatchEvent(
                  new CustomEvent($eventName, {detail: '!expired'}))
              });
              host.dataset.widgetId = widgetId;
              return;
            }
            if (++attempts < 120) window.setTimeout(render, 250);
            else window.dispatchEvent(new CustomEvent($eventName,
              {detail: '!error:Không tải được Turnstile. Kiểm tra kết nối mạng.'}));
          }
          render();
        })();
      ''';
    html.document.body?.append(script);
  }

  @override
  void dispose() {
    _tokenSubscription?.cancel();
    _element?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: 70, child: HtmlElementView(viewType: _viewType));
}
