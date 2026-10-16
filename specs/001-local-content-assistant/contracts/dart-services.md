# قرارداد سرویس‌های Dart — P1

این سند قرارداد طراحی است، نه کد آمادهٔ اجرا. HTTP/OpenAPI وجود ندارد. همهٔ فراخوانی‌ها
در همان process هستند؛ role، approved و confirmed آرگومان قابل اعتماد از مدل نیستند.

## انواع مشترک

- BlogResult<T>: دقیقاً BlogSuccess<T>(value) یا BlogFailure(code, message).
- BlogFailure.code: یکی از کدهای جدول پایین؛ payload شامل Post غیرمجاز نیست.
- PendingPublish و PublishReceipt طبق data-model.md؛ فهرست‌ها و مدل‌ها immutable هستند.
- postId یک int مثبت است؛ مرز adapter آینده باید ورودی خام را پیش از تبدیل به int اعتبارسنجی کند.
- requestId یک String غیرخالی صادرشده توسط سرویس در همین اجراست؛ ناشناخته stale_confirmation است.

## Repository داخلی

```dart
List<StoredPost> readAll();
StoredPost? readById(int postId);
void replacePublished(int postId, int expectedRevision);
```

قرارداد PostRepository: خواندن همگام و snapshot immutable؛ readAll به‌تنهایی اعمال مجوز
نمی‌کند و فقط در اختیار BlogService است. replacePublished فقط status را تغییر و revision
را یک واحد افزایش می‌دهد؛ پیش‌شرط‌ها وجود و revision برابر هستند و فقط سرویس آن‌ها را
پس از قواعد دامنه فراخوانی می‌کند. در این implementation حافظه‌ای نوشتن I/O و Future ندارد.
نقض پیش‌شرط خطای برنامه‌نویسی است، نه مسیر معمول کاربر؛ سرویس در مسیر معتبر به آن نمی‌رسد.
هیچ save/delete/update عمومی به Cubit یا ابزار آینده داده نمی‌شود.

## نشست و context تحت کنترل برنامه

```dart
List<AppUser> get availableUsers;
AppUser? get currentUser;
BlogResult<AppUser> selectUser(String userId);
void invalidatePendingContext();
```

انتخاب فقط از فهرست ثابت است؛ unknown user برابر invalid_arguments و انتخاب‌نکردن برابر
permission_denied در عملیات است. selectUser روی تغییر واقعی کاربر epoch را زیاد می‌کند.
invalidatePendingContext هنگام انتخاب پست دیگر یا بستن جریان تأیید از مسیر برنامه فراخوانی
می‌شود؛ contextEpoch را زیاد می‌کند و تأییدهای اعمال‌نشده را غیرمعتبر می‌سازد. این متدها
ورودی مدل نیستند و تست بدون UI مستقیماً همان قرارداد trusted را فراخوانی می‌کند.

## BlogService

```dart
BlogResult<List<Post>> listVisiblePosts();
BlogResult<Post> getPost(int postId);
BlogResult<PendingPublish> preparePublish(int postId);
Future<BlogResult<PublishReceipt>> confirmPublish(String requestId);
BlogResult<void> cancelPublish(String requestId);
Future<BlogResult<PublishReceipt>> retryPublish(String requestId, int postId);
```

| متد | ورودی و موفقیت | رد و مسئولیت |
| --- | --- | --- |
| listVisiblePosts | هویت از session؛ فهرست مجاز | noUser → permission_denied؛ هیچ فهرست خامی به UI نمی‌رسد |
| getPost | postId مثبت؛ snapshot واقعی | invalid_arguments، permission_denied برای noUser، not_found، سپس permission_denied مالکیت |
| preparePublish | postId مثبت؛ PendingPublish برنامه‌ساخته | طبق تقدم تازه؛ ناموفق نه پست را تغییر می‌دهد نه تأیید ایجاد می‌کند |
| confirmPublish | requestId نمایش‌داده‌شده در جریان trusted؛ receipt پس از commit | مجهول/نامعتبر/لغوشده/قدیمی یا شروط جاری نامعتبر؛ فقط رویداد تأیید صریح UI آن را فراخوانی می‌کند |
| cancelPublish | همان درخواست و همان کاربر؛ لغو پیش از commit | پس از commit نمی‌تواند success را لغو کند؛ نتیجه cancelled جعلی برنمی‌گرداند |
| retryPublish | requestId قبلی و postId مورد انتظار؛ receipt ذخیره‌شده یا همان Future | تطبیق actor/post/operation؛ بدون confirm → confirmation_required؛ بدون رکورد → stale_confirmation |

در cancelPublish نتیجهٔ BlogSuccess<void> تنها به معنی ثبت لغو پیش از commit است؛ اگر
commit رخ داده باشد BlogFailure(already_published) برمی‌گردد و UI برای receipt از retryPublish
استفاده می‌کند. این خطا rollback نیست. cancel تکراری درخواست cancelled همان موفقیت لغو را
می‌دهد. confirm تکراری پس از success یا هنگام executing مانند Retry همان Future/receipt است.

در retryPublish، actor از session گرفته می‌شود، نه آرگومان. برای هویت معتبر متفاوت یا
postId متفاوت نسبت به رکورد request_conflict بدون payload قبلی برمی‌گردد؛ نبود کاربر یا
مجوز فعلی permission_denied است. fingerprint همیشه operation=publish دارد؛ adapter آینده
نباید requestId انتشار را برای عملیات دیگر مصرف کند. پس از تطبیق، receipt committed قبل
از بررسی status فعلی قابل بازیابی است. اجرای اعمال‌نشده پس از هر await باید شرایط جاری و
snapshot را دوباره بررسی کند؛ retry تأیید جدید ایجاد نمی‌کند.

### تقدم نهایی و snapshot

ورودی نامعتبر اول رد می‌شود. برای درخواست تازه یا اجرای هنوز اعمال‌نشده: مجوز Editor،
وجود پست، status، approved، سپس اعتبار تأیید/snapshot بررسی می‌شوند. اگر کاربر عوض شده یا
revision/context قدیمی باشد اما سایر قواعد برقرار باشند stale_confirmation است؛ اگر
مجوز یا status نامعتبر باشد همان خطای مقدم بازمی‌گردد. پس از رد قطعی، رکورد rejected است؛
Retry همان رد را بازمی‌گرداند، نه اینکه تأیید قدیمی را برای تغییر بعدی مصرف کند.

### نتیجه‌های دامنه و انتظار

| code | معنا |
| --- | --- |
| invalid_arguments | postId غیرمثبت، requestId خالی یا کاربر نمونهٔ نامعتبر |
| permission_denied | نبود هویت، مالکیت نامجاز خواندن یا نقش فاقد انتشار |
| not_found | پست وجود ندارد؛ برای انتشار فقط پس از احراز مجوز |
| already_published | انتشار تازه روی published؛ همچنین لغو پس از commit |
| invalid_status | archived قابل انتشار نیست |
| not_approved | draft با approved=false |
| confirmation_required | درخواست معتبر هنوز توسط کاربر تأیید نشده |
| stale_confirmation | requestId ناشناخته/اجرای قبل، epoch یا revision قدیمی |
| cancelled | Retry/confirm درخواست لغوشده پیش از commit |
| request_conflict | شناسهٔ درخواست با fingerprint متفاوت |
| success | BlogSuccess<PublishReceipt>؛ تغییر واقعی ثبت شده یا همان نتیجهٔ قبلی |
| timeout | فقط نتیجهٔ انتظار Cubit؛ در ledger نتیجهٔ نهایی دامنه نیست |

## BlogCubit و قرارداد UI

متدهای پیشنهادی: selectUser(userId)، selectPost(postId)، requestPublish()، confirm()، cancel()،
retry() و refresh(). Cubit هویت و داده را از سرویس می‌گیرد و مجوز را مستقلاً enforce نمی‌کند.
selectPost قبل از ادامه، context قبلی را invalidate می‌کند. state شامل کاربر، فهرست مجاز،
selectedPost، pending، activeRequestId، phase، failure و generation محلی است.

تأیید فقط دکمهٔ صریح در awaitingConfirmation است؛ «منتشر کن» در درخواست اولیه تأیید دوم
محسوب نمی‌شود. وضعیت publishing کلیک تکراری را محدود می‌کند، اما صحت متکی به این محدودیت
نیست. نمایش unknownOutcome شناسهٔ درخواست و Retry دارد. Cubit پاسخ قدیمی را با generation
و requestId رد می‌کند؛ ledger مستقل از عمر Cubit باقی می‌ماند.

## تأخیر و Timeout

PublishDelay دو نقطهٔ `beforeCommit()` و `afterCommitBeforeResponse()` با Future<void> دارد؛
حالت عادی هر دو فوری‌اند. دمو فقط یکی را ۳ ثانیه عقب می‌اندازد. commit میان این دو نقطه
همگام است. Cubit روی Future انتظار ۲ ثانیه‌ای می‌گذارد؛ BlogService Future اصلی را در ledger
نگه می‌دارد. اگر committed باشد Retry بی‌درنگ receipt را می‌گیرد، حتی اگر پاسخ تلاش اول هنوز
عقب افتاده باشد؛ اگر executing باشد به همان Future می‌پیوندد. هیچ تلاش دوم تغییر تازه‌ای نمی‌سازد.
لغو/تغییر context پیش از commit در بازبینی نهایی دیده می‌شود؛ پس از commit تغییر را برنمی‌گرداند.
تست به‌جای زمان واقعی gateهای Completer را باز و بسته می‌کند.

## اتصال آینده بدون ساخت قابلیت آینده

- Tool مستقیم get_post → اعتبارسنجی → getPost؛ publish_post → preparePublish یا پیگیری
  requestId موجود؛ confirmPublish در registry ابزار مدل قرار نمی‌گیرد.
- MCP get_post → همان قرارداد و همان مالک داده؛ نقش از session معتبر می‌آید. transport و
  process model اکنون تعریف یا پیاده‌سازی نمی‌شوند؛ Repository مستقل با seed تازه مجاز نیست.
- سیاست آینده از EditorialPolicySource با readPolicy() قابل دریافت و ارزیابی مصرف‌کنندهٔ
  آن خواهد بود. اکنون فایل، source اجرایی، ReviewService یا MCP Resource ساخته نمی‌شود.
- دادهٔ پست حاوی دستور تنها content است؛ مدل آینده حق دسترسی به Repository، session mutator
  یا confirmPublish ندارد. قرارداد Dart در process مرز اعتماد منطقی است، نه sandbox در برابر کد مخرب.
