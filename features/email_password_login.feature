Feature: User login with email and password
  As a registered user
  I want to log into the application using my email and password
  So that I can access my dashboard and manage my account

  # ─────────────────────────────────────────────
  # FUNCTIONAL SCENARIOS
  # ─────────────────────────────────────────────

  Scenario: Successful login with valid email and password
    Given a registered user exists with email "user@example.com" and password "CorrectPass123"
    And the user is on the login page
    When the user enters the valid email "user@example.com" and password "CorrectPass123"
    And the user submits the login form
    Then the user is redirected to the dashboard
    And a valid authenticated session is created
    And the user can access authenticated pages

  Scenario: Redirect unauthenticated user to login page when accessing a protected page
    Given the user is not logged in
    When the user attempts to access a protected page directly
    Then the user is redirected to the login page

  Scenario: Redirect authenticated user back to originally requested protected page after login
    Given the user is not logged in
    And the user attempts to access a protected page directly
    When the user completes a successful login with valid credentials
    Then the user is redirected to the originally requested protected page

  Scenario: Display error message for incorrect password
    Given a registered user exists with email "user@example.com"
    And the user is on the login page
    When the user enters the registered email "user@example.com" and an incorrect password
    And the user submits the login form
    Then an error message "incorrect password" is displayed on the login page
    And no authenticated session is created

  Scenario: Display user not found message for unregistered email
    Given no account exists for email "unknown@example.com"
    And the user is on the login page
    When the user enters the email "unknown@example.com" and any password
    And the user submits the login form
    Then a "user not found" message is displayed on the login page
    And no authenticated session is created

  Scenario: Inline validation prevents submission when email format is malformed
    Given the user is on the login page
    When the user enters the malformed email "invalid-email" in the email field
    And the user moves focus away from the email field
    Then an inline validation message is displayed indicating the email format is invalid
    And the login form cannot be submitted while the email format is invalid

  Scenario: Password field is required and form submission is prevented when empty
    Given the user is on the login page
    When the user enters a valid email "user@example.com" in the email field
    And the user leaves the password field empty
    And the user attempts to submit the login form
    Then a required-field validation message is displayed for the password field
    And the login form is not submitted

  Scenario: Authentication completes within acceptable response time with loading feedback
    Given a registered user exists with valid credentials
    And the user is on the login page under normal network conditions
    When the user submits valid email and password
    Then a loading spinner or disabled submit button is shown while authentication is in progress
    And authentication completes in under 3 seconds
    And the user is redirected to the dashboard

  Scenario: Gmail social login initiates Google OAuth and grants access on success
    Given the user is on the login page
    When the user selects the Gmail sign-in option
    And the user completes Google authentication successfully
    Then the user is redirected to the dashboard as an authenticated user

  Scenario: Handle user denying permission during Gmail OAuth flow
    Given the user is on the login page
    When the user selects the Gmail sign-in option
    And the user denies permission during the Google authentication flow
    Then an appropriate error or recovery option is displayed on the login page
    And the user remains unauthenticated

  Scenario: Gmail social login links OAuth account to existing registered account by matching email
    Given a registered user exists with email "user@example.com"
    And the user is on the login page
    When the user selects the Gmail sign-in option
    And the user completes Google authentication with the Gmail address "user@example.com"
    Then the OAuth account is linked to the existing registered account according to business rules
    And the user is granted access to the dashboard as an authenticated user

  Scenario: 2FA screen is displayed after valid credentials when 2FA is enabled
    Given a registered user exists with 2FA enabled for email "2fa-user@example.com"
    And the user is on the login page
    When the user submits valid email "2fa-user@example.com" and the correct password
    Then the system displays a 2FA screen requesting a one-time code

  Scenario: Valid 2FA code grants access to the dashboard
    Given a registered user with 2FA enabled is on the 2FA screen
    When the user enters a valid one-time 2FA code and submits it
    Then the user is granted access to the dashboard
    And an authenticated session is created

  Scenario: Invalid or expired 2FA code is rejected with a clear error
    Given a registered user with 2FA enabled is on the 2FA screen
    When the user enters an invalid or expired 2FA code and submits it
    Then a clear error message is displayed indicating the code is invalid or expired
    And access to the dashboard is denied
    And no authenticated session is created

  Scenario: Remember device bypasses 2FA step according to remembered-device policy
    Given a registered user with 2FA enabled has previously chosen to remember the current device
    And the user is on the login page using that remembered device
    When the user submits valid email and password
    Then the 2FA step is bypassed according to the remembered-device policy
    And the user is granted access to the dashboard

  Scenario: Form submission is prevented when email or password exceeds maximum allowed length
    Given the user is on the login page
    When the user enters an email or password that exceeds the maximum allowed length
    And the user attempts to submit the login form
    Then an appropriate validation message is displayed for the field exceeding the limit
    And the login form is not submitted

  Scenario: System handles email address consistently regardless of case
    Given a registered user exists with email "User@Example.com"
    And the user is on the login page
    When the user enters the email "user@example.com" with different casing and the correct password
    And the user submits the login form
    Then the system processes the email according to the business rule for case sensitivity

  # ─────────────────────────────────────────────
  # UX / ACCESSIBILITY SCENARIOS
  # ─────────────────────────────────────────────

  Scenario: Keyboard focus is placed on the email field when the login page loads
    Given the user navigates to the login page
    Then keyboard focus is automatically placed on the email input field

  Scenario: Login form is submitted when the user presses Enter while focus is in a form field
    Given the user is on the login page
    And the user has entered a valid email and password
    When the user presses the Enter key while focus is in a form field
    Then the login form is submitted

  Scenario: Password visibility toggle reveals and hides the password
    Given the user is on the login page
    And the user has entered a password in the password field
    When the user activates the password visibility toggle
    Then the password text becomes visible
    When the user deactivates the password visibility toggle
    Then the password text is masked again

  Scenario: Inline validation messages are displayed near the corresponding invalid fields
    Given the user is on the login page
    When the user submits the form with a malformed email and an empty password
    Then inline validation messages are displayed adjacent to the email and password fields respectively
    And no page layout shift occurs as a result of the validation messages

  Scenario: Error messages are clear, user-friendly, and do not expose sensitive system details
    Given the user is on the login page
    When the user submits invalid credentials
    Then the error message displayed is user-friendly and actionable
    And the error message does not expose sensitive system or database details

  Scenario: Loading indicator and disabled submit button are shown during authentication
    Given the user is on the login page
    When the user submits valid credentials
    Then the submit button is disabled while authentication is in progress
    And a loading indicator is shown while authentication is in progress

  Scenario: All interactive login controls have clear visual affordances and accessible labels
    Given the login page is loaded
    Then the submit button, social login buttons, remember-me checkbox, and password toggle each have descriptive accessible labels
    And all interactive controls have sufficient hit targets and clear visual affordances

  Scenario: Focus moves to the first invalid field and error is indicated after a failed submission
    Given the user is on the login page
    When the user submits the login form with invalid or missing input
    Then keyboard focus moves to the first invalid field
    And the corresponding error message is clearly indicated near that field

  Scenario: Login form is fully operable using keyboard-only navigation
    Given the login page is loaded
    When the user navigates through all interactive controls using only the keyboard
    Then every interactive control on the login form is reachable and operable via keyboard

  Scenario: Screen readers announce form labels, validation errors, and status updates
    Given the login page is loaded
    When the user interacts with the login form
    Then form labels, input states, validation error messages, and loading status updates are properly announced by screen readers

  Scenario: Color contrast for labels, placeholders, and error messages meets accessibility guidelines
    Given the login page is loaded
    Then the color contrast for input labels, placeholder text, and error messages meets WCAG accessibility contrast guidelines

  Scenario: 2FA screen provides clear instructions and displays code validity or timeout information
    Given a registered user with 2FA enabled is on the 2FA screen
    Then the 2FA screen displays clear instructions for entering the one-time code
    And code validity duration or timeout information is shown where applicable

  Scenario: Recovery guidance is shown when Gmail OAuth permission is denied
    Given the user is on the login page
    When the user selects the Gmail sign-in option and denies permission
    Then a clear recovery message is displayed explaining what happened and how the user can proceed

  # ─────────────────────────────────────────────
  # SECURITY SCENARIOS
  # ─────────────────────────────────────────────

  Scenario: Login page and authentication endpoints are served over HTTPS
    Given the user requests the login page and authentication endpoints
    When the server responds
    Then all pages and endpoints are served exclusively over HTTPS

  Scenario: Authentication cookies or tokens are set with Secure, HttpOnly, and SameSite attributes
    Given a user completes a successful login
    When an authenticated session is established
    Then the authentication cookies or tokens are set with the Secure attribute
    And the authentication cookies or tokens are set with the HttpOnly attribute
    And the authentication cookies or tokens are set with an appropriate SameSite attribute

  Scenario: Rate limiting or temporary lockout is enforced after repeated failed login attempts
    Given a user has made consecutive failed login attempts exceeding the configured threshold
    When the user attempts to log in again
    Then further login attempts are temporarily blocked for that user or IP address
    And a clear message is displayed about the temporary block and expected retry timing

  Scenario: Replayed or expired 2FA codes are rejected and no session is created
    Given a registered user with 2FA enabled is on the 2FA screen
    When the user submits a replayed or already-expired 2FA code
    Then the system rejects the code
    And no authenticated session is created

  Scenario: Authentication inputs are protected against SQL injection and XSS attacks
    Given the user is on the login page
    When the user enters a malicious SQL injection or XSS payload in the email or password field
    And the user submits the login form
    Then the system rejects the malicious input safely
    And no unintended action is performed and no script is executed

  Scenario: CSRF protection is in place for authentication-related endpoints
    Given a CSRF token is issued when the login page is loaded
    When a login form submission is made without a valid CSRF token
    Then the server rejects the request and no session is created

  Scenario: Gmail OAuth state parameter is validated to prevent OAuth CSRF attacks
    Given the user initiates the Gmail OAuth login flow
    When the OAuth callback is received
    Then the system validates the state parameter before processing the authentication response
    And an OAuth callback with an invalid or missing state parameter is rejected

  Scenario: A new session identifier is issued after successful authentication
    Given the user has a pre-login session identifier
    When the user completes a successful login
    Then a new session identifier is issued
    And the pre-login session identifier is no longer valid

  Scenario: Remember-me functionality uses secure storage mechanisms and does not store raw passwords
    Given a user selects the remember-me option on the login page
    When the user completes a successful login
    Then no raw password or long-lived credential is stored in insecure storage such as localStorage
    And the remember-me mechanism uses a secure token or cookie per the security policy

  Scenario: Expired authentication tokens or cookies are rejected when accessing protected resources
    Given a user's authentication token or session cookie has expired
    When the user attempts to access a protected page
    Then the server rejects the expired token or cookie
    And the user is redirected to the login page

  Scenario: Google OAuth tokens are validated for signature, issuer, audience, and expiry
    Given the user completes Google authentication in the Gmail OAuth flow
    When the system processes the returned OAuth ID token and access token
    Then the tokens are validated for correct signature, issuer, audience, and expiry
    And a local session is established only when all token validations pass

  Scenario: Authentication error messages align with the organization's account-enumeration security policy
    Given the user is on the login page
    When the user submits credentials for an unregistered email
    Then the error message displayed aligns with the organization's policy for account-enumeration risk
    And sensitive information about account existence is not exposed beyond what the policy permits