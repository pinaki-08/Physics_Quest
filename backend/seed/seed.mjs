// Pushes the JSON lesson files in this folder into Firestore.
// Run: npm install && npm run seed
import { readdir, readFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

import { initializeApp } from 'firebase/app';
import { getAuth, signInAnonymously } from 'firebase/auth';
import { doc, getFirestore, setDoc } from 'firebase/firestore';

const firebaseConfig = {
  apiKey: 'AIzaSyCtQEID9WxXxfRK2gDBgRhsCXDhg-OO1lc',
  authDomain: 'physicsquest2026.firebaseapp.com',
  projectId: 'physicsquest2026',
  storageBucket: 'physicsquest2026.firebasestorage.app',
  messagingSenderId: '454918569511',
  appId: '1:454918569511:web:0c46b973883099f7f61802',
};

const lessonsDir = join(dirname(fileURLToPath(import.meta.url)), 'lessons');

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

await signInAnonymously(getAuth(app));

const files = (await readdir(lessonsDir)).filter((f) => f.endsWith('.json'));
for (const file of files) {
  const lesson = JSON.parse(await readFile(join(lessonsDir, file), 'utf8'));
  await setDoc(doc(db, 'lessons', lesson.id), lesson);
  console.log(`seeded lessons/${lesson.id}`);
}

process.exit(0);
