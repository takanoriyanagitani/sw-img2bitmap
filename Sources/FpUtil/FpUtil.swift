public typealias IO<T> = () -> Result<T, Error>

public func Lift<T, U>(
  _ pure: @escaping (T) -> Result<U, Error>
) -> (T) -> IO<U> {
  return {
    let t: T = $0
    return {
      pure(t)
    }
  }
}

public func Err<T>(_ e: Error) -> IO<T> {
  return {
    return .failure(e)
  }
}

public func Bind<T, U>(
  _ i: @escaping IO<T>,
  _ g: @escaping (T) -> IO<U>
) -> IO<U> {
  return {
    let rt: Result<T, Error> = i()
    switch rt {
    case .success(let t): return g(t)()
    case .failure(let e): return .failure(e)
    }
  }
}
