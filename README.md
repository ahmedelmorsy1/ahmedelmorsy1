<img width="250" align="right" src="https://c.tenor.com/_DOBjnGspYAAAAAM/code-coding.gif">

<h3 align="center">
  Welcome to Ahmed Elmorsy's profile!
  <img src="https://media.giphy.com/media/hvRJCLFzcasrR4ia7z/giphy.gif" width="28">
</h3>

<!-- Typing SVG by DenverCoder1 - https://github.com/DenverCoder1/readme-typing-svg -->
<p align="center">
  <a href="https://github.com/DenverCoder1/readme-typing-svg"><img src="https://readme-typing-svg.herokuapp.com/?lines=Mobile%20app%20developer;Always%20learning%20new%20things&font=Fira%20Code&center=true&width=440&height=45&color=f75c7e&vCenter=true&size=22"></a>
</p> 

- 🏢 I'm a Software Engineer and Flutter Developer
- 👨‍💻 As a programmer, I'm constantly learning and exploring new technologies to improve my skills.
- 💬 Ask me about my experience with Dart, Flutter, C#, and Java, or anything related to mobile app development and backend development.



### Contact Me :

<a href="https://www.linkedin.com/in/ahmed-elmorsy-83a338185/" target="_blank"><img src="https://img.shields.io/badge/-Ahmed%20Elmorsy-0077B5?style=for-the-badge&logo=Linkedin&logoColor=white"/></a>
<a href="https://twitter.com/ahmed_elm0rsy" target="_blank"><img src="https://img.shields.io/badge/-Ahmed%20Elmorsy-0077B5?style=for-the-badge&logo=twitter&logoColor=white"/></a>
<a href="https://t.me/Ahmed_Elmorsy" target="_blank"><img src="https://img.shields.io/badge/-Ahmed%20Elmorsy-0077B5?style=for-the-badge&logo=Telegram&logoColor=white"/></a>


### 🛠 &nbsp;Tech Stack
![Flutter](https://img.shields.io/badge/-Flutter-05122A?style=flat&logo=Flutter)&nbsp;
![Dart](https://img.shields.io/badge/-Dart-05122A?style=flat&logo=Dart&logoColor=563D7C)&nbsp;
![C#](https://img.shields.io/badge/-C%23-239120?style=flat&logo=C%20Sharp&logoColor=white)&nbsp;
![.NET](https://img.shields.io/badge/-.NET-512BD4?style=flat&logo=.NET&logoColor=white)&nbsp;
![Java](https://img.shields.io/badge/-Java-05122A?style=flat&logo=Java)&nbsp;
![Git](https://img.shields.io/badge/-Git-05122A?style=flat&logo=git)&nbsp;
![GitHub](https://img.shields.io/badge/-GitHub-05122A?style=flat&logo=github)&nbsp;
![Visual Studio Code](https://img.shields.io/badge/-Visual%20Studio%20Code-05122A?style=flat&logo=visual-studio-code&logoColor=007ACC)&nbsp;
![Android Studio](https://img.shields.io/badge/-android%20Studio-05122A?style=flat&logo=android-studio&logoColor=007ACC)&nbsp;
![SQL](https://img.shields.io/badge/-SQL-05122A?style=flat&logo=mySQL)&nbsp;
![Firebase](https://img.shields.io/badge/-Firebase-05122A?style=flat&logo=Firebase)&nbsp;
![MongoDB](https://img.shields.io/badge/-MongoDB-05122A?style=flat&logo=MongoDB)&nbsp;
![Python](https://img.shields.io/badge/-Python%20-05122A?style=flat&logo=python)&nbsp;

---

## 🏟️ Pitch Booking Mini-Platform

> فكرة المشروع: إتاحة حجز ملاعب الكرة الخماسية أونلاين، مع لوحة تحكم بسيطة لصاحب الملعب لإدارة المواعيد والمدفوعات.

### ما الذي تم إضافته الآن؟

- **خادم خلفي جاهز للتشغيل (Node.js بدون مكتبات خارجية)** يوفر:
  - إدارة الملاعب (عرض/إضافة ملاعب جديدة).
  - إدارة الحجوزات (إنشاء حجز، عرض الحجوزات، تحديث حالة الحجز).
  - تخزين بسيط في ملفات JSON لسهولة التجربة السريعة.
- **تطبيق Flutter مبدئي** داخل [`frontend/`](frontend) لعرض الملاعب وإرسال الحجوزات والتأكد من المواعيد المتاحة.
- **دليل تشغيل وشرح للـ API** داخل [`backend/README.md`](backend/README.md).
- **قائمة تطوير مقترحة** تكمل التطبيق وتوصلك لنسخة إنتاجية.

### كيف تشغل الخادم؟

```bash
cd backend
npm start
```

الخادم سيعمل على: `http://localhost:4000`

### كيف تشغل تطبيق Flutter؟

```bash
cd frontend
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:4000
```

> يمكن تشغيل نسخة الويب باستخدام `flutter run -d chrome`، أو تحديد عنوان مختلف للخادم عند التشغيل كما هو موضح في دليل الواجهة.

### خطوات مقترحة لتكملة التطبيق

1. **واجهة Flutter أو Web**
   - شاشة عرض الملاعب (قائمة وبحث/فلترة).
   - شاشة تفاصيل الملعب مع المواعيد المتاحة.
   - نموذج حجز متكامل مع التحقق من البيانات.
2. **مصادقة المستخدمين**
   - تسجيل دخول للأدمن لإدارة الملاعب.
   - تسجيل وحجز للمستخدمين (باستخدام JWT أو أي مزود جاهز مثل Firebase Auth).
3. **لوحة تحكم لصاحب الملعب**
   - تقويم مرئي للحجوزات.
   - إمكانية تأكيد/إلغاء الحجوزات مع ملاحظات.
4. **مدفوعات إلكترونية**
   - ربط بوابة دفع (Paymob، Stripe، أو Fawry) مع تغيير حالة الحجز إلى "مدفوع".
5. **تحسين قاعدة البيانات**
   - استبدال ملفات JSON بقاعدة بيانات فعلية (PostgreSQL أو MongoDB).
   - إضافة جداول للمستخدمين، الملاعب، الحجوزات، سجلات الدفع.
6. **مراقبة وجودة**
   - إضافة اختبارات وحدات وتكامل للـ API.
   - تسجيل الأحداث (logging) وتنبيهات للأخطاء.

> جاهز لمساعدتك في أي خطوة من الخطوات السابقة أو إضافة مميزات جديدة (إشعارات واتساب، تتبع تواجد اللاعبين، ...إلخ).




<img align="left" src="https://github-readme-stats.vercel.app/api/top-langs?username=ahmedelmorsy1&show_icons=true&locale=en&layout=compact&theme=radical" alt="most used languages" />
<br>
<a href="https://komarev.com/ghpvc/?username=ahmedelmorsy1&style=for-the-badge">
    <img src="https://komarev.com/ghpvc/?username=ahmedelmorsy1&style=for-the-badge">
</a>
