import type { Schema } from "./resource";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  QueryCommand,
  PutCommand,
} from "@aws-sdk/lib-dynamodb";
import { randomUUID } from "crypto";
import { env } from "$amplify/env/addWordHandler";

const ddbClient = new DynamoDBClient();
const docClient = DynamoDBDocumentClient.from(ddbClient);

/**
 * addWordToMyList Lambda handler
 *
 * 1. Receives { word } from the GraphQL mutation
 * 2. Queries the WordEntry table to check if the word exists
 * 3. If found → creates a UserWord record for the authenticated user
 * 4. Returns success/failure response
 */
export const handler: Schema["addWordToMyList"]["functionHandler"] = async (
  event
) => {
  const { word } = event.arguments;
  const normalizedWord = word.trim();

  // Get table names from Amplify environment
  const wordEntryTable = env.WORDENTRY_TABLE_NAME;
  const userWordTable = env.USERWORD_TABLE_NAME;

  // Step 1: Look up the word in the WordEntry (dictionary) table
  const lookupResult = await docClient.send(
    new QueryCommand({
      TableName: wordEntryTable,
      IndexName: "wordIndex",
      KeyConditionExpression: "word = :word",
      ExpressionAttributeValues: {
        ":word": normalizedWord,
      },
      Limit: 1,
    })
  );

  const foundEntry = lookupResult.Items?.[0];

  if (!foundEntry) {
    return {
      success: false,
      message: `Word "${normalizedWord}" not found in dictionary.`,
      word: null,
      definitions: null,
    };
  }

  // Step 2: Create a UserWord record for this user
  const userId = event.identity?.sub ?? "anonymous";
  const now = new Date().toISOString();

  await docClient.send(
    new PutCommand({
      TableName: userWordTable,
      Item: {
        id: randomUUID(),
        word: foundEntry.word,
        definitions: foundEntry.definitions,
        crosswordClues: foundEntry.crosswordClues ?? [],
        relatedWords: foundEntry.relatedWords ?? [],
        addedAt: now,
        owner: userId,
        createdAt: now,
        updatedAt: now,
        __typename: "UserWord",
      },
    })
  );

  // Step 3: Return success
  return {
    success: true,
    message: `Word "${foundEntry.word}" added to your list.`,
    word: foundEntry.word,
    definitions: foundEntry.definitions,
  };
};
