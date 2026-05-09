import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taco/pages/add_pin_page.dart';
import 'package:taco/l10n/app_localizations.dart';
import 'package:taco/services/todo_storage.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final TextEditingController _contentCtrl = TextEditingController();
  final TextEditingController _remarkCtrl = TextEditingController();
  final ScrollController _remarkScrollCtrl = ScrollController();


  DateTime? _ddl;
  bool _saving = false;
  bool emptyContent = false;
  bool canPop = true;

  @override
  void dispose() {
    _contentCtrl.dispose();
    _remarkCtrl.dispose();
    _remarkScrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialEntryMode: DatePickerEntryMode.calendar,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            useMaterial3: false, // date picker do not use m3
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Color.fromARGB(255, 40, 110, 240),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );


    if (picked != null) {
      setState(() => _ddl = picked);
    }
  }

  Future<void> _save() async {
    final content = _contentCtrl.text.trim();
    final remark = _remarkCtrl.text.trim();

    if (content.isEmpty) {
      setState(() {
        emptyContent = true;
      });
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 80));
      HapticFeedback.mediumImpact();
      return;
    }

    setState(() => _saving = true);
    try {
      await TodoStorage.addTodo(content, remark, _ddl, false);
      if (mounted) {
        HapticFeedback.mediumImpact();
        FocusScope.of(context).unfocus();
        await Future.delayed(Duration(milliseconds: 200));
        if (context.mounted) Navigator.pop(context, true);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }


  String _formatZH(DateTime d) {
    final dateZN = ["", "一", "二", "三", "四", "五", "六", "日"];
    return "${d.year}年${d.month}月${d.day}日 周${dateZN[d.weekday]}";
  }

  String _formatEN(DateTime d) {
    final dateEN = ["", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
    final monthEN = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return "${dateEN[d.weekday]} ${monthEN[d.month]} ${d.day} ${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    final ddlText = _ddl == null
        ? t.setDeadline
        : (locale.languageCode == 'zh'
        ? _formatZH(_ddl!)
        : _formatEN(_ddl!));

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 237, 237, 237),

      body: Column(
        children: [
          const SizedBox(height: 45),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                SizedBox(
                  height: 80,
                  child: Row(
                    children: [
                      SizedBox(width: 4),
                      Text(t.addTask, style: TextStyle(fontSize: 32)),
                    ],
                  ),
                ),
                const Spacer(),
                Material(
                  shape: CircleBorder(),
                  color: Colors.white,
                  child: IconButton(
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      await Future.delayed(const Duration(milliseconds: 200));

                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => AddPinPage()),
                      );

                      if (!mounted || result == null) return;

                      final map = result as Map<String, dynamic>;

                      await TodoStorage.addTodo(
                        (map["content"] ?? "") as String,
                        (map["remark"] ?? "") as String,
                        map["ddl"] == null
                            ? null
                            : DateTime.fromMillisecondsSinceEpoch(map["ddl"] as int),
                        false,
                      );

                      if (context.mounted) Navigator.pop(context, true);

                    },

                    icon: const Icon(Icons.pin_outlined),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 1) content
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _contentCtrl,
                      autofocus: true,
                      minLines: 1,
                      maxLines: 2,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'\n')),
                      ],
                      cursorColor: const Color.fromARGB(255, 40, 110, 240),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        counterText: "",
                        hintText: emptyContent
                            ? t.contentRequired
                            : t.addContentHint,
                        hintStyle: TextStyle(
                          color: emptyContent ? Colors.red : Colors.grey,
                        ),
                      ),
                      style: const TextStyle(fontSize: 18),
                    ),

                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.note_outlined, color: Colors.grey),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Scrollbar(
                      controller: _remarkScrollCtrl,
                      thumbVisibility: true,
                      radius: const Radius.circular(8),
                      thickness: 2,
                      child: TextField(
                        controller: _remarkCtrl,
                        scrollController: _remarkScrollCtrl,
                        cursorColor: const Color.fromARGB(255, 40, 110, 240),
                        decoration: InputDecoration(
                          hintText: t.addRemarkHint,
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(fontSize: 16),
                        minLines: 1,
                        maxLines: 5,

                        onChanged: (value) {
                          // avoid empty line switch
                          if (value.trim().isEmpty && value.contains('\n')) {
                            _remarkCtrl.text = '';
                            _remarkCtrl.selection = const TextSelection.collapsed(offset: 0);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 3) date
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      enableFeedback: false,
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        _pickDate();
                      },
                      onLongPress: () async {
                        HapticFeedback.mediumImpact();
                        await Future.delayed(Duration(milliseconds: 80));
                        HapticFeedback.mediumImpact();

                        setState(() {
                          _ddl = null;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                ddlText,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _ddl == null ? Colors.grey : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Material(
                  shape: const CircleBorder(),
                  color: Colors.white,
                  child: IconButton(
                    onPressed: () async {
                      if (canPop) {
                        setState(() {
                          canPop = false;
                        });
                        FocusScope.of(context).unfocus();
                        await Future.delayed(const Duration(milliseconds: 200));
                        if (context.mounted) Navigator.pop(context);
                      }
                      return;
                    },
                    icon: const Icon(Icons.arrow_back),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(width: 10),
                Material(
                  shape: const CircleBorder(),
                  color: Colors.white,
                  child: IconButton(
                    onPressed: () {
                      if (!_saving) _save();
                    },
                    icon: Icon(Icons.done, color: const Color.fromARGB(255, 40, 110, 240)),
                    padding: const EdgeInsets.all(12),
                    color: const Color.fromARGB(255, 40, 110, 240),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
