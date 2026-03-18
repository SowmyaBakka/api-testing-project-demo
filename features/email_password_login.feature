Feature: User login with email and password
  As a registered user
  I want to log into the application using my email and password
  So that I can access my dashboard and manage my account

  # ───────────────────────────────────────────────
  # FUNCTIONAL SCENARIOS
  # ───────────────────────────────────────────────

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
    Given an unauthenticated user is not logged in
    When the user attempts to access a protected page directly
    Then the user is redirected to the login page
    And after successful login the user can access the protected page

  @functional @negative
  Scenario: Display error message for incorrect password
    Given a registered user exists with email "user@example.com"
    And the user is on the login page
    When the user enters the registered email and an incorrect password and submits the form
    Then the login page displays an "incorrect password" error message
    And no authenticated session is created

  @functional @negative
  Scenario: Display user not found message for unregistered email
    Given no account exists for the email "unknown@example.com"
    And the user is on the login page
    When the user enters "unknown@example.com" and any password and submits the form
    Then the login page displays a "user not found" message
    And no authenticated session is created

  @functional @validation
  Scenario: Inline validation prevents malformed email submission
    Given the user is on the login page
    When the user enters the malformed email "invalid-email" and moves focus away from the email field
    Then an inline validation message indicates the email format is invalid
    And the form cannot be submitted while the email format is invalid

  @functional @validation
  Scenario: Password field is required and form submission is prevented when empty
    Given the user is on the login page
    When the user leaves the password field empty and attempts to submit the form
    Then the login page displays a required-field message for the password
    And the form is not submitted

  @functional @performance
  Scenario: Authentication completes within acceptable response time and shows loading feedback
    Given normal network conditions and a registered user with valid credentials
    And the user is on the login page
    When the user submits valid credentials
    Then authentication completes in under 3 seconds
    And a loading spinner or disabled submit button is shown while authentication is in progress

  @functional @social_login
  Scenario: Gmail social login initiates Google OAuth and grants access on success
    Given the user is on the login page
    When the user selects the Gmail sign-in option and completes Google authentication successfully
    Then the user is redirected to the dashboard as an authenticated user

  @functional @social_login @negative
  Scenario: User denying permission in Gmail OAuth flow returns appropriate error
    Given the user is on the login page
    When the user selects the Gmail sign-in option and denies permission during Google authentication
    Then the login flow displays an appropriate error or recovery option
    And the user remains unauthenticated

  @functional @2fa
  Scenario: 2FA is triggered for accounts with 2FA enabled and valid code grants access
    Given a registered user exists with 2FA enabled for email "2fa-user@example.com"
    And the user is on the login page
    When the user submits valid email and password for that account
    Then the system displays a 2FA screen requesting a one-time code
    When the user enters a valid 2FA code and submits it
    Then the user is granted access to the dashboard
    And a valid authenticated session is created

  @functional @2fa @negative
  Scenario: Invalid or expired 2FA code is rejected with a clear error
    Given a registered user exists with 2FA enabled
    And the user is on the 2FA screen
    When the user enters an invalid or expired 2FA code and submits it
    Then the system displays a clear error indicating the code is invalid or expired
    And access to the dashboard is denied

  @functional @2fa
  Scenario: Remember device policy bypasses 2FA step on subsequent login
    Given a registered user has previously chosen to remember the current device according to policy
    And the user is on the login page using that remembered device
    When the user submits valid email and password
    Then the 2FA step is bypassed according to the remembered-device policy
    And the user is granted access to the dashboard

  @functional @ux
  Scenario: Password visibility toggle reveals and hides the password
    Given the user is on the login page with a password entered in the password field
    When the user toggles the password visibility control
    Then the password becomes visible while the toggle is active
    And the password returns to masked state when the toggle is turned off

  # ───────────────────────────────────────────────
  # UX SCENARIOS
  # ───────────────────────────────────────────────

  @ux @accessibility
  Scenario: Keyboard focus is placed on the email field when the login page loads
    Given the login page is loaded
    Then keyboard focus is automatically placed on the email field

  @ux @accessibility
  Scenario: Pressing Enter while focus is in an input field submits the login form
    Given the user is on the login page
    And the user has filled in a valid email and password
    When the user presses Enter while focus is in a form input field
    Then the login form is submitted

  @ux
  Scenario: Error messages are displayed close to the relevant input fields
    Given the user is on the login page
    When the user submits the form with invalid credentials
    Then error messages are displayed adjacent to the relevant input fields
    And the messages are visually prominent and readable

  @ux @social_login
  Scenario: Gmail login button uses clear provider branding and an unambiguous label
    Given the user is on the login page
    Then the Gmail login button displays clear Google provider branding
    And the button label clearly communicates the action such as "Sign in with Google" or "Continue with Google"

  @ux @accessibility
  Scenario: Password visibility control is operable via keyboard and indicates its current state
    Given the user is on the login page
    When the user navigates to the password visibility toggle using the keyboard
    Then the toggle is focusable and operable via keyboard
    And the control clearly indicates whether the password is currently visible or hidden

  @ux
  Scenario: Loading indicator provides immediate feedback without obscuring controls
    Given the user is on the login page
    When the user submits valid credentials and authentication is in progress
    Then a loading or progress indicator is displayed immediately
    And the indicator does not obscure important form controls or error messages

  @ux @2fa
  Scenario: Contextual help is available for the 2FA step explaining why it is required
    Given a registered user with 2FA enabled is on the 2FA screen
    Then a tooltip or contextual help link is available explaining why 2FA is required
    And the explanation is concise and user-friendly

  @ux @social_login
  Scenario: Contextual help is available for Gmail sign-in explaining what data Google will share
    Given the user is on the login page
    Then a tooltip or contextual help link is available near the Gmail sign-in option
    And the help text explains what data Google will share during authentication

  @ux @2fa
  Scenario: Remember this device option is clearly explained with expected behavior
    Given a registered user with 2FA enabled has completed valid email and password entry
    And the 2FA screen is displayed
    Then the "Remember this device" option is visible and clearly labeled
    And accompanying text explains how long the device will be remembered according to policy

  # ───────────────────────────────────────────────
  # SECURITY SCENARIOS
  # ───────────────────────────────────────────────

  @security
  Scenario: Login page and authentication endpoints are served over HTTPS
    Given the user requests the login page and authentication endpoints
    When the server responds
    Then the pages and endpoints are served over HTTPS
    And no insecure assets are loaded on the login page

  @security
  Scenario: Authentication cookies and tokens are set with secure attributes
    Given a registered user successfully logs in
    When the server sets authentication cookies or tokens
    Then the cookies are set with Secure and HttpOnly flags
    And appropriate SameSite attributes are applied

  @security
  Scenario: Server error responses do not leak internal details or stack traces
    Given a registered user is on the login page
    When the user submits invalid credentials that trigger a server error
    Then the error message displayed to the user does not contain stack traces
    And no internal server details are exposed in the response

  @security
  Scenario: Rate limiting enforces temporary lockout after repeated failed login attempts
    Given a user performs multiple consecutive failed login attempts exceeding the configured threshold
    When the lockout threshold is reached
    Then further login attempts are temporarily blocked for that user or IP
    And the user is shown a clear message about temporary blocking or retry timing

  @security
  Scenario: CSRF protection is present on the authentication form and state parameter is validated for OAuth
    Given the user is on the login page
    When the authentication form is rendered
    Then a CSRF token is included in the form
    And the OAuth state parameter is validated during the social login flow to prevent CSRF attacks

  @security
  Scenario: Passwords are transmitted only over TLS and are never returned in API responses
    Given a registered user submits their credentials on the login page
    When the credentials are sent to the server
    Then the password is transmitted only over TLS
    And the password is not returned or logged in any API response

  @security @2fa
  Scenario: 2FA one-time codes expire after the configured time window and cannot be reused
    Given a registered user with 2FA enabled is on the 2FA screen
    When the user submits an expired one-time code
    Then the code is rejected with an expiry error message
    When the user attempts to reuse a previously valid one-time code
    Then the code is rejected and access is denied

  @security @2fa
  Scenario: Brute-force protections are applied to 2FA code submission
    Given a registered user with 2FA enabled is on the 2FA screen
    When the user submits multiple consecutive invalid 2FA codes exceeding the configured threshold
    Then further 2FA submission attempts are blocked according to the brute-force protection policy
    And the user is shown a clear message about the restriction

  @security
  Scenario: Session tokens are invalidated on logout and session fixation protections are in place
    Given a registered user has an active authenticated session
    When the user logs out
    Then the session token is invalidated
    And the user cannot access protected pages using the previous session token

  # ───────────────────────────────────────────────
  # USABILITY SCENARIOS
  # ───────────────────────────────────────────────

  @usability @accessibility
  Scenario: Login form is usable with screen readers and includes appropriate ARIA attributes
    Given the login page is loaded
    Then all form fields have descriptive labels visible to screen readers
    And appropriate ARIA attributes are present on form controls and error messages

  @usability @accessibility
  Scenario: Tab order through the login form is logical and all elements are keyboard reachable
    Given the login page is loaded
    When the user navigates the form using the Tab key
    Then the focus order moves logically through email field, password field, and submit button
    And all interactive elements including the password visibility toggle and social login button are reachable by keyboard alone

  @usability @accessibility
  Scenario: Visual contrast, font sizes, and spacing meet basic accessibility standards
    Given the login page is loaded
    Then the text contrast ratio meets the minimum accessibility standard
    And font sizes and spacing are sufficient for readability

  @usability
  Scenario: Error messages include suggested next steps for the user
    Given the user is on the login page
    When the user submits incorrect credentials
    Then the error message includes a suggested next step such as checking the password or signing up
    And the guidance is concise and user-friendly

  @usability
  Scenario: Login experience is usable on mobile devices with tappable and legible controls
    Given the user accesses the login page on a mobile device
    Then all form controls including input fields, the submit button, and the social login button are tappable
    And all text and labels are legible without requiring zoom

  # ───────────────────────────────────────────────
  # BROWSER COMPATIBILITY SCENARIOS
  # ───────────────────────────────────────────────

  @browser @cross_browser
  Scenario Outline: Email and password login flow works in major desktop browsers
    Given the user opens the login page in "<browser>" on a desktop device
    And a registered user exists with valid credentials
    When the user enters valid email and password and submits the form
    Then the user is redirected to the dashboard
    And a valid authenticated session is created

    Examples:
      | browser |
      | Chrome  |
      | Firefox |
      | Safari  |
      | Edge    |

  @browser @mobile
  Scenario Outline: Email and password login flow works in major mobile browsers
    Given the user opens the login page in "<browser>" on a "<platform>" mobile device
    And a registered user exists with valid credentials
    When the user enters valid email and password and submits the form
    Then the user is redirected to the dashboard

    Examples:
      | browser | platform |
      | Chrome  | Android  |
      | Safari  | iOS      |

  @browser @responsive
  Scenario Outline: Login page layout adapts correctly across common viewport sizes
    Given the user opens the login page at a "<viewport>" viewport size
    Then the login form is fully visible and usable
    And no content is clipped, overlapping, or obscured

    Examples:
      | viewport |
      | desktop  |
      | tablet   |
      | phone    |

  @browser @social_login
  Scenario: Gmail OAuth flow completes successfully in supported browsers and handles popup blockers gracefully
    Given the user is on the login page in a supported browser
    When the user initiates the Gmail sign-in flow
    Then the Google OAuth popup or redirect opens successfully
    And if the popup is blocked the authentication falls back to a redirect flow gracefully

  @browser
  Scenario: Login page degrades gracefully when cookies are disabled
    Given the user has cookies disabled in their browser
    When the user navigates to the login page
    Then the page displays a helpful message informing the user that cookies are required
    And the user is not stuck in an error state or redirect loop

  @browser
  Scenario: Keyboard and focus behaviors are consistent across major browsers
    Given the login page is loaded in any supported browser
    Then keyboard focus is placed on the email field on page load
    And tab navigation and Enter key submission behavior are consistent across supported browsers

  # ───────────────────────────────────────────────
  # NEGATIVE SCENARIOS
  # ───────────────────────────────────────────────

  @negative @validation
  Scenario: Submitting the form with empty email and password fields shows required-field messages
    Given the user is on the login page
    When the user attempts to submit the form without entering an email or password
    Then the login page displays required-field validation messages for both fields
    And the form is not submitted

  @negative @validation
  Scenario: Extremely long input values in email and password fields are rejected safely
    Given the user is on the login page
    When the user enters an extremely long string in the email field and the password field and submits the form
    Then the application rejects or truncates the input safely
    And the application does not crash or behave unexpectedly

  @negative @security
  Scenario: SQL injection payload in email and password fields is safely handled
    Given the user is on the login page
    When the user enters a common SQL injection string in the email field and the password field and submits the form
    Then the server safely handles the input without executing it
    And an appropriate error message is shown without exposing internal details

  @negative @security
  Scenario: Script tag injection payload in email and password fields is safely handled
    Given the user is on the login page
    When the user enters a script tag payload in the email field and the password field and submits the form
    Then the script is not executed in the browser
    And the application displays a safe error response

  @negative @2fa
  Scenario: Repeated invalid 2FA attempts trigger brute-force protections
    Given a registered user with 2FA enabled is on the 2FA screen
    When the user submits invalid 2FA codes repeatedly exceeding the configured threshold
    Then further 2FA submission attempts are blocked
    And the user is shown a clear message about the lockout or retry timing

  @negative @social_login
  Scenario: Network interruption during OAuth exchange results in clear error and no partial authentication
    Given the user has initiated the Gmail OAuth flow
    When a network interruption occurs during the OAuth token exchange
    Then the login page displays a clear error message about the failure
    And no partial or incomplete authenticated session is created

  @negative @social_login
  Scenario: Revoked or expired OAuth token during social login shows recovery option and no authenticated session
    Given the user attempts to log in via Gmail using a revoked or expired OAuth token
    When the OAuth flow fails due to the invalid token
    Then the login page displays an appropriate error message with a recovery option
    And no authenticated session is created

  @negative @social_login
  Scenario: User cancelling the Gmail OAuth flow is returned to login with no authenticated session
    Given the user is on the login page
    When the user initiates the Gmail sign-in flow and then cancels the Google authentication dialog
    Then the user is returned to the login page
    And no authenticated session is created
