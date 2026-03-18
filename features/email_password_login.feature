Feature: User login with email and password
  As a registered user
  I want to log into the application using my email and password
  So that I can access my dashboard and manage my account

  # ────────────────────────────────────────────
  # FUNCTIONAL SCENARIOS
  # ────────────────────────────────────────────

  @functional @happy_path
  Scenario: Successful login with valid email and password redirects to dashboard
    Given a registered user exists with email "user@example.com" and password "CorrectPass123"
    And the user is on the login page
    When the user enters the valid email and password and submits the form
    Then the user is redirected to the dashboard
    And a valid authenticated session is created
    And the user can access authenticated pages

  @functional @authorization
  Scenario: Unauthenticated user is redirected to login page when accessing a protected page
    Given the user is not logged in
    When the user attempts to access a protected page directly
    Then the user is redirected to the login page

  @functional @authorization
  Scenario: Authenticated user can access a protected page after successful login
    Given a registered user exists with email "user@example.com" and password "CorrectPass123"
    And the user is on the login page
    When the user enters valid credentials and submits the form
    Then the user is redirected to the dashboard
    And the user can access protected pages without being redirected

  @functional @negative
  Scenario: Incorrect password displays error and no session is created
    Given a registered user exists with email "user@example.com"
    And the user is on the login page
    When the user enters the registered email and an incorrect password and submits the form
    Then the login page displays an "incorrect password" error message
    And no authenticated session is created

  @functional @negative
  Scenario: Unregistered email displays user not found message and no session is created
    Given no account exists for the email "unknown@example.com"
    And the user is on the login page
    When the user enters "unknown@example.com" and any password and submits the form
    Then the login page displays a "user not found" message
    And no authenticated session is created

  @functional @validation
  Scenario: Malformed email format prevents form submission with inline validation message
    Given the user is on the login page
    When the user enters the malformed email "invalid-email" and moves focus away from the email field
    Then an inline validation message indicates the email format is invalid
    And the form cannot be submitted while the email format is invalid

  @functional @validation
  Scenario: Empty password field prevents form submission with required field message
    Given the user is on the login page
    When the user leaves the password field empty and attempts to submit the form
    Then the login page displays a required field message for the password
    And the form is not submitted

  @functional @performance
  Scenario: Authentication completes within 3 seconds and shows loading feedback
    Given a registered user with valid credentials exists
    And the user is on the login page under normal network conditions
    When the user submits valid credentials
    Then authentication completes in under 3 seconds
    And a loading spinner or disabled submit button is shown while authentication is in progress

  @functional @two_factor_auth
  Scenario: 2FA screen is triggered for accounts with 2FA enabled after valid credentials
    Given a registered user exists with 2FA enabled for email "2fa-user@example.com"
    And the user is on the login page
    When the user submits valid email and password for that account
    Then the system displays a 2FA screen requesting a one-time code

  @functional @two_factor_auth
  Scenario: Valid 2FA code grants access to the dashboard
    Given a registered user with 2FA enabled is on the 2FA screen after entering valid credentials
    When the user enters a valid 2FA code and submits it
    Then the user is granted access to the dashboard
    And an authenticated session is created

  @functional @two_factor_auth
  Scenario: Invalid or expired 2FA code is rejected with a clear error
    Given a registered user with 2FA enabled is on the 2FA screen
    When the user enters an invalid or expired 2FA code and submits it
    Then the system displays a clear error indicating the code is invalid or expired
    And access to the dashboard is denied

  @functional @two_factor_auth
  Scenario: Remembered device bypasses the 2FA step according to policy
    Given a registered user has previously chosen to remember the current device
    And the user is on the login page using that remembered device
    When the user submits valid email and password
    Then the 2FA step is bypassed according to the remembered device policy
    And the user is granted access to the dashboard

  @functional @social_login
  Scenario: Successful Gmail OAuth login redirects user to the dashboard
    Given the user is on the login page
    When the user selects the Gmail sign-in option and completes Google authentication successfully
    Then the user is redirected to the dashboard as an authenticated user

  @functional @social_login
  Scenario: Denying permission during Gmail OAuth flow leaves user unauthenticated
    Given the user is on the login page
    When the user selects the Gmail sign-in option and denies permission during Google authentication
    Then the login page displays an appropriate error or recovery option
    And the user remains unauthenticated

  @functional @accessibility
  Scenario: Pressing Enter while focused on a form field submits the login form
    Given the user is on the login page
    And the user has entered valid email and password
    When the user presses the Enter key while focus is in a form field
    Then the login form is submitted

  # ────────────────────────────────────────────
  # UX SCENARIOS
  # ────────────────────────────────────────────

  @ux @validation
  Scenario: Inline validation message is displayed immediately when email format is invalid
    Given the user is on the login page
    When the user types "bad-email-format" into the email field and moves focus away
    Then an inline validation message appears next to the email field
    And the message is readable and concise

  @ux
  Scenario: Error messages for login failures are prominent and use plain language
    Given the user is on the login page
    When the user submits incorrect credentials
    Then the error message is prominently displayed on the login page
    And the message uses plain language and indicates next steps where appropriate

  @ux @accessibility
  Scenario: Keyboard focus is placed on the email field when the login page loads
    Given the login page is loaded
    Then keyboard focus is automatically placed on the email field

  @ux
  Scenario: Password visibility toggle reveals and hides the password
    Given the user is on the login page and has entered a password
    When the user activates the password visibility toggle
    Then the password text becomes visible
    When the user deactivates the password visibility toggle
    Then the password returns to a masked state

  @ux
  Scenario: Submit button shows visual feedback while authentication is in progress
    Given the user is on the login page with valid credentials entered
    When the user submits the login form
    Then the submit button is shown as disabled or displays a progress indicator while authentication is in progress

  @ux @social_login
  Scenario: Gmail sign-in button is clearly labeled and visually distinct from email and password controls
    Given the user is on the login page
    Then the Gmail sign-in button is clearly labeled
    And it is visually distinct from the email and password login controls

  @ux
  Scenario: Lockout message explains why access is blocked and when the user can retry
    Given a user has exceeded the maximum number of failed login attempts
    When the user attempts to log in again
    Then a lockout message is displayed in a readable format
    And the message explains why the action is blocked and when the user can retry

  @ux @two_factor_auth
  Scenario: 2FA screen provides clear instructions on where the code was sent and recovery steps
    Given a registered user with 2FA enabled is on the 2FA screen
    Then the screen shows clear instructions about where the one-time code was sent
    And the screen provides guidance on what to do if the code is not received

  # ────────────────────────────────────────────
  # SECURITY SCENARIOS
  # ────────────────────────────────────────────

  @security
  Scenario: Authentication pages and endpoints are served over HTTPS
    Given the user navigates to the login page and authentication endpoints
    When the server responds to the request
    Then all pages and endpoints are served over HTTPS
    And insecure HTTP connections are rejected

  @security
  Scenario: Authentication cookies and tokens are set with secure attributes
    Given a registered user successfully logs in
    When an authenticated session is created
    Then authentication cookies or tokens are set with Secure and HttpOnly attributes
    And the SameSite attribute is set to an appropriate value
    And session tokens are not exposed to JavaScript

  @security
  Scenario: A new session identifier is issued after successful authentication to prevent session fixation
    Given the user has a pre-login session identifier
    And the user is on the login page
    When the user submits valid credentials and authentication succeeds
    Then a new session identifier is issued
    And the pre-login session identifier is invalidated

  @security
  Scenario: Repeated failed login attempts trigger rate limiting and temporary lockout
    Given a user submits consecutive failed login attempts exceeding the configured threshold
    When the threshold is reached
    Then further login attempts are temporarily blocked for that user or IP
    And the user is shown a clear message about the temporary block and retry timing

  @security
  Scenario: Login error messages do not expose sensitive internal details or stack traces
    Given the user is on the login page
    When the user submits invalid credentials
    Then the error message displayed is generic and does not contain stack traces or sensitive internal information

  @security @social_login
  Scenario: Gmail OAuth flow validates state and redirect URI parameters and rejects tampered values
    Given the user initiates the Gmail OAuth login flow
    When the state or redirect URI parameter is tampered or mismatched
    Then the OAuth flow is rejected
    And the user is shown an appropriate error message

  @security @two_factor_auth
  Scenario: 2FA codes expire after the configured interval and cannot be reused
    Given a registered user with 2FA enabled has received a one-time code
    When the user attempts to submit an expired or previously used 2FA code
    Then the submission is rejected with a clear error
    And access to the dashboard is denied

  @security @two_factor_auth
  Scenario: Brute force attempts against the 2FA endpoint are rate limited
    Given a registered user with 2FA enabled is on the 2FA screen
    When the user submits multiple consecutive invalid 2FA codes exceeding the configured threshold
    Then further 2FA submission attempts are temporarily blocked
    And an appropriate error message is displayed

  @security
  Scenario: Inputs on the login page are protected against injection attacks
    Given the user is on the login page
    When the user submits email or password fields containing SQL meta-characters or script tags
    Then the system handles the input safely without causing injection or XSS
    And an appropriate error message is displayed without exposing internal errors

  @security
  Scenario: CSRF protections are in place for authentication related POST endpoints
    Given an authentication related POST endpoint exists
    When a request is submitted without a valid CSRF token
    Then the request is rejected
    And an appropriate error response is returned

  @security
  Scenario: Tampered or expired session cookies do not grant access to protected pages
    Given a user has a tampered or expired session cookie
    When the user attempts to access a protected page
    Then the user is redirected to the login page
    And the invalid session is not honored

  # ────────────────────────────────────────────
  # USABILITY SCENARIOS
  # ────────────────────────────────────────────

  @usability
  Scenario: Login form is readable and usable on different screen sizes and touch devices
    Given the user opens the login page on a mobile device
    Then the form fields are large enough for touch interaction
    And the login form is fully readable and usable on the mobile screen size

  @usability
  Scenario: Login failure guides the user toward recovery options without exposing sensitive account information
    Given the user is on the login page
    When the user submits invalid credentials and authentication fails
    Then the login page provides recovery guidance such as checking credentials or reattempting sign-in
    And no sensitive account information is exposed in the response

  @usability
  Scenario: Session timeout warning is displayed before automatic logout
    Given an authenticated user has an active session approaching the timeout threshold
    When the session timeout is about to occur
    Then a warning is displayed to the user before automatic logout

  @usability @social_login
  Scenario: Gmail sign-in flow clearly indicates navigation behavior before redirecting
    Given the user is on the login page
    When the user views the Gmail sign-in option
    Then it is clearly indicated whether the flow will open a new window or redirect the current tab

  @usability @accessibility
  Scenario: ARIA attributes and visible focus styles are present for assistive technology support
    Given the login page is loaded
    Then ARIA attributes are present on form fields and error message regions
    And visible focus styles are applied to interactive elements
    And validation errors and success messages are announced by assistive technologies

  # ────────────────────────────────────────────
  # BROWSER COMPATIBILITY SCENARIOS
  # ────────────────────────────────────────────

  @browser @cross_browser
  Scenario Outline: Login page and full login flow work correctly on major desktop browsers
    Given the user opens the login page on "<browser>" browser
    When the user completes the full login flow with valid credentials
    Then the user is redirected to the dashboard successfully
    And all UI elements render correctly without clipping or overlapping

    Examples:
      | browser |
      | Chrome  |
      | Firefox |
      | Safari  |
      | Edge    |

  @browser @mobile
  Scenario Outline: Login page and full login flow work correctly on major mobile browsers
    Given the user opens the login page on "<mobile_browser>" mobile browser
    When the user completes the full login flow with valid credentials
    Then the user is redirected to the dashboard successfully
    And all UI elements render correctly on the mobile viewport

    Examples:
      | mobile_browser          |
      | Mobile Safari on iOS    |
      | Chrome on Android       |

  @browser @social_login
  Scenario: Gmail OAuth flow handles popups and redirects consistently across browsers
    Given the user is on the login page in a supported browser
    When the user selects the Gmail sign-in option
    Then the Google OAuth flow is initiated and handles popups or redirects correctly
    And the user is authenticated and redirected to the dashboard upon success

  @browser
  Scenario: Keyboard navigation, Enter to submit, and tab order work consistently across browsers
    Given the user is on the login page in a major browser
    When the user navigates the form using the keyboard Tab key and presses Enter to submit
    Then the tab order follows the expected sequence through form fields
    And pressing Enter submits the login form correctly

  @browser
  Scenario: Browser privacy features blocking third party cookies show graceful error messaging for Gmail OAuth
    Given the user is on the login page in a browser with third-party cookie blocking enabled
    When the user attempts to use Gmail social login
    Then the system either completes the OAuth flow gracefully or displays a clear error message explaining the limitation

  # ────────────────────────────────────────────
  # NEGATIVE SCENARIOS
  # ────────────────────────────────────────────

  @negative @validation
  Scenario: Login attempt with malformed email is rejected and inline validation is shown without form submission
    Given the user is on the login page
    When the user enters a malformed email address and attempts to submit the form
    Then the inline validation message is displayed next to the email field
    And the form is not submitted to the server

  @negative @validation
  Scenario: Login attempt with empty or whitespace-only fields is rejected with required field messages
    Given the user is on the login page
    When the user submits the form with required fields containing only whitespace
    Then required field validation messages are displayed for the affected fields
    And the form is not submitted

  @negative
  Scenario: Extremely long email or password input is handled gracefully with input length limits enforced
    Given the user is on the login page
    When the user enters an extremely long string in the email or password field and submits the form
    Then the system handles the input gracefully without server errors
    And an appropriate validation or error message is displayed

  @negative
  Scenario: Inputs containing special characters or script tags do not cause injection or XSS
    Given the user is on the login page
    When the user submits inputs containing special characters, SQL meta-characters, or script tags
    Then the application sanitizes and escapes the inputs appropriately
    And no injection, XSS, or server error occurs
    And an appropriate error message is displayed to the user

  @negative
  Scenario: Network failure during login is handled gracefully without creating a partial authenticated session
    Given the user is on the login page with valid credentials entered
    When a network failure or timeout occurs during form submission
    Then the login page displays an error or retry option
    And no partial authenticated session is created

  @negative @two_factor_auth
  Scenario: Repeated invalid 2FA submissions are rate limited with appropriate error messaging
    Given a registered user with 2FA enabled is on the 2FA screen
    When the user repeatedly submits invalid 2FA codes exceeding the retry threshold
    Then further 2FA submission attempts are blocked
    And an appropriate error message is displayed indicating the retry threshold has been exceeded
