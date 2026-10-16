# Implementation Plan: دستیار محلی انتشار محتوا — برش P1

**Branch**: `001-local-content-assistant` | **Date**: 2026-10-16 | **Spec**: [spec.md](spec.md)

**Input**: Specification کل تمرین، تصمیم‌های Clarify در تاریخ‌های 2026-10-15 و 2026-10-16،
Constitution 1.0.0 و تصمیم‌های فنی کاربر.

## Summary

یک برنامهٔ Flutter desktop با ساختار feature-based و یک BlogCubit ساخته خواهد شد؛ منطق
مشاهده و انتشار در BlogService خالص Dart و دسترسی داده در PostRepository حافظه‌ای است.
این Plan فقط طراحی مرحلهٔ P1 را تا مشاهده، انتشار، تأیید/لغو و Retry انجام می‌دهد؛
Specification کل تمرین کوچک نشده است. دستیار، Tool Calling مستقیم و MCP برش‌های آینده‌اند.
هیچ کد، پروژهٔ Flutter، تست اجرایی یا tasks.md در این مرحله ایجاد نمی‌شود.

## Technical Context

**Language/Version**: Dart 3.x همراه Flutter stable نصب‌شده؛ نسخهٔ واقعی در شروع پیاده‌سازی
ثبت و سازگاری dependencyها قفل می‌شود. SDK نصب‌شده روی PATH یافت شد؛ سلامت آن آزموده نشده است.

**Primary Dependencies**: Flutter SDK، bloc و flutter_bloc برای Cubit؛ test و flutter_test
برای آزمون. تزریق با سازنده؛ بدون generator، service locator، persistence یا SDK مدل/MCP.

**Storage**: یک InMemoryPostRepository با چهار پست Spec، کاربران ثابت، ledger و نشست در حافظه.

**Testing**: unit pure Dart برای دامنه/Repository، تست stream برای Cubit، Widget test برای
انتخاب کاربر و تأیید؛ تأخیر با Completer در تست کنترل می‌شود.

**Target Platform**: Windows desktop روی کامپیوتر کاربر؛ نیازمند toolchain Windows Flutter.

**Project Type**: یک برنامهٔ desktop محلی؛ بدون HTTP، OpenAPI، backend و هاست.

**Performance Goals**: برای چهار پست هیچ I/O شبکه‌ای در P1 وجود ندارد؛ CPU سنگین یا خواب
مسدودکننده روی UI ممنوع است. مهلت انتظار انتشار ۲ ثانیه و تأخیر اختیاری دمو ۳ ثانیه است؛
این اعداد تنظیم دمو هستند، نه SLA تازهٔ محصول.

**Constraints**: قوانین و تأیید در سرویس، snapshot تغییرناپذیر، commit همگام در یک isolate،
یک مالک برای Repository و ledger؛ timeout باعث پاک‌شدن درخواست نمی‌شود.

**Scale/Scope**: سه کاربر، چهار پست اولیه، یک کاربر انتخاب‌شده در هر لحظه و یک صفحهٔ اصلی.
درخواست‌های متوالی و هم‌زمان یک انتشار آزموده می‌شوند؛ چند process یا چند دستگاه در محدوده نیست.

## Constitution Check

Gate پیش از پژوهش و دوباره پس از طراحی بررسی شد؛ هر یازده اصل پاس هستند.

| اصل | شاهد طراحی پیش و پس از Phase 1 |
| --- | --- |
| ۱. Flutter/Dart محلی | یک desktop app؛ بدون وب یا دیتابیس؛ مدل آنلاین آینده منع نشده است |
| ۲. سادگی | یک feature، یک Cubit و Repository؛ بدون use-case layer و زیرساخت اضافی |
| ۳. منطق مشترک مستقل | BlogService بدون import Flutter/bloc/model؛ قرارداد مشترک آینده |
| ۴. نقش محدود مدل | در P1 مدل وجود ندارد؛ adapter آینده فقط prepare و خواندن دارد |
| ۵. قواعد در کد | ترتیب AC-38 و مجوز مشاهده در سرویس؛ UI مرجع تصمیم نیست |
| ۶. تأیید و Retry | تأیید متصل به snapshot و نشست؛ ledger و commit یکپارچهٔ همگام |
| ۷. اعتبارسنجی | شناسه‌ها و تطبیق درخواست در سرویس؛ مرز اعتبارسنجی خروجی آینده محفوظ |
| ۸. دادهٔ غیرقابل اعتماد | content فقط نمایش؛ هیچ اجرای دستور یا مسیر تأیید از متن ندارد |
| ۹. تست مقدم بر رفتار | ماتریس تست و red/green پیش از پیاده‌سازی در quickstart تعریف شده |
| ۱۰. تقدم Spec | Spec و سه تصمیم مبنا هستند؛ تغییر رفتار تازه نیازمند اصلاح Spec است |
| ۱۱. جداسازی دانش | P1 ارزیابی ندارد؛ قرارداد دریافت دانش آینده از ارزیابی جدا نگه داشته شده |

هیچ نقض یا استثنای حاکمیتی شناسایی نشد. بررسی این gate ادعای تکمیل تست اجرایی نیست.

## Project Structure

### Documentation (this feature)

```text
specs/001-local-content-assistant/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── dart-services.md
└── checklists/requirements.md
```

tasks.md در این فرمان ساخته نمی‌شود. Spec و چک‌لیست موجود در این Plan تغییر نمی‌کنند.

### Source Code (repository root)

ساختار زیر فقط طرح فایل‌های آینده است؛ اکنون هیچ‌یک ساخته نمی‌شوند.

```text
lib/
├── main.dart
├── app/
│   └── app.dart
└── features/
    └── blog/
        ├── domain/
        │   ├── post.dart
        │   ├── app_user.dart
        │   ├── blog_result.dart
        │   ├── publish_request.dart
        │   └── post_repository.dart
        ├── application/
        │   ├── current_user_session.dart
        │   ├── blog_service.dart
        │   └── publish_delay.dart
        ├── data/
        │   ├── in_memory_post_repository.dart
        │   └── sample_data.dart
        └── presentation/
            ├── cubit/blog_cubit.dart
            ├── cubit/blog_state.dart
            └── blog_page.dart
test/
├── unit/blog/
├── cubit/
└── widget/
windows/
pubspec.yaml
```

**Structure Decision**: یک feature کافی است؛ هر لایه تنها مسئولیت فعلی دارد. main/app
composition root است: یک Repository، نشست و BlogService برای طول اجرای برنامه می‌سازد
و به Cubit می‌دهد. Widgetها فقط state را رسم و رویداد صریح کاربر را ارسال می‌کنند.
Repository مسئول map داده و snapshot است؛ قواعد مجوز در آن تکرار نمی‌شوند. BlogService
تنها مصرف‌کنندهٔ مسیر نوشتن Repository است. domain/application/data وابستگی Flutter ندارند.
BlogCubit از package:bloc استفاده می‌کند؛ Flutter فقط در صفحه و app وارد می‌شود.

### جریان انتشار و حالت رابط

۱. انتخاب کاربر از فهرست ثابت؛ سرویس هویت معتبر و sessionEpoch را نگه می‌دارد. تغییر انتخاب
کاربر یا پست، context قبلی را بی‌اعتبار می‌کند و Cubit دادهٔ قبلی را از نمایش پاک می‌کند.
۲. getPost و listVisiblePosts از سرویس؛ Author فقط مالکیت خودش و Editor همه را می‌بیند.
۳. requestPublish در Cubit، preparePublish در سرویس: اعتبارسنجی ورودی و ترتیب مجوز، وجود،
status و approved؛ در شکست، بدون تغییر پست خطا نشان داده می‌شود.
۴. در موفقیت، PendingPublish با requestId و snapshot پست برمی‌گردد؛ state رابط awaitingConfirmation
است. پیام شناسه، عنوان و تغییر draft → published را با دکمه‌های «تأیید انتشار» و «لغو» نشان می‌دهد.
۵. فقط کلیک تأیید، confirmPublish را فراخوانی می‌کند. بازکردن پیام یا درخواست اولیهٔ انتشار
تأیید نیست. لغو پیش از اعمال، رکورد را cancelled می‌کند و هیچ پستی تغییر نمی‌کند.
۶. هنگام اجرا همهٔ شروط و اعتبار snapshot/session دوباره بررسی می‌شوند؛ commit بدون await:
خواندن جاری ← بررسی قواعد و تأیید ← جایگزینی status ← ثبت success در ledger.
۷. Cubit حداکثر ۲ ثانیه منتظر می‌ماند؛ timeout وضعیت unknownOutcome و دکمهٔ «پیگیری/Retry»
می‌سازد. Retry از همان requestId استفاده می‌کند؛ prepare تازه یا تأیید ساختگی نمی‌سازد.
۸. پاسخ با generation محلی Cubit و requestId تطبیق داده می‌شود؛ پاسخ قدیمی برای کاربر/پست
جدید نمایش داده نمی‌شود. success باعث refresh از سرویس می‌شود، نه تغییر حدسی state پست.

حالت‌های رابط: noUser، loading، viewing، awaitingConfirmation، publishing، unknownOutcome،
success، failure، cancelled. وضعیت رابط با وضعیت ledger متفاوت است؛ timeout terminal دامنه نیست.
در unknownOutcome نمی‌توان ادعا کرد «لغو شد»؛ ممکن است commit قبلاً انجام شده باشد. لغو تنها
تا پیش از commit اثر دارد؛ بعد از آن نتیجهٔ موفق موجود گزارش می‌شود و rollback نداریم.

### Timeout، داده و اشتراک آینده

تفصیل ledger، اثر تکراری و تأخیر در data-model و قراردادها آمده است. داده و ledger در scope
برنامه هستند؛ rebuild صفحه یا ایجاد مجدد Cubit آن‌ها را پاک نمی‌کند. پایان process/hot restart
اجرای تازه است؛ hot reload حفظ‌شدن state را تضمین محصول نمی‌کند. هیچ reset داخلی یا ذخیره‌سازی
پنهان لازم نیست؛ سناریوی دمو با اجرای مستقل شروع می‌شود.

adapter مستقیم آینده به getPost/preparePublish/retryPublish متصل می‌شود؛ اجازهٔ confirmPublish
از خروجی مدل ندارد. MCP آینده فقط خواندن را ارائه می‌کند و باید به همین instance یا مالک
واحد داده متصل شود، نه اینکه seed مستقل بسازد. روش حمل و اشتراک بین processها نیاز فعلی نیست
و اکنون انتخاب نمی‌شود. دریافت سیاست آینده یک قرارداد باریک مستقل از ارزیابی خواهد داشت؛
SDK مدل، Resource، Prompt نهایی و schema اجرایی در برش‌های آینده طراحی می‌شوند.

### محدودهٔ پوشش و تحویل بعدی

| محدودهٔ Spec | پوشش Plan حاضر |
| --- | --- |
| FR-001 تا FR-016، FR-033؛ AC-01 تا AC-16 و AC-38 | طراحی کامل P1 و راهنمای تست |
| ECهای مرتبط با مجوز، تأیید و Retry | ماتریس quickstart و قرارداد سرویس |
| FR-017 تا FR-031؛ D1 تا D3، D8 و D9 | فقط حفظ مرز اتصال؛ قابلیت‌ها و تست‌های یکپارچهٔ آینده ساخته نمی‌شوند |
| D4 تا D7 | در مسیر معمول اکنون قابل طراحی/آزمون؛ بخش مدل بعداً |
| FR-032، FR-034 و OUTها | تعهد کل تمرین محفوظ؛ این Plan تکمیل همهٔ خروجی‌ها را ادعا نمی‌کند |

## Complexity Tracking

نقض Constitution وجود ندارد؛ جدول استثنا لازم نیست. Repository، Cubit و ledger هر یک مستقیماً
نیاز مصوب دارند. قفل، event bus، چند package، persistence، HTTP و code generation اضافه نمی‌شوند.

پژوهش و منابع: [research.md](research.md). مدل داده: [data-model.md](data-model.md).
قرارداد متدها: [contracts/dart-services.md](contracts/dart-services.md).
راهنمای اجرا و اعتبارسنجی: [quickstart.md](quickstart.md).
