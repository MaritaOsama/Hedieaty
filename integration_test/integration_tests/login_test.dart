import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hedieaty/main.dart' as app;
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('End-to-end app test', (WidgetTester tester) async {
    // Step 1: Launch the app and log in
    await app.mainTest(); // Use mainTest() for integration tests
    await tester.pumpAndSettle();  // Wait for the app to settle

    // Find and interact with the login fields and buttons
    final emailField = find.byKey(const Key('email_field'));
    final passwordField = find.byKey(const Key('password_field'));
    final loginButton = find.byKey(const Key('login_button'));

    // Verify login screen elements
    expect(emailField, findsOneWidget);
    expect(passwordField, findsOneWidget);
    expect(loginButton, findsOneWidget);

    // Enter credentials and submit
    await tester.enterText(emailField, 'maro@asu.com');
    await tester.enterText(passwordField, 'maro1234');
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // Step 2: Home Page - Verify home page UI
    final addFriendButton = find.byKey(const Key('add_friend_button'));
    final friendNameField = find.byKey(const Key('friend_name_field'));
    final saveFriendButton = find.byKey(const Key('save_friend'));
    final friendsList = find.byKey(const Key('friends_list'));
    expect(addFriendButton, findsOneWidget);
    expect(friendNameField, findsOneWidget);
    expect(saveFriendButton, findsOneWidget);
    expect(friendsList, findsOneWidget);

    // Step 3: Navigate to Events Page
    final eventsNavButton = find.byKey(const Key('nav_events_button'));
    await tester.tap(eventsNavButton);
    await tester.pumpAndSettle();

    // Verify Events Page UI
    final eventsList = find.byKey(const Key('events_list'));

    expect(eventsList, findsOneWidget);

    // Step 4: Navigate to Gift List from Event
    final eventCard = find.byKey(const Key('event_card_1'));
    await tester.tap(eventCard);
    await tester.pumpAndSettle();

    final giftsList = find.byKey(const Key('gifts_list'));
    expect(giftsList, findsOneWidget);

    // Test Add/Edit/Delete Gift functionality
    final addGiftButton = find.byKey(const Key('add_gift_button'));
    final giftNameField = find.byKey(const Key('gift_name_field'));
    final giftCategoryField = find.byKey(const Key('gift_category_field'));
    final saveGiftButton = find.byKey(const Key('save_gift_button'));

    final editGiftButton = find.byKey(const Key('edit_gift_button'));
    final editGiftNameField = find.byKey(const Key('edit_gift_name_field'));
    final editGiftCategoryField = find.byKey(const Key('edit_gift_category_field'));
    final saveChangesGiftButton = find.byKey(const Key('save_changes_gift_button'));

    final deleteGiftButton = find.byKey(const Key('delete_gift_button'));
    final confirmDeleteGiftButton = find.byKey(const Key('confrim_delete_gift_button'));
    expect(addGiftButton, findsOneWidget);
    await tester.tap(addGiftButton);
    await tester.pumpAndSettle();

    expect(giftNameField, findsOneWidget);
    expect(saveGiftButton, findsOneWidget);

    await tester.enterText(giftNameField, 'New Gift');
    await tester.tap(saveGiftButton);
    await tester.pumpAndSettle();

    // Verify the gift is saved and displayed in the list
    expect(find.text('New Gift'), findsOneWidget);

    // Step 5: Gift Details Page - Edit Gift
    final giftDetailsButton = find.byKey(const Key('gift_details_button'));
    await tester.tap(giftDetailsButton);
    await tester.pumpAndSettle();

    final giftDetailTextField = find.byKey(const Key('gift_detail_text_field'));
    final saveDetailsButton = find.byKey(const Key('save_details_button'));
    expect(giftDetailTextField, findsOneWidget);
    expect(saveDetailsButton, findsOneWidget);

    await tester.enterText(giftDetailTextField, 'Updated Gift Details');
    await tester.tap(saveDetailsButton);
    await tester.pumpAndSettle();

    // Verify the updated gift details are saved
    expect(find.text('Updated Gift Details'), findsOneWidget);

    // Step 6: Profile Page - View User's Events and Pledged Gifts
    final profileNavButton = find.byKey(const Key('nav_profile_button'));
    await tester.tap(profileNavButton);
    await tester.pumpAndSettle();

    final profileEventsList = find.byKey(const Key('profile_events_list'));
    expect(profileEventsList, findsOneWidget);

    final pledgedGiftsButton = find.byKey(const Key('pledged_gifts_button'));
    expect(pledgedGiftsButton, findsOneWidget);

    // Step 7: Friend's Event Page - View Friend's Events
    final friendCard = find.byKey(const Key('friend_card_1'));
    await tester.tap(friendCard);
    await tester.pumpAndSettle();

    final friendsEventsList = find.byKey(const Key('friends_events_list'));
    expect(friendsEventsList, findsOneWidget);

    // Step 8: Friend's Gift List
    final friendEventCard = find.byKey(const Key('friend_event_card_1'));
    await tester.tap(friendEventCard);
    await tester.pumpAndSettle();

    final friendGiftList = find.byKey(const Key('friend_gifts_list'));
    expect(friendGiftList, findsOneWidget);

    // Step 9: Pledge Friend's Gift
    final giftDetailsButtonForFriend = find.byKey(const Key('friend_gift_details_button'));
    await tester.tap(giftDetailsButtonForFriend);
    await tester.pumpAndSettle();

    final pledgeButton = find.byKey(const Key('pledge_button'));
    expect(pledgeButton, findsOneWidget);
    await tester.tap(pledgeButton);
    await tester.pumpAndSettle();

    // Step 10: Verify Notification Sent
    // In a real test case, you'd verify the notification here.
    expect(find.text('Gift Pledged!'), findsOneWidget); // Mock notification check

    // Step 11: Create Event and Notify Friends
    final createEventButton = find.byKey(const Key('create_event_button'));
    await tester.tap(createEventButton);
    await tester.pumpAndSettle();

    final eventNameFieldForCreate = find.byKey(const Key('event_name_field'));
    final eventCategoryField = find.byKey(const Key('event_category_field'));
    final eventDateField = find.byKey(const Key('event_date_field'));
    final saveEventButtonForCreate = find.byKey(const Key('save_event_button'));

    expect(eventNameFieldForCreate, findsOneWidget);
    expect(eventCategoryField, findsOneWidget);
    expect(eventDateField, findsOneWidget);
    expect(saveEventButtonForCreate, findsOneWidget);

    await tester.enterText(eventNameFieldForCreate, 'Test Event');
    await tester.tap(saveEventButtonForCreate);
    await tester.pumpAndSettle();


    // Verify event creation and friends notification (mocked)
    expect(find.text('Test Event'), findsOneWidget);
    // Verify that friends are notified about the event (this would be done in real test case with a mock or checking backend response)
  });
}
