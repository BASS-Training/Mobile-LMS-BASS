import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../../core/utils/local_storage.dart';
import '../models/catalog_course_model.dart';
import 'catalog_local_data_source.dart';

class CatalogLocalDataSourceImpl implements CatalogLocalDataSource {
  final AssetBundle assetBundle;

  CatalogLocalDataSourceImpl({AssetBundle? assetBundle})
    : assetBundle = assetBundle ?? rootBundle;

  @override
  Future<List<CatalogCourseModel>> getCatalog() async {
    final raw = await assetBundle.loadString('assets/data/catalog_dummy.json');
    final decoded = jsonDecode(raw);
    if (decoded is! Map || decoded['catalog'] is! List) {
      throw const FormatException('Format data katalog tidak valid.');
    }

    return (decoded['catalog'] as List)
        .whereType<Map>()
        .map(
          (item) => CatalogCourseModel.fromJson(
            item.map((key, value) => MapEntry(key.toString(), value)),
          ),
        )
        .toList();
  }

  @override
  Future<Set<String>> getEnrolledCourseIds() async {
    return LocalStorage.getCatalogEnrollments().toSet();
  }

  @override
  Future<void> enroll(String catalogId) {
    return LocalStorage.enrollCatalogCourse(catalogId);
  }
}
