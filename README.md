# KataGenserverBasics

This Kata contains some of the `heureka` i had when using GenServer.

## Solving

Clone this repo an run `mix test` till all tests work.

## Heureka

Short list of important points:

* Starting and initializing a Process.
* How a Process should fail when initializing.
* Using PID or name to access Process.
* Public interface for hiding the messages underneath.
* Transforming data before/after sending to process.
* Reducing messages to GenServer to changes of state.
* Avoiding crashing a GenServer, kill the caller instead.
* Handling timeouts from client and server side.
* Destructing a GenServer.

### Handle a pid like a object

* No objects, no processes = just passing _data_ around.
* Only using objects = passing _references_ to instances around.
* Only using processes = passing _pids_ of processes around.

Lets skip using objects and stay with pids and data.

---------------------

But data is not data!
Consider this:

* In OOP there are objects representing data OR objects representing functionality.
* But some of the functionality objects need internal state to handle data.
* Example: `(new IpCounter(["127.0.0.1": 42])).count(ip)` where `ip` is the data to process and `["127.0.0.1": 42]` is the internal state.

IMHO data has to be divided in "data" and "state".
Erlang is providing a wonderful mechanism to do that with state kept in GenServers and data flowing around.

### Global naming is a wonderful thing

Remember that "singleton" pattern? Erlang has it!

When a server is named by a well known name like `user_auth`, others can depend on it.
Yet still that server can be replaced by another process that will simply take over that name.
So there is no explicit binding for classes or interfaces, just a defined _name_ in the middle.

### Naming only if needed

Giving every GenServer a `:name` may not be needed.

* Give it a name when its a static service (started at application start)
* If is a dynamic service (started and running after application start/on demand) ...
  * give it a name if the process needs to be referenced by name (when PID cant be used because of serialization)
  * else using the PID should be working just fine.

### Public and Private

Just a simple convention.

* A function besides `init, handle_*, terminate, code_change` is considered a public API. They will be _sending_ messages to the GenServer if needed.
* A function like `handle_*` should be considered private because messages are a implementation detail. They are answering messages.
* All `defp` functions are private by definition.

### Caller can do some work too

```
def work(pid, data) do
  pid
    |> GenServer.call({:work, prepare(data)})
    |> finalize
end

def handle_call({:work, data}, _from, state) do
  {:reply, real_work(data), state}
end
```

* The process invoking `work` will execute the functions `prepare` and `finalize`.
* The GenServer itself will only execute `real_work`.

This has quite some advantages:

* Validate data before sending it to the GenServer.
* Crash the calling process if needed instead of the GenServer.
* Moving reductions out of GenServer.
* Message passing can even more reduced to updating state instead of sending data.
* Idea is simple: Instead of slowly moving data around, move the Algorithm/State.

### Creating a GenServer

The pattern "factory method" does also exist for GenServers.
By default `init` is executed in _the process starting_ the GenServer, which can be seen as a helper for a "factory method".
A real "factory method" can be implemented using a own `start*` function.

GenServer are not having a equivalent for "constructor" inside the newly created process, so a message has to send after `start*` has returned.
Sending this message from `init` is not possible, because the pid of the new GenServer does not yet exist.

There seems to be a convention, to use the `:timeout` feature of a genserver, with a `timeout=0`.
This will trigger a `handle_info(:timeout, state)` immediatly when the process enters the loop
and can be used for constructing the process.

### Destructor

Use `terminate` to close stuff like sockets.
But (Re-)Starting should not be done here, that is something outside of the GenServer scope.


### Let somebody else reply

A GenServer call can return `{:noreply, state}` or (let) call `GenServer.reply(from, reply)`.

Why? To the docs!

* To reply before returning from the callback because the response is known before calling a slow function.
* To reply after returning from the callback because the response is not yet available.
* To reply from another process, such as a task.


### Timeouts

Returning {:reply, reply, new_state, timeout} is similar to {:reply, reply, new_state}
except handle_info(:timeout, new_state) will be called after timeout milliseconds if no messages are received.


## Comparision

### Java

```java
// Instantiating = creating and initializing object
my_service = new MyService(init_args)
// Instead of "new", it could be a function like "MyService.new(init_args)"
// If that feature is needed, a factory method should be used.
// The "init_args" are processed inside the created objects, so _after_ is was created. 

// Calling method
result = my_service.do_something(42)
// Methods are bound to a Interface (/Class), a abstraction has to be actively added.

// Destructing
my_service = null
// Will call "finalize()"
```

### Elixir

```elixir
# Creating a process with given Module, init_args and options for starting.
my_server = GenServer.start_link(MyServer, init_args, options)
# The "start_link" function is a factory for creating new processes.
# Internally "init" will be called to calculate initial state, before the process even exists.
# Running some code after a process is started can be done using the "timeout" hack.
# Why this way? This is the only way to be "sure" that a GenServer will run even before it is really started.

# Calling a function
result = MyServer.do_something(my_service, 42)
# MyServer can run code inside calling process and/or in GenServer via messages.
# There is no coupling using Interfaces (/Classes), "my_service" can be any kind of pid/reference.
# Even a async model can be implemented this way, without a APi change.

# Destructing
GenServer.stop(my_server, :normal, :infinity)
# Will call "terminate", so the GenServer can clean up internal state (sockets, queues, ...)
# There are different types of "deaths" and even a timeout for it. While java is only able to handle afterwards and returning void.
```
