import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transfer_state.dart';
part 'transfer_event.dart';
part 'transfer_bloc.freezed.dart';

class TransferBloc extends Bloc<TransferEvent, TransferState> {
  new() : super(TransferState()) {
    on<TransferEventReset>((event, emit) {
      emit(state.copyWith(id: "", size: 0));
    });

    on<TransferEventProcessed>((event, emit) {
      emit(state.copyWith(id: event.id, size: event.size));
    });
  }
}
