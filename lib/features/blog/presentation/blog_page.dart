import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/app_user.dart';
import '../domain/blog_result.dart';
import '../domain/post.dart';
import '../application/publish_delay.dart';
import 'cubit/blog_cubit.dart';
import 'cubit/blog_state.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({super.key, this.demoDelay});
  final DemoPublishDelay? demoDelay;
  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  String? _dialogRequestId;
  BuildContext? _dialogContext;

  Future<void> _listen(BuildContext context, BlogState state) async {
    if (_dialogContext != null &&
        state.pending?.requestId != _dialogRequestId) {
      Navigator.of(_dialogContext!).pop();
      _dialogContext = null;
    }
    final pending = state.pending;
    if (pending == null ||
        state.phase != BlogPhase.awaitingConfirmation ||
        _dialogRequestId != null) {
      return;
    }
    final cubit = context.read<BlogCubit>();
    _dialogRequestId = pending.requestId;
    final answer = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        _dialogContext = dialogContext;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('تأیید اجرای انتشار'),
            content: Text(
              'پست ${pending.postId}: ${pending.title}\n'
              'draft → published\n'
              'تأیید محتوای پست ثبت شده است؛ آیا اجرای انتشار را تأیید می‌کنید؟',
            ),
            actions: [
              TextButton(
                key: const Key('publish-cancel'),
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('لغو'),
              ),
              FilledButton(
                key: const Key('publish-confirm'),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('تأیید انتشار'),
              ),
            ],
          ),
        );
      },
    );
    _dialogContext = null;
    _dialogRequestId = null;
    if (!mounted ||
        cubit.isClosed ||
        cubit.state.pending?.requestId != pending.requestId ||
        cubit.state.phase != BlogPhase.awaitingConfirmation) {
      return;
    }
    if (answer == true) {
      await cubit.confirm();
    } else {
      cubit.cancel();
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(title: const Text('دستیار محلی انتشار محتوا')),
      body: BlocConsumer<BlogCubit, BlogState>(
        listener: _listen,
        builder: (context, state) {
          final cubit = context.read<BlogCubit>();
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('انتخاب کاربر آزمایشی (ورود واقعی نیست)'),
                DropdownButton<String>(
                  key: const Key('user-picker'),
                  isExpanded: true,
                  value: state.user?.id,
                  hint: const Text('انتخاب کاربر'),
                  items: cubit.availableUsers
                      .map(
                        (user) => DropdownMenuItem(
                          value: user.id,
                          child: Text(
                            '${user.id} (${user.role == UserRole.author ? 'Author' : 'Editor'})',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) cubit.selectUser(value);
                  },
                ),
                if (state.phase == BlogPhase.noUser)
                  const Text('یک کاربر آزمایشی انتخاب کنید.'),
                if (state.phase == BlogPhase.loading)
                  const LinearProgressIndicator(),
                if (kDebugMode && widget.demoDelay != null)
                  DropdownButton<PublishDemoMode>(
                    key: const Key('demo-delay'),
                    value: widget.demoDelay!.mode,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: PublishDemoMode.normal,
                        child: Text('دمو: بدون تأخیر'),
                      ),
                      DropdownMenuItem(
                        value: PublishDemoMode.beforeCommit,
                        child: Text('دمو: تأخیر قبل از ثبت'),
                      ),
                      DropdownMenuItem(
                        value: PublishDemoMode.afterCommit,
                        child: Text('دمو: تأخیر پاسخ پس از ثبت'),
                      ),
                    ],
                    onChanged: state.pending != null
                        ? null
                        : (mode) {
                            if (mode != null) {
                              setState(() => widget.demoDelay!.mode = mode);
                            }
                          },
                  ),
                if (state.failure != null)
                  Text(
                    _errorMessage(
                      state.failure!.code,
                      isPublish: state.selectedPost != null,
                    ),
                    key: const Key('error-message'),
                  ),
                if (state.phase == BlogPhase.success)
                  const Text('پست با موفقیت منتشر شد.'),
                if (state.phase == BlogPhase.cancelled)
                  const Text('انتشار لغو شد.'),
                if (state.phase == BlogPhase.unknownOutcome) ...[
                  Text(
                    'نتیجهٔ انتشار نامعلوم است؛ ممکن است انجام شده باشد.\nدرخواست: ${state.pending!.requestId}',
                    key: const Key('unknown-outcome'),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      key: const Key('publish-retry'),
                      onPressed: cubit.retry,
                      child: const Text('پیگیری / Retry'),
                    ),
                  ),
                ],
                if (state.selectedPost != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      key: const Key('publish-request'),
                      onPressed:
                          state.phase == BlogPhase.publishing ||
                              state.pending != null
                          ? null
                          : cubit.requestPublish,
                      child: const Text('درخواست انتشار'),
                    ),
                  ),
                const SizedBox(height: 12),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 220,
                        child: state.user != null && state.posts.isEmpty
                            ? const Text('پستی برای نمایش ندارید.')
                            : ListView(
                                children: state.posts
                                    .map(
                                      (post) => ListTile(
                                        key: Key('post-${post.id}'),
                                        title: Text(post.title),
                                        subtitle: Text(
                                          '${post.id} — ${post.status.name}',
                                        ),
                                        selected:
                                            state.selectedPost?.id == post.id,
                                        onTap: () => cubit.selectPost(post.id),
                                      ),
                                    )
                                    .toList(),
                              ),
                      ),
                      const VerticalDivider(),
                      Expanded(
                        child: state.selectedPost == null
                            ? const Text('برای مشاهده، یک پست انتخاب کنید.')
                            : _PostDetails(post: state.selectedPost!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

String _errorMessage(BlogErrorCode code, {bool isPublish = false}) =>
    switch (code) {
      BlogErrorCode.permissionDenied =>
        isPublish ? 'مجوز انتشار ندارید.' : 'اجازهٔ مشاهده ندارید.',
      BlogErrorCode.notFound => 'پست یافت نشد.',
      BlogErrorCode.invalidArguments => 'شناسه یا انتخاب کاربر نامعتبر است.',
      BlogErrorCode.notApproved => 'پست هنوز تأیید نشده است.',
      BlogErrorCode.alreadyPublished => 'پست قبلاً منتشر شده است.',
      BlogErrorCode.invalidStatus => 'پست آرشیوشده قابل انتشار نیست.',
      BlogErrorCode.staleConfirmation =>
        'شرایط تغییر کرده است؛ درخواست و تأیید تازه لازم است.',
      BlogErrorCode.cancelled => 'انتشار لغو شده است.',
      BlogErrorCode.requestConflict =>
        'درخواست با کاربر یا عملیات فعلی سازگار نیست.',
      BlogErrorCode.confirmationRequired => 'تأیید صریح اجرای انتشار لازم است.',
    };

class _PostDetails extends StatelessWidget {
  const _PostDetails({required this.post});
  final Post post;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('شناسه: ${post.id}', key: const Key('detail-id')),
        Text(
          post.title,
          key: const Key('detail-title'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text('وضعیت: ${post.status.name}', key: const Key('detail-status')),
        Text('تأیید پست: ${post.approved}', key: const Key('detail-approved')),
        Text('نویسنده: ${post.authorId}', key: const Key('detail-author')),
        Text(
          'زمان ایجاد: ${post.createdAt.toIso8601String()}',
          key: const Key('detail-created'),
        ),
        const Divider(),
        Text(post.content, key: const Key('detail-content')),
      ],
    ),
  );
}
