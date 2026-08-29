// Stub for any external debug helpers that may call this global
window.ff_trigger_firebase_auth = window.ff_trigger_firebase_auth || (async function(){ return null; });

// Replace the values below with your Firebase Web config (safe to be public)
// Example usage: window.__FIREBASE_WEB_CONFIG = { apiKey: '...', authDomain: '...', projectId: '...', storageBucket: '...', messagingSenderId: '...', appId: '...', measurementId: '...' };

window.__FIREBASE_WEB_CONFIG = {
  "apiKey": "REPLACE_WITH_YOUR_API_KEY",
  "authDomain": "REPLACE_WITH_YOUR_PROJECT.firebaseapp.com",
  "projectId": "REPLACE_WITH_YOUR_PROJECT",
  "storageBucket": "REPLACE_WITH_YOUR_PROJECT.appspot.com",
  "messagingSenderId": "REPLACE_WITH_YOUR_SENDER_ID",
  "appId": "REPLACE_WITH_YOUR_APP_ID",
  "measurementId": "REPLACE_WITH_YOUR_MEASUREMENT_ID"
};
