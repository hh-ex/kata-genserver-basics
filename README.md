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

