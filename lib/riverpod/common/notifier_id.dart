import 'dart:async';

class ObjectNotifierId<T, I> {
  ObjectNotifierId(this._identifier, [this._dataFuture]);
  final I _identifier;
  final Future<T?>? _dataFuture;

  Future<T?>? get dataFuture => _dataFuture;
  I get identifier => _identifier;

  Type get dataType => T;

  @override
  bool operator ==(Object other) =>
      (other is ObjectNotifierId && other._identifier == _identifier) || (other is String && other == _identifier);

  @override
  int get hashCode => _identifier.hashCode;
}
