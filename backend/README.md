# VocaBuilder Backend

Backend for the VocaBuilder app, built with **AWS Amplify Gen 2**.

See the frontend [here](https://github.com/chobbs1/VocaBuilder)

## Tech Stack

| Service | Purpose |
|---------|---------|
| AWS Amplify Gen 2 | Orchestration & deployment |
| Amazon DynamoDB | NoSQL database (auto-provisioned) |
| AWS AppSync | GraphQL API (auto-generated) |
| Amazon Cognito | Authentication (email/password) |

## Project Structure

```
amplify/
├── auth/
│   └── resource.ts        # Cognito user pool config
├── data/
│   └── resource.ts        # Data models → DynamoDB tables + AppSync API
└── backend.ts             # Wires auth + data together
```

## Prerequisites

- **Node.js** ≥ 18
- **AWS Account** with credentials configured
- **AWS CLI** configured (`aws configure`)

## Getting Started

```bash
# Install dependencies
npm install

# Start local cloud sandbox (deploys a personal dev stack)
npm run sandbox
```

The sandbox command will:
1. Deploy a personal Amplify backend to your AWS account
2. Create real DynamoDB tables & AppSync API in a sandbox environment
3. Generate `amplify_outputs.json` — used by the frontend to connect
4. **Hot-reload** — changes to `amplify/` files auto-deploy

## Data Models

### VocabularySet
A collection of vocabulary words owned by a user.

| Field | Type | Required |
|-------|------|----------|
| name | String | ✅ |
| description | String | |
| language | String | ✅ |
| words | HasMany → VocabularyWord | |

### VocabularyWord
An individual term within a set, with review tracking.

| Field | Type | Required |
|-------|------|----------|
| term | String | ✅ |
| definition | String | ✅ |
| exampleSentence | String | |
| timesReviewed | Integer | (default: 0) |
| timesCorrect | Integer | (default: 0) |
| lastReviewedAt | DateTime | |

## Local setup

### Setup AWS Credentials
  ```bash
  sudo pacman -S aws-cli-v2 docker-compose docker                                                                                                                                  
```


## Docker Container Setup

```bash
docker compose up -d
```

## Useful Commands



```bash
# Start sandbox (local dev)
npm run sandbox

# Tear down sandbox resources
npm run sandbox:delete
```

## How Local Testing Works

Amplify Gen 2 uses a **cloud sandbox** model — it provisions real AWS resources in an isolated per-developer stack. This means:

- You test against **real** DynamoDB, AppSync, and Cognito (no emulators)
- Each developer gets their own isolated stack
- Changes hot-reload in ~15-20 seconds
- Sandbox resources are cheap and can be torn down with `npm run sandbox:delete`