library bundelizer;

import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:bundelizer/uuid_generator.dart';

class Bundelizer {

  ZipEncoder? _encoder;
  OutputStream? _os;
  final UUIDGenerator _generator;

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

  static BundleSnapshot decode(Uint8List data) {

    Archive ar = ZipDecoder().decodeBytes(data);
    final fields = ar.findFile('fields.json');
    if (fields == null) {
      return const BundleSnapshot();
    }

    OutputStream os = OutputStream(size: fields.size);
    fields.writeContent(os);
    var bytes = os.getBytes();
    String source = String.fromCharCodes(bytes);
    var json = jsonDecode(source);

    Map<String, Uint8List> blobs = {};
    String prefix = 'blobs/';
    for (var file in ar.files) {
      //print('${file.name} prefix: $prefix');
      if (file.isFile && file.name.startsWith(prefix)) {

        String id = file.name.replaceAll(prefix, '');
        OutputStream os = OutputStream(size: file.size);
        file.writeContent(os);
        var bytes = os.getBytes();
        var data = Uint8List.fromList(bytes);
        blobs[id] = data;
      }
    }

    return BundleSnapshot(fields: json, blobs: blobs);
  }
}

class BundleSnapshot {
  final Object? fields;
  final Map<String, Uint8List> blobs;

  const BundleSnapshot({this.fields, this.blobs=const {}});
}