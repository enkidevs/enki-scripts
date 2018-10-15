const MongoClient = require("mongodb").MongoClient;

const mongoURL = process.env.MONGODB_URL;

async function verifyDb() {
  const client = await MongoClient.connect(
    mongoURL,
    { useNewUrlParser: true }
  );
  const db = client.db();

  const collections = await db.collections();

  const collectionCounts = await Promise.all(
    collections.map(async collection => [
      collection.collectionName,
      await collection.countDocuments()
    ])
  );

  const [err, success] = verifyCollections(collectionCounts);

  if (success === null) {
    console.log(`Test fails for:`);
    err.forEach(collection => console.log(collection));
  } else {
    console.log(success);
  }
  client.close();
}

function verifyCollections(collectionCounts) {
  let err = null;
  let success = true;

  collectionCounts.forEach(([collectionName, count]) => {
    if (count > 0) {
      err = err
        ? err.concat([[collectionName, count]])
        : [[collectionName, count]];

      success = null;
    }
  });

  if (success !== null) {
    success = `Verified ${
      collectionsCounts.length
    } collections. None had more than 0 records.`;
  }
  return [err, success];
}

verifyDb();
