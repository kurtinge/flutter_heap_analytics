# heapanalytics

Heap Analytics

A dart wrapper for Heap.io Analytics

## How to use

Here is an exampel app to demonstrate how to use the plugin.

After you have initiated the class you have the `track` and `userInformation` functions.
`userInformation` is used to add extra data to the user.
`track` is used to track events.

```dart

    int _counter = 0;
    // This can be any string, email, an id, etc.
    String _identity = 'the-identity-of-the-user';

    HeapAnalytics heap = HeapAnalytics(
      appId: 'your-app-id-from-heap',
      errorHandler: (e) => {
          print(e);
      }
    );

    heap.userProperties(
      identity: _identity,
      properties: {
        'email': 'email@example.com',
        'firstname': 'John',
        'lastname': 'Doe',
        'language': 'English',
      },
    );

    _counter++;
    heap.track(
      identity: _identity,
      event: 'Increment Button', 
      properties: {
        'platform': 'Mobile',
        'subject': "Clicked the increment button",
        'new_count': _counter
      },
    );
```
