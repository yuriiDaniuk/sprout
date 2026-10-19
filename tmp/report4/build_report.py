from pathlib import Path
from docx import Document
from docx.shared import Cm, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from PIL import Image
import re, json, textwrap

ROOT = Path('/Users/urijdanuk/Desktop/KPP/laba3/sprout')
OUT = ROOT / 'output/report/Данюк_КПП_4.docx'
EVID = ROOT / 'artifacts/lab4'
TMP = ROOT / 'tmp/report4'
d = Document()
s = d.sections[0]
s.page_width, s.page_height = Cm(21), Cm(29.7)
s.top_margin = s.bottom_margin = s.left_margin = s.right_margin = Cm(2)
s.header_distance, s.footer_distance = Cm(1), Cm(1)
s.different_first_page_header_footer = True

def style_font(st, name='Times New Roman', size=14, bold=False):
    st.font.name = name
    st.font.size = Pt(size)
    st.font.bold = bold
    st.font.color.rgb = RGBColor(0, 0, 0)
    fonts=st.element.get_or_add_rPr().rFonts
    fonts.set(qn('w:eastAsia'), name)
    for attr in ['asciiTheme','eastAsiaTheme','hAnsiTheme','cstheme']:
        fonts.attrib.pop(qn('w:'+attr),None)

normal=d.styles['Normal']; style_font(normal)
pf=normal.paragraph_format
pf.line_spacing=1.25; pf.first_line_indent=Cm(1)
pf.space_before=pf.space_after=Pt(0)
pf.alignment=WD_ALIGN_PARAGRAPH.JUSTIFY
pf.widow_control=True
for name in ['Heading 1','Heading 2','Heading 3','Title']:
    st=d.styles[name]; style_font(st, size=16 if name=='Title' else 14, bold=True)
    p=st.paragraph_format; p.alignment=WD_ALIGN_PARAGRAPH.CENTER
    p.first_line_indent=Cm(0); p.space_before=Pt(14); p.space_after=Pt(7)
    p.line_spacing=1.25; p.keep_with_next=True
    for border in st.element.xpath('./w:pPr/w:pBdr'):
        border.getparent().remove(border)
style_font(d.styles['Header'])
code_style=d.styles.add_style('Source Code',1)
style_font(code_style,'Courier New',12)
cp=code_style.paragraph_format;cp.line_spacing=1;cp.space_before=cp.space_after=Pt(0)
cp.first_line_indent=Cm(0);cp.alignment=WD_ALIGN_PARAGRAPH.LEFT
cp.widow_control=False
caption=d.styles['Caption'];style_font(caption)
caption.paragraph_format.first_line_indent=Cm(0)
caption.paragraph_format.alignment=WD_ALIGN_PARAGRAPH.CENTER
caption.paragraph_format.space_before=Pt(4);caption.paragraph_format.space_after=Pt(8)
caption.paragraph_format.line_spacing=1.25
hp=s.header.paragraphs[0]; hp.alignment=WD_ALIGN_PARAGRAPH.RIGHT
hp.paragraph_format.first_line_indent=Cm(0)
r=hp.add_run(); field=OxmlElement('w:fldSimple');field.set(qn('w:instr'),'PAGE')
r._r.addnext(field)
settings=d.settings.element
update=OxmlElement('w:updateFields');update.set(qn('w:val'),'true');settings.append(update)
lang=OxmlElement('w:lang');lang.set(qn('w:val'),'uk-UA')
normal.element.get_or_add_rPr().append(lang)

def para(text='', bold=False, align=None, before=0, after=0, indent=True, keep=False, style=None):
    p=d.add_paragraph(style=style)
    if text: p.add_run(text).bold=bold
    f=p.paragraph_format
    if align is not None: f.alignment=align
    if not indent: f.first_line_indent=Cm(0)
    f.space_before=Pt(before);f.space_after=Pt(after)
    f.keep_with_next=keep
    return p

def heading(text,level=1,new=False):
    p=d.add_paragraph(text,f'Heading {level}')
    if new: p.paragraph_format.page_break_before=True
    return p

def code(path=None,text=None,label=None):
    if path:
        text=(ROOT/path).read_text(); label=label or path
    code_title=('Файл: ' + label) if label else 'Фрагмент коду'
    if label=='структура робочого Flutter-проєкту':
        code_title='Структура робочого Flutter-проєкту'
    p=para(code_title,bold=True,indent=False,before=7,keep=True)
    lines=textwrap.dedent(text).rstrip('\n').split('\n')
    for i,line in enumerate(lines):
        p=d.add_paragraph(style='Source Code')
        p.add_run(line if line else ' ')
        if not path and len(lines)<=22:
            p.paragraph_format.keep_with_next=i<len(lines)-1
    return text

figures=[]
def figure(paths,title,width=None):
    if isinstance(paths,str): paths=[paths]
    n=len(figures)+1; figures.append((n,paths,title))
    p=d.add_paragraph(); p.alignment=WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.first_line_indent=Cm(0);p.paragraph_format.keep_with_next=True
    p.paragraph_format.line_spacing=1
    if len(paths)>1:
        ims=[Image.open(EVID/path).convert('RGB') for path in paths]
        height=max(im.height for im in ims)
        ims=[im.resize((round(im.width*height/im.height),height)) for im in ims]
        pair=Image.new('RGB',(sum(im.width for im in ims)+60,height),'white')
        x=0
        for im in ims:pair.paste(im,(x,0));x+=im.width+60
        source=TMP/f'figure-{n}.png';pair.save(source)
        w=width or 16
    else:
        source=EVID/paths[0];im=Image.open(source)
        w=width or (7.6 if im.height>im.width else 16.5)
        details={
            'analytics-debugview.png':(1060,210,1410,418),
            'crashlytics-readable-stack.png':(307,482,1007,690),
            'auth-providers-report.png':(382,380,1002,427),
        }
        if paths[0] in details:
            detail=im.crop(details[paths[0]])
            factor=min(im.width/detail.width,2.3)
            detail=detail.resize((round(detail.width*factor),round(detail.height*factor)))
            panel=Image.new('RGB',(im.width,im.height+detail.height+30),'white')
            panel.paste(im.convert('RGB'),(0,0))
            panel.paste(detail.convert('RGB'),((im.width-detail.width)//2,im.height+20))
            source=TMP/f'figure-{n}.png';panel.save(source)
    p.add_run().add_picture(str(source),width=Cm(w))
    p=d.add_paragraph(f'Рис. {n}. {title}',style='Caption')
    p.paragraph_format.keep_together=True
    return n

def section(text): return heading(text,2,new=True)

# Title follows the supplied laboratory No. 3 cover.
para('МІНІСТЕРСТВО ОСВІТИ І НАУКИ УКРАЇНИ',True,WD_ALIGN_PARAGRAPH.CENTER,indent=False)
para('НАЦІОНАЛЬНИЙ УНІВЕРСИТЕТ "ЛЬВІВСЬКА ПОЛІТЕХНІКА"',True,WD_ALIGN_PARAGRAPH.CENTER,indent=False)
para('Інститут КНІТ\nКафедра ПЗ',align=WD_ALIGN_PARAGRAPH.RIGHT,before=18,indent=False)
p=d.add_paragraph('ЗВІТ','Title');p.paragraph_format.space_before=Pt(140);p.paragraph_format.space_after=Pt(14)
para('До лабораторної роботи № 4',align=WD_ALIGN_PARAGRAPH.CENTER,indent=False)
p=para(align=WD_ALIGN_PARAGRAPH.CENTER,indent=False)
p.add_run('З дисципліни: ').bold=True;p.add_run('“Кросплатформне програмування”').italic=True
p=para(align=WD_ALIGN_PARAGRAPH.CENTER,indent=False)
p.add_run('На тему: ').bold=True;p.add_run('“Реалізація автентифікації та інтеграція з Firebase”').italic=True
for title,lines,gap in [('Лектор:','ст. викл. каф. ПЗ\nУгриновський Б. В.',58),('Виконав:','студент гр. ПЗ-34\nДанюк Ю. І.',14),('Прийняв:','асистент каф. ПЗ\nГавдульський Р. І.',14)]:
    para(title,True,WD_ALIGN_PARAGRAPH.RIGHT,before=gap,indent=False,keep=True)
    para(lines,align=WD_ALIGN_PARAGRAPH.RIGHT,indent=False)
para('Львів – 2026',align=WD_ALIGN_PARAGRAPH.CENTER,before=52,indent=False)
d.add_page_break()

p=para();p.add_run('Тема роботи: ').bold=True;p.add_run('Реалізація автентифікації та інтеграція з Firebase.')
p=para();p.add_run('Мета роботи: ').bold=True;p.add_run('Навчитися інтегрувати Firebase у Flutter-застосунок та реалізовувати автентифікацію користувачів.')
heading('ТЕОРЕТИЧНІ ВІДОМОСТІ')
for text in [
'Залежності Flutter-проєкту описуються у pubspec.yaml. Пакети для роботи застосунку додають у dependencies, а засоби розробки та тестування — у dev_dependencies. Обмеження версій визначають допустимий діапазон, а pubspec.lock фіксує конкретні версії прямих і транзитивних залежностей. Це дає змогу відтворювати однакове середовище під час розробки.',
'Плагіни поєднують Dart API з реалізаціями для цільових платформ. Для взаємодії Dart із нативним кодом використовують платформні канали. MethodChannel передає назву операції й аргументи нативному обробнику та асинхронно повертає результат. Перед використанням плагіна потрібно перевірити підтримку платформи і виконати її налаштування.',
'Firebase надає окремі сервіси для автентифікації, аналітики та діагностики. Пакет firebase_core забезпечує ініціалізацію застосунку, а згенерований firebase_options.dart містить параметри його зв’язку з Firebase-проєктом. Звертатися до сервісів слід після завершення Firebase.initializeApp().',
'Firebase Authentication створює облікові записи та перевіряє облікові дані. Для email і пароля використовують createUserWithEmailAndPassword() та signInWithEmailAndPassword(). Стан користувача можна відстежувати через userChanges(). Поточний користувач має uid, email, displayName і photoURL. Оновлення імені або посилання на аватар не потребує створення окремої колекції у базі даних.',
'Сеанс підтримується Firebase SDK за допомогою токенів. Після повторного запуску застосунок очікує початковий стан автентифікації, а потім показує екран входу або головний екран. Вихід через signOut() завершує локальний сеанс. Пароль не слід зберігати у власній моделі користувача або записувати в журнали.',
'Зміна пароля в активному сеансі відрізняється від відновлення забутого пароля. У першому випадку користувач підтверджує особу через reauthenticateWithCredential(), після чого виконується updatePassword(). У другому випадку sendPasswordResetEmail() надсилає лист із посиланням на встановлення нового пароля. Зміна photoURL зберігає лише HTTPS-посилання, а не завантажує файл у сховище.',
'Firebase Analytics реєструє події використання застосунку. Частину подій SDK збирає автоматично, а прикладні дії й переходи між Flutter-екранами потрібно передавати з коду. Для цього доступні logLogin(), logSignUp(), logScreenView() і logEvent(). DebugView допомагає перевірити доставку подій під час розробки.',
'Firebase Crashlytics об’єднує повідомлення про помилки у звіти зі стеком викликів, версією застосунку та інформацією про середовище. Помилки Flutter перехоплюють через FlutterError.onError, а необроблені помилки кореневого ізоляту — через PlatformDispatcher.instance.onError. recordError() створює звіт; log() лише доповнює діагностичний журнал. Позначка fatal визначає класифікацію звіту й сама по собі не завершує процес.',
'Віджет Form об’єднує поля TextFormField. Ключ GlobalKey<FormState> зберігають у State, щоб він не змінювався під час кожної побудови. Метод validate() викликає валідатори: null означає коректне значення, а рядок — повідомлення про помилку. Локальна перевірка обов’язковості й формату не замінює серверну перевірку пароля, існування акаунта та мережевих помилок.',
'Для відокремлення інтерфейсу від Firebase застосовують репозиторій. Екран викликає метод AuthRepository, показує завантаження й обробляє результат. Поки запит виконується, повторне надсилання блокують; після помилки зберігають введені дані та дозволяють повторну спробу. Такий поділ дає змогу тестувати інтерфейс із підставним репозиторієм без реальних запитів.'
]: para(text)

heading('ЗАВДАННЯ',new=True)
para('Варіант № 4 — «Помічник із догляду за рослинами». Застосунок Sprout розвиває інтерфейс із лабораторної роботи № 3 та функціональні вимоги лабораторної роботи № 2.')
tasks=[
'1. Виконати інтеграцію Firebase Analytics. У звіті відобразити сторінку аналітики Firebase для свого проєкту. Якщо цільова платформа не підтримується, використати Amplitude Analytics або інший аналог.',
'2. Виконати інтеграцію Firebase Crashlytics. Згенерувати одну помилку, яка відобразиться у Firebase Crashlytics. У звіті відобразити сторінку звіту про помилки свого проєкту. За відсутності підтримки платформи допускається Sentry.io або інший аналог.',
'3. Налаштувати Firebase Auth відповідно до вимог лабораторної роботи № 2: а) обов’язково реалізувати основний метод email/password для реєстрації і входу; б) за потреби об’єднати кілька способів входу в один акаунт, якщо передбачено соціальну автентифікацію. У звіті відобразити сторінку з налаштованими способами входу.',
'4. Реалізувати бізнес-логіку взаємодії з Firebase Auth: а) реєстрацію, вхід і відновлення пароля через електронну пошту; б) керування профілем зі зміною пароля. Функції, що потребують Cloud Firestore або push-сповіщень, допускається залишити демонстраційними. Зміну фото реалізувати вибором готових HTTPS-зображень або введенням власного HTTPS-посилання з попереднім переглядом; завантаження файлів у сховище відкладено до лабораторної роботи № 6.',
'Забезпечити коректну роботу з правильними та неправильними даними: повідомлення про невдалий вхід і реєстрацію; стан завантаження та блокування повторного надсилання; успішний вхід, вихід і відновлення сеансу; помилки зміни пароля, зокрема потребу повторного входу. Винести взаємодію з Firebase в окремий клас AuthRepository. У звіті навести код репозиторію та один приклад виклику його методу з відображенням даних.',
'5. Додати валідацію полів через Form на екранах реєстрації та входу: обов’язкове ім’я, правильний формат email та інші відповідні перевірки. У звіті відобразити код форми реєстрації. Оновити також інші попередньо створені екрани, які потребують перевірки введених даних.',
'6. Відобразити у звіті зміст файлу main.dart після всіх змін.',
'7. Відобразити у звіті структуру проєкту після всіх змін.'
]
for t in tasks: para(t)

heading('ХІД РОБОТИ',new=True)
heading('1 Інтеграція Firebase Analytics',2)
para('Для Sprout створено Firebase-проєкт sprout-a6523 та зареєстровано iOS-застосунок із Bundle ID com.example.sprout. У цій роботі Firebase використано замість попередньо запропонованого у лабораторній № 2 Supabase. Цільова платформа застосунку — iOS 15.0 і новіші версії.')
para('FlutterFire CLI сформував firebase_options.dart і конфігурацію iOS. У pubspec.yaml підключено firebase_core 5.0.0, firebase_auth 7.0.0, firebase_analytics 13.0.0 та firebase_crashlytics 6.0.0; ці версії зафіксовано у pubspec.lock. Ініціалізація завершується до створення репозиторію та використання сервісів.')
para('AnalyticsService надсилає події login і sign_up після успішних відповідних операцій. Метод screen() реєструє screen_view. RouteAware відстежує відкриття та повторний показ маршруту, а перемикання Home/Profile обробляється окремо. Повторна побудова віджета сама по собі не створює нової події. Email і паролі у параметри подій не передаються.')
code('lib/core/services/analytics_service.dart')
para('Під час перевірки DebugView отримав події screen_view, login та user_engagement. На рис. 1 наведено сторінку Analytics проєкту Sprout із фактично доставленими подіями.')
figure('analytics-debugview.png','Firebase Analytics DebugView та збільшений фрагмент подій')

section('2 Інтеграція Firebase Crashlytics')
para('CrashReportingService встановлює обробники помилок Flutter і кореневого ізоляту. Для перевірки інтеграції створено контрольну нефатальну помилку з повідомленням «Sprout laboratory 4 controlled non-fatal test». Виклик доступний лише у debug-збірці за параметром CRASHLYTICS_TEST; звичайний запуск його не виконує.')
code('lib/core/services/crash_reporting_service.dart')
para('Після надсилання звіту та завантаження символів налагодження у Firebase відобразився читабельний стек: crash_reporting_service.dart:20 та main.dart:38. На рис. 2 видно контрольну нефатальну помилку; застосунок після її реєстрації продовжив роботу.')
figure('crashlytics-readable-stack.png','Firebase Crashlytics та збільшений фрагмент контрольної помилки')

section('3 Налаштування Firebase Authentication')
para('У Firebase Authentication увімкнено провайдер Email/Password, що показано на рис. 3. Соціальні способи входу не були передбачені вимогами Sprout, тому зв’язування Google, Apple або Facebook з акаунтом у цій роботі не потрібне.')
para('Для нового пароля погоджено мінімум 8 символів і щонайменше одну велику латинську літеру A–Z. Правило застосовано у формах реєстрації та зміни пароля й узгоджено з політикою Firebase. На вході перевіряється наявність пароля; його правильність визначає Firebase.')
figure('auth-providers-report.png','Email/Password для Sprout та збільшений фрагмент статусу Enabled')
para('Успішна реєстрація створює справжній акаунт Firebase та зберігає ім’я. Вхід відкриває Home, вихід очищає поточний стек екранів, а Firebase SDK відновлює сеанс після повторного запуску. AuthGate очікує початковий стан та визначає потрібний екран. Пароль не входить у модель AppUser.')

section('4 Автентифікація та керування профілем')
para('Взаємодію із сервером винесено в AuthRepository та його реалізацію FirebaseAuthRepository. Репозиторій перетворює Firebase User у власну модель AppUser, повідомляє слухачів про зміни та надає зрозумілі повідомлення замість технічного тексту винятків.')
para('Реєстрація враховує частковий успіх: якщо акаунт створено, але ім’я не збережено, повторна спроба завершує оновлення профілю. Зміна пароля спочатку повторно підтверджує поточні облікові дані. Оновлення імені одразу публікується для Home та Profile, зокрема якщо наступна операція з фото завершилася помилкою.')
code('lib/features/auth/data/auth_repository.dart')
heading('4.1 Виклик репозиторію та відображення даних',3)
para('Наведений метод екрана входу спочатку перевіряє Form, потім викликає repository.signIn(). runAction() керує завантаженням, блокує повторну дію та показує AuthFailure. Після успішного входу AuthGate змінює екран відповідно до актуального currentUser.')
login=(ROOT/'lib/features/auth/login_screen.dart').read_text()
login_method=login[login.index('  Future<void> _login()'):login.index('\n  @override\n  Widget build',login.index('  Future<void> _login()'))]
code(text=login_method,label='lib/features/auth/login_screen.dart — метод _login()')
para('SessionScreen слухає той самий репозиторій. Після зміни профілю ListenableBuilder отримує нову модель користувача й оновлює вміст без повторного створення маршруту та без втрати локального стану поливу.')
sess=(ROOT/'lib/features/session/session_screen.dart').read_text()
start=sess.index('  @override\n  Widget build(BuildContext context) {')
code(text=sess[start:sess.index('\n  Widget _buildSession',start)],label='lib/features/session/session_screen.dart — підписка на дані')
prof=(ROOT/'lib/features/profile/profile_screen.dart').read_text()
start=prof.index('                  Text(\n                    user.name,')
end=prof.index('                  const SizedBox(height: 28)',start)
code(text=prof[start:end],label='lib/features/profile/profile_screen.dart — виведення імені та email')
para('На рис. 4 наведено профіль із збереженими даними та результат окремої перевірки оновлення імені: після встановлення Alex Green на Home відобразилося «Hi, Alex». Це різні стани тестування одного сценарію, а не фіксовані демонстраційні дані.')
figure(['profile-saved.png','home-updated-name.png'],'Профіль користувача та Home після оновлення імені')

heading('4.2 Редагування профілю та вибір аватара',3,new=True)
para('Edit Profile показує поточне ім’я, email лише для читання та фото. Натискання Change Photo відкриває нижню панель із вісьмома погодженими аватарами-персонажами. Вибір до Save Changes є чернеткою; повернення без збереження його скасовує. Під час запису заблоковано повторне надсилання та повернення, щоб незавершений запит не перезаписав наступні зміни.')
para('У Firebase зберігається HTTPS-посилання на вибраний PNG у публічному репозиторії. У застосунок також додано локальні резервні зображення. Власні файли з галереї не завантажуються. Вигляд екранів наведено на рис. 5.')
figure(['edit-profile-final.png','avatar-picker-final.png'],'Edit Profile та панель вибору аватарів')
heading('4.3 Зміна та відновлення пароля',3,new=True)
para('Change Password перевіряє Current Password, New Password і Confirm New Password. Після валідації репозиторій виконує reauthenticateWithCredential() та updatePassword(). Неправильний поточний пароль і потреба свіжого входу мають зрозумілі повідомлення; після успіху поля очищуються.')
para('Forgot Password перевіряє email та викликає sendPasswordResetEmail(). Підтвердження не розкриває існування акаунта й очищується при зміні email або новій спробі. Лист відкриває стандартну сторінку Firebase. Екран запиту показано на рис. 6.')
figure('forgot-password-report.png','Екран відновлення пароля через електронну пошту')

section('5 Валідація форм реєстрації та входу')
para('Форми входу, реєстрації, відновлення пароля, редагування імені й зміни пароля використовують Form. Власний SproutTextField побудовано на TextFormField і передає йому validator. GlobalKey зберігається у State. Порожнє ім’я, некоректний email або новий пароль, що не відповідає політиці, не надсилаються до Firebase.')
para('Нижче наведено повний поточний код екрана реєстрації. Кнопка та відправлення з клавіатури використовують один метод _signup(). Поки busy дорівнює true, повторні натискання й повернення блокуються, а SproutButton показує індикатор завантаження.')
code('lib/features/auth/signup_screen.dart')
para('Спільні правила перевірки винесено в AuthValidators. Для входу використовується requiredPassword(), а для реєстрації та нового пароля — newPassword(). Помилки серверної автентифікації обробляються окремо у репозиторії, оскільки правильний формат не доводить правильність облікових даних.')
code('lib/features/auth/validation/auth_validators.dart')
para('На рис. 7 наведено два різні види помилок: локальна перевірка порожніх полів реєстрації та повідомлення про відсутність мережевого з’єднання під час входу. Після помилки користувач може виправити дані або повторити спробу.')
figure(['signup-validation-report.png','login-network-error-report.png'],'Локальна валідація реєстрації та повідомлення про помилку мережі')

section('6 Вміст файлу main.dart після змін')
para('Точка входу запускає SproutBootstrap. Він один раз ініціалізує Firebase у initState(), підключає Crashlytics та створює репозиторій. FutureBuilder показує індикатор очікування або екран із Retry у разі помилки старту. У dispose() репозиторій звільняє підписку. Нижче наведено весь main.dart без скорочень.')
code('lib/main.dart')

section('7 Структура проєкту після змін')
para('Основний код розділено за функціями: auth, home, profile і session. Каталог core містить спільні сервіси, тему та віджети. Повну структуру Dart-коду та основні конфігураційні файли наведено нижче; згенеровані каталоги збірки й кеші не показано.')
def tree_dir(path,prefix=''):
    items=sorted(path.iterdir(),key=lambda p:(not p.is_dir(),p.name))
    lines=[]
    for i,p in enumerate(items):
        last=i==len(items)-1
        lines.append(prefix+('└── ' if last else '├── ')+p.name+('/' if p.is_dir() else ''))
        if p.is_dir(): lines.extend(tree_dir(p,prefix+('    ' if last else '│   ')))
    return lines
tree=['sprout/','├── lib/']+tree_dir(ROOT/'lib','│   ')+['├── test/']+tree_dir(ROOT/'test','│   ')+[
'├── assets/', '│   ├── avatars/   (8 PNG та опис походження)', '│   ├── fonts/     (Manrope)', '│   ├── icons/     (локальні SVG)', '│   └── images/    (фотографії рослин)', '├── ios/', '│   ├── Runner/GoogleService-Info.plist', '│   ├── Runner.xcodeproj/', '│   └── Runner.xcworkspace/', '├── firebase.json', '├── pubspec.yaml', '├── pubspec.lock', '├── analysis_options.yaml', '├── LAB3_PLAN.md', '└── LAB4_PLAN.md']
code(text='\n'.join(tree),label='структура робочого Flutter-проєкту')
para('firebase_options.dart і GoogleService-Info.plist пов’язують клієнт із Firebase. auth_repository.dart містить операції акаунта; auth_gate.dart визначає доступний стек екранів; auth_action.dart керує станами запитів і відстеженням маршрутів. app_user.dart описує дані профілю, а session_screen.dart оновлює Home/Profile за змінами репозиторію.')
para('У core/services розміщені AnalyticsService, CrashReportingService та ScreenTrackingScope. У core/widgets — спільні кнопки, поля, заголовки, аватар та компонування форм. Тести відокремлено від робочого коду; FakeAuthRepository дає змогу перевіряти сценарії без реального Firebase.')
para('Публічний репозиторій проєкту: https://github.com/yuriiDaniuk/sprout. У ньому опубліковано базовий проєкт і погоджені PNG аватарів; поточна реалізація лабораторної № 4 та цей звіт підготовлені локально.')

section('8 Перевірка результатів')
para('20 жовтня 2026 року повторно виконано flutter analyze та flutter test. Аналіз завершився повідомленням «No issues found!», усі 30 тестів пройшли успішно. Результати автоматизованих перевірок наведено в табл. 1.')
para('Таблиця 1 — Результати автоматизованої перевірки',align=WD_ALIGN_PARAGRAPH.CENTER,indent=False,keep=True,before=7,after=4)
t=d.add_table(rows=1,cols=3);t.autofit=False
widths=[4.3,8.2,4.5]
for c,w in zip(t.columns,widths): c.width=Cm(w)
for c,txt in zip(t.rows[0].cells,['Перевірка','Що перевірено','Результат']): c.text=txt
rows=[
('flutter analyze','Статичний аналіз Dart-коду','Без зауважень'),
('flutter test','3 тестові файли з 30 перевірками','30 успішних'),
('Форми й запити','Валідація, видимість пароля, завантаження та захист від повторного надсилання','Успішно'),
('Сеанс і профіль','Навігація, оновлення імені, чернетка аватара, повторна спроба після помилки','Успішно'),
('Граничні сценарії','Часткова реєстрація, незавершений профіль, блокування повернення, вузький екран і шрифт 200%','Успішно'),
('Analytics','Повернення на маршрути та вкладки без дублів від перебудови','Успішно')]
for row in rows:
    for c,txt in zip(t.add_row().cells,row): c.text=txt
for i,row in enumerate(t.rows):
    trpr=row._tr.get_or_add_trPr();cant=OxmlElement('w:cantSplit');trpr.append(cant)
    if i==0:
        repeat=OxmlElement('w:tblHeader');trpr.append(repeat)
    for j,c in enumerate(row.cells):
        c.width=Cm(widths[j]);tcpr=c._tc.get_or_add_tcPr()
        borders=OxmlElement('w:tcBorders')
        for side in ['top','left','bottom','right']:
            b=OxmlElement('w:'+side);b.set(qn('w:val'),'single');b.set(qn('w:sz'),'4');b.set(qn('w:color'),'D9D9D9');borders.append(b)
        tcpr.append(borders)
        sh=OxmlElement('w:shd');sh.set(qn('w:fill'),'E7E6E6' if i==0 else 'FFFFFF');tcpr.append(sh)
        mar=OxmlElement('w:tcMar')
        for side in ['top','left','bottom','right']:
            e=OxmlElement('w:'+side);e.set(qn('w:w'),'80');e.set(qn('w:type'),'dxa');mar.append(e)
        tcpr.append(mar)
        for p in c.paragraphs:
            p.paragraph_format.first_line_indent=Cm(0);p.paragraph_format.line_spacing=1.25
            p.alignment=WD_ALIGN_PARAGRAPH.CENTER if j!=1 else WD_ALIGN_PARAGRAPH.LEFT
            for r in p.runs:r.bold=i==0
para('Ручні перевірки виконувалися на iPhone 17 Pro з iOS 26.5. Підтверджено реєстрацію, вхід і вихід, відновлення сеансу, оновлення імені та аватара, скасування чернетки й актуальне привітання Home. Успішні зміну пароля та відновлення через лист підтверджено користувачем.')
para('Перевірено валідацію, повідомлення про помилки облікових даних і мережі, блокування дубльованих запитів та повторні спроби. Тести також охоплюють клавіатуру, прокручування й збільшений текст. Усі скриншоти застосунку в цьому звіті отримано лише з iPhone 17 Pro.')
para('Акаунт, профіль і телеметрія працюють із Firebase. Рослини та полив залишаються локальними. Cloud Firestore, push-сповіщення й завантаження власних фото відкладені відповідно до винятків методички.')

heading('ВІДПОВІДІ НА КОНТРОЛЬНІ ЗАПИТАННЯ',new=True)
qa=[
('Що означають складові номера версії MAJOR.MINOR.PATCH?', 'MAJOR збільшують для несумісних змін API, MINOR — для додавання сумісної функціональності, PATCH — для сумісних виправлень помилок. Наприклад, у версії 1.2.3 ці складові дорівнюють 1, 2 і 3. Дотримання правил залежить від автора пакета, тому після оновлення потрібні перевірки.'),
('Які діапазони версій задають записи ^1.2.0 та ^0.2.3?', '^1.2.0 означає >=1.2.0 <2.0.0, а ^0.2.3 — >=0.2.3 <0.3.0. Для початкової мажорної версії 0 сумісна верхня межа вужча. Остаточний вибір також обмежується вимогами SDK та інших залежностей.'),
('Як у pubspec.yaml зафіксувати точну версію пакета без автооновлень?', 'Потрібно вказати номер без символу ^ і без діапазону, наприклад firebase_core: 5.0.0. Конкретні розв’язані версії усіх залежностей зберігаються у pubspec.lock. Пакети не оновлюються самі під час запуску застосунку.'),
('Чим відрізняються команди flutter pub get та flutter pub upgrade?', 'pub get отримує залежності та за можливості зберігає сумісні версії з pubspec.lock. pub upgrade намагається вибрати найновіші версії, які дозволені поточними обмеженнями проєкту, і оновлює lock-файл. Обидві команди враховують взаємні обмеження залежностей.'),
('Який офіційний репозиторій є основним джерелом пакетів для Flutter?', 'Основним репозиторієм є pub.dev. На сторінках пакетів наведено опис, версії, підтримувані платформи, документацію й приклади. Перед підключенням слід перевірити сумісність пакета з проєктом.'),
('Як підключити локальний пакет із сусідньої директорії?', 'У dependencies для потрібного пакета задають поле path, наприклад my_package: з вкладеним path: ../my_package. Шлях відраховується від pubspec.yaml застосунку. Після зміни конфігурації виконують flutter pub get.'),
('Як додати залежність із Git?', 'У dependencies для пакета задають git, усередині — url репозиторію та, за потреби, ref гілки, тегу або коміту. Якщо пакет лежить у підкаталозі, вказують також path. Фіксація коміту дає змогу відтворити саме потрібну редакцію коду.'),
('Для чого використовують платформні канали та як працює взаємодія через MethodChannel?', 'Канали дають Dart доступ до нативних API або SDK. Dart і нативний код створюють канал з однаковою назвою; invokeMethod() надсилає назву операції та аргументи, обробник виконує її й повертає результат або помилку. Обмін асинхронний, а значення мають підтримуватися кодеком.'),
('Чим відрізняються помилки PlatformException та MissingPluginException?', 'PlatformException означає, що виклик отримав повідомлення про помилку від платформного обробника. MissingPluginException означає відсутність зареєстрованої реалізації для каналу чи методу. У другому випадку перевіряють підтримку платформи, реєстрацію плагіна та повну перебудову застосунку.'),
('Чому перед підключенням Firebase-плагіна потрібно перевіряти підтримку цільової платформи? Які є альтернативи за відсутності підтримки?', 'Не кожний Firebase-плагін має реалізацію для всіх платформ, тому наявність Dart API ще не гарантує роботу на цільовому пристрої. За відсутності підтримки можна використати інший сервіс, зокрема Amplitude для аналітики чи Sentry для помилок, або доступний REST API. Альтернативи також потрібно перевіряти на сумісність.'),
('Яку роль відіграють firebase_core, firebase_options.dart і виклик Firebase.initializeApp()?', 'firebase_core надає базовий API ініціалізації Firebase. firebase_options.dart містить згенеровані параметри для зареєстрованих платформ. Firebase.initializeApp() створює налаштований екземпляр Firebase; перед роботою інших сервісів потрібно дочекатися завершення цього Future.'),
('Що таке подія та її параметри у Firebase Analytics? Чим автоматично зібрані події відрізняються від подій, які реєструє розробник?', 'Подія описує дію або стан, а параметри уточнюють її контекст. Автоматичні події SDK створює сам за передбачених умов, наприклад для першого запуску чи активності сеансу. Специфічні дії Sprout і переходи між його Flutter-екранами реєструються з коду.'),
('Як зареєструвати власну подію та організувати відстеження переходів між Flutter-екранами?', 'Власну подію передають через FirebaseAnalytics.instance.logEvent(name: ..., parameters: ...). Екрани можна відстежувати через logScreenView() або налаштований observer навігації. У Sprout RouteAware відстежує відкриття й повернення на маршрут, а зміна вкладок окремо викликає AnalyticsService.screen().'),
('Яку інформацію містять звіти Firebase Crashlytics і як вони допомагають знаходити причини помилок?', 'Звіт містить опис винятку, стек викликів, версію застосунку та характеристики середовища. Схожі події об’єднуються в issue з даними про повторюваність. Читабельний стек допомагає знайти файл і рядок, із якого виникла помилка, як у контрольному звіті Sprout.'),
('Чим відрізняються фатальні й нефатальні помилки?', 'Фатальна помилка призводить до аварійного завершення або позначається як критична у звіті Crashlytics. Нефатальна помилка реєструє проблему, після якої застосунок може продовжити роботу. Наприклад, невдалий запит можна обробити повідомленням і дозволити повторну спробу.'),
('Чи завершує застосунок виклик recordError() із fatal: true?', 'Ні. Параметр fatal: true позначає звіт як фатальний, але сам recordError() не припиняє виконання процесу. Реальне аварійне завершення та класифікація запису в системі звітності — різні дії.'),
('Чим відрізняються методи log() та recordError() у Crashlytics?', 'log() додає діагностичний запис у журнал, який може супроводжувати звіт. recordError() реєструє саму помилку зі стеком та додатковою причиною. Виклик лише log() не створює окремого звіту про виняток.'),
('Для чого налаштовують FlutterError.onError та PlatformDispatcher.instance.onError?', 'FlutterError.onError отримує помилки, які перехоплює Flutter під час виконання своїх callback, компонування чи малювання. PlatformDispatcher.instance.onError обробляє необроблені помилки кореневого ізоляту поза цим механізмом. Обидва обробники потрібні для передавання відповідних категорій помилок до Crashlytics.'),
('Які способи автентифікації підтримує Firebase Authentication?', 'Серед способів — email/password, вхід за номером телефону, анонімний вхід, зовнішні провайдери, зокрема Google, Apple, Facebook і GitHub, а також custom token. Набір доступних способів залежить від платформи й конфігурації. У Sprout увімкнено лише погоджений Email/Password.'),
('Чим вхід за email і паролем відрізняється від входу за номером телефону?', 'Email/password перевіряє постійні облікові дані акаунта. Телефонний вхід підтверджує доступ до номера через SMS-код і відповідний credential; звичайна операція зміни пароля до нього не застосовується. Це різні провайдери, які за потреби можна зв’язати з одним користувачем.'),
('Яке призначення Firebase ID token, refresh token, токенів зовнішніх провайдерів і Firebase custom token?', 'ID token — підписаний Firebase токен, що підтверджує особу для сервісів або власного бекенду. Refresh token дозволяє отримувати нові ID-токени без повторного введення пароля. Токени зовнішнього провайдера використовують для отримання Firebase credential. Custom token створює довірений сервер для входу у Firebase, після якого клієнт отримує звичайні токени сеансу.'),
('Для чого використовують зв’язування кількох способів входу з одним обліковим записом?', 'Зв’язування дає користувачу змогу входити різними провайдерами зі збереженням одного uid і спільних даних. Для цього нові облікові дані приєднують до поточного користувача, наприклад через linkWithCredential(). Окрема реєстрація кожним способом без зв’язування може створити різні акаунти.'),
('Які дані профілю зберігає Firebase Authentication?', 'Основні поля — uid, email, displayName, photoURL, номер телефону та дані провайдерів залежно від способу входу й заповнення. Сервіс також має стан підтвердження email та інші атрибути акаунта. Він не є сховищем довільних даних рослин, статистики чи налаштувань застосунку.'),
('Як отримати поточного користувача та змінити його ім’я або URL фотографії?', 'Поточного користувача отримують через FirebaseAuth.instance.currentUser, значення може бути null. Ім’я змінюють методом updateDisplayName(), а посилання на фото — updatePhotoURL(). Після завершення слід оновити дані інтерфейсу через відстеження стану або актуальну модель; зображення при цьому не завантажується у Storage.'),
('Як виконується зміна пароля та чим вона відрізняється від відновлення забутого пароля?', 'Для зміни пароля активного користувача викликають updatePassword(), за потреби після повторної автентифікації. Для забутого пароля sendPasswordResetEmail() надсилає лист із посиланням для встановлення нового значення. У Sprout зміна підтверджується поточним паролем, а відновлення виконується на стандартній сторінці Firebase.'),
('Що означає помилка requires-recent-login і як її опрацювати?', 'Чутлива операція потребує недавнього підтвердження особи, а поточний сеанс такого підтвердження вже не має. Потрібно отримати credential користувача, виконати reauthenticateWithCredential() і повторити операцію або запропонувати повторний вхід. Повторення того самого запиту без підтвердження проблему не усуне.'),
('Для чого використовують Form і GlobalKey<FormState>?', 'Form об’єднує поля, їхню перевірку та стан. GlobalKey<FormState> дає доступ до відповідного FormState, зокрема до validate(), save() і reset(). У Sprout він використовується для перевірки всіх полів перед серверним запитом.'),
('Чому ключ GlobalKey<FormState> не слід створювати заново в методі build()?', 'Новий ключ змінює ідентичність форми під час кожної побудови й може спричинити втрату її стану та повідомлень. Ключ створюють один раз як поле State, а build() використовує вже наявний екземпляр. Це особливо важливо під час зміни busy або показу помилки.'),
('Як працюють TextFormField.validator та FormState.validate()?', 'validator отримує значення поля та повертає null, якщо воно коректне, або текст помилки. FormState.validate() викликає перевірки всіх підключених полів, оновлює їхнє відображення та повертає true лише за відсутності помилок. Після true можна починати асинхронний запит.'),
('Чим локальна валідація введених даних відрізняється від перевірок Firebase Authentication та оброблення помилок запиту?', 'Локальна валідація перевіряє обов’язковість, формат email, політику й підтвердження пароля до звернення до мережі. Firebase перевіряє правильність облікових даних, стан акаунта та серверні обмеження. Навіть валідна форма може отримати помилку мережі або автентифікації, яку потрібно окремо пояснити користувачу.'),
('Навіщо виносити взаємодію з Firebase в окремий клас AuthRepository?', 'Репозиторій відокремлює представлення від SDK та бізнес-логіки, централізує оброблення помилок і модель користувача. Екрани викликають зрозумілі операції signIn(), signUp() та updateProfile(). У тестах реалізацію можна замінити підставною, щоб перевіряти UI без мережі та реальних паролів.'),
('Як інтерфейс повинен відображати виконання асинхронного запиту, його успішне завершення та помилку?', 'Під час запиту показують завантаження, блокують повторне надсилання та небезпечне закриття форми. Після успіху оновлюють дані, переходять на потрібний екран або показують підтвердження. Після помилки відновлюють доступність дій, зберігають введені дані та показують зрозуміле повідомлення з можливістю повторити спробу; перед оновленням State після await перевіряють mounted.')]
for i,(q,a) in enumerate(qa,1):
    para(f'{i}. {q}',bold=True,indent=False,before=7,keep=True,align=WD_ALIGN_PARAGRAPH.LEFT)
    para(a).paragraph_format.keep_together=True

heading('ВИСНОВКИ',new=True)
for text in [
'Під час виконання лабораторної роботи я підключив Sprout до Firebase та замінив демонстраційну автентифікацію справжньою роботою з акаунтами. Реалізував реєстрацію й вхід за email та паролем, відновлення доступу листом, вихід і відновлення сеансу після перезапуску.',
'Я додав редагування імені, вибір одного з восьми HTTPS-аватарів та зміну пароля з повторною перевіркою поточних облікових даних. Зміни профілю відображаються на Home та Profile. У формах реалізував валідацію, стан завантаження, блокування повторного надсилання і зрозумілі повідомлення про помилки.',
'Взаємодію з Firebase я виніс у AuthRepository, а сервіси аналітики та діагностики — у спільні компоненти. Firebase Analytics отримав події використання, а Crashlytics — контрольну нефатальну помилку з читабельним стеком. Статичний аналіз завершився без зауважень, усі 30 автоматизованих тестів пройшли успішно; основні сценарії перевірено на iPhone 17 Pro.',
'У результаті я закріпив навички інтеграції Flutter із Firebase, організації асинхронних операцій, перевірки форм і розділення інтерфейсу та бізнес-логіки. Дані рослин і поливу залишив локальними: хмарна база, push-сповіщення та завантаження власних зображень належать до наступних етапів.'
]:para(text)
d.core_properties.title='Звіт до лабораторної роботи № 4 — Sprout'
d.core_properties.subject='Реалізація автентифікації та інтеграція з Firebase'
d.core_properties.author='Данюк Ю. І.'
d.core_properties.language='uk-UA'
d.save(OUT)
(TMP/'figures.json').write_text(json.dumps(figures,ensure_ascii=False,indent=2))
print(OUT)
print('Paragraphs:',len(d.paragraphs),'Figures:',len(figures),'Questions:',len(qa))
