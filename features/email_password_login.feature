Feature: User login with email and password
  As a registered user
  I want to log into the application using my email and password
  So that I can access my dashboard and manage my account

  # ─────────────────────────────────────────────
  # FUNCTIONAL TESTING
  # ─────────────────────────────────────────────

  @functional @happy_path
  Scenario: Successful login with valid credentials redirects user to the dashboard
    Given a registered user exists with email "user@example.com" and password "CorrectPass123"
    And the user is on the login page
    When the user enters valid email and password and submits the login form
    Then the user is redirected to the dashboard
    And a valid authenticated session is created
    And the user can access protected pages

  @functional @authorization
  Scenario: Unauthenticated user is redirected to the login page when accessing a protected page
    Given the user is not logged in
    When the user attempts to navigate directly to a protected page
    Then the user is redirected to the login page

  @functional @authorization
  Scenario: Authenticated user can access protected pages after successful login
    Given a registered user exists with email "user@example.com" and password "CorrectPass123"
    And the user is on the login page
    When the user submits valid credentials
    Then a valid authenticated session is created
    And the user can successfully access protected pages

  @functional @negative
  Scenario: Incorrect password displays an error and does not create a session
    Given a registered user exists with email "user@example.com"
    And the user is on the login page
    When the user enters the registered email and an incorrect password and submits the form
    Then the login page displays an "incorrect password" error message
    And no authenticated session is created

  @functional @negative
  Scenario: Unregistered email displays a user not found message
    Given no account exists for the email "unknown@example.com"
    And the user is on the login page
    When the user enters "unknown@example.com" and any password and submits the form
    Then the login page displays a "user not found" message
    And no authenticated session is created

  @functional @validation
  Scenario: Malformed email format prevents form submission with inline validation
    Given the user is on the login page
    When the user enters the malformed email "invalid-email" and moves focus away from the email field
    Then an inline validation message indicates the email format is invalid
    And the form cannot be submitted while the email format is invalid

  @functional @validation
  Scenario: Empty password field prevents form submission with a required-field message
    Given the user is on the login page
    When the user leaves the password field empty and attempts to submit the form
    Then the login page displays a required-field message for the password field
    And the form is not submitted

  @functional @performance
  Scenario: Authentication completes within 3 seconds and shows loading feedback
    Given a registered user exists with valid credentials
    And the user is on the login page under normal network conditions
    When the user submits valid credentials
    Then authentication completes in under 3 seconds
    And a loading spinner or a disabled submit button is displayed while authentication is in progress

  @functional @social_login
  Scenario: Gmail social login initiates Google OAuth and grants access on success
    Given the user is on the login page
    When the user selects the Gmail sign-in option and completes Google authentication successfully
    Then the user is redirected to the dashboard as an authenticated user

  @functional @social_login
  Scenario: Denying permission during Gmail OAuth flow leaves the user unauthenticated
    Given the user is on the login page
    When the user selects the Gmail sign-in option and denies permission during Google authentication
    Then the login page displays an appropriate error message or recovery option
    And the user remains unauthenticated

  @functional @2fa
  Scenario: 2FA screen is displayed after successful credentials for a 2FA-enabled account
    Given a registered user exists with 2FA enabled for email "2fa-user@example.com"
    And the user is on the login page
    When the user submits valid email and password for that account
    Then the system displays a 2FA screen requesting a one-time code

  @functional @2fa
  Scenario: Valid 2FA code grants access to the dashboard
    Given a registered user has passed email and password verification and is on the 2FA screen
    When the user enters a valid 2FA code and submits it
    Then the user is granted access to the dashboard
    And a valid authenticated session is created

  @functional @2fa
  Scenario: Invalid or expired 2FA code is rejected with a clear error
    Given a registered user exists with 2FA enabled
    And the user is on the 2FA screen
    When the user enters an invalid or expired 2FA code and submits it
    Then the system displays a clear error indicating the code is invalid or expired
    And access to the dashboard is denied

  @functional @2fa
  Scenario: Previously remembered device bypasses the 2FA step according to policy
    Given a registered user has previously chosen to remember the current device
    And the user is on the login page using that remembered device
    When the user submits valid email and password
    Then the 2FA step is bypassed according to the remembered-device policy
    And the user is granted access to the dashboard

  # ─────────────────────────────────────────────
  # UX TESTING
  # ─────────────────────────────────────────────

  @ux @accessibility
  Scenario: Keyboard focus is placed on the email field when the login page loads
    Given the user navigates to the login page
    When the page finishes loading
    Then keyboard focus is automatically placed on the email field

  @ux @accessibility
  Scenario: Pressing Enter while focused on a form field submits the login form
    Given the user is on the login page with email and password entered
    When the user presses Enter while focus is in a form field
    Then the login form is submitted

  @ux
  Scenario: Password visibility toggle reveals and hides the password
    Given the user is on the login page and has typed a password
    When the user activates the password visibility toggle
    Then the password characters become visible
    When the user deactivates the password visibility toggle
    Then the password characters return to masked state

  @ux
  Scenario: Gmail sign-in option is clearly visible and distinct from the email and password form
    Given the user is on the login page
    When the page is fully rendered
    Then the Gmail sign-in option is clearly visible and labeled appropriately
    And it is visually distinct from the email and password form

  @ux
  Scenario: Loading feedback is visible while authentication is in progress
    Given the user is on the login page
    When the user submits valid credentials
    Then a loading spinner, progress indicator, or disabled submit button is displayed
    And it clearly indicates that authentication is in progress

  @ux
  Scenario: Error messages are visually distinct and sufficiently contrasted
    Given the user is on the login page
    When the user submits incorrect credentials
    Then the error message is visually distinct from regular text through color, icon, or placement
    And the error message maintains sufficient contrast for readability

  @ux
  Scenario: Login form layout and touch targets are usable on both desktop and mobile
    Given the user accesses the login page on a desktop or touch device
    When the page is rendered at the appropriate viewport size
    Then all form fields, buttons, and touch targets have adequate spacing and are fully usable

  # ─────────────────────────────────────────────
  # SECURITY TESTING
  # ─────────────────────────────────────────────

  @security
  Scenario: Login page and authentication endpoints are served over HTTPS only
    Given the user requests the login page and authentication endpoints
    When the server responds
    Then all pages and endpoints are served exclusively over HTTPS
    And any HTTP requests are redirected to HTTPS

  @security
  Scenario: Authentication cookies and tokens are set with Secure HttpOnly and SameSite attributes
    Given the user successfully logs in
    When the authentication response is received
    Then authentication cookies or tokens are set with the Secure attribute
    And they are set with the HttpOnly attribute
    And they carry an appropriate SameSite policy

  @security
  Scenario: Sensitive credentials and tokens are not exposed in URLs or browser logs
    Given the user completes any part of the login or OAuth flow
    When the browser processes the authentication response
    Then no sensitive tokens, passwords, or authorization codes appear in URLs or query parameters
    And no sensitive data is written to browser console logs

  @security
  Scenario: Rate limiting is triggered after repeated failed login attempts
    Given a user performs multiple consecutive failed login attempts exceeding the configured threshold
    When the threshold is reached
    Then further login attempts are temporarily blocked for that user or IP address
    And the user is shown a clear message about the temporary block and retry timing

  @security
  Scenario: A new session identifier is issued after successful login to prevent session fixation
    Given a user has a pre-login session identifier
    And the user is on the login page
    When the user successfully logs in
    Then a new unique session identifier is issued
    And the pre-login session identifier is invalidated

  @security
  Scenario: Google OAuth redirect URIs are validated and open redirect is not possible
    Given the Google OAuth integration is configured for the application
    When the OAuth callback is processed
    Then only pre-approved redirect URIs are accepted
    And unauthorized or manipulated redirect URIs are rejected

  @security
  Scenario: Expired 2FA codes are rejected and brute-force protection is enforced
    Given a registered user is on the 2FA screen
    When the user enters multiple invalid 2FA codes exceeding the configured attempt threshold
    Then further 2FA attempts are blocked
    And the user is informed that the code has expired or that the attempt limit has been reached

  @security
  Scenario: Authentication endpoints include CSRF protection for applicable actions
    Given an authentication action is submitted from an unauthorized external origin
    When the server processes the request
    Then the request is rejected with an appropriate security error
    And no authentication action is performed

  # ─────────────────────────────────────────────
  # USABILITY TESTING
  # ─────────────────────────────────────────────

  @usability
  Scenario: Error messages provide actionable guidance for recovery
    Given the user is on the login page
    When the user submits incorrect credentials
    Then the error message clearly describes the problem
    And the error message provides guidance on the recommended next steps

  @usability
  Scenario: Email and password input fields have clear labels not relying solely on placeholder text
    Given the user is on the login page
    When the page is fully rendered
    Then the email field has a visible and descriptive label
    And the password field has a visible and descriptive label
    And the labels are not replaced by placeholder text alone

  @usability
  Scenario: Remember device option includes a description of its behavior and duration
    Given the user is on the login page
    When the remember device or remember me option is visible
    Then a brief explanation of its behavior is displayed
    And the duration for which the device will be remembered is indicated

  @usability
  Scenario: 2FA screen provides clear instructions on code source format and validity period
    Given the user has passed email and password verification and is on the 2FA screen
    When the 2FA screen is displayed
    Then clear instructions describe where to find the one-time code
    And the expected format of the code is indicated
    And the remaining validity time is visible

  @usability @accessibility
  Scenario: Keyboard focus indicators are visible for all controls on login and 2FA screens
    Given the user is navigating the login or 2FA screen using the keyboard
    When the user moves focus through all interactive controls
    Then a visible focus indicator is displayed on the currently focused control

  # ─────────────────────────────────────────────
  # BROWSER TESTING
  # ─────────────────────────────────────────────

  @browser
  Scenario Outline: Email and password login works across major desktop browsers
    Given a registered user exists with valid credentials
    And the user is using the latest stable version of "<browser>" on desktop
    And the user is on the login page
    When the user enters valid credentials and submits the form
    Then the user is redirected to the dashboard
    And a valid authenticated session is created

    Examples:
      | browser |
      | Chrome  |
      | Firefox |
      | Safari  |
      | Edge    |

  @browser @mobile
  Scenario Outline: Login works on major mobile browsers
    Given a registered user exists with valid credentials
    And the user is using "<mobile_browser>" on a mobile device
    And the user is on the login page
    When the user enters valid credentials and submits the form
    Then the user is redirected to the dashboard
    And a valid authenticated session is created

    Examples:
      | mobile_browser       |
      | Chrome on Android    |
      | Safari on iOS        |

  @browser @social_login
  Scenario: Gmail OAuth popup or redirect works reliably across major browsers
    Given the user is on the login page in a supported browser
    When the user initiates Gmail OAuth login
    Then the Google authentication popup or redirect is initiated without being blocked
    And upon successful Google authentication the user is redirected to the dashboard

  @browser
  Scenario: Cookie security attributes and session persistence work consistently across browsers
    Given a registered user successfully logs in on a supported browser
    When authentication cookies are issued
    Then the Secure and SameSite cookie attributes are honored by the browser
    And the session persists consistently for the authenticated user

  @browser @responsive
  Scenario Outline: Login page is responsive and usable at common viewport sizes
    Given the user accesses the login page on a device with a "<viewport>" viewport
    When the page is rendered
    Then the login form is fully visible and usable
    And all touch interactions are functional where applicable

    Examples:
      | viewport |
      | desktop  |
      | tablet   |
      | mobile   |

  # ─────────────────────────────────────────────
  # NEGATIVE TESTING
  # ─────────────────────────────────────────────

  @negative @validation
  Scenario: Whitespace-only email or password input is rejected with a validation message
    Given the user is on the login page
    When the user enters only whitespace characters in the email and password fields and submits the form
    Then form submission is rejected
    And a clear validation message is displayed for the affected fields

  @negative @validation
  Scenario: Extremely long email and password inputs are safely handled without crashes
    Given the user is on the login page
    When the user enters an extremely long string in the email and password fields and submits the form
    Then the application safely handles the input without crashing or returning a server error
    And an appropriate validation or error message is displayed

  @negative @validation
  Scenario: Special characters and Unicode input in credentials are handled safely
    Given the user is on the login page
    When the user enters special characters or non-ASCII Unicode input in the email and password fields and submits the form
    Then the application handles the input safely according to the specification
    And no unexpected behavior or unhandled error occurs

  @negative @security
  Scenario: SQL injection payloads in login fields are sanitized and not executed
    Given the user is on the login page
    When the user enters a SQL injection payload in the email or password field and submits the form
    Then the payload is sanitized or rejected by the application
    And no database query is manipulated or unintended data is returned

  @negative @security
  Scenario: XSS payloads in login fields are sanitized and not executed
    Given the user is on the login page
    When the user enters a cross-site scripting payload in the email or password field and submits the form
    Then the script is not executed in the browser
    And the payload is properly sanitized or rejected

  @negative @social_login
  Scenario: Canceling or closing the Gmail OAuth popup leaves the user unauthenticated with a recovery option
    Given the user is on the login page
    When the user initiates Gmail OAuth login and then cancels or closes the OAuth popup
    Then the user remains unauthenticated
    And a clear recovery option is available on the login page

  @negative @2fa
  Scenario: Reusing a one-time 2FA code is rejected with a clear error
    Given a registered user has already used a valid 2FA code to authenticate
    And the user is back on the 2FA screen
    When the user attempts to submit the same already-used 2FA code
    Then the system rejects the code
    And displays a clear error indicating the code has already been used

  @negative
  Scenario: Network failure during login results in a clear error message without an inconsistent state
    Given the user is on the login page and the authentication service is unreachable
    When the user submits valid credentials
    Then a clear error message is displayed informing the user of the network failure
    And the application does not enter an inconsistent or partially authenticated state

  @negative @validation
  Scenario: Leading and trailing spaces in the email field are handled consistently
    Given the user is on the login page
    When the user enters an email address with leading or trailing whitespace and submits the form
    Then the application either trims the whitespace automatically and processes the login
    Or rejects the input with a clear validation message consistent with account storage rules