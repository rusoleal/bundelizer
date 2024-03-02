/// Bundelizer library. Bundle and compress data in a easy way.
library bundelizer;

import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:bundelizer/uuid_generator.dart';

/// Main class for bundelize data
class Bundelizer {
  ZipEncoder? _encoder;
  OutputStream? _os;
  final UUIDGenerator _generator;

  /// Constructor for bundelizer class
  Bundelizer() : _generator = UUIDGenerator();

  /// start bundle process.
  ///
  /// Bundelize data in memory.
  void start() {
    _encoder = ZipEncoder();
    _os = OutputStream();
    _encoder!.startEncode(_os);
  }

  /// Add json compatible fields
  ///
  /// Compatible json fields:
  ///   null
  ///   bool
  ///   number
  ///   List<>
  ///   Map<>
  void addFields(Object fields) {
    var jsonData = jsonEncode(fields);
    _encoder?.addFile(ArchiveFile.string('fields.json', jsonData));
  }

  /// Add ByteData
  void addBlob(String name, ByteData data) {
    _encoder?.addFile(ArchiveFile('blobs/$name', 0, data));
  }

  /// Finish bundelize process.
  ///
  /// Returns compressed buffer in order to store it.
  List<int> finish() {
    _encoder?.endEncode();
    return _os!.getBytes();
  }

  /// get uuid generator in order to store blobs with unique id
  UUIDGenerator get generator {
    return _generator;
  }

  /// Static method to read bundelized buffer
  ///
  /// Returns a 'BundleSnapshot' with fields and blobs.
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

/// Snapshot with fields and blobs
class BundleSnapshot {
  /// json objects
  final Object? fields;

  /// Blobs map
  final Map<String, Uint8List> blobs;

  /// Default constructor
  const BundleSnapshot({this.fields, this.blobs = const {}});
}
