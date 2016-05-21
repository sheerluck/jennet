use "net/http"
use ".."

actor Main
  new create(env: Env) =>
    try
      let auth = env.root as AmbientAuth
      let rb = RouteBuilder(env.out)
      rb.get("/", H)
      Server(auth, Info(env), (consume rb).build(), DiscardLog
        where service = "8080", limit = USize(100), reversedns = auth)
    else
      env.out.print("unable to use network.")
    end

class H is Handler
  fun val apply(c: Context, req: Payload): Context iso^ =>
    let res = Payload.response()
    res.add_chunk("Hello!")
    c.respond(consume req, consume res)
    consume c

class iso Info
  let _env: Env

  new iso create(env: Env) =>
    _env = env

  fun ref listening(server: Server ref) =>
    try
      (let host, let service) = server.local_address().name()
      _env.out.print("Listening on " + host + ":" + service)
    else
      _env.out.print("Couldn't get local address.")
      server.dispose()
    end

  fun ref not_listening(server: Server ref) =>
    _env.out.print("Failed to listen.")

  fun ref closed(server: Server ref) =>
    _env.out.print("Shutdown.")
