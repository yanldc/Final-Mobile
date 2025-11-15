// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_card.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedCardAdapter extends TypeAdapter<SavedCard> {
  @override
  final int typeId = 1;

  @override
  SavedCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedCard(
      id: fields[0] as String,
      name: fields[1] as String,
      imageUrl: fields[2] as String?,
      smallImageUrl: fields[3] as String?,
      setName: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SavedCard obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.smallImageUrl)
      ..writeByte(4)
      ..write(obj.setName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
