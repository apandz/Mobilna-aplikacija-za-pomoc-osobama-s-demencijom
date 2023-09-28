const functions = require("firebase-functions");
const {firestore} = require("firebase-admin");
const admin = require("firebase-admin");
admin.initializeApp();

const notificationCollection = "notification";

exports.checkNotifications = functions.runWith({
  memory: "512MB",
}).pubsub.schedule("0 14 * * *").onRun(async (context) => {
  const now = admin.firestore.Timestamp.now();

  const query = firestore().collection(
      notificationCollection).where(
      "scheduledTime", "<=", now)
      .where("sent", "==", false).where(
          "cancel", "==", false);
  const tasks = await query.get();

  const jobs = [];

  tasks.forEach(async (snapshot) => {
    const {
      body,
      title,
      data,
      token,
      toBuy,
    } = snapshot.data();

    if (toBuy==false) {
      const job = await admin.messaging().send({
        notification: {
          title: title,
          body: body,
        },
        data: data,
        token: token,
      });

      if (job.length != 0) {
        firestore().
            collection(notificationCollection).
            doc(snapshot.id).
            delete();
      }

      jobs.push(job);
    } else {
      const job = await admin.messaging().send({
        notification: {
          title: title,
          body: body,
        },
        data: data,
        topic: "all",
      });

      if (job.length != 0) {
        const date = new Date();
        date.setDate(date.getDate() + 1);
        firestore().
            collection(notificationCollection).
            doc(snapshot.id).
            update({"scheduledTime": date});
      }

      jobs.push(job);
    }
  });
});
