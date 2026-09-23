part of 'transfer_bloc.dart';

abstract class TransferEvent {
  final String id;
  final int size;

  new({this.id = "", this.size = 0});
}

class TransferEventReset extends TransferEvent {
  new() : super();
}

class TransferEventProcessed extends TransferEvent {
  new({required super.id, required super.size});
}
