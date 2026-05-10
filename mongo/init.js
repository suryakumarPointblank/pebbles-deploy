// Runs once on first container start (when data volume is empty).
// MONGO_INITDB_ROOT_USERNAME / PASSWORD are set via docker-compose env.

db = db.getSiblingDB(process.env.MONGO_DB_NAME || 'pebbles');

db.createUser({
    user: process.env.MONGO_APP_USER,
    pwd:  process.env.MONGO_APP_PASSWORD,
    roles: [{ role: 'readWrite', db: process.env.MONGO_DB_NAME || 'pebbles' }]
});

db.createCollection('_init');
