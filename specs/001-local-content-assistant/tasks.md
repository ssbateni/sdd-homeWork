<div dir="rtl" align="right">
---

description: "تسک‌های اجرایی P1 برای مشاهده و انتشار محلی پست‌ها"
---

# Tasks: دستیار محلی انتشار محتوا — برش P1

**Input**: اسناد قابلیت فعال در `specs/001-local-content-assistant/`، کشف‌شده از خروجی setup-tasks.
**Prerequisites**: [plan.md](plan.md)، [spec.md](spec.md)، [research.md](research.md)،
[data-model.md](data-model.md)، [قرارداد Dart](contracts/dart-services.md)، [quickstart.md](quickstart.md)،
[Constitution](../../.specify/memory/constitution.md) و [Technical Baseline](../../docs/architecture/technical-baseline.md).
**Created**: 2026-10-16

**Tests**: مطابق FR-033 و Constitution الزامی‌اند؛ قواعد با package:test، Widgetها با flutter_test.
**Organization**: فقط US1، US2 و US3 (هر سه Priority: P1) در Plan فعلی طراحی اجرایی دارند.
US4 تا US7 از Spec حذف نشده‌اند؛ مراحل آیندهٔ آن‌ها پایین سند جداگانه مشخص شده و تسک
پیاده‌سازی بدون طراحی برای آن‌ها ساخته نشده است. اجرای همهٔ checkboxها فقط پایان P1 است، نه کل تمرین.

## Format: `[ID] [P?] [Story] Description`

همهٔ تسک‌ها فعلاً باز هستند. [P] فقط اجرای موازی فایل‌های مستقل پس از وابستگی‌های ذکرشده
را مجاز می‌کند؛ دستوری برای اجرای خودکار agent نیست. برچسب US به Story اصلی Spec اشاره دارد.
هر تغییر رفتار مهم ابتدا تست و شکست assertion مورد انتظار و سپس پیاده‌سازی و موفقیت همان
تست را دارد. می‌توان برای compile، امضای قرارداد و stub حداقلی ساخت؛ خطای import/compile
یا نصب، شاهد red رفتاری نیست. تست رگرسیون رفتار موجود ممکن است از ابتدا سبز باشد و نباید
برای ساخت شکست مصنوعی رفتار درست را خراب کرد. شواهد red/green در `specs/001-local-content-assistant/validation.md`
در مرحلهٔ پیاده‌سازی ثبت می‌شوند؛ این فایل اکنون ایجاد نمی‌شود. هیچ Commit خودکار مجاز نیست.

## Path Conventions

تمام مسیرهای کد و تست نسبت به ریشهٔ مخزن هستند؛ یک پروژهٔ Flutter Windows در ریشه طبق
Plan، بدون backend یا HTTP. `lib/features/blog/` مرز feature است. تغییر Constitution، Baseline
یا Spec در تسک پیاده‌سازی مجاز نیست؛ اگر نیازمندی تازه لازم شد ابتدا اصلاح Spec مطرح شود.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: آماده‌سازی پروژه بدون قابلیت دستیار، MCP یا ذخیره‌سازی پایدار.

- [X] T001 نسخهٔ واقعی Flutter/Dart، `flutter doctor -v` و دستگاه Windows را بررسی و نتیجه را در `specs/001-local-content-assistant/validation.md` ثبت کن؛ نسخه‌ای را حدس نزن و مشکل محیط را از شکست رفتاری تفکیک کن.
- [X] T002 پس از T001 پروژهٔ Flutter فقط برای Windows را در ریشه با `pubspec.yaml`، `lib/main.dart` و `windows/` ایجاد کن؛ `AGENTS.md`، `docs/`، `.specify/` و `specs/` را حفظ و ساختار feature-based در `lib/features/blog/` را طبق Plan آماده کن.
- [X] T003 پس از T002 وابستگی‌های bloc و flutter_bloc و dev dependencyهای test و flutter_test را سازگار با SDK در `pubspec.yaml` تنظیم و در `pubspec.lock` ثبت کن؛ قالب تست counter تولیدشده در `test/widget_test.dart` را کنار بگذار و تنظیم lint موجود در `analysis_options.yaml` را برای پروژه نگه دار؛ پکیج اضافی نصب نکن.

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: قراردادهای داده و خطای مشترک؛ هیچ رفتار Story قبل از این checkpoint پیاده نشود.

- [X] T004 پس از T003 تست قرارداد مدل‌ها را در `test/unit/blog/models_test.dart` بنویس: «id: String غیرخالی»، «id: int مثبت و یکتا»، enum نقش و وضعیت، snapshot immutable و «revision داخلی و افزایشی با هر تغییر»؛ برای رفتارهای جدید شکست assertion مورد انتظار را بررسی و در `specs/001-local-content-assistant/validation.md` ثبت کن؛ یکتایی مجموعه را در Repository نیز آزمون خواهیم کرد.
- [X] T005 پس از T004 مدل AppUser را در `lib/features/blog/domain/app_user.dart` با قیود عین مدل داده «id: String غیرخالی؛ role: UserRole.author/editor؛ از فهرست ثابت معتبر» ایجاد و تست‌های مربوط T004 را سبز کن؛ تأیید عضویت فهرست در session انجام می‌شود.
- [X] T006 پس از T005 مدل‌های immutable Post و StoredPost را در `lib/features/blog/domain/post.dart` با قیود «id: int مثبت و یکتا؛ title/content: String؛ status: PostStatus.draft/published/archived؛ approved: bool؛ authorId: شناسهٔ کاربر؛ createdAt: DateTime» و «Post و revision: int؛ revision داخلی و افزایشی با هر تغییر» تعریف و تست‌های مدل T004 را تکمیل کن؛ یکتایی و رابطهٔ author در مجموعهٔ seed بررسی شوند.
- [X] T007 پس از T006 BlogResult<T>، BlogSuccess<T> و BlogFailure را در `lib/features/blog/domain/blog_result.dart` مطابق قرارداد تعریف کن؛ «code از جدول قرارداد؛ پیام قابل نمایش بدون اطلاعات پست غیرمجاز» و تمام کدهای P1 پایدار باشند؛ UI نباید از متن پیام برای تشخیص استفاده کند.
- [X] T008 پس از T007 قرارداد همگام `readAll`، `readById` و `replacePublished(postId, expectedRevision)` را در `lib/features/blog/domain/post_repository.dart` تعریف کن؛ خروجی immutable و تغییر فقط status/revision باشد؛ هیچ CRUD عمومی در اختیار UI قرار نگیرد.
- [X] T009 پس از T008 امضاهای CurrentUserSession و BlogService را در `lib/features/blog/application/current_user_session.dart` و `lib/features/blog/application/blog_service.dart` مطابق قرارداد آماده کن؛ constructor injection و مرز import مستقل از Flutter/model حفظ شود؛ تا تست هر Story رفتار آن را اجرا نکن.

**Checkpoint**: مدل و قرارداد آمادهٔ تست هستند؛ Stub به‌تنهایی رفتار تکمیل‌شده محسوب نمی‌شود.

## Phase 3: User Story 1 — انتخاب کاربر و مشاهدهٔ پست (Priority: P1) — MVP

**Goal**: کاربر آماده انتخاب شود و فقط پست‌های مجاز دیده شوند؛ هیچ مدل یا انتشار لازم نیست.
**Independent Test**: author-a فقط 101/103، editor-e هر چهار پست؛ 102 برای author-a برابر
permission_denied بدون payload و 999 برابر not_found؛ AC-01 تا AC-05.

### Tests for User Story 1

- [X] T010 [US1] پس از T009 تست seed و قرارداد Repository را در `test/unit/blog/in_memory_post_repository_test.dart` بنویس و red رفتاری را ثبت کن: چهار پست/سه کاربر جدول Spec، یکتایی id، authorId معتبر، snapshot غیرقابل تغییر، revision افزایشی و عدم تغییر سایر فیلدها در replacePublished.

### Implementation for User Story 1

- [X] T011 [US1] پس از T010 `lib/features/blog/data/sample_data.dart` و `lib/features/blog/data/in_memory_post_repository.dart` را پیاده کن و تست T010 را سبز کن؛ متن کامل نمونه‌ها ویژگی‌های Spec از جمله TODO و جملهٔ Injection در 102 را حفظ کند؛ داده فقط در حافظه و کپی seed هر scope مستقل باشد.
- [X] T012 [US1] پس از T011 تست انتخاب کاربر، فهرست و getPost را در `test/unit/blog/blog_read_service_test.dart` بنویس و red را ثبت کن: noUser، unknown user، id صفر/منفی، مالکیت تمام statusها، not_found و permission_denied بدون افشای داده؛ تفاوت هویت و مجوز روشن باشد.
- [X] T013 [US1] پس از T012 session با قید «userId اختیاری، epoch افزایشی و contextEpoch؛ نقش هر بار از فهرست معتبر خوانده می‌شود» و متدهای خواندن BlogService را در `lib/features/blog/application/current_user_session.dart` و `lib/features/blog/application/blog_service.dart` پیاده کن؛ تغییر واقعی کاربر epoch را افزایش دهد؛ T012 را سبز کن.
- [X] T014 [P] [US1] پس از T013 تست Cubit مشاهده را در `test/cubit/blog_read_cubit_test.dart` بنویس و red رفتاری ثبت کن: noUser، انتخاب کاربر، فهرست، انتخاب پست، خطا با code و پاک‌شدن دادهٔ کاربر قبلی؛ به Flutter UI import نداشته باشد.
- [X] T015 [P] [US1] پس از T013 تست Widget انتخاب و مشاهده را در `test/widget/blog_read_page_test.dart` بنویس و red ثبت کن: کاربران آماده، نمایش جزئیات تمام فیلدهای Post و فهرست مجاز بدون ورود/ثبت‌نام؛ از T014 مستقل باشد و فقط stub حداقلی لازم داشته باشد.
- [X] T016 [US1] پس از T014 و T015 state immutable و BlogCubit خواندن را در `lib/features/blog/presentation/cubit/blog_state.dart` و `lib/features/blog/presentation/cubit/blog_cubit.dart` پیاده کن؛ وابستگی فقط Dart/package:bloc و تصمیم دسترسی فقط از سرویس؛ تست T014 سبز شود.
- [X] T017 [US1] پس از T016 صفحهٔ سادهٔ فارسی در `lib/features/blog/presentation/blog_page.dart` و composition root در `lib/app/app.dart` و `lib/main.dart` را وصل کن؛ یک instance از Repository/session/BlogService در طول اجرا ساخته شود و rebuild داده را reset نکند؛ T015 سبز شود.
- [X] T018 [US1] پس از T017 تست‌های US1 و دموی مستقل مشاهده را طبق `specs/001-local-content-assistant/quickstart.md` اجرا و نتایج AC-01 تا AC-05 و red/green را در `specs/001-local-content-assistant/validation.md` ثبت کن؛ بدون مدل و شبکه.

**Checkpoint**: MVP خواندنی قابل دمو است؛ قواعد انتشار برای رسیدن به این checkpoint لازم نیستند.

## Phase 4: User Story 2 — انتشار معمول با کنترل کامل (Priority: P1)

**Goal**: Editor با تأیید صریح منتشر کند؛ رد، لغو و تغییر شرایط هیچ انتشار نامعتبر نسازند.
**Independent Test**: fixture تازه و متدهای مستقیم سرویس؛ AC-06 تا AC-11 و AC-38؛ D4 تا D6
در مسیر معمول. UI نیز تأیید و لغو را جدا از approved نشان دهد.

### Tests for User Story 2

- [X] T019 [US2] پس از T018 تست دادهٔ درخواست و snapshot را در `test/unit/blog/publish_request_test.dart` بنویس و red ثبت کن؛ requestId برنامه‌ساخته، fingerprint ثابت و PendingPublish فقط snapshot نمایش باشد، نه مرجع تأیید.

### Implementation for User Story 2

- [X] T020 [US2] پس از T019 مدل‌های `lib/features/blog/domain/publish_request.dart` را با فیلدهای عین data-model پیاده و T019 را سبز کن: PendingPublish «requestId، postId، title، fromStatus=draft، toStatus=published»، PublishFingerprint «actorId، postId و operation=publish»، ConfirmationSnapshot «fingerprint، sessionEpoch، contextEpoch، postRevision»، PublishRecord «fingerprint، snapshot، phase، confirmedByUser، inFlight اختیاری و terminalResult اختیاری» و PublishReceipt «requestId، postId، status=published»؛ فیلدهای الزامی nullable نشوند.
- [X] T021 [US2] پس از T020 تست prepare و تقدم خطا را در `test/unit/blog/blog_publish_prepare_test.dart` بنویس و red ثبت کن: invalid_arguments، سپس مجوز، وجود، status، approved؛ Author با 999 permission_denied، published/archived با approved=false خطای وضعیت بدهند؛ prepare هیچ Post یا approved را تغییر ندهد.
- [X] T022 [US2] پس از T021 preparePublish و صدور requestId با runNonce و شمارنده و ledger سرویس را در `lib/features/blog/application/blog_service.dart` پیاده کن؛ snapshot/هویت معتبر زیر کنترل برنامه و خروجی PendingPublish فقط برای نمایش؛ T021 سبز شود.
- [X] T023 [US2] پس از T022 تست confirm/cancel را در `test/unit/blog/blog_publish_confirmation_test.dart` بنویس و red ثبت کن: قبل از تأیید اثر صفر، تأیید صریح status را یک بار تغییر دهد، تأیید اولیه با approved فرق دارد، لغو پیش از اعمال بدون تغییر و confirm لغوشده cancelled باشد، لغو پس از success خطای already_published بدون rollback بدهد.
- [X] T024 [US2] پس از T023 confirmPublish و cancelPublish را در `lib/features/blog/application/blog_service.dart` پیاده کن؛ receipt واقعی و تغییر فقط status/revision، ثبت نتیجه کنار تغییر در بخش همگام بدون await و بدون callback خارجی؛ T023 سبز شود و نتیجه موفق برای پیگیری باقی بماند.
- [X] T025 [US2] پس از T024 تست stale و بازبینی نهایی را در `test/unit/blog/blog_publish_revalidation_test.dart` بنویس و red ثبت کن: تغییر user/role با fixture، رفت‌وبرگشت کاربر، context، revision/content/status/approved قبل از اجرای نهایی؛ خطای دامنهٔ مقدم یا stale_confirmation و صفر write؛ ویرایش واقعی به برنامه اضافه نکن.
- [X] T026 [US2] پس از T025 اعتبار snapshot، invalidatePendingContext و کنترل نهایی با شرایط جاری را در `lib/features/blog/application/blog_service.dart` و `lib/features/blog/application/current_user_session.dart` تکمیل کن؛ رفت‌وبرگشت epoch تأیید قدیمی را احیا نکند و همهٔ T025 سبز شوند.
- [X] T027 [P] [US2] پس از T026 تست state انتشار Cubit را در `test/cubit/blog_publish_cubit_test.dart` بنویس و red ثبت کن: awaitingConfirmation قبل از confirm، cancel، publishing/success و خطای typed؛ درخواست اولیه تأیید اجرا محسوب نشود.
- [X] T028 [P] [US2] پس از T026 تست Widget تأیید/لغو را در `test/widget/blog_publish_page_test.dart` بنویس و red ثبت کن: شناسه، عنوان، draft → published و دو اقدام روشن؛ رد بستن دیالوگ اثر صفر و پس از success refresh از سرویس باشد؛ از فایل T027 مستقل است.
- [X] T029 [US2] پس از T027 و T028 جریان requestPublish/confirm/cancel و stateهای لازم را در `lib/features/blog/presentation/cubit/blog_cubit.dart`، `lib/features/blog/presentation/cubit/blog_state.dart` و `lib/features/blog/presentation/blog_page.dart` وصل کن؛ UI قواعد را تکرار نکند و فقط رویداد trusted تأیید متد confirm را صدا بزند؛ هر دو تست سبز شوند.
- [X] T030 [US2] پس از T029 ماتریس AC-06 تا AC-11 و AC-38 و D4 تا D6 مسیر معمول را با fixture مستقل اجرا و نتیجه و تعداد write و red/green را در `specs/001-local-content-assistant/validation.md` ثبت کن؛ مشاهدهٔ US1 رگرسیون نداشته باشد.

**Checkpoint**: انتشار معمول درست است؛ تحویل P1 نهایی هنوز به صحت Retry و هم‌زمانی US3 نیاز دارد.

## Phase 5: User Story 3 — Timeout و تلاش مجدد امن (Priority: P1)

**Goal**: نتیجهٔ نامعلوم صادقانه نمایش داده شود و همان درخواست منطقی حداکثر یک اثر داشته باشد.
**Independent Test**: بدون مدل، Completer پیش/پس از commit را نگه دارد؛ Retry متوالی و هم‌زمان
write دوم نسازد؛ اجرای جدید seed/ledger مستقل داشته باشد؛ AC-12 تا AC-16، EC-10 و D7.

### Tests for User Story 3

- [ ] T031 [US3] پس از T030 تست retry و ledger را در `test/unit/blog/blog_publish_retry_test.dart` بنویس و red رفتارهای جدید را ثبت کن: دوبار confirm، Retry هم‌زمان/متوالی، همان receipt قبل از بررسی published، درخواست تازه روی published برابر already_published، تضاد postId/Editor دیگر برابر request_conflict بدون افشا، noUser برابر permission_denied، ناشناخته stale_confirmation و بدون تأیید confirmation_required.

### Implementation for User Story 3

- [ ] T032 [US3] پس از T031 retryPublish و اشتراک inFlight/terminalResult را در `lib/features/blog/application/blog_service.dart` پیاده کن؛ Future و رکورد پیش از اولین await ثبت شوند، کنترل هویت و fingerprint قبل از بازیابی نتیجه و اثر تکراری صفر باشد؛ cancelled/rejected نتیجهٔ پیشین بدهند؛ T031 سبز شود.
- [ ] T033 [US3] پس از T032 تست تأخیر و race را در `test/unit/blog/blog_publish_timeout_test.dart` با Completer بنویس و red ثبت کن: تأخیر beforeCommit و afterCommitBeforeResponse، Retry در حال اجرا یا پس از commit، لغو/تعویض هویت در تأخیر و پاسخ دیررس؛ timeout هرگز ledger را شکست نهایی یا پاک نکند؛ خواب واقعی استفاده نکن.
- [ ] T034 [US3] پس از T033 PublishDelay با دو نقطهٔ `beforeCommit()` و `afterCommitBeforeResponse()` را در `lib/features/blog/application/publish_delay.dart` و اتصال آن در `lib/features/blog/application/blog_service.dart` تکمیل کن؛ حالت عادی فوری، commit و ثبت success همگام بین دو نقطه و بررسی دوباره پس از await؛ committed حتی پیش از پاسخ دیررس receipt را به Retry بدهد؛ T033 سبز شود.
- [ ] T035 [P] [US3] پس از T034 تست Cubit timeout را در `test/cubit/blog_retry_cubit_test.dart` بنویس و red ثبت کن: انتظار محدود، unknownOutcome، حفظ requestId و Retry بدون prepare تازه، کنارگذاشتن پاسخ generation/requestId قبلی و بدون لغو فرضی عملیات.
- [ ] T036 [P] [US3] پس از T034 تست Widget Retry و طول عمر را در `test/widget/blog_retry_page_test.dart` بنویس و red رفتار جدید را ثبت کن: نتیجهٔ نامعلوم، اقدام پیگیری، نبود success حدسی، عدم نمایش دادهٔ کاربر قبلی و حفظ سرویس/داده در rebuild؛ از T035 مستقل باشد.
- [ ] T037 [US3] پس از T035 و T036 مهلت انتظار ۲ ثانیه و unknownOutcome/retry و محافظ generation/requestId را در `lib/features/blog/presentation/cubit/blog_cubit.dart` و `lib/features/blog/presentation/cubit/blog_state.dart` تکمیل کن؛ فقط Future انتظار timeout شود و Future سرویس زنده بماند؛ T035 سبز شود.
- [ ] T038 [US3] پس از T037 نمایش Retry و کنترل debug تأخیر اختیاری ۳ ثانیه پیش/پس از commit را در `lib/features/blog/presentation/blog_page.dart` و `lib/app/app.dart` وصل کن؛ کنترل دمو فقط delay را عوض کند نه مجوز/approved، سرویس/Repository singleton همان scope بمانند و T036 سبز شود.
- [ ] T039 [US3] پس از T038 تست طول عمر scope را در `test/unit/blog/blog_scope_lifetime_test.dart` اضافه و اجرا کن: اجرای مستقل seed اولیه/ledger خالی و requestId قبلی stale_confirmation، در همان scope بازسازی مصرف‌کننده ledger را پاک نکند؛ رفتار موجود را به‌عنوان رگرسیون و رفتار تازه را با red/green ثبت و در صورت نیاز فقط scope wiring در `lib/app/app.dart` را اصلاح کن.
- [ ] T040 [US3] پس از T039 دموی D7 را برای timeout پیش و پس از commit و AC-12 تا AC-16 با شمار write و requestId اجرا و در `specs/001-local-content-assistant/validation.md` ثبت کن؛ همچنین retry خواندن بدون write و reset پس از بستن برنامه بررسی شود؛ تضمین بین process یا restart ادعا نشود.

**Checkpoint**: US1 تا US3 با دادهٔ محلی و بدون مدل/MCP کامل و مستقل از اتصال بیرونی قابل اعتبارسنجی‌اند.

## Phase 6: User Story 4 — مشاهده و رفع ابهام با دستیار (Priority: P2؛ deferred)

**Goal / Independent Test آینده**: ورودی کنترل‌شدهٔ مدل، get_post واقعی و سؤال تکمیلی بدون حدس؛
AC-17 تا AC-21، D1 و D3. **صفر تسک اجرایی فعلی**: Plan اتصال مدل، قرارداد Tool و مدیریت
context باید ابتدا تکمیل شود. هیچ پوشه، package یا stub دستیار در این برش نسازید.

## Phase 7: User Story 5 — ارزیابی تحریریه (Priority: P2؛ deferred)

**Goal / Independent Test آینده**: خروجی‌های ثابت ready/not_ready/needs_input و نامعتبر بدون
تغییر مجوز یا approved؛ AC-22 تا AC-27 و D2. **صفر تسک اجرایی فعلی**: طراحی منبع سیاست و
Schema اجرایی ارزیابی هنوز جزو Plan P1 نیست؛ فایل سیاست یا راه‌حل دانش آینده اکنون ساخته نشود.

## Phase 8: User Story 6 — انتشار با دستیار و Injection (Priority: P2؛ deferred)

**Goal / Independent Test آینده**: پیشنهاد اجباری ابزار، از جمله Injection، نتواند قواعد و
تأیید را دور بزند؛ AC-28 تا AC-32 و D8. **صفر تسک اجرایی فعلی**: پس از طراحی US4/US5 و
اتصال به همان BlogService، تسک‌های ابزار تولید شوند؛ confirmPublish ابزار مدل نمی‌شود.

## Phase 9: User Story 7 — MCP و Resource (Priority: P3؛ deferred)

**Goal / Independent Test آینده**: کشف get_post و سیاست، برابری رفتار مسیرها و عدم ارتقای نقش؛
AC-33 تا AC-37 و D9. **صفر تسک اجرایی فعلی**: روش ارتباط و اشتراک داده با process MCP باز
است؛ ابتدا Plan مربوط تکمیل شود، سپس تسک. seed مستقل برای ایجاد ظاهر اشتراک مجاز نیست.

## Phase 10: Polish & Cross-Cutting Concerns — فقط P1

- [ ] T041 پس از T040 مرز import و وابستگی‌ها در `lib/features/blog/domain/`، `lib/features/blog/application/` و `lib/features/blog/data/` و مسیر نوشتن در `lib/features/blog/presentation/` را بررسی کن؛ قواعد در Widget/Cubit و نقش/تأیید از ورودی مدل وجود نداشته باشد، متن Injection فقط داده باشد و کلید/اطلاعات حساس در خطا یا Git ثبت نشده باشد؛ شواهد را در `specs/001-local-content-assistant/validation.md` بنویس.
- [ ] T042 پس از T041 `flutter analyze`، `dart test test/unit/blog`، `dart test test/cubit` و `flutter test test/widget` را از ریشه طبق `specs/001-local-content-assistant/quickstart.md` اجرا و نتیجه را در `specs/001-local-content-assistant/validation.md` ثبت کن؛ هر خطای واقعی را در فایل مرتبط رفع و همان تست‌های متأثر را دوباره اجرا کن؛ تست مدل واقعی اضافه نکن.
- [ ] T043 پس از T042 فرمان‌ها و پیش‌نیازهای واقعی اجرا را در `specs/001-local-content-assistant/quickstart.md` با پروژه تطبیق بده و شرح کوتاه معماری P1 و محدودیت حافظه/تأیید/Retry را در `specs/001-local-content-assistant/validation.md` ثبت کن؛ موارد P2/P3 را اجراشده اعلام نکن و Baseline/Constitution را تغییر نده.
- [ ] T044 پس از T043 با `flutter run -d windows` جریان انتخاب، مشاهده، رد انتشار، تأیید/لغو و دو Timeout را بررسی و نتیجهٔ نهایی P1 را در `specs/001-local-content-assistant/validation.md` ثبت کن؛ اگر محیط مانع تست desktop است دقیقاً همان محدودیت را گزارش کن، موفقیت حدسی و Commit انجام نده.

## Dependencies & Execution Order

### Phase Dependencies

```text
Setup T001–T003
  → Foundation T004–T009
  → US1 T010–T018
  → US2 T019–T030
  → US3 T031–T040
  → Polish P1 T041–T044
```

شماره‌ها ترتیب پیش‌فرض‌اند؛ استثناهای موازی فقط زوج‌های ذکرشدهٔ زیر هستند. ترتیب درون
هر تسک red → implementation → green ثابت است؛ کار هم‌زمان روی BlogService، Cubit یا صفحه
انجام نشود. US2/US3 برای integration به Story قبلی وابسته‌اند اما با fixture مستقل قابل
تست‌اند؛ مستقل‌بودن تست به معنی بی‌نیازی از قراردادهای مشترک نیست.

### User Story Dependencies

| Story | وابستگی تحویل | تست مستقل/Checkpoint |
| --- | --- | --- |
| US1 | Setup و Foundation | نقش‌ها، مالکیت، نبود پست؛ AC-01 تا AC-05 |
| US2 | US1 برای UI و سرویس خواندن | fixture تازه؛ قواعد، تأیید، لغو و stale؛ AC-06 تا AC-11 و AC-38 |
| US3 | US2 و ledger انتشار | دو gate کنترل‌شده؛ حداکثر یک write؛ AC-12 تا AC-16 |
| US4 | Plan بعدی و منطق خواندن P1 | D1/D3؛ اکنون deferred |
| US5 | Plan بعدی ارزیابی و منبع سیاست | D2؛ اکنون deferred |
| US6 | US2/US3 و طراحی adapter دستیار | D4 تا D8 در مسیر دستیار؛ اکنون deferred |
| US7 | طراحی MCP پس از ابزار مستقیم | D9 و Resource؛ اکنون deferred |

### Parallel Opportunities / Examples per Story

- **US1**: پس از T013، نوشتن تست Cubit در T014 و تست Widget در T015 موازی است؛ سپس T016.
- **US2**: پس از T026، نوشتن تست Cubit در T027 و تست Widget در T028 موازی است؛ سپس T029.
- **US3**: پس از T034، نوشتن تست Cubit در T035 و تست Widget در T036 موازی است؛ سپس T037.
- **US4 تا US7**: مثال اجرایی موازی ندارند؛ بدون Plan برش مربوط هیچ کاری برای آن‌ها dispatch نشود.

در هر زوج، فایل تست متفاوت است؛ اگر برای compile هر دو به stub مشترک احتیاج داشتند، stub
یک بار و پیش از fork کار آماده شود و رفتار پیاده‌سازی نشود. بقیهٔ تسک‌ها به‌دلیل فایل‌های
مشترک یا ترتیب TDD موازی علامت نخورده‌اند.

## Implementation Strategy

### MVP First

T001 تا T018 حداقل دموی مستقل مشاهده است. تحویل مشاهده به معنی پایان تمرین نیست؛ برای P1
کامل باید T019 تا T044 نیز انجام شوند، چون تأیید و Retry بخشی از صحت انتشارند.

### Incremental Delivery

۱. Setup و قراردادهای مشترک؛ ۲. مشاهدهٔ مستقل؛ ۳. انتشار معمول با تأیید؛ ۴. Retry و Timeout؛
۵. اعتبارسنجی نهایی P1. سپس فقط با درخواست کاربر و Plan تکمیلی، تسک‌های P2 و P3 افزوده شوند.
این فایل اجازهٔ حذف الزامات آینده یا افزودن تصمیم سراسری از پیشنهادهای Plan را نمی‌دهد.

## Coverage & Notes

| نیازمندی | تسک‌های اصلی |
| --- | --- |
| FR-001 تا FR-004 | T001–T011، T017 |
| FR-005 و FR-006 | T012–T018 |
| FR-007 تا FR-011 و AC-38 | T019–T024، T027–T030 |
| FR-012 و FR-013 | T025–T029، T033–T034 |
| FR-014 تا FR-016 | T031–T040 |
| FR-033 | همهٔ جفت‌های red/green و T042 |
| EC-01 تا EC-07 و EC-10 در P1 | T012، T021–T026، T031–T040 |
| FR-017 تا FR-031، EC-08 و بخش‌های مدل/MCP از EC-09 | US4 تا US7، deferred؛ طراحی بعدی لازم است |
| FR-032، FR-034، SC-001 و SC-009 | تعهد کل تمرین؛ اکنون فقط شواهد P1/D4–D7 در T030، T040، T043–T044 |
| SC-002 تا SC-004 و SC-006 در P1 | T012، T021–T026، T031–T044؛ بخش مدل SC-002 آینده است |
| SC-005، SC-007 و SC-008 | مرتبط با ارزیابی/دستیار/MCP؛ deferred |

همهٔ ۴۴ تسک مسیر مشخص دارند؛ US1: ۹، US2: ۱۲، US3: ۱۰؛ Setup: ۳، Foundation: ۶، Polish: ۴.
شناسه‌ها T001 تا T044 یکتا و پیوسته‌اند. ۶ تسک در سه زوج مستقل [P] دارند. تغییر فقط همین
سند در مرحلهٔ Tasks است؛ هنوز هیچ تست، کد، پروژه یا گزارش validation ایجاد یا اجرا نشده است.

</div>