public enum Result<T> {
  case error(Error), result(T)
}
