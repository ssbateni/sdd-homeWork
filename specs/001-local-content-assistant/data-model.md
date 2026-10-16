# مدل داده و چرخهٔ عمر — P1

تمام مدل‌های دامنه Dart خالص و immutable هستند؛ Repository هیچ Map یا Post قابل تغییر
به بیرون نمی‌دهد. داده‌های نمونه و شناسه/مالکیت مطابق جدول spec.md هستند.

## موجودیت‌ها

| مدل | فیلدها و قید |
| --- | --- |
| AppUser | id: String غیرخالی؛ role: UserRole.author/editor؛ از فهرست ثابت معتبر |
| Post | id: int مثبت و یکتا؛ title/content: String؛ status: PostStatus.draft/published/archived؛ approved: bool؛ authorId: شناسهٔ کاربر؛ createdAt: DateTime |
| StoredPost | Post و revision: int؛ revision داخلی و افزایشی با هر تغییر؛ جزو محتوای دامنه‌ای پست نیست |
| CurrentUserSession | userId اختیاری، epoch افزایشی و contextEpoch؛ نقش هر بار از فهرست معتبر خوانده می‌شود |
| PendingPublish | requestId، postId، title، fromStatus=draft، toStatus=published؛ فقط snapshot نمایش |
| PublishFingerprint | actorId، postId و operation=publish؛ پس از ایجاد ثابت |
| ConfirmationSnapshot | fingerprint، sessionEpoch، contextEpoch، postRevision؛ زیر کنترل سرویس |
| PublishRecord | fingerprint، snapshot، phase، confirmedByUser، inFlight اختیاری و terminalResult اختیاری |
| PublishReceipt | requestId، postId، status=published؛ موفقیت واقعی ثبت‌شده |
| BlogFailure | code از جدول قرارداد؛ پیام قابل نمایش بدون اطلاعات پست غیرمجاز |

requestId از nonce همان اجرا و شمارنده ساخته می‌شود؛ ورودی جدید publish همیشه شناسهٔ
برنامه‌ساخته می‌گیرد. lookup/retry می‌تواند شناسه را دریافت کند ولی اجازهٔ ساخت رکورد دلخواه ندارد.
هویت و approved از ورودی ابزار یا Widget به‌عنوان دادهٔ معتبر پذیرفته نمی‌شوند.

## مالکیت و دسترسی

- Author فهرست پست‌های خودش و جزئیات همهٔ وضعیت‌های پست خودش را می‌بیند؛ Editor همه را می‌بیند.
- getPost برای ورودی معتبر: نبود هویت permission_denied؛ سپس نبود پست not_found؛ برای پست
  موجود متعلق به Author دیگر permission_denied. payload غیرمجاز هیچ فیلد Post ندارد.
- انتشار تازه پس از اعتبارسنجی: مجوز Editor، وجود، status، approved و در نهایت confirmation.
- revision و اطلاعات ledger API ویرایش عمومی نیستند؛ تغییر شرایط برای تست با fixture یا
  Repository آزمایشی انجام می‌شود، نه افزودن قابلیت ویرایش/تأیید به رابط.

## حالت پست

تنها انتقال عملیاتی P1 برابر draft → published با approved=true است. archived هیچ انتقالی
ندارد. انتشار، approved، authorId، createdAt، title و content را تغییر نمی‌دهد. revision
داخلی برای ثبت snapshot به‌روز می‌شود و خاصیت قابل ویرایش کاربر نیست.

## حالت درخواست

| مبدأ | رویداد | مقصد/اثر |
| --- | --- | --- |
| بدون رکورد | prepare معتبر | awaitingConfirmation؛ ذخیرهٔ snapshot؛ بدون تغییر پست |
| awaitingConfirmation | confirm صریح همان کاربر | executing؛ ثبت تأیید و Future قبل از await |
| awaitingConfirmation | retry بدون confirm | confirmation_required؛ بدون تغییر |
| awaitingConfirmation یا executing پیش از commit | cancel صریح | cancelled؛ بدون تغییر پست؛ ادامهٔ Future نیز باید لغو را ببیند |
| هر درخواست اعمال‌نشده | تغییر نشست یا context | تأیید نامعتبر؛ اجرای نهایی stale_confirmation یا خطای دامنهٔ مقدم |
| executing | بررسی نهایی معتبر | committed؛ تغییر پست و ثبت receipt در همان بخش همگام |
| executing | شرط جاری نامعتبر | rejected با خطای قطعی؛ بدون تغییر پست |
| committed | پاسخ با تأخیر | همان committed؛ timeout فقط برای انتظارکننده است |
| committed | retry همان fingerprint و هویت مجاز | receipt قبلی، بدون اثر جدید |
| cancelled/rejected | retry همان درخواست | نتیجهٔ نهایی قبلی؛ برای اقدام جدید prepare و تأیید تازه |

تغییر کاربر حتی رفت‌وبرگشت به همان شناسه، epoch جدید می‌سازد و تأیید اعمال‌نشدهٔ قبلی را
احیا نمی‌کند. انتخاب پست تازه نیز contextEpoch را تغییر می‌دهد. نتیجهٔ موفق اعمال‌شده با
همان هویت و مجوز قابل پیگیری است؛ تعویض context مانع تکمیل پنهانی یک درخواست اعمال‌نشده می‌شود.

## اتمیک‌بودن در حافظه

Repository، session و ledger یک مالک و یک isolate دارند. ثبت inFlight پیش از اولین await
است؛ درخواست دوم به همان Future متصل می‌شود. پس از هر تأخیر آزمایشی، سرویس در یک قطعهٔ
همگام دوباره phase، هویت/epoch، پست و قواعد را می‌خواند؛ سپس Post جدید و success را ثبت
می‌کند. در این قطعه هیچ await، callback کاربر، I/O یا تخصیص تأخیر وجود ندارد؛ عملیات
Repository حافظه‌ای معتبر نباید خطای عملیاتی قابل انتظار بدهد. این تضمین به write async،
چند isolate یا process دیگر تعمیم ندارد؛ تغییر این فرض نیازمند طراحی دوبارهٔ commit است.

برای درخواست موجود ابتدا هویت معتبر و تطبیق fingerprint کنترل می‌شود؛ بازیابی success قبل
از بررسی draft انجام می‌شود تا Retry با already_published اشتباه نشود. درخواست تازهٔ دیگر
روی همان published واقعاً already_published است. هیچ نتیجهٔ قبلی به هویت دیگر افشا نمی‌شود.

## طول عمر

Composition root یک نمونه از داده، نشست و سرویس می‌سازد؛ rebuild و تغییر Cubit داده را
reset نمی‌کند. چهار پست و سه کاربر در شروع هر اجرای مستقل seed می‌شوند؛ ledger خالی است.
پایان process/hot restart همهٔ تغییرها، تأییدها و درخواست‌ها را از بین می‌برد. شناسهٔ اجرای
قبل unknown است و stale_confirmation می‌دهد؛ هیچ بازیابی یا Retry بین اجراها نداریم.
سابقه تا پایان همان اجرا نگه داشته می‌شود؛ برای حجم این تمرین پاک‌سازی زمان‌دار لازم نیست.

## مرز موجودیت‌های آینده

ReviewOutput با پنج فیلد و قواعد result همان spec.md است؛ در P1 مدل اجرایی یا validator آن
ساخته نمی‌شود. EditorialPolicy شامل متن و نسخه است؛ دریافت آن پشت منبع مستقل از ارزیابی
قرار خواهد گرفت. مدل/ابزارها حق ساخت ConfirmationSnapshot یا نوشتن Repository ندارند.
