#!/bin/sh

curl -XPUT localhost:9200/filebeat-cw-queue-\*/_mapping/doc
{
  "properties": {
    "name": { 
      "properties": {
        "last": { 
          "type": "text"
        }
      }
    },
    "user_id": {
      "type": "keyword",
      "ignore_above": 100 
    }
  }