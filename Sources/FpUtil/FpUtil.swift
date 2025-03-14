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

public func All<T>(_ ios: [IO<T>]) -> IO<[T]> {
  return {
    let sz: Int = ios.count

    var arr: [T] = []
    arr.reserveCapacity(sz)

    for i in ios {
      let res: Result<T, _> = i()

      switch res {
      case .failure(let err): return .failure(err)
      case .success(let t): arr.append(t)
      }
    }

    return .success(arr)
  }
}
