import 'package:get/get.dart';
import 'package:money_record/data/models/history_model.dart';
import 'package:money_record/data/sources/source_history.dart';

class CDetailHistory extends GetxController {
  final _data = HistoryModel().obs;
  HistoryModel get data => _data.value;

  getData(idUser, date, type) async {
    HistoryModel? history = await SourceHistory.detail(idUser, date, type);
    _data.value = history ?? HistoryModel();
    update();
  }
}
