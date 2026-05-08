// ignore_for_file: unused_import
// Imports are consumed by `part` files (blocs.dart, providers.dart,
// repositories.dart, mappers.dart) — the analyzer can't see them across
// the part boundary.

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/local_db/local_database.dart';
import 'package:flutter_chat/mappers/chat_message_mapper.dart';
import 'package:flutter_chat/network/service/chat_api_service.dart';
import 'package:flutter_chat/network/service/impl/chat_api_service_impl.dart';
import 'package:flutter_chat/network/service/impl/local_sql_service_impl.dart';
import 'package:flutter_chat/network/service/local_sql_service.dart';
import 'package:flutter_chat/other/contants/api_contants.dart';
import 'package:flutter_chat/repositories/chat_repository.dart';
import 'package:flutter_chat/repositories/impl/chat_repository_impl.dart';
import 'package:flutter_chat/state_management/blocs/chat_bloc/chat_bloc.dart';
import 'package:pine/pine.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

part 'blocs.dart';
part 'mappers.dart';
part 'providers.dart';
part 'repositories.dart';

class DependencyInjector extends StatelessWidget {
  final Widget child;

  const DependencyInjector({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => DependencyInjectorHelper(
        blocs: blocs,
        mappers: _mappers,
        repositories: repositories,
        providers: _providers,
        child: child,
      );
}
