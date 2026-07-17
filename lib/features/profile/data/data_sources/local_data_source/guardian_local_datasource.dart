import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/child_of_parent.dart';

abstract class GuardianLocalDataSource {
  Future<void> cacheChildren(List<ChildCardModel> children);
  Future<List<ChildCardModel>?> getCachedChildren();
}

class GuardianLocalDataSourceImpl implements GuardianLocalDataSource {
  final SharedPreferences sharedPreferences;

  GuardianLocalDataSourceImpl({required this.sharedPreferences});

  static const CACHE_KEY = 'CACHE_GUARDIAN_CHILDREN';

  @override
  Future<void> cacheChildren(List<ChildCardModel> children) async {
    // تحويل القائمة إلى JSON String
    final jsonList = jsonEncode(children.map((e) => e.toJson()).toList());
    await sharedPreferences.setString(CACHE_KEY, jsonList);
  }

  @override
  Future<List<ChildCardModel>?> getCachedChildren() async {
    final jsonString = sharedPreferences.getString(CACHE_KEY);
    if (jsonString != null) {
      final List<dynamic> decodedList = jsonDecode(jsonString);
      return decodedList
          .map((e) => ChildCardModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return null;
  }
}