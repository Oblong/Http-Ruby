# Core.http from node to Ruby
This is an implementation of node.js 0.5.0's http module for rack-aware applications. It is used along with
[EventEmitter-Ruby](https://github.com/Oblong/EventEmitter-Ruby) to emulate the API as documented in the
[Node.js manual](http://nodejs.org/docs/v0.5.0/api/http.html).

## Limitations
This was written solely to support the subset of core.http that is being used by [Socket.IO-node](https://github.com/LearnBoost/socket.io) and
is as such, features will remain unimplemented by this author unless the said project actively makes use of them.

You can also get [Ruby Socket.IO](https://github.com/Oblong/Socket.io-Ruby) as per the relevancy of this library.

## Notes
This was designed with [thin](http://code.macournoyer.com/thin/) and eventually [rainbows!](http://rainbows.rubyforge.org/) in mind.
