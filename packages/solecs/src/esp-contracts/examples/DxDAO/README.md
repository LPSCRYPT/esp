Example ESP implementation for DxDAO

Users have a certain amount of points which they can use to signal on a string-indexed signal.

Users and their points values are hardcoded by stream owners.

Emitted events must have all relevant information in their `bytes value`: 
1. StreamID
2. User emitting event
3. Total points of user
4. Points user has (de)signalled
5. String to which (de)signalling has occured
6. If user is adding or withdrawing points in this transaction