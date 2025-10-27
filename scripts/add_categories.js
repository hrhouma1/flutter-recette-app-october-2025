const admin = require('firebase-admin');
const serviceAccount = require('../service-account-key.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

const categories = [
  { name: 'Breakfast', icon: '🍳', color: 'FFE8B4' },
  { name: 'Lunch', icon: '🍱', color: 'FFC4E1' },
  { name: 'Dinner', icon: '🍽️', color: 'C4E1FF' },
  { name: 'Desserts', icon: '🍰', color: 'FFD4D4' },
  { name: 'Appetizers', icon: '🥗', color: 'D4FFD4' },
  { name: 'Soups', icon: '🍲', color: 'FFE4C4' },
  { name: 'Beverages', icon: '🥤', color: 'E4C4FF' },
  { name: 'Snacks', icon: '🍿', color: 'FFFACD' },
  { name: 'Vegetarian', icon: '🥬', color: 'C8E6C9' },
  { name: 'Seafood', icon: '🦐', color: 'B3E5FC' },
  { name: 'Pasta', icon: '🍝', color: 'FFCCBC' },
  { name: 'Pizza', icon: '🍕', color: 'FFE0B2' },
];

async function addCategories() {
  console.log('🔧 Connexion à Firestore...');
  
  try {
    const batch = db.batch();
    
    categories.forEach((category) => {
      const docRef = db.collection('categories').doc();
      batch.set(docRef, category);
    });
    
    await batch.commit();
    
    console.log('✅ 12 catégories ajoutées avec succès!');
    
    // Vérification
    const snapshot = await db.collection('categories').get();
    console.log(`📊 Total: ${snapshot.size} catégories dans Firestore`);
    
    process.exit(0);
  } catch (error) {
    console.error('❌ ERREUR:', error);
    process.exit(1);
  }
}

addCategories();

