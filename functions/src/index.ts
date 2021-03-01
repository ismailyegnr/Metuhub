import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

const db = admin.firestore();
const fcm = admin.messaging();

export const taskRunner = functions.runWith({memory: '2GB'}).pubsub.schedule('* * * * *').onRun(async context => {
  const date = new Date(Date.now() + 60*60*1000);
  const timestamp = admin.firestore.Timestamp.fromDate(date);

  const meetingQuery = db.collection('meetings').where('date','<=',timestamp).where('notification',"==","scheduled");
  const eventQuery = db.collection("events").where('date','<=',timestamp).where('notification',"==","scheduled");

  const meetingTasks = await meetingQuery.get();
  const eventTasks = await eventQuery.get();

  const jobs: Promise<any>[] = [];

  meetingTasks.forEach(snapshot => {
    const doc = snapshot.data();

    const job = sendToTopic(doc).then(() => snapshot.ref.update({notification : "completed"})).catch((err) => snapshot.ref.update({notification: "error"}) );

    jobs.push(job);

  
  });

  eventTasks.forEach(snapshot => {
    const doc = snapshot.data();

    const job = sendToTopic(doc).then(() => snapshot.ref.update({notification : "completed"})).catch((err) => snapshot.ref.update({notification: "error"}) );

    jobs.push(job);
  });

  return await Promise.all(jobs);
});

function sendToTopic(doc: FirebaseFirestore.DocumentData){
  const message = doc;
  const docType = message.club == null ? "event" : "meeting";



  const payload: admin.messaging.MessagingPayload = {
    notification: {
      title: docType == "event" ? "Etkinlik başlıyor" : "Toplantı başlıyor",
      body: `${message.name}'in başlamasına bir saatten daha az kaldı.`,
      click_action: 'FLUTTER_NOTIFICATION_CLICK' // required only for onResume or onLaunch callbacks
    },
    data: {
      type: docType,
      id: message.id
    }
    
  }

  return fcm.sendToTopic(`${message.id}`,payload);
}




