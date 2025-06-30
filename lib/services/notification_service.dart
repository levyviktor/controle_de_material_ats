import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool _permissionGranted = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    final initialized = await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = initialized ?? false;
    
    if (kDebugMode) {
      print('NotificationService: Inicializado com sucesso');
    }
  }

  Future<bool> requestPermission() async {
    if (_permissionGranted) return true;

    try {
      // Para Android
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidImplementation != null) {
        final granted = await androidImplementation.requestNotificationsPermission();
        _permissionGranted = granted ?? false;
      } else {
        // Para iOS ou outras plataformas, assume que foi concedido
        _permissionGranted = true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao solicitar permissão: $e');
      }
      _permissionGranted = false;
    }
    
    if (kDebugMode) {
      print('NotificationService: Permissão ${_permissionGranted ? 'concedida' : 'negada'}');
    }
    
    return _permissionGranted;
  }

  Future<void> showDataUpdateNotification({
    required int newItemsCount,
    required int totalItems,
  }) async {
    if (!_isInitialized) return;

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'data_updates',
        'Atualizações de Dados',
        channelDescription: 'Notificações sobre atualizações na planilha de materiais',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF1976D2),
        playSound: true,
        enableVibration: true,
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      String title = 'Planilha Atualizada! 📊';
      String body;
      
      if (newItemsCount > 0) {
        body = '$newItemsCount novos itens adicionados. Total: $totalItems equipamentos';
      } else {
        body = 'Dados atualizados. Total: $totalItems equipamentos';
      }

      await _flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        platformChannelSpecifics,
      );

      if (kDebugMode) {
        print('NotificationService: Notificação enviada - $title: $body');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao enviar notificação: $e');
      }
    }
  }

  Future<void> showErrorNotification(String errorMessage) async {
    if (!_isInitialized) return;

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'errors',
        'Erros do Sistema',
        channelDescription: 'Notificações sobre erros no carregamento de dados',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFFD32F2F),
        playSound: true,
        enableVibration: true,
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        1,
        'Erro na Atualização ⚠️',
        'Não foi possível atualizar os dados: $errorMessage',
        platformChannelSpecifics,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao enviar notificação de erro: $e');
      }
    }
  }

  Future<void> showWelcomeNotification() async {
    if (!_isInitialized) return;

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'welcome',
        'Boas-vindas',
        channelDescription: 'Notificação de boas-vindas',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF1976D2),
        playSound: false,
        enableVibration: false,
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: false,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        2,
        'Notificações Ativadas! ✅',
        'Você será notificado sobre atualizações na planilha de materiais',
        platformChannelSpecifics,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao enviar notificação de boas-vindas: $e');
      }
    }
  }

  void _onNotificationTapped(NotificationResponse notificationResponse) {
    if (kDebugMode) {
      print('NotificationService: Notificação tocada - ID: ${notificationResponse.id}');
    }
    // Aqui você pode adicionar navegação específica baseada no tipo de notificação
  }

  bool get hasPermission => _permissionGranted;

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
