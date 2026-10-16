# گزارش اعتبارسنجی — T001 تا T003

تاریخ: 2026-10-16. محدودهٔ این اجرا فقط آماده‌سازی پروژه است؛ تست رفتار دامنه هنوز انجام نشده است.

## T001 — بررسی محیط

- `flutter --version`: موفق؛ Flutter 3.47.2، stable، revision d3b14c8769.
- `dart --version`: موفق؛ Dart 3.13.2 stable روی windows_x64.
- `flutter doctor -v`: موفق؛ No issues found.
- Visual Studio Community 2026 18.2.1 و Windows SDK 10.0.26100.0 شناسایی شدند.
- `flutter devices`: دستگاه Windows desktop با شناسهٔ windows در دسترس است.
- نسخه‌ها شاهد محیط فعلی‌اند و تصمیم سراسری تثبیت نسخهٔ SDK نیستند.
- cache نصب SDK خارج از workspace است؛ اجرای اولیهٔ sandbox روی قفل cache پیش نرفت،
  سپس فرمان با دسترسی تأییدشده اجرا و نتایج بالا دریافت شد. این مشکل شکست تست رفتاری نیست.
- محیط از mirror ازپیش‌تنظیم‌شدهٔ pub.myket.ir استفاده می‌کند؛ تنظیم آن تغییر نکرد.
- چک‌لیست requirements.md: تعداد ۱۶، تأییدشده ۱۶، باز صفر؛ فایل چک‌لیست تغییر نکرد.
- T001 پیش‌نیاز تسکی خارج از بازه ندارد؛ T002 به T001 و T003 به T002 وابسته‌اند.

## T002 — اسکلت Windows

- `flutter create --empty --platforms=windows --project-name=local_content_assistant --no-pub .`: موفق.
- فقط runner ویندوز و entrypoint خالی تولید شدند؛ Android/iOS/Web/Linux/macOS ایجاد نشدند.
- ساختار feature-based و مسیرهای تست Plan با پوشه‌های خالی و .gitkeep آماده شدند؛ هیچ مدل،
  سرویس، Cubit یا قابلیت کسب‌وکار پیاده‌سازی نشده است.
- اسناد و AGENTS.md موجود حفظ شدند؛ .gitignore تولیدشده با الگوهای secrets/temp تکمیل شد.
- template خالی انتخاب شد؛ تست counter از ابتدا تولید نشد.

## T003 — وابستگی‌ها و بررسی نهایی Setup

- `flutter pub add bloc flutter_bloc`: موفق؛ bloc 9.2.1 و flutter_bloc 9.1.1.
- `flutter pub add --dev test`: موفق؛ test 1.31.1؛ flutter_test از SDK و lint تولیدشده حفظ شدند.
- `pubspec.lock` نسخه‌های resolveشده را ثبت می‌کند؛ وابستگی‌های transitive ابزار تست، API وب
  یا backend برنامه محسوب نمی‌شوند. پکیج مستقیمی خارج از Plan اضافه نشده است.
- SDK constraint تولیدشدهٔ `^3.13.2` در pubspec بر پایهٔ SDK مشاهده‌شده است؛ Baseline تغییر نکرد.
- `flutter analyze --no-pub`: موفق، No issues found.
- `flutter build windows --debug --no-pub`: موفق؛ خروجی در
  `build/windows/x64/runner/Debug/local_content_assistant.exe` ساخته شد.
- الگوهای ignore برای build، .dart_tool، .idea و .env با git check-ignore بررسی و تأیید شدند.
- تست counter تولید نشد و هیچ فایل *_test.dart وجود ندارد؛ تست رفتاری و red/green اجرا نشده‌اند.
  این بازه فقط Setup است؛ تست قواعد و مدل‌ها از T004 آغاز می‌شود. build و analyze جای آن‌ها نیستند.
- برنامهٔ گرافیکی اجرا نشده؛ فقط ساخت نسخهٔ debug بررسی شده است.
- T001 تا T003 پس از بررسی انجام‌شده علامت خوردند؛ T004 تا T044 باز باقی ماندند. Commit انجام نشد.

## فایل‌های ایجادشده یا تغییرکرده در این بازه

- `.gitignore`، `.metadata`، `README.md`، `analysis_options.yaml`، `pubspec.yaml`، `pubspec.lock`.
- `lib/main.dart`؛ .gitkeep در `lib/app/` و شاخه‌های domain/application/data/presentation/cubit
  زیر `lib/features/blog/` و `test/unit/blog/`، `test/cubit/`، `test/widget/`.
- `windows/.gitignore`، `windows/CMakeLists.txt`؛ CMakeLists و generated_plugin_registrant.cc/.h
  و generated_plugins.cmake در `windows/flutter/`؛ فایل‌های runner در `windows/runner/` شامل
  CMakeLists.txt، main.cpp، flutter_window.cpp/.h، win32_window.cpp/.h، utils.cpp/.h، Runner.rc،
  resource.h، runner.exe.manifest و resources/app_icon.ico.
- `specs/001-local-content-assistant/tasks.md` فقط نشانگر T001 تا T003؛ همین `validation.md`.
- cacheهای `.dart_tool/`، خروجی `build/` و فایل‌های IDE تولید شدند و در Git نادیده گرفته می‌شوند.
  AGENTS.md، Constitution، Baseline و اسناد طراحی تغییر داده نشدند.

## T004 تا T009 — Foundation (2026-10-16)

- بازهٔ معکوس نوشته‌شدهٔ کاربر به‌صورت T004 تا T009، با ترتیب وابستگی صعودی اجرا می‌شود.
- پیش‌نیاز بیرون بازه: T003 انجام شده است؛ چک‌لیست ۱۶/۱۶ قبول و بدون تغییر است.
- T004: models_test.dart با ۱۰ تست pure Dart نوشته شد؛ ابتدا تنها شکل داده/امضاهای مدل
  برای compile فراهم شد و اعتبارسنجی شناسه هنوز وجود نداشت.
- `dart test test/unit/blog/models_test.dart --reporter expanded` در مرحلهٔ red:
  ۷ موفق و ۳ شکست assertion مورد انتظار (AppUser خالی و Post با id صفر و منفی).
  تست‌ها compile شدند؛ شکست ناشی از برنگرداندن ArgumentError برای شناسهٔ نامعتبر بود.
- اجرای اولیهٔ محدود قبل از تست با منع دسترسی به تنظیم telemetry ابزار متوقف شد؛ آن نتیجه
  red محسوب نشد. اجرای با دسترسی تأییدشده به پروفایل کاربر، شکست‌های رفتاری بالا را نشان داد.
- یکتایی id مجموعه، عضویت authorId و افزایش revision هنگام write مربوط به Repository
  اجرایی و T010/T011 هستند؛ این بازه فقط immutable snapshot و نگهداری revision را می‌سازد.
- T005: اعتبارسنجی شناسهٔ خالی AppUser اضافه شد؛ سه تست AppUser موفق شدند.
- T006: Post مثبت و تمام فیلدها immutable؛ ۱۰/۱۰ تست مدل موفق. منطق افزایش revision در Repository هنوز خارج از محدوده است.
- T007: BlogResult به‌صورت sealed، BlogSuccess<T> و BlogFailure با code از enum پایدار
  و message امنِ قراردادی تعریف شد؛ payload پست در Failure وجود ندارد. timeout کد نتیجهٔ
  نهایی دامنه نیست و success با نوع نتیجهٔ موفق مشخص می‌شود.
- T008: PostRepository فقط قرارداد همگام readAll/readById/replacePublished است؛ snapshot
  immutable و افزایش revision در توضیح قرارداد الزام شده‌اند؛ پیاده‌سازی و CRUD اضافه نشده‌اند.
- T009: CurrentUserSession و BlogService به‌صورت abstract با constructor injection و متدهای
  قرارداد آماده شدند؛ بدنهٔ قواعد و ذخیرهٔ وضعیت وجود ندارد. در publish_request.dart تنها
  دو اعلان نوع PendingPublish و PublishReceipt برای امضاهاست؛ هیچ فیلد/رفتار T020 ساخته نشد.
- `dart format lib/features/blog/domain lib/features/blog/application test/unit/blog/models_test.dart`:
  موفق؛ سپس `dart analyze` روی همان مسیرها بدون مشکل بود.
- اجرای نهایی `dart test test/unit/blog/models_test.dart --reporter expanded`: هر ۱۰ تست موفق.
- `flutter analyze --no-pub`: موفق، No issues found.
- مرز import در domain/application بررسی شد؛ Flutter، bloc، SDK مدل یا اتصال شبکه وجود ندارد.
- تست Widget و build جدید اجرا نشدند؛ UI و runner در این بازه تغییر نکرده‌اند.
- T004 تا T009 تکمیل شدند؛ T010 تا T044 باز باقی ماندند؛ هیچ Commit انجام نشد.

### فایل‌های همین بازه

- test/unit/blog/models_test.dart
- lib/features/blog/domain/app_user.dart
- lib/features/blog/domain/post.dart
- lib/features/blog/domain/blog_result.dart
- lib/features/blog/domain/post_repository.dart
- lib/features/blog/domain/publish_request.dart (فقط اعلان نوع مورد نیاز قرارداد T009)
- lib/features/blog/application/current_user_session.dart
- lib/features/blog/application/blog_service.dart
- specs/001-local-content-assistant/tasks.md (فقط وضعیت T004 تا T009)
- specs/001-local-content-assistant/validation.md (افزودن شواهد این بازه)

Constitution، Baseline، Spec، Plan، قراردادهای مستند، چک‌لیست، وابستگی‌ها و UI تغییر نکردند.

## T010 تا T018 — مشاهدهٔ مستقل (2026-10-16)

- بازهٔ کاربر به ترتیب وابستگی T010 تا T018 اجرا می‌شود؛ T009 تکمیل و چک‌لیست ۱۶/۱۶ قبول است.
- T010 red: هر ۵ تست Repository/seed با stub قابل compile شکست رفتاری خوردند؛ دادهٔ خالی،
  عدم رد شناسهٔ تکراری، نبود snapshot و عدم write صحیح مشاهده شدند.
- T011 green: هر ۵ تست موفق؛ seed کامل سه کاربر و چهار پست، جملهٔ Injection در 102،
  جداسازی scopeها، snapshot immutable و افزایش revision فقط هنگام write بررسی شدند.
- T012 red: ۷ تست مشاهده شکست خوردند؛ موارد assertion شامل نبود هویت، فهرست خالی، epoch،
  شناسهٔ نامعتبر بودند؛ دو مورد نوع نتیجهٔ اشتباه نیز آشکار شد. خطای compile وجود نداشت.
- T013 green: تمام ۲۲ تست unit (۱۰ مدل + ۵ Repository + ۷ مشاهده) موفق شدند.
- هویت انتخابی دمو است؛ عضویت کاربر و نقش معتبر از session و مجوز مشاهده فقط از BlogService است.
- T014 red: هر چهار تست Cubit به‌علت نبود کاربران، تغییر state و انتخاب/خطا شکست assertion خوردند.
- T015 red: هر سه تست Widget به‌علت نبود انتخابگر و پیام اولیه شکست خوردند؛ تست‌ها compile شدند.
- T016 green: چهار تست Cubit موفق؛ state immutable و خطا با code و پاک‌شدن جزئیات قبلی بررسی شد.
- T017 green: سه تست اولیهٔ Widget موفق؛ صفحهٔ فارسی و scope برنامه متصل شدند. دو تست رگرسیون
  دیگر برای خطای قابل نمایش و rebuild ریشه اضافه شدند؛ هر پنج تست Widget موفق شدند.
- composition root یک Repository/session/BlogService می‌سازد؛ Cubit فقط از سرویس می‌خواند.
- انتشار در BlogService همچنان stub تسک‌های آینده است و در UI راه اجرای آن وجود ندارد.
- رگرسیون نهایی pure Dart: ۲۶ تست موفق (۲۲ unit و ۴ Cubit)، بدون Flutter UI یا مدل واقعی.
- تحلیل اولیه پنج lint سبک کد داشت؛ اصلاح شد و رگرسیون pure Dart دوباره موفق بود.
- T018: اجرای نهایی `dart test test/unit/blog test/cubit` برابر ۲۶/۲۶ موفق؛
  `flutter test test/widget --reporter expanded` برابر ۵/۵ موفق؛ مجموع ۳۱ تست.
- `flutter analyze --no-pub`: No issues found. `git diff --check` بدون خطای whitespace.
- `flutter run -d windows --no-resident --no-pub`: موفق؛ build ویندوز ساخته و فایل‌ها به
  دستگاه Windows sync شدند. برنامه راه‌اندازی شد؛ بررسی دستی تعاملی پنجره ادعا نمی‌شود.
- دموی مشاهدهٔ مستقل و خودکار در Widgetها با انتخاب Author/Editor، جزئیات و تعویض کاربر
  اجرا شد. مسیرهای مستقیم خطا در سرویس و Cubit پوشش دارند؛ هیچ مدل یا شبکهٔ خارجی لازم نبود.

### ردیابی پذیرش T018

| معیار | شاهد |
| --- | --- |
| AC-01 | no identity/invalid identity در سرویس؛ انتخاب کاربر و نبود TextField ورود در Widget |
| AC-02 | author only lists and reads own و نمایش فهرست 101/103 و جزئیات در Widget |
| AC-03 | editor sees all four posts و دسترسی author-b به archived؛ تمام فیلدها بررسی شدند |
| AC-04 | getPost(999) برابر not_found؛ Cubit typed error و پیام پست یافت نشد |
| AC-05 | getPost(102/104) برای author-a برابر permission_denied و بدون payload؛ جزئیات قبلی پس از خطا/تعویض کاربر پاک شدند |

### فایل‌های همین بازه

ایجادشده:
- lib/features/blog/data/sample_data.dart
- lib/features/blog/data/in_memory_post_repository.dart
- lib/features/blog/presentation/cubit/blog_state.dart
- lib/features/blog/presentation/cubit/blog_cubit.dart
- lib/features/blog/presentation/blog_page.dart
- lib/app/app.dart
- test/unit/blog/in_memory_post_repository_test.dart
- test/unit/blog/blog_read_service_test.dart
- test/cubit/blog_read_cubit_test.dart
- test/widget/blog_read_page_test.dart

اصلاح‌شده:
- lib/features/blog/application/current_user_session.dart
- lib/features/blog/application/blog_service.dart
- lib/main.dart
- specs/001-local-content-assistant/tasks.md (فقط وضعیت T010 تا T018)
- specs/001-local-content-assistant/validation.md (شواهد این بازه)

T010 تا T018 تکمیل و علامت‌گذاری شدند؛ T019 تا T044 باز ماندند. هیچ Task خارج از بازه اجرا
نشد و Commit انجام نشد. Constitution، Baseline، Spec، Plan، قراردادهای مستند و چک‌لیست
تغییر نکردند؛ وابستگی جدید اضافه نشد. build و cache تولیدشده در Git نادیده گرفته می‌شوند.

## T019 تا T030 — انتشار معمول (2026-10-16)

- T018 تکمیل است؛ چک‌لیست ۱۶/۱۶ قبول و پیش‌نیاز انجام‌نشدهٔ خارج از بازه وجود ندارد.
- T019 red: دو تست مدل موفق و یک شکست assertion برای requestId خالی؛ پس از اعتبارسنجی
  T020 هر سه تست موفق شدند. PendingPublish تأیید اجرا ایجاد نمی‌کند؛ ledger سرویس داخلی است.
- T021 red: چهار تست prepare با stub شکست خوردند؛ برای شواهد assertion، stub قابل اجرا
  به‌جای UnimplementedError استفاده شد و سه عدم تطبیق code و یک نوع نتیجهٔ اشتباه مشاهده شد.
- T022 green: هر چهار تست prepare موفق؛ ترتیب invalid input → permission → وجود → status
  → approved رعایت شد، requestId با nonce اجرای برنامه و شمارنده صادر و snapshot ثبت شد.
- در این مرحله انتشار و approved با prepare تغییر نمی‌کنند؛ Retry/Timeout هنوز اجرا نشده‌اند.
- T023 red: یک تست prepare بدون اثر موفق و چهار تست تأیید/لغو با assertion شکست خوردند.
- T024 green: هر پنج تست موفق؛ فقط status/revision تغییر می‌کند، لغو قبل از اعمال اثر صفر
  و لغو پس از success خطای already_published بدون rollback دارد؛ نتیجه در ledger باقی می‌ماند.
- T025 red: شش رگرسیون قواعد جاری موفق و چهار تست snapshot قدیمی شکست خوردند؛ دو assertion
  مربوط به epoch/context و دو خطای precondition ناشی از revision تغییرکرده مشاهده شد.
- T026: مقایسهٔ epoch/context/revision به اجرای نهایی اضافه شد؛ قواعد دامنه قبل از خطای
  snapshot بررسی می‌شوند. تغییر شرایط فقط با fixture آزمایشی است؛ قابلیت ویرایش UI اضافه نشد.
- T026 green: همهٔ ۴۴ تست unit موفق، از جمله هر ۱۰ سناریوی بازبینی شرایط نهایی.
- T027 red: سه شکست assertion و دو تست رگرسیون موفق در Cubit؛ T028 red: چهار شکست به علت
  نبود اقدام انتشار/دیالوگ. همه compile شدند و سپس رفتار مربوط پیاده شد.
- T029 green: پنج تست Cubit و چهار تست Widget اولیه موفق شدند؛ request فقط pending است و
  دیالوگ نقش تأیید اجرا را جدا از approved توضیح می‌دهد؛ بستن/لغو عملیات را اجرا نمی‌کند.
- محافظ پاسخ دیررس Cubit برای تعویض context وجود دارد؛ Retry و timeout همچنان خارج از بازه‌اند.
- T030: رگرسیون نهایی پس از اصلاح lint، ۵۳ تست pure Dart (۴۴ unit و ۹ Cubit) و ۱۰ تست
  Widget موفق؛ مجموع ۶۳ تست. `flutter analyze --no-pub`: No issues found.
- `git diff --check` بدون خطای whitespace. بدون تست وابسته به مدل واقعی یا سرویس بیرونی.
- یک رگرسیون رابط برای تعویض کاربر با دیالوگ باز اضافه شد؛ دیالوگ بسته و تعداد write صفر است.
- این بازه تست Widget/سرویس و سناریوی خودکار است؛ build و تست دستی تازهٔ Windows انجام نشد.

### ماتریس پذیرش T030 — دادهٔ مستقل برای هر تست

| معیار/سناریو | ورودی و نتیجه | تعداد write |
| --- | --- | --- |
| AC-06 | editor-e و 101 تأییدشده؛ prepare فقط pending و دیالوگ با شناسه/عنوان و draft → published | ۰ |
| AC-07 / D6 مسیر معمول | تأیید صریح؛ success و published؛ سایر فیلدها ثابت، revision یک واحد بیشتر | ۱ |
| AC-08 / D4 مسیر معمول | author-a انتشار 101 یا 999؛ permission_denied پیش از وجود پست | ۰ |
| AC-09 / D5 مسیر معمول | Editor و 102؛ not_approved؛ 999 not_found، 103 already_published، 104 invalid_status | ۰ |
| AC-10 | لغو صریح یا بستن دیالوگ، تعویض کاربر یا انتخاب پست تازه؛ تأیید قبلی قابل اجرا نیست | ۰ |
| AC-11 | role، status، approved یا وجود پست پس از prepare تغییر کرده؛ کنترل جاری درخواست را رد می‌کند | ۰ |
| AC-38 | published/archived با approved=false؛ خطای status پیش از approval؛ ترتیب ورودی/مجوز/وجود رعایت شد | ۰ |
| تأیید قدیمی | تغییر epoch/context یا revision/title/content با برقرارماندن قواعد دامنه؛ stale_confirmation | ۰ |
| لغو پس از اعمال | already_published، بدون rollback یا write دوم | همان ۱ |
| رگرسیون US1 | همهٔ unit/Cubit/Widgetهای مشاهدهٔ قبلی همچنان موفق | بدون write از مسیر مشاهده |

### فایل‌های همین بازه

ایجادشده:
- test/unit/blog/publish_request_test.dart
- test/unit/blog/blog_publish_prepare_test.dart
- test/unit/blog/blog_publish_confirmation_test.dart
- test/unit/blog/blog_publish_revalidation_test.dart
- test/support/publish_fixture.dart (فقط تغییر کنترل‌شدهٔ شرایط برای تست)
- test/cubit/blog_publish_cubit_test.dart
- test/widget/blog_publish_page_test.dart

اصلاح‌شده:
- lib/features/blog/domain/publish_request.dart
- lib/features/blog/application/blog_service.dart
- lib/features/blog/presentation/cubit/blog_state.dart
- lib/features/blog/presentation/cubit/blog_cubit.dart
- lib/features/blog/presentation/blog_page.dart
- specs/001-local-content-assistant/tasks.md (فقط وضعیت T019 تا T030)
- specs/001-local-content-assistant/validation.md (افزودن شواهد این بازه)

T019 تا T030 تکمیل شدند. T031 تا T044 باز هستند؛ retryPublish هنوز stub است، Timeout،
adapter مدل و MCP پیاده نشده‌اند. CurrentUserSession از رفتار epoch موجود استفاده می‌کند؛
نیازی به تغییر آن در T026 نبود. Constitution، Baseline، Spec، Plan، قراردادهای مستند،
چک‌لیست و وابستگی‌ها تغییر نکردند. Commit انجام نشد.
