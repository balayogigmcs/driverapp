importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyAtedTYdh2b484usx8sIa1JELhOY7vOIJM",
      authDomain: "cccc-4b8a5.firebaseapp.com",
      databaseURL: "https://cccc-4b8a5-default-rtdb.firebaseio.com",
      projectId: "cccc-4b8a5",
      storageBucket: "cccc-4b8a5.appspot.com",
      messagingSenderId: "185150577423",
      appId: "1:185150577423:web:1609a142ee2dd704357c7a",
      measurementId: "G-XB7PHQ9P2Q"
});
// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((m) => {
  console.log("onBackgroundMessage", m);
});