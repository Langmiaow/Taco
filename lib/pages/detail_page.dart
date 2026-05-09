import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taco/pages/share_info_page.dart';
import 'package:taco/l10n/app_localizations.dart';
import 'package:taco/services/share_service.dart';
import 'package:taco/services/todo_storage.dart';

class DetailPage extends StatefulWidget {
  final int todoIndex;

  const DetailPage({super.key, required this.todoIndex});

  @override
  State<DetailPage> createState() => _DetailPage();
}

class _DetailPage extends State<DetailPage> {
  bool loading = true;
  bool isDone = false;
  bool showEdit = false;
  bool sharing = false;
  bool hasUpdated = false;
  String content = "";
  String remark = "";
  int? ddlTs;
  String ddlText = "";
  String _editContentInit = "";
  String _editRemarkInit = "";
  DateTime? _editDdlInit;
  bool emptyContent = false;
  bool unableToShare = false;

  //edit function
  final TextEditingController _contentCtrl = TextEditingController();
  final TextEditingController _remarkCtrl = TextEditingController();
  final ScrollController _editRemarkScrollCtrl = ScrollController();
  DateTime? _ddlEdit;

  String _dateFormatZH(DateTime d) {
    final dateCN = ["", "一", "二", "三", "四", "五", "六", "日"];
    return "${d.year}年${d.month}月${d.day}日 周${dateCN[d.weekday]}";
  }

  String _dateFormatEN(DateTime d) {
    final dateEN = [
      "",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];
    final monthEN = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return "${dateEN[d.weekday]} ${monthEN[d.month]} ${d.day} ${d.year}";
  }

  String _remainingDaysFormatZH(int d) {
    if (d < 0) {
      return "已过期";
    } else if (d == 0) {
      return "今天之内";
    } else {
      return "还剩 $d 天";
    }
  }

  String _remainingDaysFormatEN(int d) {
    if (d < 0) {
      return "Expired";
    } else if (d == 0) {
      return "Due today";
    } else if (d == 1) {
      return "$d day remaining";
    } else {
      return "$d days remaining";
    }
  }

  Future<void> _load() async {
    final data = await TodoStorage.readTodoList();
    final List todos = List.from(data["todos"] ?? []);
    final locale = Localizations.localeOf(context);

    final Map t = todos[widget.todoIndex] as Map;

    setState(() {
      loading = false;
      content = (t["content"] ?? "").toString();
      remark = (t["remark"] ?? "").toString();

      _contentCtrl.text = content;
      _remarkCtrl.text = remark;

      final rawDdl = t["ddl"];
      ddlTs = rawDdl;
      DateTime? parsed;
      if (rawDdl is int) parsed = DateTime.fromMillisecondsSinceEpoch(rawDdl);
      _ddlEdit = parsed;

      ddlText = parsed == null
          ? ""
          : (locale.languageCode == 'zh'
                ? _dateFormatZH(parsed)
                : _dateFormatEN(parsed));

      isDone = (t["isDone"] ?? false) == true;
    });
  }

  Future<void> _markDone() async {
    await TodoStorage.setDone(widget.todoIndex, true);

    setState(() {
      isDone = true;
    });

    HapticFeedback.mediumImpact();
    Navigator.pop(context, true);
  }

  Future<void> _confirmEdit() async {
    final newContent = _contentCtrl.text.trim();
    final newRemark = _remarkCtrl.text.trim();

    if (newContent.isEmpty) {
      setState(() {
        emptyContent = true;
      });
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 80));
      HapticFeedback.mediumImpact();
      return;
    }

    final data = await TodoStorage.readTodoList();
    final List todos = List.from(data["todos"] ?? []);
    if (widget.todoIndex < 0 || widget.todoIndex >= todos.length) return;

    final Map t = Map<String, dynamic>.from(todos[widget.todoIndex] as Map);
    t["content"] = newContent;
    t["remark"] = newRemark;
    t["ddl"] = _ddlEdit?.millisecondsSinceEpoch;
    todos[widget.todoIndex] = t;

    await TodoStorage.writeAllTodos(todos);

    HapticFeedback.mediumImpact();
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;

    setState(() {
      content = newContent;
      remark = newRemark;
      ddlTs = _ddlEdit?.millisecondsSinceEpoch;
      hasUpdated = true;
      showEdit = false;
      emptyContent = false;

      final locale = Localizations.localeOf(context);
      ddlText = _ddlEdit == null
          ? ""
          : (locale.languageCode == 'zh'
          ? _dateFormatZH(_ddlEdit!)
          : _dateFormatEN(_ddlEdit!));
    });
  }

  Future<void> _share() async {
    setState(() {
      sharing = true;
    });

    try {
      final pin = await ShareService.shareTodo(
        content: content,
        remark: remark,
        ddl: ddlTs,
      );

      if (!mounted) return;

      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => ShareInfoPage(pin: pin)));

      await Future.delayed(const Duration(milliseconds: 200));

      setState(() {
        unableToShare = false;
        sharing = false;
      });
    } catch (e) {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 80));
      HapticFeedback.mediumImpact();

      setState(() {
        unableToShare = true;
        sharing = false;
      });
    }
  }

  int _remainingDays(DateTime inp) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(inp.year, inp.month, inp.day);

    return targetDay.difference(today).inDays;
  }

  Color _remainingDaysColor(int inp) {
    if (inp < 0) {
      return const Color.fromARGB(255, 220, 226, 232);
    } else if (inp < 2) {
      return const Color.fromARGB(255, 251, 224, 236);
    } else if (inp < 15) {
      return const Color.fromARGB(255, 255, 241, 213);
    } else {
      return const Color.fromARGB(255, 207, 239, 207);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    _remarkCtrl.dispose();
    _editRemarkScrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final hasChanges =
        _contentCtrl.text.trim() != _editContentInit.trim() ||
        _remarkCtrl.text.trim() != _editRemarkInit.trim() ||
        (_ddlEdit?.millisecondsSinceEpoch !=
            _editDdlInit?.millisecondsSinceEpoch);

    return PopScope(
      canPop: !showEdit,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (showEdit) {
          setState(() {
            showEdit = false;
            emptyContent = false;
          });
          return;
        }
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 237, 237, 237),

        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),

            child: loading
                ? Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  )
                : showEdit
                ? const SizedBox()
                : Material(
                    color: isDone
                        ? Colors.white
                        : const Color.fromARGB(255, 40, 110, 240),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: isDone ? null : _markDone,
                      child: SizedBox(
                        height: 56,
                        child: Center(
                          child: Text(
                            t.markDone,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDone ? Colors.grey : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ),

        body: Column(
          children: [
            const SizedBox(height: 45),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 80,
                child: Row(
                  children: [
                    const SizedBox(width: 4),
                    Text(
                      showEdit ? t.editTask : t.detail,
                      style: const TextStyle(fontSize: 32),
                    ),
                    Spacer(),
                    if (!isDone && !loading) ...[
                      if (!showEdit)
                        Material(
                          shape: const CircleBorder(),
                          color: Colors.white,
                          child: IconButton(
                            onPressed: sharing ? null : _share,
                            icon: sharing
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color.fromARGB(255, 40, 110, 240),
                                    ),
                                  )
                                : unableToShare
                                ? Icon(Icons.error_outline)
                                : Icon(Icons.share),
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      const SizedBox(width: 10),
                      Material(
                        shape: const CircleBorder(),
                        color: Colors.white,
                        child: IconButton(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              if (!showEdit) {
                                _editContentInit = content;
                                _editRemarkInit = remark;
                                _editDdlInit = _ddlEdit;
                                _contentCtrl.text = content;
                                _remarkCtrl.text = remark;
                              }
                              showEdit = !showEdit;
                            });
                          },
                          icon: Icon(showEdit ? Icons.edit_off : Icons.edit),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                    if (!showEdit) ...[
                      const SizedBox(width: 10),
                      Material(
                        shape: const CircleBorder(),
                        color: Colors.white,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context, hasUpdated);
                          },
                          icon: const Icon(Icons.arrow_back),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (loading) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
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
                        child: showEdit
                            ? TextField(
                                controller: _contentCtrl,
                                minLines: 1,
                                maxLines: 2,
                                textInputAction: TextInputAction.done,
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(
                                    RegExp(r'\n'),
                                  ),
                                ],
                                cursorColor: Color.fromARGB(255, 40, 110, 240),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  counterText: "",
                                  hintText: emptyContent
                                      ? t.contentRequired
                                      : t.editContentHint,
                                  hintStyle: TextStyle(
                                    color: emptyContent
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                ),
                                style: const TextStyle(fontSize: 18),
                                onChanged: (_) {
                                  if (emptyContent) {
                                    setState(() => emptyContent = false);
                                  } else {
                                    setState(() {});
                                  }
                                },
                              )
                            : SelectableText(
                                content,
                                minLines: 1,
                                maxLines: 2,
                                style: TextStyle(fontSize: 18),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              if (showEdit || remark.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(width: 12),
                        const Icon(Icons.note_outlined, color: Colors.grey),
                        const SizedBox(width: 16),
                        Expanded(
                          child: showEdit
                              ? Scrollbar(
                                  controller: _editRemarkScrollCtrl,
                                  thumbVisibility: true,
                                  radius: const Radius.circular(8),
                                  thickness: 2,
                                  child: TextField(
                                    controller: _remarkCtrl,
                                    scrollController: _editRemarkScrollCtrl,
                                    cursorColor: Color.fromARGB(
                                      255,
                                      40,
                                      110,
                                      240,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: t.editRemarkHint,
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                    ),
                                    style: const TextStyle(fontSize: 16),
                                    minLines: 1,
                                    maxLines: 5,
                                    onChanged: (_) => setState(() {}),
                                  ),
                                )
                              : SelectableText(
                                  remark,
                                  minLines: 1,
                                  maxLines: 12,
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),

                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                ),
              ],
              if (showEdit || ddlText.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          child: showEdit
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: Material(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        child: InkWell(
                                          enableFeedback: false,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          onTap: () async {
                                            final picked = await showDatePicker(
                                              context: context,
                                              initialDate:
                                                  _ddlEdit ?? DateTime.now(),
                                              firstDate: DateTime(2020),
                                              lastDate: DateTime(2030),
                                              initialEntryMode:
                                                  DatePickerEntryMode.calendar,
                                              builder: (context, child) {
                                                return Theme(
                                                  data: Theme.of(context).copyWith(
                                                    useMaterial3: false,
                                                    colorScheme:
                                                        Theme.of(
                                                          context,
                                                        ).colorScheme.copyWith(
                                                          primary:
                                                              const Color.fromARGB(
                                                                255,
                                                                40,
                                                                110,
                                                                240,
                                                              ),
                                                          onPrimary:
                                                              Colors.white,
                                                          surface: Colors.white,
                                                          onSurface:
                                                              Colors.black,
                                                        ),
                                                  ),
                                                  child: child!,
                                                );
                                              },
                                            );

                                            if (picked != null) {
                                              final locale =
                                                  Localizations.localeOf(
                                                    context,
                                                  );
                                              setState(() {
                                                _ddlEdit = picked;
                                                ddlText =
                                                    locale.languageCode == 'zh'
                                                    ? _dateFormatZH(picked)
                                                    : _dateFormatEN(picked);
                                              });
                                            }
                                          },
                                          onLongPress: () async {
                                            HapticFeedback.mediumImpact();
                                            await Future.delayed(
                                              Duration(milliseconds: 80),
                                            );
                                            HapticFeedback.mediumImpact();

                                            setState(() {
                                              _ddlEdit = null;
                                              ddlText = "";
                                            });
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 16,
                                            ),
                                            child: Row(
                                              children: [
                                                const SizedBox(width: 12),
                                                const Icon(
                                                  Icons.calendar_today_outlined,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Text(
                                                    ddlText.isEmpty
                                                        ? t.setDeadline
                                                        : ddlText,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: _ddlEdit == null
                                                          ? Colors.grey
                                                          : Colors.black,
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
                                        onPressed: () {
                                          setState(() {
                                            _contentCtrl.text =
                                                _editContentInit;
                                            _remarkCtrl.text = _editRemarkInit;
                                            _ddlEdit = _editDdlInit;

                                            final locale =
                                                Localizations.localeOf(context);
                                            ddlText = _ddlEdit == null
                                                ? ""
                                                : (locale.languageCode == 'zh'
                                                      ? _dateFormatZH(
                                                          _editDdlInit!,
                                                        )
                                                      : _dateFormatEN(
                                                          _editDdlInit!,
                                                        ));
                                          });
                                        },
                                        icon: const Icon(Icons.restart_alt),
                                        padding: const EdgeInsets.all(12),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Material(
                                      shape: const CircleBorder(),
                                      color: Colors.white,
                                      child: IconButton(
                                        onPressed: hasChanges
                                            ? _confirmEdit
                                            : null,
                                        icon: Icon(
                                          Icons.done,
                                          color: hasChanges
                                              ? const Color.fromARGB(
                                                  255,
                                                  40,
                                                  110,
                                                  240,
                                                )
                                              : Colors.grey,
                                        ),
                                        padding: const EdgeInsets.all(12),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: isDone
                                            ? BorderRadius.circular(12)
                                            : BorderRadius.only(
                                                topLeft: Radius.circular(12),
                                                topRight: Radius.circular(12),
                                              ),
                                        color: Colors.white,
                                      ),
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 12),
                                          const Icon(
                                            Icons.calendar_today_outlined,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Text(
                                              ddlText,
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    if (!isDone)
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(12),
                                            bottomRight: Radius.circular(12),
                                          ),
                                          color: _remainingDaysColor(
                                            _remainingDays(_ddlEdit!),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const SizedBox(width: 16),
                                            Text(
                                              Localizations.localeOf(
                                                        context,
                                                      ).languageCode ==
                                                      'zh'
                                                  ? _remainingDaysFormatZH(
                                                      _remainingDays(_ddlEdit!),
                                                    )
                                                  : _remainingDaysFormatEN(
                                                      _remainingDays(_ddlEdit!),
                                                    ),
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
