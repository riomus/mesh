# Backlog


- [x] Create app icon using assets/icon.png
- [x] Define smoke test that will run the app using web and android simulator and check if it works
- [x] Create integration test that will run the app using web and android simulator and check functionalities
- [x] Create a CI pipeline that will run the smoke and integration tests on every PR
- [x] Create a CI pipeline that will run the smoke and integration tests on every push to main branch
- [x] Update CI pipelines to publish reports on tests results
- [x] Add a badges to README
- [x] Create issue/PR templates
- [ ] Update release creation to include changelog based on all git commits since last release
- [ ] Update mapped meshtastic events to include all data avialble after buffer parsing - create DTOs for it - never drop data that is exposed in PB - we need to have all in Dart for example ModuleConfigDTO can not be empty
- [ ] Create DeviceCommunicationEventService that should work like logging service - it should gather tagged events (for now just meshtastic), and allow for subscription
- [ ] Create widget for events list display - similar to logging widget - show events with ability to search and filter using chips
- [ ] Use widget for events on device details page 
- [ ] Create new page for device events that will show all events from all devices
- [ ] Update logging widget to have "full screen" button that will enlarge the log view to full screen
- [ ] Update event list widget to have "full screen" button that will enlarge the event list view to full screen
- [ ] In event list widget - add ability to click on each events and show specific event details page
- [ ] For events with location - use flutter_map plugin to show map with pin on the location
- [ ] Add ability to share logs - dump them to json file and share it
- [ ] Add ability to share events - dump them to json file and share it
- [ ] Create chatting widget that will allow to send messages to devices and display them in the list
  - Chat view should be scrollable and has a input component at the bottom
  - Input should accept rich text - with emojis
  - Messages should be displayed in chronological order
  - Input should have a send button
  - Input should allow a size limit - by computing message size in bytes and comparing it to the limit
  - Current size should be shown and color of it should be updated based on the limit (green, yellow, red)