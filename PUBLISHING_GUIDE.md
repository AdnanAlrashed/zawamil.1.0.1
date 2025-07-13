# دليل نشر تطبيق Zwamil

## 📱 خطوات نشر التطبيق على Google Play Store

### 1. تحضير التطبيق للنشر

#### أ. تحديث معلومات التطبيق
```bash
# تحديث اسم التطبيق في pubspec.yaml
name: zawamil
description: تطبيق زوامل - استمع لأفضل الزوامل والأناشيد
version: 1.0.0+1
```

#### ب. إنشاء مفتاح التوقيع (Keystore)
```bash
# إنشاء مفتاح التوقيع
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# كلمة المرور المطلوبة: (احفظها في مكان آمن)
# كلمة مرور Keystore: your_keystore_password
# كلمة مرور Key: your_key_password
```

#### ج. إعداد ملف key.properties
أنشئ ملف `android/key.properties`:
```properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=upload
storeFile=../upload-keystore.jks
```

#### د. تحديث build.gradle
في `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 2. بناء APK للإنتاج

#### أ. تنظيف المشروع
```bash
flutter clean
flutter pub get
```

#### ب. بناء APK
```bash
# بناء APK للإنتاج
flutter build apk --release

# أو بناء App Bundle (مفضل لـ Google Play)
flutter build appbundle --release
```

### 3. إنشاء حساب مطور على Google Play

#### أ. التسجيل
1. اذهب إلى [Google Play Console](https://play.google.com/console)
2. سجل حساب جديد (رسوم 25$ لمرة واحدة)
3. أكمل معلومات الحساب

#### ب. إنشاء تطبيق جديد
1. اضغط "Create app"
2. أدخل اسم التطبيق: "Zwamil"
3. اختر اللغة: العربية
4. اختر نوع التطبيق: App
5. اختر مجاني أو مدفوع

### 4. رفع التطبيق

#### أ. معلومات التطبيق الأساسية
- **اسم التطبيق**: Zwamil
- **الوصف القصير**: تطبيق زوامل - استمع لأفضل الزوامل والأناشيد
- **الوصف الكامل**: 
```
تطبيق Zwamil يوفر لك مجموعة متنوعة من الزوامل والأناشيد الجميلة.

المميزات:
🎵 مجموعة كبيرة من الزوامل
🎤 فنانين موهوبين
📱 واجهة سهلة الاستخدام
🌙 وضع ليلي مريح للعين
🔔 إشعارات للمحتوى الجديد
💾 حفظ المفضلة
📤 مشاركة الزوامل مع الأصدقاء

حمل التطبيق الآن واستمتع بأفضل الزوامل!
```

#### ب. الصور والرسومات
- **أيقونة التطبيق**: 512x512 px
- **لقطة شاشة**: 1080x1920 px (على الأقل 2 صور)
- **صورة مميزة**: 1024x500 px

#### ج. رفع الملف
1. اذهب إلى "Production" في القائمة الجانبية
2. اضغط "Create new release"
3. ارفع ملف APK أو AAB
4. أضف ملاحظات الإصدار

### 5. إعدادات الأمان

#### أ. تغيير كلمة مرور الإدارة
قبل النشر، غيّر كلمة المرور في `lib/utils/admin_config.dart`:
```dart
static const String adminPassword = 'كلمة_المرور_القوية_الجديدة';
```

#### ب. إخفاء معلومات التطوير
- تأكد من إزالة أي رسائل debug
- تأكد من عدم وجود معلومات حساسة في الكود

### 6. مراجعة وإطلاق

#### أ. مراجعة المحتوى
- تأكد من أن جميع الصور والملفات الصوتية مملوكة لك
- تأكد من عدم انتهاك حقوق الملكية الفكرية

#### ب. إرسال للمراجعة
1. اضغط "Review release"
2. أكمل جميع الأقسام المطلوبة
3. أرسل للمراجعة

#### ج. وقت المراجعة
- عادةً 1-3 أيام عمل
- قد يطلب Google معلومات إضافية

### 7. بعد الإطلاق

#### أ. مراقبة الأداء
- استخدم Google Play Console لمراقبة التطبيق
- تابع التقييمات والمراجعات

#### ب. التحديثات
- عند إضافة محتوى جديد، أرسل إشعارات للمستخدمين
- حدث التطبيق بانتظام

## 🔔 نظام الإشعارات

### كيفية عمل الإشعارات:
1. **عند إضافة فنان جديد**: يرسل إشعار "فنان جديد! 🎵"
2. **عند إضافة زامل جديد**: يرسل إشعار "زامل جديد! 🎶"
3. **الإشعارات محلية**: تعمل حتى بدون إنترنت

### إعدادات الإشعارات:
- **القناة**: "Zwamil Notifications"
- **الأولوية**: عالية
- **الاهتزاز**: مفعل

## 📋 قائمة التحقق قبل النشر

- [ ] تغيير كلمة مرور الإدارة
- [ ] اختبار جميع الميزات
- [ ] إنشاء مفتاح التوقيع
- [ ] بناء APK للإنتاج
- [ ] إعداد حساب Google Play
- [ ] تحضير الصور والوصف
- [ ] مراجعة المحتوى
- [ ] إرسال للمراجعة

## 🆘 استكشاف الأخطاء

### مشاكل شائعة:
1. **خطأ في التوقيع**: تأكد من صحة كلمة المرور
2. **رفض المراجعة**: راجع سياسات Google Play
3. **مشاكل في الإشعارات**: تأكد من الأذونات

### دعم فني:
- Google Play Console Help
- Flutter Documentation
- Stack Overflow 