import 'dart:convert';
import 'package:d_input/d_input.dart';
import 'package:d_view/d_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:money_record/config/app_colors.dart';
import 'package:money_record/config/app_formats.dart';
import 'package:money_record/data/sources/source_history.dart';
import 'package:money_record/views/controllers/c_update_history.dart';
import 'package:money_record/views/controllers/c_user.dart';

class UpdatedHistoryPage extends StatefulWidget {
  const UpdatedHistoryPage(
      {Key? key, required this.date, required this.idHistory})
      : super(key: key);
  final String date;
  final String idHistory;

  @override
  State<UpdatedHistoryPage> createState() => _UpdatedHistoryPageState();
}

class _UpdatedHistoryPageState extends State<UpdatedHistoryPage> {
  final cUpdateHistory = Get.put(CUpdateHistory());
  final cUser = Get.put(CUser());
  final controllerName = TextEditingController();
  final controllerPrice = TextEditingController();

  updateHistory() async {
    bool success = await SourceHistory.update(
      widget.idHistory,
      cUser.data.idUser!,
      cUpdateHistory.date,
      cUpdateHistory.type,
      jsonEncode(cUpdateHistory.items),
      cUpdateHistory.total.toString(),
    );
    if (success) {
      Future.delayed(const Duration(milliseconds: 3000), () {
        Get.back(result: true);
      });
    }
  }

  @override
  void initState() {
    cUpdateHistory.init(cUser.data.idUser, widget.date);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DView.appBarLeft('Update'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Tanggal',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Obx(
                () {
                  return Text(
                    cUpdateHistory.date,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  );
                },
              ),
              DView.spaceWidth(),
              ElevatedButton.icon(
                onPressed: () async {
                  DateTime? result = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2022, 01, 01),
                      lastDate: DateTime(DateTime.now().year + 1));
                  if (result != null) {
                    cUpdateHistory
                        .setDate(DateFormat('yyyy-MM-dd').format(result));
                  }
                },
                icon: const Icon(Icons.event),
                label: const Text('Pilih'),
              ),
            ],
          ),
          DView.spaceHeight(),
          const Text(
            'Tipe',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          DView.spaceHeight(8),
          Obx(() {
            return DropdownButtonFormField(
              value: cUpdateHistory.type,
              items: ['Pemasukan', 'Pengeluaran'].map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e),
                );
              }).toList(),
              onChanged: (value) {
                cUpdateHistory.setType(value);
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
            );
          }),
          DView.spaceHeight(20),
          DInput(
            controller: controllerName,
            hint: 'Contoh: Pulsa',
            title: 'Sumber/Objek Pengeluaran',
          ),
          DView.spaceHeight(),
          DInput(
            controller: controllerPrice,
            hint: 'Rp. 0',
            title: 'Harga',
            inputType: TextInputType.number,
          ),
          DView.spaceHeight(20),
          ElevatedButton(
            onPressed: () {
              cUpdateHistory.addItem({
                'name': controllerName.text,
                'price': controllerPrice.text,
              });
              controllerName.clear();
              controllerPrice.clear();
            },
            child: const Text('Tambah ke Items'),
          ),
          DView.spaceHeight(30),
          Center(
            child: Container(
              height: 6,
              width: MediaQuery.of(context).size.width * 0.3,
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          DView.spaceHeight(30),
          const Text(
            'Items',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          DView.spaceHeight(8),
          GetBuilder<CUpdateHistory>(
            builder: (_) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _.items.isEmpty ? Colors.grey : AppColors.primary,
                  ),
                ),
                child: Wrap(
                  runSpacing: 8,
                  spacing: 8,
                  children: List.generate(_.items.length, (index) {
                    return Chip(
                      backgroundColor: AppColors.primary,
                      label: Text(
                        _.items[index]['name'],
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      deleteIcon: const Icon(
                        Icons.clear,
                        color: Colors.white,
                      ),
                      onDeleted: () => _.deleteItem(index),
                    );
                  }),
                ),
              );
            },
          ),
          DView.spaceHeight(20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              DView.spaceWidth(8),
              Obx(() {
                return Text(
                  AppFormat.currency(cUpdateHistory.total.toString()),
                  style: Theme.of(context).textTheme.headline5!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                );
              })
            ],
          ),
          DView.spaceHeight(40),
          Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () => updateHistory(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    'SUBMIT',
                    style: Theme.of(context).textTheme.headline6!.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
