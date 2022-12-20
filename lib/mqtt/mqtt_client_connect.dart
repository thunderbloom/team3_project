import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'package:project_flutter/pages/notification_service.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'dart:convert';


import 'package:project_flutter/pages/mysql.dart';

Future<MqttClient> connect() async {
  MqttServerClient client = 
    // MqttServerClient.withPort('34.64.233.244', 'test999', 19883);
    MqttServerClient.withPort('34.64.233.244', 'ayWebSocketClient_123456_33f7423c-a3b7-46b1-8a1a-26937e4a071f', 19883);
  client.logging(on : true);
  client.onConnected = onConnected;
  
  client.onDisconnected =  onDisconnected;
  client.keepAlivePeriod = 20;
  // client.onUnsubscribed = onUnsubscribed;
  
  client.port = 19883;
  client.onSubscribeFail = onSubscribeFail;
  client.pongCallback = pong;
  
 

  final connMess = MqttConnectMessage()
      // .withClientIdentifier("test999")
      .withClientIdentifier("ayWebSocketClient_123456_33f7423c-a3b7-46b1-8a1a-26937e4a071f")
      .authenticateAs("admin", "qwer123")
      // .keepAliveFor(60)
      .withWillTopic('willtopic')
      .withWillMessage("My Will message")
      .startClean()
      .withWillQos(MqttQos.atLeastOnce);
  client.connectionMessage = connMess;

  try {
    print('Connecting');
    await client.connect("admin", "qwer123");
  } catch (e) {
    print('Exception: $e');
    client.disconnect();
  }

  if (client.connectionStatus!.state == MqttConnectionState.connected) {
    print('EMQX client connected');
    print("접속완료");
    const topic = 'house/door';
    
    // client.subscribe(topic, MqttQos.atLeastOnce);
    client.subscribe('test9999', MqttQos.atLeastOnce);
    // client.subscribe('house/door', MqttQos.atLeastOnce);
    // client.subscribe('house/door1', MqttQos.atLeastOnce);
    // client.subscribe('house/door2', MqttQos.atLeastOnce);
    // client.subscribe('house/window', MqttQos.atLeastOnce);
    // client.subscribe('house/window1', MqttQos.atLeastOnce);
    // client.subscribe('house/window2', MqttQos.atLeastOnce);
    // client.subscribe('house/camera', MqttQos.atLeastOnce);
    // client.subscribe('house/camera1', MqttQos.atLeastOnce);
    // client.subscribe('house/camera2', MqttQos.atLeastOnce);

    // client.update?.listen 이 callback 함수 역할을 함.
    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final recMess = c[0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      var jsonPt = json.decode(pt);
      // Map<String, dynamic> jsonPt = jsonDecode(pt);
      final sensor = jsonPt["sensor"];
      final status = jsonPt["status"];
      // print(payloadmsg);
      // final MqttMessage message = c[0].payload;
      // final payload = 
      //   MqttPublishPayload.bytesToStringAsString(message.toString()); //.payload.message;
      
      // print('Received message:$payload from topic: ${c[0].topic}>');
      NotificationService()
      .showNotification(0, '새로운 알림이 있습니다.', '$sensor에서 $status 되었습니다',);
      // .showNotification(0, '새로운 알림이 있습니다.', '${c[0].topic}에서 $status 되었습니다',);
      // NotificationService()
      // .showNotification(0, '새로운 알림이 있습니다.', '${c[0].topic}에서 움직임이 감지되었습니다',);
      
      print('Received message: from topic: ${c[0].topic}>');  
    });

    client.published?.listen((MqttPublishMessage message) {
      print('published');
      final payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);
      
      // NotificationService()
      // .showNotification(0, '새로운 알림이 있습니다', '${message.variableHeader?.topicName}에서 $payload.',);
      // print(formatDate);
      print(        
        'Published message: $payload to topic: ${message.variableHeader?.topicName}'
      );
      
    });
  } else {
    print(
      'EMQX client connection failed - disconnecting, status is ${client.connectionStatus}');
    client.disconnect();
    exit(-1);
    
  }
  return client;
}




void onMessage() { print('Message Arrived');}
void onConnected() {  
  NotificationService()
      .showNotification(0, '새로운 알림이 있습니다.', '서버와 연결되었습니다',);
  print('Connected');}
void onDisconnected() { 
  NotificationService()
      .showNotification(0, '새로운 알림이 있습니다.', '서버와 연결이 해제되었습니다',);
  print('Disconneted');}
void onSubscribed(String topic) { print('subscribed topic: $topic');}
void onSubscribeFail(String topic) { print('Failed to subscribe: $topic');}
void onUnsubscribed(String topic) { print('Unsubscribed topic: $topic');}
void pong() { print('Ping response client callback invoked');}