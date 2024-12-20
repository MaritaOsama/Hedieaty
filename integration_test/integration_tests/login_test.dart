import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hedieaty/main.dart' as app;
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('End-to-end app test', (WidgetTester tester) async {
    print('Starting test...');

    // Step 1: Launch the app and log in
    await app.mainTest(); // Use mainTest() for integration tests
    await tester.pumpAndSettle(); // Wait for the app to settle
    print('App launched and settled.');

    // Find and interact with the login fields and buttons
    final emailField = find.byKey(const Key('email_field'));
    final passwordField = find.byKey(const Key('password_field'));
    final loginButton = find.byKey(const Key('login_button'));

    // Verify login screen elements
    expect(emailField, findsOneWidget, reason: 'Email field is missing.');
    expect(passwordField, findsOneWidget, reason: 'Password field is missing.');
    expect(loginButton, findsOneWidget, reason: 'Login button is missing.');
    print('Login screen verified.');

    // Enter credentials and submit
    await tester.enterText(emailField, 'maro@asu.com');
    await tester.enterText(passwordField, 'maro1234');
    await tester.tap(loginButton);
    await tester.pumpAndSettle();
    print('Logged in successfully.');

    // Step 2: Verify Home Page UI
    final addFriendButton = find.byKey(const Key('add_friend_button'));
    final friendNameField = find.byKey(const Key('friend_name_field'));
    final saveFriendButton = find.byKey(const Key('save_friend'));
    final friendsList = find.byKey(const Key('friends_list'));

    expect(addFriendButton, findsOneWidget, reason: 'Add Friend button is missing.');
    expect(friendNameField, findsOneWidget, reason: 'Friend Name field is missing.');
    expect(saveFriendButton, findsOneWidget, reason: 'Save Friend button is missing.');
    expect(friendsList, findsOneWidget, reason: 'Friends List is missing.');
    print('Home page verified.');

    // Step 3: Navigate to Events Page
    final eventsNavButton = find.byKey(const Key('nav_events_button'));
    await tester.tap(eventsNavButton);
    await tester.pumpAndSettle();
    print('Navigated to Events page.');

    // Verify Events Page UI
    final eventsList = find.byKey(const Key('events_list'));
    expect(eventsList, findsOneWidget, reason: 'Events list is missing.');
    print('Events page verified.');

    // Add similar debug prints and reasoned expects for other steps...
  });
}
