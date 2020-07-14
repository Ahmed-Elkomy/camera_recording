// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/material.dart';

import 'alert_types.dart';
import 'alerts_create_video_view.dart';

class CameraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AlertsCreateVideoView(
        alertType: AlertTypes.ready_set_trade,
      ),
//      home: VideoPicker(),
    );
  }
}

Future<void> main() async {
  runApp(CameraApp());
}
