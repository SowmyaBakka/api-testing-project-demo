Feature: User login with email and password
  As a registered user
  I want to log into the application using my email and password
  So that I can access my dashboard and manage my account

  Scenario: Successful login with valid email and password
    Given a registered user exists with email 'user@example.com' and password 'CorrectPass123'
    And the user is on the login page
    When the user enters the valid email and password and submits the form
    Then the user is redirected to the dashboard
    And a valid authenticated session is created
    And authenticated pages are accessible

  Scenario: Incorrect password displays error
    Given a registered user exists with email 'user@example.com'
    And the user is on the login page
    When the user enters the registered email and an incorrect password and submits the form
    Then the login page displays an 'incorrect password' error message
    And no authenticated session is created

  Scenario: Unregistered email shows user not found
    Given no account exists for email 'unknown@example.com'
    And the user is on the login page
    When the user enters 'unknown@example.com' and submits the form
    Then the login page displays a 'user not found' message
    And no authenticated session is created

  Scenario: Email format validation prevents submission
    Given the user is on the login page
    When the user enters an invalid email 'invalid-email' and moves focus away from the email field
    Then an inline validation message indicates the email format is invalid
    And the form cannot be submitted while the email format is invalid

  Scenario: Password field is required and prevents submission when empty
    Given the user is on the login page
    When the user leaves the password field empty and attempts to submit the form
    Then the login page displays a required-field message for the password
    And the form is not submitted

  Scenario: Protected page requires authentication and redirects unauthenticated users
    Given a protected page requires authentication
    When an unauthenticated user attempts to access the protected page
    Then the user is redirected to the login page
    And after successful login the user can access the protected page

  Scenario: Authentication completes within acceptable response time
    Given normal network conditions and a registered user with valid credentials
    And the user is on the login page
    When the user submits valid credentials
    Then authentication completes in under 3 seconds
    And a loading indicator or disabled submit control is shown while authentication is in progress

  Scenario: Gmail OAuth success redirects to dashboard
    Given the user is on the login page
    When the user selects the Gmail sign-in option and completes Google authentication successfully
    Then the user is redirected to the dashboard as an authenticated user
    And a valid authenticated session is created

  Scenario: Gmail OAuth denial shows error and keeps user unauthenticated
    Given the user is on the login page
    When the user selects the Gmail sign-in option and denies permission during Google authentication
    Then the login flow displays an appropriate error or recovery option
    And the user remains unauthenticated

  Scenario: Two-factor authentication required and accepted
    Given a registered user exists with 2FA enabled for email '2fa-user@example.com'
    And the user is on the login page
    When the user submits valid email and password for that account
    Then the system displays a 2FA screen requesting a one-time code
    When the user enters a valid 2FA code and submits it
    Then the user is granted access to the dashboard
    And an authenticated session is created

  Scenario: Invalid or expired 2FA code is rejected
    Given a registered user exists with 2FA enabled
    And the user is on the 2FA screen
    When the user enters an invalid or expired 2FA code and submits it
    Then the system displays a clear error indicating the code is invalid or expired
    And access to the dashboard is denied

  Scenario: Rate limiting after repeated failed login attempts
    Given a user performs multiple consecutive failed login attempts exceeding the configured threshold
    When the threshold is reached
    Then further login attempts are temporarily blocked for that user or IP
    And the user is shown a clear message about temporary blocking or retry timing

  Scenario: Login endpoints served over HTTPS and secure cookies set
    Given the user requests the login page and authentication endpoints
    When the server responds
    Then the pages and endpoints are served over HTTPS
    And authentication cookies or tokens are set with Secure, HttpOnly and appropriate SameSite attributes

  Scenario: Keyboard behavior and Enter key submission
    Given the login page is loaded
    Then keyboard focus is placed on the email field
    When the user fills in email and password and presses Enter while focus is in a form field
    Then the login form is submitted

  Scenario: Password visibility toggle reveals and re-masks password
    Given the user is on the login page with a password entered
    When the user toggles the password visibility control
    Then the password becomes visible while the toggle is active
    And the password returns to masked state when the toggle is turned off or after navigation
