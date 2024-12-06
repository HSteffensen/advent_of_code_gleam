pub fn result_guard(r: Result(a, _), return: c, f_ok: fn(a) -> c) -> c {
  case r {
    Error(_) -> return
    Ok(o) -> f_ok(o)
  }
}

pub fn result_lazy_guard(
  r: Result(a, _),
  return: fn(b) -> c,
  f_ok: fn(a) -> c,
) -> c {
  case r {
    Error(e) -> return(e)
    Ok(o) -> f_ok(o)
  }
}