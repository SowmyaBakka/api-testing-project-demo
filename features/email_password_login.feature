Feature: User login with email and password
  As a registered user
  I want to log into the application using my email and password
  So that I can access my dashboard and manage my account

  # ──────────────────────────────────────────────
  # HAPPY PATH SCENARIOS
  # ──────────────────────────────────────────────

  Scenario: Successful login with valid email and password redirects to dashboard
    Given a registered user exists with email "user@example.com" and password "CorrectPass123"
    And the user is on the login page
    When the user enters "user@example.com" and "CorrectPass123" and submits the login form
    Then the user is redirected to the dashboard
    And a valid authenticated session is created
    And the user can access authenticated pages

  Scenario: Authenticated session persists and grants access to protected pages after login
    Given a registered user has successfully logged in with valid credentials
    When the user navigates to a protected page
    Then the user can access the protected page without being redirected to the login page

  Scenario: Login succeeds when email contains leading or trailing whitespace that is trimmed
    Given a registered user exists with email "user@example.com" and password "CorrectPass123"
    And the user is on the login page
    When the user enters "  user@example.com  " and "CorrectPass123" and submits the login form
    Then the user is redirected to the dashboard
    And a valid authenticated session is created

  Scenario: Email matching during login is case-insensitive
    Given a registered user exists with email "user@example.com" and password "CorrectPass123"
    And the user is on the login page
    When the user enters "USER@EXAMPLE.COM" and "CorrectPass123" and submits the login form
    Then the user is redirected to the dashboard
    And a valid authenticated session is created

  # ──────────────────────────────────────────────
  # NEGATIVE SCENARIOS
  # ──────────────────────────────────────────────

  Scenario: Display error message for incorrect password
    Given a registered user exists with email "user@example.com"
    And the user is on the login page
    When the user enters "user@example.com" and an incorrect password and submits the login form
    Then the login page displays an "Incorrect password" error message
    And no authenticated session is created

  Scenario: Display user not found message for unregistered email
    Given no account exists for email "unknown@example.com"
    And the user is on the login page
    When the user enters "unknown@example.com" and any password and submits the login form
    Then the login page displays a "user not found" message
    And no authenticated session is created

  Scenario: Login fails for a deactivated or suspended account
    Given a registered user account with email "suspended@example.com" is deactivated
    And the user is on the login page
    When the user enters "suspended@example.com" and the correct password and submits the login form
    Then the login page displays a clear message indicating the account is inactive
    And no authenticated session is created

  Scenario: Login fails when cookies are disabled in the browser
    Given the user's browser has cookies disabled
    And the user is on the login page
    When the user enters valid credentials and submits the login form
    Then a clear message is displayed explaining that cookies are required to authenticate
    And no authenticated session is created

  Scenario: Previously issued session cookie cannot restore session after logout
    Given a registered user has logged out and their session has been invalidated
    When an attempt is made to access a protected page using the old session cookie
    Then the user is redirected to the login page
    And no authenticated session is restored

  Scenario: Very long email and password inputs are handled safely without server errors
    Given the user is on the login page
    When the user enters an email exceeding 500 characters and a password exceeding 500 characters and submits the login form
    Then the system handles the input safely without a server error
    And an appropriate validation or rejection message is displayed

  Scenario: SQL injection in email or password field is rejected safely
    Given the user is on the login page
    When the user enters a SQL injection string in the email field and submits the login form
    Then the login attempt is rejected safely
    And no authentication is granted
    And no server error or data leak occurs

  Scenario: Script injection in email or password field does not cause XSS
    Given the user is on the login page
    When the user enters a script injection string in the password field and submits the login form
    Then the input is sanitized or rejected
    And no script is executed in the browser

  # ──────────────────────────────────────────────
  # VALIDATION SCENARIOS
  # ──────────────────────────────────────────────

  Scenario: Inline validation rejects malformed email format and prevents form submission
    Given the user is on the login page
    When the user enters the malformed email "invalid-email" and moves focus away from the email field
    Then an inline validation message indicates the email format is invalid
    And the form cannot be submitted while the email format is invalid

  Scenario: Inline validation rejects email missing domain and prevents form submission
    Given the user is on the login page
    When the user enters the malformed email "user@" and moves focus away from the email field
    Then an inline validation message indicates the email format is invalid
    And the form cannot be submitted while the email format is invalid

  Scenario: Password field is required and form submission is prevented when empty
    Given the user is on the login page
    When the user leaves the password field empty and attempts to submit the login form
    Then the login page displays a required-field validation message for the password
    And the form is not submitted

  Scenario: Both fields empty prevents form submission and surfaces validation messages
    Given the user is on the login page
    When the user leaves both the email and password fields empty and attempts to submit the login form
    Then the login page displays required-field validation messages for both email and password
    And the form is not submitted

  # ──────────────────────────────────────────────
  # AUTHORIZATION SCENARIOS
  # ──────────────────────────────────────────────

  Scenario: Unauthenticated user attempting to access a protected page is redirected to login
    Given an unauthenticated user is not logged in
    When the user attempts to access a protected page directly
    Then the user is redirected to the login page

  Scenario: After successful login the user is redirected back to the originally requested protected page
    Given an unauthenticated user attempts to access a protected page and is redirected to the login page
    When the user enters valid credentials and submits the login form
    Then the user is redirected to the originally requested protected page
    And a valid authenticated session is created

  Scenario: Logout invalidates the session and prevents access to protected pages without reauthentication
    Given a registered user is logged in with a valid session
    When the user logs out
    Then the authenticated session is invalidated
    And attempting to access a protected page redirects the user to the login page

  # ──────────────────────────────────────────────
  # PERFORMANCE SCENARIOS
  # ──────────────────────────────────────────────

  Scenario: Authentication completes within acceptable response time and shows loading feedback
    Given normal network conditions and a registered user with valid credentials
    And the user is on the login page
    When the user submits valid credentials
    Then authentication completes in under 3 seconds
    And a loading spinner or disabled submit button is displayed while authentication is in progress

  # ──────────────────────────────────────────────
  # SOCIAL LOGIN SCENARIOS
  # ──────────────────────────────────────────────

  Scenario: Gmail social login initiates Google OAuth and redirects to dashboard on success
    Given the user is on the login page
    When the user selects the Gmail sign-in option and completes Google authentication successfully
    Then the user is redirected to the dashboard as an authenticated user

  Scenario: Gmail social login with an existing local account links to the existing account
    Given a local account already exists for the Gmail address "user@gmail.com"
    And the user is on the login page
    When the user selects the Gmail sign-in option and completes Google authentication for "user@gmail.com"
    Then the user is logged in to the existing local account
    And no duplicate account is created

  Scenario: User denying permission during Gmail OAuth flow is shown a clear error message
    Given the user is on the login page
    When the user selects the Gmail sign-in option and denies permission during Google authentication
    Then the login page displays a clear message explaining the denial and providing next steps
    And the user remains unauthenticated

  Scenario: Tampering with OAuth redirect parameters does not grant access
    Given an attempt is made to tamper with the OAuth redirect_uri or state parameter
    When the tampered OAuth callback is processed
    Then the authentication is rejected
    And the user is not granted access
    And an appropriate error is displayed

  Scenario: Pop-up blocker does not silently break the OAuth flow
    Given the user's browser has a pop-up blocker enabled
    And the user is on the login page
    When the user selects the Gmail sign-in option and the OAuth popup is blocked
    Then the application displays clear guidance to the user about the blocked popup
    And the user is not left in a broken or unresponsive state

  # ──────────────────────────────────────────────
  # 2FA SCENARIOS
  # ──────────────────────────────────────────────

  Scenario: Valid credentials for 2FA-enabled account triggers the 2FA screen
    Given a registered user exists with 2FA enabled for email "2fa-user@example.com"
    And the user is on the login page
    When the user submits valid email and password for that account
    Then the system displays a 2FA screen requesting a one-time code
    And no authenticated session is created until the 2FA code is verified

  Scenario: Valid 2FA one-time code grants access to the dashboard
    Given a registered user exists with 2FA enabled and has reached the 2FA screen
    When the user enters a valid one-time 2FA code and submits it
    Then the user is granted access to the dashboard
    And a valid authenticated session is created

  Scenario: Invalid 2FA code is rejected with a clear error message
    Given a registered user exists with 2FA enabled
    And the user is on the 2FA screen
    When the user enters an invalid 2FA code and submits it
    Then the system displays a clear error indicating the code is invalid
    And access to the dashboard is denied

  Scenario: Expired 2FA code is rejected with a clear error message
    Given a registered user exists with 2FA enabled
    And the user is on the 2FA screen
    When the user enters an expired 2FA code and submits it
    Then the system displays a clear error indicating the code has expired
    And access to the dashboard is denied

  Scenario: Repeated invalid 2FA attempts trigger rate limiting or lockout
    Given a registered user is on the 2FA screen
    When the user submits invalid 2FA codes repeatedly exceeding the configured threshold
    Then further 2FA submission attempts are temporarily blocked
    And the user is shown a clear message about the temporary block or retry timing

  Scenario: Remember device policy correctly bypasses 2FA on a previously remembered device
    Given a registered user has previously chosen to remember the current device according to policy
    And the user is on the login page using that remembered device
    When the user submits valid email and password
    Then the 2FA step is bypassed according to the remembered-device policy
    And the user is granted access to the dashboard

  # ──────────────────────────────────────────────
  # SECURITY SCENARIOS
  # ──────────────────────────────────────────────

  Scenario: Authentication endpoints and login page are served over HTTPS
    Given the user requests the login page and authentication endpoints
    When the server responds
    Then all pages and endpoints are served over HTTPS
    And insecure HTTP requests are rejected or redirected to HTTPS

  Scenario: Authentication cookies are set with Secure, HttpOnly and appropriate SameSite attributes
    Given a registered user successfully logs in with valid credentials
    When the authenticated session is established
    Then session cookies are set with the Secure flag
    And session cookies are set with the HttpOnly flag
    And session cookies are set with an appropriate SameSite attribute

  Scenario: Rate limiting is enforced after repeated failed login attempts
    Given a user performs multiple consecutive failed login attempts exceeding the configured threshold
    When the threshold is reached
    Then further login attempts are temporarily blocked for that user or IP
    And the user is shown a clear message about the temporary block or retry timing

  Scenario: Session identifier is regenerated after successful authentication to prevent session fixation
    Given a user has a pre-authentication session identifier
    When the user successfully logs in with valid credentials
    Then the session identifier is regenerated
    And the old session identifier is no longer valid

  Scenario: Redirect target after login is validated to prevent open redirect attacks
    Given an attacker attempts to manipulate the post-login redirect URL to an external malicious domain
    When the user successfully logs in
    Then the application only redirects to approved internal domains or paths
    And the external malicious redirect is rejected

  Scenario: Rate limit events do not expose whether an email is registered to prevent user enumeration
    Given a user has reached the login attempt threshold
    When the lockout message is displayed
    Then the message does not reveal whether the email address is registered or not

  Scenario: OAuth tokens and revoked OAuth authorizations prevent future logins
    Given a user has revoked OAuth authorization for the application in their Google account settings
    When the user attempts to log in using Gmail social login
    Then the authentication is rejected
    And the user is shown an appropriate error message

  Scenario: Sensitive data such as passwords and tokens are never exposed in URLs or logs
    Given a registered user submits the login form with valid credentials
    When the authentication request is processed
    Then the password and authentication tokens do not appear in the browser URL
    And the password and tokens are not stored in client-side storage such as localStorage

  # ──────────────────────────────────────────────
  # UX SCENARIOS
  # ──────────────────────────────────────────────

  Scenario: Login page places keyboard focus on the email field on load
    Given the user navigates to the login page
    When the page finishes loading
    Then keyboard focus is automatically placed on the email field

  Scenario: Pressing Enter while focused on a form field submits the login form
    Given the user is on the login page with valid email and password entered
    When the user presses the Enter key while focus is within a form field
    Then the login form is submitted

  Scenario: Password visibility toggle reveals and hides the password temporarily
    Given the user is on the login page with a password entered in the password field
    When the user activates the password visibility toggle
    Then the password becomes visible in the password field
    When the user deactivates the password visibility toggle
    Then the password returns to a masked state

  Scenario: Error messages contain actionable guidance for the user
    Given a registered user enters a correct email but incorrect password
    And the user is on the login page
    When the user submits the login form
    Then the error message displayed contains actionable guidance such as suggesting alternative login options

  Scenario: Loading indicator is visible while authentication is in progress
    Given the user is on the login page with valid credentials entered
    When the user submits the login form and authentication is in progress
    Then a loading spinner is displayed or the submit button is disabled
    And the indicator disappears once authentication completes

  # ──────────────────────────────────────────────
  # ACCESSIBILITY SCENARIOS
  # ──────────────────────────────────────────────

  Scenario: Form fields have accessible labels and ARIA attributes for screen readers
    Given the login page is loaded
    When a screen reader scans the login form
    Then the email field, password field, and submit button are correctly announced with accessible labels and ARIA attributes

  Scenario: Tab order on the login form follows a logical sequence
    Given the login page is loaded
    When the user navigates through the form controls using the Tab key
    Then focus moves in the order of email field, password field, submit button, and social login option

  Scenario: Validation errors are announced to assistive technologies and focus moves to the first invalid field
    Given the user is on the login page
    When the user submits the form with invalid input
    Then validation error messages are announced to assistive technologies
    And focus is moved to the first invalid field

  Scenario: Login process can be completed using only keyboard input
    Given the user is on the login page
    When the user completes the entire login flow using only keyboard input
    Then the user is successfully authenticated and redirected to the dashboard

  Scenario: Login page is usable on small mobile screens with sufficient touch targets
    Given the user accesses the login page on a mobile device with a small screen
    When the login form is displayed
    Then all form fields, buttons, and controls have sufficient size for touch interaction
    And the layout adapts correctly to the small screen viewport

  # ──────────────────────────────────────────────
  # BROWSER COMPATIBILITY SCENARIOS
  # ──────────────────────────────────────────────

  Scenario Outline: Email and password login works correctly on major browsers
    Given a registered user exists with valid credentials
    And the user is using the "<browser>" browser on the latest stable version
    When the user completes the email and password login flow
    Then the user is redirected to the dashboard
    And a valid authenticated session is created

    Examples:
      | browser |
      | Chrome  |
      | Firefox |
      | Safari  |
      | Edge    |

  Scenario Outline: Gmail social login OAuth flow works correctly on major browsers
    Given the user is using the "<browser>" browser on the latest stable version
    And the user is on the login page
    When the user completes the Gmail social login OAuth flow successfully
    Then the user is redirected to the dashboard as an authenticated user

    Examples:
      | browser |
      | Chrome  |
      | Firefox |
      | Safari  |
      | Edge    |

  Scenario: Login and OAuth flows function correctly in private or incognito mode
    Given the user is using the browser in private or incognito mode
    And the user is on the login page
    When the user completes the email and password login flow with valid credentials
    Then the user is redirected to the dashboard
    And a valid authenticated session is created

  Scenario: Login page is not improperly cached and stale pages do not allow unauthenticated access
    Given the user has previously logged out
    When the user navigates back using the browser back button
    Then the login page is not served from cache in a way that allows authenticated access
    And the user is presented with the login page or an appropriate redirect

  Scenario: Third-party cookie blocking or privacy settings do not silently break Gmail OAuth
    Given the user's browser has third-party cookies blocked
    And the user is on the login page
    When the user attempts Gmail social login
    Then the application handles the condition gracefully
    And a clear recovery message or alternative login guidance is displayed to the user

  Scenario: Browser script-blocking extensions do not silently break login functionality
    Given the user has a script-blocking or tracker-blocking browser extension active
    And the user is on the login page
    When essential login functionality is affected by the extension
    Then the application fails gracefully
    And a clear message is displayed to the user explaining the issue

  Scenario: 2FA numeric keypad is triggered on mobile browsers for code entry
    Given the user is on the 2FA screen using a mobile browser such as Safari on iOS or Chrome on Android
    When the 2FA code input field is focused
    Then the numeric keypad is displayed to facilitate easy code entry