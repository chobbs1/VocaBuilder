import { defineAuth } from "@aws-amplify/backend";

/**
 * Cognito User Pool configuration for VocaBuilder.
 * - Email-based sign-in
 * - Email verification required
 */
export const auth = defineAuth({
  loginWith: {
    email: true,
  },
});
