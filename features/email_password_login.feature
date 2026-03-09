Feature: User login with email and password
  As a registered user
  I want to log into the application using my email and password
  So that I can access my dashboard and manage my account

  # ───────────────────────────────────────────────
  # FUNCTIONAL – Happy Path
  # ───────────────────────────────────────────────

  Scenario: Successful login with valid email and password redirects to dashboard
    Given a registered user exists with email "user@example.com" and password "CorrectPass123"
    And the user is on the login page
    When the user enters the valid email and password and submits the form
    Then the user is redirected to the dashboard
    And a valid authenticated session is created
    And the user can access authenticated pages

  Scenario: Dashboard displays user-specific data after successful login
    Given a registered user exists with email "user@example.com" and password "CorrectPass123"
    And the user is on the login page
    When the user enters the valid email and password and submits the form
    Then the user is redirected to the dashboard
    And the dashboard displays the user's name and account summary

  Scenario: User is redirected to originally requested protected page after login
    Given an unauthenticated user attempts to access a protected page
    Then the user is redirected to the login page
    When the user enters valid credentials and submits the form
    Then the user is redirected to the originally requested protected page

  # ───────────────────────────────────────────────
  # FUNCTIONAL – Negative
  # ───────────────────────────────────────────────

  Scenario: Display error message for incorrect password
    Given a registered user exists with email "user@example.com"
    And the user is on the login page
    When the user enters the registered email and an incorrect password and submits the form
    Then the login page displays an "incorrect password" error message
    And no authenticated session is created

  Scenario: Display user not found message for unregistered email
    Given no account exists for email "unknown@example.com"
    And the user is on the login page
    When the user enters "unknown@example.com" and any password and submits the form
    Then the login page displays a "user not found" message
    And no authenticated session is created

  # ───────────────────────────────────────────────
  # FUNCTIONAL – Validation
  # ───────────────────────────────────────────────

  Scenario: Inline validation prevents malformed email submission
    Given the user is on the login page
    When the user enters the malformed email "invalid-email" and moves focus away from the email field
    Then an inline validation message indicates the email format is invalid
    And the form cannot be submitted while the email format is invalid

  Scenario: Email field is required and submission is prevented when empty
    Given the user is on the login page
    When the user leaves the email field empty and attempts to submit the form
    Then the login page displays a required-field message for the email
    And the form is not submitted

  Scenario: Password field is required and submission is prevented when empty
    Given the user is on the login page
    When the user leaves the password field empty and attempts to submit the form
    Then the login page displays a required-field message for the password
    And the form is not submitted

  Scenario: Form prevents submission when email exceeds maximum allowed length
    Given the user is on the login page
    When the user enters an email that exceeds the maximum allowed length and attempts to submit the form
    Then the login page displays an appropriate validation message for the email field
    And the form is not submitted

  Scenario: Form prevents submission when password exceeds maximum allowed length
    Given the user is on the login page
    When the user enters a password that exceeds the maximum allowed length and attempts to submit the form
    Then the login page displays an appropriate validation message for the password field
    And the form is not submitted

  Scenario: System handles email case sensitivity consistently
    Given a registered user exists with email "User@Example.com"
    And the user is on the login page
    When the user enters "user@example.com" with the correct password and submits the form
    Then the system processes email case sensitivity according to the defined business rule

  # ───────────────────────────────────────────────
  # FUNCTIONAL – Performance
  # ───────────────────────────────────────────────

  Scenario: Authentication completes within acceptable response time with loading feedback
    Given normal network conditions exist and a registered user has valid credentials
    And the user is on the login page
    When the user submits valid credentials
    Then authentication completes in under 3 seconds
    And a loading spinner or disabled submit button is shown while authentication is in progress

  # ───────────────────────────────────────────────
  # FUNCTIONAL – Session Management
  # ───────────────────────────────────────────────

  Scenario: Unauthenticated user is redirected to login page when accessing a protected page
    Given an unauthenticated user is not logged in
    When the user attempts to access a protected page
    Then the user is redirected to the login page

  Scenario: Session timeout after inactivity results in logout and redirect to login page
    Given a registered user is logged in and the session inactivity timeout has elapsed
    When the user attempts to access a protected page
    Then the user is logged out
    And the user is redirected to the login page

  # ───────────────────────────────────────────────
  # FUNCTIONAL – Social Login (Gmail / Google OAuth)
  # ───────────────────────────────────────────────

  Scenario: Gmail social login initiates Google OAuth and grants access on success
    Given the user is on the login page
    When the user selects the Gmail sign-in option and completes Google authentication successfully
    Then the user is redirected to the dashboard as an authenticated user

  Scenario: Handle user denying permission in Gmail OAuth flow
    Given the user is on the login page
    When the user selects the Gmail sign-in option and denies permission during Google authentication
    Then the login flow displays an appropriate error or recovery option
    And the user remains unauthenticated

  Scenario: Gmail social login links to existing account when Gmail address matches
    Given a registered user exists with email "user@example.com"
    And the user is on the login page
    When the user selects the Gmail sign-in option and authenticates with the matching Google account
    Then the OAuth account is associated with the existing registered account per business rules
    And the user is redirected to the dashboard

  # ───────────────────────────────────────────────
  # FUNCTIONAL – Two-Factor Authentication (2FA)
  # ───────────────────────────────────────────────

  Scenario: 2FA is triggered for accounts with 2FA enabled and grants access after valid code
    Given a registered user exists with 2FA enabled for email "2fa-user@example.com"
    And the user is on the login page
    When the user submits the valid email and password for that account
    Then the system displays a 2FA screen requesting a one-time code
    When the user enters a valid 2FA code and submits it
    Then the user is granted access to the dashboard
    And an authenticated session is created

  Scenario: Invalid or expired 2FA code is rejected with a clear error
    Given a registered user exists with 2FA enabled
    And the user is on the 2FA screen after submitting valid credentials
    When the user enters an invalid or expired 2FA code and submits it
    Then the system displays a clear error indicating the code is invalid or expired
    And access to the dashboard is denied
    And no authenticated session is created

  Scenario: Remember device bypasses 2FA step according to configured policy
    Given a registered user has previously chosen to remember the current device according to policy
    And the user is on the login page using that remembered device
    When the user submits valid email and password
    Then the 2FA step is bypassed according to the remembered-device policy
    And the user is granted access to the dashboard

  # ───────────────────────────────────────────────
  # SECURITY
  # ───────────────────────────────────────────────

  Scenario: Login page and authentication endpoints are served over HTTPS
    Given the user requests the login page and authentication endpoints
    When the server responds
    Then all pages and endpoints are served over HTTPS
    And authentication cookies or tokens are set with Secure, HttpOnly and appropriate SameSite attributes

  Scenario: Rate limiting or temporary lockout enforced after repeated failed login attempts
    Given a user performs multiple consecutive failed login attempts exceeding the configured threshold
    When the threshold is reached
    Then further login attempts are temporarily blocked for that user or IP
    And the user is shown a clear message about the temporary block or retry timing

  Scenario: 2FA code submission endpoint is rate-limited to prevent brute-force attacks
    Given a user is on the 2FA screen
    When the user submits multiple consecutive invalid 2FA codes exceeding the configured threshold
    Then further 2FA submission attempts are throttled or blocked
    And the user is shown a clear message about the restriction

  Scenario: Authentication inputs are protected against injection attacks
    Given the user is on the login page
    When the user enters a SQL injection payload in the email field and submits the form
    Then the system rejects the input safely
    And no authenticated session is created
    And no sensitive information is exposed in the response

  Scenario: A new session identifier is issued after successful authentication
    Given a registered user exists with valid credentials
    And the user has a pre-login session identifier
    When the user successfully logs in
    Then a new session identifier is issued
    And the pre-login session identifier is no longer valid

  Scenario: Expired or invalid session tokens are rejected when accessing protected resources
    Given a registered user holds an expired authentication token
    When the user attempts to access a protected page using the expired token
    Then the request is rejected
    And the user is redirected to the login page

  Scenario: Remember-me functionality uses secure storage mechanisms
    Given the user is on the login page
    When the user selects the remember-me option and successfully logs in
    Then the remember-me token is stored using a secure mechanism
    And raw passwords or long-lived credentials are not stored in insecure storage such as localStorage

  Scenario: Google OAuth tokens are validated before establishing a local session
    Given a user completes Google OAuth authentication
    When the application receives the OAuth ID token and access token
    Then the tokens are validated for signature, issuer, audience, and expiry
    And a local session is only established when all validations pass

  Scenario: CSRF protection is in place for authentication-related endpoints
    Given the login form is loaded
    When the system renders the form
    Then a CSRF token or equivalent protection mechanism is present in the authentication request

  Scenario: Failed login attempts and security events are logged for audit purposes
    Given a registered user with email "user@example.com" exists
    And the user is on the login page
    When the user submits an incorrect password
    Then the failed login attempt is logged with a timestamp and source identifier

  Scenario: Login endpoints enforce secure response headers
    Given the user requests the login page
    When the server responds
    Then the response includes security headers such as Content-Security-Policy and X-Frame-Options

  # ───────────────────────────────────────────────
  # UX / ACCESSIBILITY
  # ───────────────────────────────────────────────

  Scenario: Keyboard focus is placed on the email field when the login page loads
    Given the login page is loaded
    Then keyboard focus is automatically placed on the email field

  Scenario: Pressing Enter while focus is in a form field submits the login form
    Given the user is on the login page
    And the user has entered a valid email and password
    When the user presses Enter while focus is in a form field
    Then the login form is submitted

  Scenario: Password visibility toggle reveals and hides the password
    Given the user is on the login page with a password entered in the password field
    When the user activates the password visibility toggle
    Then the password text becomes visible
    When the user deactivates the password visibility toggle
    Then the password returns to masked state

  Scenario: Error messages are clear, user-friendly, and do not expose sensitive details
    Given a registered user exists with email "user@example.com"
    And the user is on the login page
    When the user enters the registered email with an incorrect password and submits the form
    Then the displayed error message is clear and actionable
    And the error message does not expose sensitive system details

  Scenario: Inline validation messages are displayed near the corresponding fields
    Given the user is on the login page
    When the user enters a malformed email and leaves the password empty and attempts to submit the form
    Then an inline validation message is displayed adjacent to the email field
    And an inline validation message is displayed adjacent to the password field

  Scenario: Loading indicators provide clear feedback while authentication is in progress
    Given a registered user exists with valid credentials
    And the user is on the login page
    When the user submits valid credentials
    Then a loading spinner or disabled submit button is displayed while authentication is in progress
    And the loading indicator is removed once authentication completes

  Scenario: Clicking or tapping an input label focuses the corresponding input field
    Given the user is on the login page
    When the user clicks the label for the email field
    Then focus is moved to the email input field
    When the user clicks the label for the password field
    Then focus is moved to the password input field

  Scenario: All interactive controls have clear visual affordances and accessible labels
    Given the login page is loaded
    Then the submit button, social login buttons, remember-me checkbox, and password toggle each have a descriptive accessible label
    And each control has a sufficient hit target size and a clear visual affordance

  Scenario: Focus moves to the first invalid field after a failed form submission
    Given the user is on the login page
    When the user submits the form with invalid or missing fields
    Then focus is moved to the first invalid field
    And the associated error message is clearly indicated for that field

  Scenario: Form control states have distinct and consistent visual styles
    Given the login page is loaded
    When the user interacts with the email and password fields
    Then the focused, error, and disabled states of the form controls are visually distinct and consistent

  Scenario: Gmail OAuth flow provides guidance when pop-ups are blocked or third-party cookies are restricted
    Given the user is on the login page
    When the user selects the Gmail sign-in option and the browser blocks the OAuth pop-up or restricts third-party cookies
    Then the login page displays fallback guidance explaining how to proceed
