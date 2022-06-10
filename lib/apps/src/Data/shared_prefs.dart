import 'package:expence_generator/apps/src/Data/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedDb get db => SharedDb();

class SharedDb {
  SharedPreferences? _prefs;
  static final SharedDb _singleton = SharedDb._internal();

  factory SharedDb() {
    return _singleton;
  }

  SharedDb._internal();
  SharedPreferences get prefs => _prefs!;
  Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future putUpdateData(ExpenceInputModel model) async {
    await prefs.setString(model.uqIdx, model.toJson());
  }

  Future deleteData(String uqIdx) async {
    await prefs.remove(uqIdx);
  }

  Future<List<ExpenceInputModel>> getDatas() async {
    List<ExpenceInputModel> outData = [];
    final sets = prefs.getKeys();
    await Future.forEach(sets, (String key) async {
      final data = prefs.getString(key);
      outData.add(ExpenceInputModel.fromJson(data!));
    });
    return outData;
  }
}
