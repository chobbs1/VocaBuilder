import { type ClientSchema, a, defineData } from "@aws-amplify/backend";

const schema = a.schema({
  WordEntry: a
    .model({
      word: a.string().required(),
      definitions: a.string().array().required(),
    })
    .authorization((allow) => [allow.publicApiKey()]),
});

export type Schema = ClientSchema<typeof schema>;

export const data = defineData({
  schema,
  authorizationModes: {
    defaultAuthorizationMode: "apiKey",
    apiKeyAuthorizationMode: {
      expiresInDays: 365,
    },
  },
});
