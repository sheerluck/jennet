
class _RouterGroup
  let _middleware: Array[Middleware]
  let _handler: RequestHandler

  new create(middleware: Array[Middleware], handler: RequestHandler) =>
    _middleware = middleware
    _handler = handler

  fun val apply(c: Context) ? =>
    let c' = match _middleware.size()
    | 0 => consume c
    else
      _exec_middleware(0, consume c)
    end
    _handler(consume c')

  fun val _exec_middleware(i: USize, c: Context): Context iso^ ? =>
    match i
    | _middleware.size() => consume c
    else
      _exec_middleware(i + 1, _middleware(i)(consume c))
    end

interface Middleware
  fun apply(c: Context): Context iso^

interface RequestHandler
  fun val apply(c: Context): Any tag