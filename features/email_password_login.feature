Feature: User login with email and password
  As a registered user
  I want to log into the application using my email and password
  So that I can access my dashboard and manage my account

  # ─────────────────────────────────────────────
  # FUNCTIONAL TESTING
  # ─────────────────────────────────────────────

  Scenario: Successful login with valid email and password redirects to dashboard
    Given a registered user exists with email "user@example.com" and password "CorrectPass123"
    And the user is on the login page
    When the user enters the valid email and password and submits the form
    Then the user is redirected to the dashboard
    And a valid authenticated session is created
    And the user can access authenticated pages

  Scenario: Authenticated session allows access to protected pages after login
    Given a registered user has successfully logged in with valid credentials
    When the user navigates to a protected page
    Then the protected page is displayed without redirection

  Scenario: Login is blocked when email format is invalid
    Given the user is on the login page
    When the user enters the malformed email "invalid-email" and attempts to submit the form
    Then the form submission is prevented
    And an inline validation message indicates the email format is invalid

  Scenario: Login is blocked when password field is empty
    Given the user is on the login page
    When the user enters a valid email but leaves the password field empty and attempts to submit the form
    Then the form submission is prevented
    And the login page displays a required-field message for the password

  Scenario: Incorrect password displays error and does not create a session
    Given a registered user exists with email "user@example.com"
    And the user is on the login page
    When the user enters the registered email with an incorrect password and submits the form
    Then the login page displays an "incorrect password" error message
    And no authenticated session is created

  Scenario: Unregistered email displays user not found message and does not create a session
    Given no account exists for email "unknown@example.com"
    And the user is on the login page
    When the user enters "unknown@example.com" with any password and submits the form
    Then the login page displays a "user not found" message
    And no authenticated session is created

  Scenario: Gmail sign-in option initiates the Google OAuth flow
    Given the user is on the login page
    When the user selects the Gmail sign-in option
    Then the Google OAuth authentication flow is initiated

  Scenario: Successful Gmail OAuth login redirects user to dashboard
    Given the user is on the login page
    When the user selects the Gmail sign-in option and completes Google authentication successfully
    Then the user is redirected to the dashboard as an authenticated user

  Scenario: Denying permission during Gmail OAuth returns user to login page unauthenticated
    Given the user is on the login page
    When the user selects the Gmail sign-in option and denies permission during Google authentication
    Then the login page displays an appropriate error or recovery option
    And the user remains unauthenticated

  Scenario: 2FA screen is displayed after valid credentials for a 2FA-enabled account
    Given a registered user exists with 2FA enabled for email "2fa-user@example.com"
    And the user is on the login page
    When the user submits the valid email and password for that account
    Then the system displays a 2FA screen requesting a one-time code

  Scenario: Valid 2FA code grants access to the dashboard
    Given a registered user with 2FA enabled has reached the 2FA verification screen
    When the user enters a valid 2FA code and submits it
    Then the user is granted access to the dashboard
    And an authenticated session is created

  Scenario: Invalid or expired 2FA code is rejected with a clear error
    Given a registered user with 2FA enabled is on the 2FA verification screen
    When the user enters an invalid or expired 2FA code and submits it
    Then the system displays a clear error indicating the code is invalid or expired
    And access to the dashboard is denied

  Scenario: Remembered device bypasses 2FA on subsequent login
    Given a registered user has previously chosen to remember the current device
    And the user is on the login page using that remembered device
    When the user submits valid email and password
    Then the 2FA step is bypassed according to the remembered-device policy
    And the user is granted access to the dashboard

  Scenario: Unauthenticated user is redirected to login page when accessing a protected page
    Given an unauthenticated user is not logged in
    When the user attempts to access a protected page directly
    Then the user is redirected to the login page

  Scenario: After successful login user is returned to the originally requested protected page
    Given an unauthenticated user attempted to access a protected page and was redirected to the login page
    When the user successfully logs in with valid credentials
    Then the user is redirected to the originally requested protected page

  Scenario: Loading indicator is displayed while authentication is in progress
    Given a registered user is on the login page
    When the user submits valid credentials
    Then a loading spinner or disabled submit button is shown while authentication is in progress
    And the user is redirected to the dashboard once authentication completes

  # ─────────────────────────────────────────────
  # PERFORMANCE TESTING
  # ─────────────────────────────────────────────

  Scenario: Authentication completes within 3 seconds under normal network conditions
    Given a registered user exists with valid credentials
    And the user is on the login page under normal network conditions
    When the user submits valid credentials
    Then authentication completes in under 3 seconds
    And the user is redirected to the dashboard

  # ─────────────────────────────────────────────
  # UX TESTING
  # ─────────────────────────────────────────────

  Scenario: Keyboard focus is placed on the email field when the login page loads
    Given the login page is loaded
    Then keyboard focus is automatically placed on the email field

  Scenario: Pressing Enter while focused on a form field submits the login form
    Given the user is on the login page with valid email and password entered
    When the user presses the Enter key while focus is on a form field
    Then the login form is submitted

  Scenario: Inline email validation appears immediately after focus leaves the email field
    Given the user is on the login page
    When the user enters a malformed email "invalid-email" and moves focus away from the email field
    Then an inline validation message appears immediately indicating the email format is invalid

  Scenario: Password visibility toggle reveals and re-masks the password
    Given the user is on the login page with a password entered in the password field
    When the user activates the password visibility toggle
    Then the password text becomes visible
    When the user deactivates the password visibility toggle
    Then the password returns to masked state

  Scenario: Error messages are clear and user-friendly with actionable guidance
    Given the user is on the login page
    When the user submits incorrect credentials
    Then the error message displayed is clear, user-friendly, and indicates actionable next steps

  Scenario: Gmail sign-in button is visually distinct and correctly labeled with Google branding
    Given the user is on the login page
    Then the Gmail sign-in button is visually distinct and labeled correctly with the Google or Gmail brand

  Scenario: Login form fields and buttons have sufficient touch targets for mobile usage
    Given the user is on the login page on a mobile device
    Then form fields and buttons have sufficient touch target sizes and spacing for mobile interaction

  Scenario: Visual loading and success states are communicated during authentication
    Given a registered user is on the login page
    When the user submits valid credentials
    Then the loading state is visually communicated via a spinner or disabled button
    And upon success the user is redirected to the dashboard in a timely manner

  Scenario: Focus order and visual focus indicators follow a logical tab sequence
    Given the login page is loaded
    When the user navigates through the form using the Tab key
    Then the focus moves in a logical sequence through email, password, and submit button
    And each focused element has a visible focus indicator

  # ─────────────────────────────────────────────
  # SECURITY TESTING
  # ─────────────────────────────────────────────

  Scenario: Login page and authentication endpoints are served over HTTPS
    Given the user requests the login page and authentication endpoints
    When the server responds
    Then all pages and endpoints are served over HTTPS without mixed-content issues

  Scenario: Authentication cookies are set with Secure, HttpOnly and SameSite attributes
    Given a registered user successfully logs in
    When the authenticated session is established
    Then authentication cookies or tokens are set with Secure, HttpOnly, and appropriate SameSite attributes

  Scenario: Session is invalidated on logout and cannot be reused
    Given a registered user is logged in with an active session
    When the user logs out
    Then the session is invalidated
    And the session cookie cannot be reused to access authenticated pages

  Scenario: Rate limiting is enforced after repeated failed login attempts
    Given a user performs consecutive failed login attempts exceeding the configured threshold
    When the threshold is reached
    Then further login attempts are temporarily blocked for that user or IP
    And the user is shown a clear message about temporary blocking or retry timing

  Scenario: Expired 2FA codes are rejected after the configured validity period
    Given a registered user with 2FA enabled has received a one-time code
    When the user attempts to use the code after its configured validity period has elapsed
    Then the system rejects the code with a clear expiry error message

  Scenario: Gmail OAuth flow validates CSRF state parameter and redirect URIs
    Given the user initiates the Gmail OAuth login flow
    When the OAuth callback is received
    Then the CSRF state parameter is validated
    And the redirect URI is validated to prevent open redirect vulnerabilities

  Scenario: User-supplied input is handled safely to prevent injection attacks
    Given the user is on the login page
    When the user enters SQL metacharacters or HTML tags in the email or password fields and submits the form
    Then the application handles the input safely without server errors
    And no injection attack is executed

  Scenario: Authentication failures do not leak sensitive information in error responses
    Given the user submits invalid credentials
    When the server responds with an authentication failure
    Then the error response does not contain stack traces, internal error codes, or other sensitive information

  Scenario: Google OAuth tokens are not stored in insecure client storage
    Given a user successfully logs in via Gmail OAuth
    When the session is established
    Then OAuth tokens issued by Google are not stored in insecure client-side storage such as localStorage or sessionStorage without appropriate safeguards

  Scenario: Overly long or malformed inputs are handled safely without server errors
    Given the user is on the login page
    When the user submits an excessively long email or password, or inputs containing special characters
    Then the application handles the input gracefully without causing server errors
    And appropriate input length limits are enforced on both client and server

  # ─────────────────────────────────────────────
  # USABILITY AND ACCESSIBILITY TESTING
  # ─────────────────────────────────────────────

  Scenario: Form labels and placeholders are descriptive and each input has an accessible label
    Given the login page is loaded
    Then each input field has a descriptive label associated with it
    And placeholder text provides additional guidance where applicable

  Scenario: Password input supports copy and paste and the visibility toggle is accessible to screen readers
    Given the user is on the login page
    When the user attempts to paste a password into the password field
    Then the paste action is accepted
    And the password visibility toggle is accessible and operable via screen reader

  Scenario: Login flow meets accessibility standards with ARIA attributes and semantic HTML
    Given the login page is loaded
    Then the form uses proper semantic HTML and ARIA attributes
    And screen readers can correctly announce fields, error messages, and buttons

  Scenario: Error messages are announced to assistive technologies when they appear
    Given the user is on the login page
    When a validation error or authentication error message appears
    Then the error message is announced to assistive technologies such as screen readers

  Scenario: Login page has sufficient color contrast and does not rely solely on color to convey errors
    Given the login page is displayed
    Then all text and interactive elements meet the minimum color contrast ratio requirements
    And errors are conveyed using text or icons in addition to color

  Scenario: Remembered device and stay signed in options are clearly explained to the user
    Given the user is on the login page
    When the user views the remembered-device or stay-signed-in option
    Then the option includes a clear description of its security implications

  Scenario: Session timeout and automatic logout behaviors are communicated to the user
    Given a user is logged in with an active session approaching the session timeout limit
    When the session is about to expire or has expired
    Then the user is notified of the upcoming or completed automatic logout

  # ─────────────────────────────────────────────
  # BROWSER TESTING
  # ─────────────────────────────────────────────

  Scenario Outline: Login functionality works correctly on major desktop browsers
    Given the user is accessing the login page on "<browser>" latest stable version
    And a registered user exists with valid credentials
    When the user enters valid email and password and submits the form
    Then the user is redirected to the dashboard
    And the authenticated session is created successfully

    Examples:
      | browser         |
      | Chrome          |
      | Firefox         |
      | Microsoft Edge  |
      | Safari          |

  Scenario Outline: Login functionality works correctly on major mobile browsers
    Given the user is accessing the login page on "<mobile_browser>"
    And a registered user exists with valid credentials
    When the user enters valid email and password and submits the form
    Then the user is redirected to the dashboard
    And the login page is responsive and correctly displayed on the mobile device

    Examples:
      | mobile_browser         |
      | Chrome on Android      |
      | Safari on iOS          |

  Scenario: Gmail OAuth flow and redirect handling work across supported browsers
    Given the user is accessing the login page on a supported browser
    When the user selects the Gmail sign-in option and completes Google OAuth authentication
    Then the OAuth pop-up or redirect is handled correctly
    And the user is redirected to the dashboard as an authenticated user

  Scenario: Keyboard navigation and accessibility features work consistently across major browsers
    Given the user is accessing the login page on a major browser
    When the user navigates the login form using the keyboard
    Then focus order, focus indicators, and Enter-key form submission work consistently

  Scenario: Cookie and session behavior is consistent across major browsers
    Given a registered user logs in on different major browsers
    When the authenticated session is established in each browser
    Then cookies, session storage behavior, and login state are consistent and do not result in unexpected login states

  # ─────────────────────────────────────────────
  # NEGATIVE TESTING
  # ─────────────────────────────────────────────

  Scenario: Malformed email prevents form submission and shows inline validation message
    Given the user is on the login page
    When the user enters the malformed email "not-an-email" and attempts to submit the form
    Then the form submission is prevented
    And an inline email format validation message is displayed

  Scenario: Empty password field prevents form submission and shows required-field message
    Given the user is on the login page
    When the user submits the form with the password field empty
    Then the form submission is prevented
    And a required-field error message is displayed for the password field

  Scenario: Multiple failed login attempts trigger rate limiting or lockout
    Given a user has exceeded the configured threshold of consecutive failed login attempts
    When the user attempts another login
    Then the login attempt is blocked temporarily
    And the user is shown a clear message about the lockout duration or retry timing

  Scenario: After temporary lockout period the user can retry login only per configured policy
    Given a user has been temporarily locked out after exceeding the failed login threshold
    When the lockout period configured by policy has elapsed
    Then the user is allowed to attempt login again
    And the timing information and retry rules are communicated clearly to the user

  Scenario: Expired or previously used 2FA code is rejected with a clear error
    Given a registered user with 2FA enabled is on the 2FA verification screen
    When the user enters an expired or previously used 2FA code
    Then the system rejects the code with a clear error message
    And access to the dashboard is denied

  Scenario: Submitting credentials while offline displays a network error message without creating a partial session
    Given the user is on the login page and the network connection is unavailable
    When the user submits valid credentials
    Then an appropriate network error message is displayed
    And no partial authenticated session is created

  Scenario: Social login with invalid or tampered OAuth response is rejected
    Given the user initiates the Gmail OAuth login flow
    When the OAuth callback contains an invalid or tampered response
    Then the login attempt is rejected
    And the user remains unauthenticated

  Scenario: Attempts to bypass 2FA using replayed tokens or client-side manipulation are rejected
    Given a registered user with 2FA enabled has completed the credential step
    When the user attempts to bypass the 2FA step by replaying an old token or manipulating client state
    Then the server rejects the bypass attempt
    And the user is denied access to the dashboard

  Scenario: Redirect parameter in the login URL does not allow open redirect to external domains
    Given the login page URL contains a redirect parameter pointing to an external domain
    When the user successfully logs in
    Then the application ignores or rejects the external redirect target
    And the user is redirected only to a valid internal page
