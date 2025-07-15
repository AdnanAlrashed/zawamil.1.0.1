// notificationServer.js
// سيرفر Node.js بسيط لإرسال إشعارات جماعية عبر FCM باستخدام Service Account

const express = require('express');
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const app = express();
app.use(express.json());

// نقطة استقبال طلب الإشعار من تطبيق المدير
app.post('/send-notification', (req, res) => {
  const { title, body } = req.body;
  const message = {
    notification: { title, body },
    topic: 'all_users'
  };
  admin.messaging().send(message)
    .then((response) => {
      res.status(200).send({ success: true, response });
    })
    .catch((error) => {
      res.status(500).send({ success: false, error });
    });
});

app.listen(3000, () => {
  console.log('Notification server running on port 3000');
}); 