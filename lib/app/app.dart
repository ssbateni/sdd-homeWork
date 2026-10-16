import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/blog/application/blog_service.dart';
import '../features/blog/application/current_user_session.dart';
import '../features/blog/data/in_memory_post_repository.dart';
import '../features/blog/data/sample_data.dart';
import '../features/blog/presentation/blog_page.dart';
import '../features/blog/presentation/cubit/blog_cubit.dart';

/// Owns the single in-memory scope for this app's lifetime, not each rebuild.
class ContentAssistantApp extends StatefulWidget {
  const ContentAssistantApp({super.key});
  @override
  State<ContentAssistantApp> createState() => _ContentAssistantAppState();
}

class _ContentAssistantAppState extends State<ContentAssistantApp> {
  late final CurrentUserSession _session;
  late final BlogService _service;
  @override
  void initState() {
    super.initState();
    _session = CurrentUserSession(users: sampleUsers());
    _service = BlogService(
      repository: InMemoryPostRepository(samplePosts()),
      session: _session,
    );
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => BlogCubit(service: _service, session: _session),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'دستیار محلی انتشار محتوا',
      home: const BlogPage(),
    ),
  );
}
