part of 'transfer_bloc.dart';

@freezed
sealed class TransferState with _$TransferState {
  const factory TransferState({@Default("") String id, @Default(0) int size}) =
      _TransferState;
}
