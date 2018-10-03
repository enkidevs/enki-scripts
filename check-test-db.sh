#!/bin/bash

# get collections list
collections=`mongo $MONGODB_URL --quiet --eval 'db.getCollectionNames().join(",")' | sed 's/,/ /g' | tr -d '\r'`

nonzeroCollections=""
collectionsCount=0

for col in $collections
do
    prefix="${col:0:6}"
    collectionsCount=$((collectionsCount + 1))
    if [ $prefix != "system" ]; then
        # get documents count
        query="db.getCollection('$col').count()"
        count=`mongo $MONGODB_URL --quiet --eval $query | tr -d '\r'`
        # accumulate all non-empty ones
        if [ "$count" != "0" ]; then
            nonzeroCollections+="$col: $count\n"
        fi
    fi
done

if [ -z "$nonzeroCollections" ]; then
    echo "Verified ${collectionsCount} collection. None had more than 0 records."
    exit 0
fi

echo -e "Test fails for: \n${nonzeroCollections}"
exit 1


# docker exec -it --env MONGODB_URL="${MONGODB_URL}" "${MONGO_CONTAINER}" curl https://raw.githubusercontent.com/enkidevs/enki-scripts/master/check-test-db.sh | MONGODB_URL="$MONGODB_URL" sh