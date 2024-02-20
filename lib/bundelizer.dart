library bundelizer;

import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:bundelizer/uuid_generator.dart';

class Bundelizer {

  ZipEncoder? _encoder;
  OutputStream? _os;
  UUIDGenerator _generator;

  Bundelizer():_generator=UUIDGenerator();

  void start() {
    _encoder = ZipEncoder();
    _os = OutputStream();
    _encoder!.startEncode(_os);
  }

  void addFields(Object fields) {
    var jsonData = jsonEncode(fields);
    _encoder?.addFile(ArchiveFile.string('fields.json',jsonData));
  }

  void addBlob(String name, ByteData data) {
    _encoder?.addFile(ArchiveFile('blobs/$name',0,data));
  }

  List<int> finish() {
    _encoder?.endEncode();
    return _os!.getBytes();
  }

  UUIDGenerator get generator {
    return _generator;
  }
}