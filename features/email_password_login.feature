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
    When the user enters the valid email and password and submits the form
    Then the user is redirected to the dashboard
    And a valid authenticated session is created
    And the user can access authenticated pages

  Scenario: Authenticated session persists and grants access to protected pages after login
    Given a registered user has successfully logged in with valid credentials
    When the user navigates to a protected page
    Then the protected page is accessible without being redirected to the login page

  Scenario: Unauthenticated user is redirected to login page when accessing a protected page
    Given the user is not logged in
    When the user attempts to directly access a protected page URL
    Then the user is redirected to the login page

  Scenario: User is redirected to the originally requested protected page after successful login
    Given an unauthenticated user was redirected to the login page from a protected page
    When the user submits valid credentials on the login page
    Then the user is redirected to the originally requested protected page
    And the user is authenticated

  Scenario: 2FA screen is displayed after valid credentials for a 2FA-enabled account
    Given a registered user exists with 2FA enabled for email "2fa-user@example.com"
    And the user is on the login page
    When the user submits valid email and password for that account
    Then the system displays a 2FA verification screen requesting a one-time code
    And no authenticated session is created yet

  Scenario: Dashboard access is granted after entering a valid 2FA code
    Given a registered user with 2FA enabled has passed the email and password step
    And the 2FA verification screen is displayed
    When the user enters a valid one-time 2FA code and submits it
    Then the user is redirected to the dashboard
    And an authenticated session is created

  Scenario: Gmail social login grants dashboard access on successful Google authentication
    Given the user is on the login page
    When the user selects the Gmail sign-in option and completes Google authentication successfully
    Then the user is redirected to the dashboard as an authenticated user
    And an authenticated session is created

  Scenario: Login form submission is prevented while email format validation is failing
    Given the user is on the login page
    When the user enters a malformed email "invalid-email" and moves focus away from the email field
    Then an inline validation message indicates the email format is invalid
    And the form cannot be submitted while the email format is invalid

  Scenario: Login form submission is prevented when the password field is empty
    Given the user is on the login page
    When the user enters a valid email but leaves the password field empty
    And the user attempts to submit the form
    Then a required-field validation message is displayed for the password field
    And the form is not submitted

  Scenario: Remembered device bypasses the 2FA step on login
    Given a registered user with 2FA enabled has previously chosen to remember the current device
    And the user is on the login page using that remembered device
    When the user submits valid email and password
    Then the 2FA step is bypassed in accordance with the remember-device policy
    And the user is redirected to the dashboard

  Scenario: Authentication completes within 3 seconds and shows loading feedback
    Given a registered user with valid credentials is on the login page
    When the user submits valid credentials under normal network conditions
    Then authentication completes within 3 seconds
    And a loading indicator or disabled submit button is shown while authentication is in progress

  # ─────────────────────────────────────────────
  # UX SCENARIOS
  # ─────────────────────────────────────────────

  Scenario: Inline validation messages are displayed near their respective fields
    Given the user is on the login page
    When the user submits the form with an invalid email and an empty password
    Then inline validation messages are displayed adjacent to each invalid field
    And the messages clearly describe what is expected for each field

  Scenario: Loading indicator is shown while authentication is in progress
    Given the user is on the login page
    When the user submits valid login credentials
    Then a loading indicator is visible or the submit button is disabled
    And the indicator disappears once the authentication response is received

  Scenario: Password visibility toggle reveals and re-masks the password
    Given the user is on the login page and has typed a password into the password field
    When the user activates the password visibility toggle
    Then the password text becomes visible in the password field
    When the user deactivates the password visibility toggle
    Then the password field returns to the masked state

  Scenario: Success and error messages use visually distinct and consistent styling
    Given the login page is displayed
    When a successful login or an error condition occurs
    Then success and error messages are visually distinct from each other
    And the message styles and wording are consistent across the login and 2FA flows

  Scenario: Gmail sign-in button is clearly labeled with Google branding
    Given the user is on the login page
    Then the Gmail sign-in button is visible and clearly labeled with Google branding
    And the purpose of the button is immediately obvious to the user

  Scenario: Keyboard focus is placed on the email field when the login page loads
    Given the login page has finished loading
    Then keyboard focus is automatically placed on the email input field

  Scenario: Pressing Enter while focused on a form field submits the login form
    Given the user is on the login page and has entered a valid email and password
    When the user presses the Enter key while focus is on a form field
    Then the login form is submitted
    And no unexpected additional actions occur

  # ─────────────────────────────────────────────
  # SECURITY SCENARIOS
  # ─────────────────────────────────────────────

  Scenario: Login page and authentication endpoints are served exclusively over HTTPS
    Given the user navigates to the login page over HTTP
    When the server processes the request
    Then the user is redirected to the HTTPS version of the login page
    And all authentication endpoints are accessible only over HTTPS

  Scenario: Authentication cookies are set with Secure, HttpOnly, and SameSite attributes
    Given the user has successfully logged in
    When the authentication cookies are inspected
    Then the session cookies have the Secure flag set
    And the session cookies have the HttpOnly flag set
    And the session cookies have an appropriate SameSite attribute set

  Scenario: Repeated failed login attempts trigger rate limiting or temporary lockout
    Given a user has made multiple consecutive failed login attempts exceeding the configured threshold
    When the user attempts another login
    Then further login attempts are temporarily blocked for that user or IP address
    And the user is shown a clear message indicating the temporary block and retry timing

  Scenario: CSRF protections are enforced on login and 2FA submission endpoints
    Given the login or 2FA submission endpoint is targeted without a valid CSRF token
    When the request is submitted
    Then the server rejects the request
    And no authenticated session is created

  Scenario: OAuth state and redirect_uri parameters are validated during Gmail login flow
    Given the Gmail OAuth flow has been initiated
    When the OAuth callback is received with a tampered or missing state or redirect_uri parameter
    Then the application rejects the OAuth callback
    And the user is not authenticated
    And a safe error message is displayed

  Scenario: Sensitive data is never exposed in URLs, logs, or client-side storage
    Given a user is performing the login or 2FA flow
    When the flow is completed
    Then passwords, 2FA codes, and tokens do not appear in the page URL or browser history
    And sensitive data is not stored in localStorage or sessionStorage
    And sensitive data is not written to accessible logs

  Scenario: Reused, expired, or invalid 2FA codes are rejected
    Given a registered user with 2FA enabled is on the 2FA verification screen
    When the user enters an expired or already-used 2FA code and submits it
    Then the system rejects the code with a clear error message
    And access to the dashboard is denied

  # ─────────────────────────────────────────────
  # USABILITY / ACCESSIBILITY SCENARIOS
  # ─────────────────────────────────────────────

  Scenario: Login form fields have accessible labels and ARIA attributes
    Given the login page has loaded
    Then the email, password, and 2FA input fields each have a visible label
    And the fields are announced correctly by screen readers via ARIA attributes

  Scenario: Tab key navigates form fields in a logical sequence
    Given the login page is loaded
    When the user navigates through the form using the Tab key
    Then focus moves in the logical order: email field, password field, submit button, and social login option

  Scenario: Validation error focus and assistive technology announcement on form submission
    Given the user is on the login page
    When the user submits the form with invalid or missing field values
    Then validation error messages are announced to assistive technologies
    And focus is moved to the first invalid field

  Scenario: Placeholders and labels make input expectations clear
    Given the user is on the login page
    Then the email field displays a label and placeholder that indicate an email address is expected
    And the password field displays a label that clearly identifies it as the password input

  Scenario: Login interface is usable on mobile viewports
    Given the login page is viewed on a small mobile screen
    Then all form fields, buttons, and messages are fully visible and usable
    And the 2FA code entry field provides sufficient touch target size
    And a numeric keypad is suggested where applicable for 2FA entry

  Scenario: Complete login flow is achievable using only keyboard input
    Given the user is on the login page with no mouse available
    When the user completes the full login flow using only keyboard navigation and input
    Then the user is successfully authenticated and redirected to the dashboard

  # ─────────────────────────────────────────────
  # NEGATIVE SCENARIOS
  # ─────────────────────────────────────────────

  Scenario: Unregistered email displays user not found message and blocks session creation
    Given no account exists for the email "unknown@example.com"
    And the user is on the login page
    When the user enters "unknown@example.com" with any password and submits the form
    Then the login page displays a "user not found" error message
    And no authenticated session is created

  Scenario: Incorrect password displays error message and blocks session creation
    Given a registered user exists with email "user@example.com"
    And the user is on the login page
    When the user enters the registered email with an incorrect password and submits the form
    Then the login page displays an "incorrect password" error message
    And no authenticated session is created

  Scenario: Malformed email input is rejected by inline validation
    Given the user is on the login page
    When the user types "missing-at-sign" into the email field and moves focus away
    Then an inline validation error is displayed indicating the email format is invalid
    And the form cannot be submitted

  Scenario: Excessively long email and password inputs are handled safely
    Given the user is on the login page
    When the user enters an email and password that exceed the maximum allowed length
    And the user submits the form
    Then the application handles the input safely without a server error
    And an appropriate validation or rejection message is displayed

  Scenario: Script and SQL injection attempts in login fields are sanitized
    Given the user is on the login page
    When the user enters script or SQL injection payloads into the email or password fields and submits the form
    Then the application rejects or sanitizes the input
    And no XSS or SQL injection vulnerability is triggered
    And a standard authentication error is displayed

  Scenario: Invalid or expired 2FA code is rejected with a clear error and rate limiting
    Given a registered user with 2FA enabled is on the 2FA verification screen
    When the user enters an invalid or expired 2FA code multiple times
    Then each attempt is rejected with a clear error message
    And repeated invalid attempts are subject to rate limiting or lockout

  Scenario: Tampered or reused OAuth parameters do not grant access
    Given the user is attempting Gmail social login
    When OAuth redirect parameters are tampered with or an OAuth token is reused
    Then the application denies authentication
    And a safe error message is displayed to the user
    And no authenticated session is created

  Scenario: Denying permission during Gmail OAuth flow returns an error and keeps user unauthenticated
    Given the user is on the login page
    When the user selects the Gmail sign-in option and denies permission during Google authentication
    Then the login flow displays an appropriate error or recovery message
    And the user remains unauthenticated

  # ─────────────────────────────────────────────
  # BROWSER COMPATIBILITY SCENARIOS
  # ─────────────────────────────────────────────

  Scenario Outline: Email and password login works across major browsers
    Given the user is using the latest stable version of "<browser>"
    And a registered user exists with valid credentials
    And the user is on the login page
    When the user enters valid credentials and submits the form
    Then the user is redirected to the dashboard
    And an authenticated session is created

    Examples:
      | browser |
      | Chrome  |
      | Firefox |
      | Safari  |
      | Edge    |

  Scenario Outline: Gmail OAuth social login works across major browsers
    Given the user is using the latest stable version of "<browser>"
    And the user is on the login page
    When the user selects the Gmail sign-in option and completes Google authentication successfully
    Then the user is redirected to the dashboard as an authenticated user

    Examples:
      | browser |
      | Chrome  |
      | Firefox |
      | Safari  |
      | Edge    |

  Scenario Outline: Login page layout and form controls render correctly on desktop and mobile viewports in each major browser
    Given the user is using the latest stable version of "<browser>"
    And the user views the login page on a "<viewport>" viewport
    Then the login page layout is correctly rendered
    And all form controls and validation messages are visible and functional

    Examples:
      | browser | viewport |
      | Chrome  | desktop  |
      | Chrome  | mobile   |
      | Firefox | desktop  |
      | Firefox | mobile   |
      | Safari  | desktop  |
      | Safari  | mobile   |
      | Edge    | desktop  |
      | Edge    | mobile   |

  Scenario: Third-party cookie blocking does not break the Gmail OAuth flow
    Given the user is on a browser with third-party cookies blocked
    And the user is on the login page
    When the user selects the Gmail sign-in option
    Then the application handles the restricted cookie environment gracefully
    And a clear recovery or guidance message is displayed if the OAuth flow cannot proceed

  Scenario: Pop-up blocker does not silently break the OAuth flow
    Given the user is on a browser with pop-up blocking enabled
    And the user is on the login page
    When the user selects the Gmail sign-in option and the OAuth pop-up is blocked
    Then the application detects the blocked pop-up
    And a clear message or guidance is displayed to the user explaining how to proceed