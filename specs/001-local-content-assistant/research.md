# پژوهش و تصمیم‌های فنی

تاریخ: 2026-10-16. مبنا: spec.md، سه پاسخ Clarify، Constitution 1.0.0 و تصمیم‌های کاربر.
این سند تصمیم طراحی است؛ پروژه، وابستگی یا کد ایجاد نمی‌کند.

## R1 — محدوده و SDK

- **Decision**: این Plan مرحلهٔ P1 (مشاهده و انتشار معمول، شامل Retry) را طراحی می‌کند؛
  P2/P3 در Specification کامل باقی می‌مانند اما اجرای آن‌ها یا انتخاب SDK مدل/MCP در این
  برش انجام نمی‌شود. Flutter desktop برای Windows و Dart همراه همان SDK استفاده می‌شوند.
- **Rationale**: هدف فعلی کامپیوتر کاربر است؛ سرویس وب و پایگاه داده لازم نیست.
- **Alternatives considered**: وب و API رد شدند؛ ساخت چند package مستقل فعلاً هزینهٔ غیرضروری است.
- **Verification**: flutter و dart روی PATH پیدا شدند؛ نسخه و سلامت toolchain اجرا نشده است.
  در آغاز پیاده‌سازی `flutter --version`، `dart --version` و `flutter doctor -v` ثبت و نسخهٔ
  سازگار وابستگی‌ها در pubspec.lock قفل شود؛ این کار تصمیم رفتاری باز نیست.

## R2 — Cubit و مرز دامنه

- **Decision**: یک BlogCubit با state تغییرناپذیر برای انتخاب کاربر، فهرست، جزئیات و جریان
  انتشار؛ package:bloc برای Cubit و flutter_bloc برای اتصال Widgetها. تزریق وابستگی با سازنده.
- **Rationale**: Cubit با فراخوانی متد و emit کار می‌کند و برای این جریان کوچک کافی است؛
  قواعد نقش و انتشار در BlogService خالص Dart می‌مانند.
- **Alternatives considered**: Bloc مبتنی بر event، چند Cubit و service locator فعلاً نیاز ندارند.
- **Source**: [Bloc Concepts](https://bloclibrary.dev/bloc-concepts/)،
  [Flutter Bloc Concepts](https://bloclibrary.dev/flutter-bloc-concepts/).

## R3 — Repository و دادهٔ حافظه‌ای

- **Decision**: یک PostRepository برای خواندن snapshotها و جایگزینی داخلی وضعیت و یک
  InMemoryPostRepository؛ مجموعهٔ کاربران ثابت و CurrentUserSession خالص Dart در scope برنامه.
- **Rationale**: Repository فقط دسترسی به داده است؛ مجوز و انتشار در BlogService هستند.
  دادهٔ mutable یا Repository به Widget و adapter آینده داده نمی‌شود.
- **Alternatives considered**: فایل، دیتابیس، cache پایدار و repository عمومی CRUD رد شدند.

## R4 — تأیید و اجرای نهایی

- **Decision**: preparePublish درخواست و snapshot برای نمایش می‌سازد؛ confirmPublish فقط
  از رویداد صریح رابط قابل فراخوانی است. برنامه نقش/هویت، پست، revision و epoch نشست را نگه
  می‌دارد و هنگام commit دوباره بررسی می‌کند. مدل هیچ پارامتر confirmed=true تعیین نمی‌کند.
- **Rationale**: approved خاصیت پست و confirmation مجوز اجرای همان درخواست‌اند.
- **Alternatives considered**: تأیید فقط در Prompt یا نگه‌داری آن صرفاً در Cubit ناقض Constitution است.

## R5 — یک اثر در یک اجرای برنامه

- **Decision**: BlogService یک ledger حافظه‌ای و یک Future جاری برای هر requestId نگه می‌دارد.
  شناسه از runNonce تولیدشده با Random.secure و شمارندهٔ افزایشی ساخته می‌شود؛ UUID package لازم نیست.
  ثبت Future در ledger پیش از هر await است. بررسی نهایی، تغییر وضعیت و ثبت success در یک
  بخش همگام در همان isolate انجام می‌شود؛ Repository حافظه‌ای در این بخش throw نمی‌کند.
- **Rationale**: چند Retry به همان Future می‌پیوندند؛ runNonce درخواست اجرای قبلی را معتبر نمی‌کند.
- **Alternatives considered**: صرف چک published، قفل دیتابیس، retry با شناسهٔ جدید و ledger
  مجزا در Cubit رد شدند. اگر در آینده نوشتن async شود، این تضمین باید با تراکنش یا صف بازطراحی شود.
- **Source**: [Dart concurrency](https://dart.dev/language/concurrency)؛ تضمین بخش همگام
  محدود به مالکیت داده در یک isolate است و تضمین چندپردازه‌ای نیست.

## R6 — Timeout و دمو

- **Decision**: مهلت انتظار رابط ۲ ثانیه، حالت عادی بدون تأخیر، تأخیر دمو ۳ ثانیه پیش از
  commit یا پیش از تحویل پاسخ. تأخیر از طریق یک seam کوچک در BlogService تزریق می‌شود؛ در
  تست با Completer کنترل می‌شود، نه خواب واقعی. timeout فقط state رابط است و ledger را پاک نمی‌کند.
- **Rationale**: Future.timeout عملیات اصلی را لغو نمی‌کند؛ نتیجه ممکن است پس از timeout برسد.
  Retry همان Future را دنبال می‌کند یا نتیجهٔ ذخیره‌شده را بازمی‌گرداند.
- **Alternatives considered**: تعبیر timeout به شکست قطعی یا rollback و retry خودکار با شناسهٔ
  جدید رد شدند. Retry در رابط به‌صورت اقدام صریح کاربر است؛ تلاش خودکار پنهانی نداریم.
- **Source**: [Future.timeout](https://api.dart.dev/dart-async/Future/timeout.html).

## R7 — تست و اجرای محلی

- **Decision**: package:test برای تست pure Dart، flutter_test برای Widget و تست Cubit با
  مشاهدهٔ stream؛ بدون mock framework، code generation یا bloc_test تا نیاز واقعی.
- **Rationale**: Repository حافظه‌ای و دادهٔ immutable، تست قواعد بدون مدل/UI را ممکن می‌کنند.
  تست ابتدا با شکست مورد انتظار، سپس پیاده‌سازی و تأیید موفقیت انجام می‌شود.
- **Alternatives considered**: وابستگی مدل واقعی در تست قواعد یا صرفاً Widget test کافی نیست.
- **Source**: [Flutter testing overview](https://docs.flutter.dev/testing/overview)،
  [Unit testing](https://docs.flutter.dev/cookbook/testing/unit/introduction)،
  [Windows setup](https://docs.flutter.dev/platform-integration/windows/setup).

## نتیجه

ابهام نیازمند تصمیم تازهٔ کاربر وجود ندارد. نسخهٔ دقیق SDK و resolution وابستگی‌ها در زمان
ساخت ثبت می‌شوند. روش ارتباط MCP و provider مدل عمداً خارج از برش جاری‌اند؛ هیچ قابلیت
آینده‌ای برای عبور از gate فعلی لازم نیست.
