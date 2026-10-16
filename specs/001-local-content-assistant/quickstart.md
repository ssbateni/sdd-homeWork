# راهنمای اجرای آینده و اعتبارسنجی P1

این راهنما پس از ساخت پروژه و پیاده‌سازی قابل اجراست. اکنون فقط اسناد Plan تولید شده‌اند؛
هیچ‌یک از فرمان‌های ساخت، دریافت وابستگی، تست یا اجرای Flutter در این مرحله اجرا نشده است.

## پیش‌نیاز

- Flutter stable همراه Dart روی PATH؛ ابزارهای آن در محیط فعلی پیدا شدند ولی نسخه و سلامت
  toolchain تأیید نشده است. نسخهٔ واقعی در آغاز پیاده‌سازی ثبت و dependencyها قفل شوند.
- Windows desktop و Visual Studio با Desktop development with C++ مطابق
  [راهنمای رسمی](https://docs.flutter.dev/platform-integration/windows/setup).
- اینترنت تنها برای تهیهٔ SDK/وابستگی‌ها در صورت نیاز؛ P1 پس از آماده‌شدن محیط به مدل یا
  شبکه وابسته نیست. هیچ کلید مدل، حساب واقعی، backend یا database لازم نیست.

## آماده‌سازی در مرحلهٔ پیاده‌سازی، نه اکنون

فرمان‌ها از ریشهٔ مخزن در PowerShell اجرا می‌شوند. ساخت Windows runner و pubspec در ریشه
تنها پس از درخواست پیاده‌سازی و با حفظ docs/.specify/specs انجام شود.

```powershell
Set-Location 'D:\sdd-homeWork'
flutter --version
dart --version
flutter doctor -v
flutter devices
```

انتظار: Windows در فهرست دستگاه‌ها و toolchain قابل استفاده باشد؛ در غیر این صورت محیط
باید آماده شود و تست‌نشدن برنامه صریح گزارش شود. این Plan نصب یا تغییر SDK انجام نمی‌دهد.

پس از ایجاد پروژهٔ برنامه و dependencyهای ذکرشده در plan.md:

```powershell
flutter pub get
flutter analyze
dart test test/unit/blog
dart test test/cubit
flutter test test/widget
flutter run -d windows
```

واحدهای domain/application/data و Cubit فقط Dart/package:bloc وارد می‌کنند، بنابراین
تست‌های unit و Cubit با dart test و package:test اجرا می‌شوند؛ تست Widget با flutter test.
اگر test/cubit ناخواسته import Flutter داشته باشد باید مرز import اصلاح شود، نه اینکه
منطق دامنه برای اجرا به UI وابسته شود. pubspec.lock در مرحلهٔ پیاده‌سازی ثبت نسخه‌ها را دارد.

## روش توسعه و شواهد

برای هر رفتار مهم زیر: ابتدا تست مشخص، سپس اجرای آن و ثبت شکست ناشی از نبود همان رفتار؛
پس از پیاده‌سازی همان تست موفق شود. خطای نصب/compile جای شکست رفتاری مورد انتظار نیست.
در این Plan تست تولید یا اجرا نشده است. دادهٔ test fixture مستقل و زمان با Completer است؛
sleep چندثانیه‌ای، API مدل واقعی و mock framework لازم نیستند.

## ماتریس تست pure Dart

| گروه | موارد و انتظار | ردیابی |
| --- | --- | --- |
| داده | چهار پست و سه کاربر Spec؛ status محدود؛ snapshot غیرقابل تغییر؛ seed مستقل | FR-003، FR-004 |
| انتخاب و فهرست | بدون کاربر permission_denied؛ Author فقط دو پست خودش؛ Editor هر چهار؛ unknown user invalid_arguments | AC-01 تا AC-03 |
| مشاهده | پست خود و پست archived مجاز؛ پست دیگری permission_denied بدون payload؛ 999 not_found؛ id صفر/منفی invalid_arguments | AC-02 تا AC-05، EC-01 |
| تقدم انتشار | Author با id=999 → permission_denied؛ Editor با 999 → not_found؛ published/archived حتی با approved=false خطای status؛ draft false → not_approved | AC-08، AC-09، AC-38 |
| prepare | برای draft approved نزد Editor pending و بدون تغییر؛ تأیید نمایش‌داده‌شده approved را تغییر نمی‌دهد | AC-06، FR-008 |
| تأیید | بدون confirm هیچ تغییر؛ confirm صریح یک status تغییر می‌دهد؛ سایر فیلدها ثابت | AC-06، AC-07 |
| لغو | قبل از commit اثر صفر؛ confirm/retry پس از لغو cancelled؛ پس از commit لغو rollback نمی‌کند | AC-10، EC-07 |
| اعتبار نهایی | تغییر role/user حتی رفت‌وبرگشت؛ تغییر context؛ revision/content/status/approved بین prepare/confirm/commit با fixture | AC-10، AC-11، EC-05 |
| تأیید قدیمی | همهٔ شروط دامنه برقرار ولی snapshot/epoch متفاوت → stale_confirmation؛ شرط دامنه نامعتبر → خطای مقدم | FR-012، FR-013 |
| تکرار | double confirm، Retry متوالی و دو Future هم‌زمان با همان id؛ شمار write موفق دقیقاً یک | AC-13، AC-14، EC-04 |
| تعارض | همان id با post متفاوت و هویت Editor متفاوت در fixture → request_conflict بدون افشای receipt؛ noUser فاقد دسترسی | AC-15، FR-014 |
| نتیجهٔ قبلی | پس از success Retry همان id → receipt قبلی؛ prepare تازه برای همان published → already_published | AC-13، EC-03 |
| Timeout پیش از اعمال | gate beforeCommit بسته؛ انتظار timeout و state پست draft؛ Retry به همان Future متصل؛ پس از بازکردن gate فقط یک write | AC-12، AC-14، D7 |
| Timeout پس از اعمال | gate afterCommit بسته؛ status published و ledger committed ولی پاسخ نخست timeout؛ Retry receipt قبلی می‌دهد؛ write دوم صفر | AC-12، AC-13، D7 |
| لغو در تأخیر | پیش از commit لغو/تعویض کاربر، سپس بازشدن gate؛ هیچ انتشار پنهانی رخ ندهد | EC-05، EC-07 |
| Retry خواندن | بازخوانی، وضعیت مجاز جاری را می‌دهد و هیچ write ندارد | AC-16 |
| اجرای دوباره | ساخت scope تازه: seed اولیه، ledger خالی، id اجرای قبل stale_confirmation؛ scope قبلی قابل ادامه نیست | EC-10، SC-004 |
| استقلال UI | همان قواعد از Dart test بدون Widget و مدل اجرا شوند؛ fake Repository فقط برای تغییر شرط تست | FR-033 |

## تست Cubit و Widget

| تست | انتظار |
| --- | --- |
| state بدون انتخاب کاربر | پیام انتخاب کاربر؛ بدون محتوای پست |
| انتخاب Author و Editor | فهرست مجاز از سرویس؛ دادهٔ کاربر قبلی پاک شود |
| درخواست انتشار معتبر | awaitingConfirmation با شناسه و عنوان و دو اقدام صریح؛ قبل از کلیک تأیید وضعیت draft |
| لغو دیالوگ | cancelled/بازگشت به مشاهده؛ هیچ write |
| confirm و دوبار کلیک | publishing و سپس success؛ تعداد write یک، مستقل از disable بودن دکمه |
| خطای دامنه | پیام متناظر code، بدون payload غیرمجاز |
| timeout | unknownOutcome با requestId قبلی و Retry؛ نه «قطعاً انجام نشد» |
| پاسخ دیررس | generation/requestId تطبیق داده شود؛ موفقیت کاربر قبلی در صفحهٔ تازه نمایش داده نشود |
| rebuild یا Cubit تازه | همان Repository/BlogService و داده و ledger محفوظ؛ process تازه reset می‌کند |

## دموی دستی P1

هر ردیف مستقل است؛ برای بازگشت به seed برنامه را کامل ببندید و دوباره اجرا کنید.

۱. author-a را انتخاب کنید: فقط 101 و 103 دیده شوند؛ مشاهدهٔ 102 با دسترسی مستقیم تست
permission_denied و 999 برابر not_found باشد. رابط لازم نیست امکان واردکردن هر شناسه را
برای دمو اضافه کند؛ این مرزها در unit test پوشش داده می‌شوند.
۲. author-a انتشار 101 را درخواست کند: permission_denied و draft ثابت (D4).
۳. editor-e انتشار 102 را بخواهد: not_approved و بدون درخواست تأیید (D5).
۴. editor-e انتشار 101 را بخواهد: قبل از تأیید draft؛ لغو کنید و draft باقی بماند. دوباره
درخواست بدهید و تأیید کنید: published و success؛ approved/سایر فیلدها ثابت (D6).
۵. در اجرای مستقل، حالت دمو beforeCommit با تأخیر ۳ ثانیه و مهلت انتظار ۲ ثانیه را انتخاب
کنید؛ یک انتشار تأییدشده timeout شود. Retry همان requestId و تعداد اثر یک باشد (D7).
۶. همان آزمایش را با afterCommitBeforeResponse انجام دهید؛ پس از timeout بازخوانی published
را نشان دهد و Retry success قبلی را بدون اثر تازه بازگرداند. تأخیر فقط در کنترل دموی debug
است؛ حالت عادی بدون تأخیر. کنترل debug فقط delay seam را عوض می‌کند، نه مجوز و approved.
۷. برنامه را ببندید و باز کنید: 101 دوباره draft است؛ سابقه و تأییدهای اجرای قبل وجود ندارند.

## مرز تحویل

P1 باید بدون مدل و MCP اجرا شود. D1 تا D3، D8 و D9 و بررسی تحریریه/Resource به برش‌های
آینده متعلق‌اند و در این تحویل «موفق اجراشده» گزارش نمی‌شوند. تمام ۹ سناریو در Spec محفوظ‌اند.
تغییر requirements ابتدا در spec.md ثبت می‌شود؛ طراحی transport MCP یا provider مدل در این
Plan لازم نیست. قراردادهای جزئی در [dart-services.md](contracts/dart-services.md) و مدل‌های
داده در [data-model.md](data-model.md) مرجع آزمون‌اند.
