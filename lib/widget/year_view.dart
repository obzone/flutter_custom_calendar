import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_calendar/configuration.dart';
import 'package:flutter_custom_calendar/flutter_custom_calendar.dart';
import 'package:flutter_custom_calendar/utils/LogUtil.dart';
import 'package:flutter_custom_calendar/utils/date_util.dart';
import 'package:provider/provider.dart';

/**
 * 年视图，只显示本年的月份
 */
class YearView extends StatefulWidget {
  final int year;
  final int month;
  final DateModel firstDayOfYear;
  final CalendarConfiguration configuration;

  const YearView({@required this.year, @required this.month, this.firstDayOfYear, this.configuration});

  @override
  _YearViewState createState() => _YearViewState();
}

class _YearViewState extends State<YearView> {
  List<DateModel> items;

  Map<DateModel, Object> extraDataMap; //自定义额外的数据

  @override
  void initState() {
    super.initState();
    extraDataMap = widget.configuration.extraDataMap;
    items = DateUtil.initCalendarForYearView(
      widget.year,
      widget.month,
      widget.firstDayOfYear.getDateTime(),
      minSelectDate: widget.configuration.minSelectDate,
      maxSelectDate: widget.configuration.maxSelectDate,
      extraDataMap: extraDataMap,
      offset: widget.configuration.offset,
    );

    //第一帧后,添加监听，generation发生变化后，需要刷新整个日历
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      Provider.of<CalendarProvider>(context, listen: false).generation.addListener(() async {
        items = DateUtil.initCalendarForYearView(
          widget.year,
          widget.month,
          widget.firstDayOfYear.getDateTime(),
          minSelectDate: widget.configuration.minSelectDate,
          maxSelectDate: widget.configuration.maxSelectDate,
          extraDataMap: extraDataMap,
          offset: widget.configuration.offset,
        );
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    CalendarProvider calendarProvider = Provider.of<CalendarProvider>(context, listen: false);

    CalendarConfiguration configuration = calendarProvider.calendarConfiguration;
    return new GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, mainAxisSpacing: 10, crossAxisSpacing: 10),
        itemCount: 12,
        itemBuilder: (context, index) {
          DateModel dateModel = items[index];
          //判断是否被选择
          switch (configuration.selectMode) {
            case CalendarSelectedMode.multiSelect:
              if (calendarProvider.selectedDateList.contains(dateModel)) {
                dateModel.isSelected = true;
              } else {
                dateModel.isSelected = false;
              }
              break;
            case CalendarSelectedMode.singleSelect:
              if (calendarProvider.selectDateModel?.month == dateModel.month && calendarProvider.selectDateModel?.year == dateModel.year) {
                dateModel.isSelected = true;
                print(dateModel);
              } else {
                dateModel.isSelected = false;
              }
              break;
            case CalendarSelectedMode.mutltiStartToEndSelect:
              if (calendarProvider.selectedDateList.contains(dateModel)) {
                dateModel.isSelected = true;
              } else {
                dateModel.isSelected = false;
              }
              break;
          }

          return MonthItemContainer(
              dateModel: dateModel,
              clickCall: () {
                setState(() {});
                // 选中之后要下钻到月份视图
              });
        });
  }
}

/**
 * 多选模式，包装item，这样的话，就只需要刷新当前点击的item就行了，不需要刷新整个页面
 */
class MonthItemContainer extends StatefulWidget {
  final DateModel dateModel;

  final GestureTapCallback clickCall;
  const MonthItemContainer({Key key, this.dateModel, this.clickCall}) : super(key: key);

  @override
  MonthItemContainerState createState() => MonthItemContainerState();
}

class MonthItemContainerState extends State<MonthItemContainer> {
  DateModel dateModel;
  CalendarConfiguration configuration;
  CalendarProvider calendarProvider;

  ValueNotifier<bool> isSelected;

  @override
  void initState() {
    super.initState();
    dateModel = widget.dateModel;
    isSelected = ValueNotifier(dateModel.isSelected);
  }

  /**
   * 提供方法给外部，可以调用这个方法进行刷新item是否选中状态
   */
  void refreshItem(bool v) {
    /**
        Exception caught by gesture
        The following assertion was thrown while handling a gesture:
        setState() called after dispose()
     */
    v ??= false;
    if (mounted) {
      setState(() {
        dateModel.isSelected = v;
      });

      if (widget.clickCall != null) {
        widget.clickCall();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
//    LogUtil.log(TAG: this.runtimeType, message: "ItemContainerState build");
    calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
    configuration = calendarProvider.calendarConfiguration;

    return GestureDetector(
      //点击整个item都会触发事件
      behavior: HitTestBehavior.opaque,
      onTap: () {
        LogUtil.log(TAG: this.runtimeType, message: "GestureDetector onTap: $dateModel}");

        //范围外不可点击
        if (!dateModel.isInRange) {
          return;
        }

        // 点击直接下钻到选中的月份视图
        // 通知月份发生变化
        calendarProvider.lastClickDateModel = dateModel;
        calendarProvider.expandStatus.value = !calendarProvider.expandStatus.value;

        //月份的变化
        configuration.monthChangeListeners.forEach((listener) {
          listener(dateModel.year, dateModel.month);
        });
      },
      child: configuration.monthWidgetBuilder(dateModel),
    );
  }

  @override
  void deactivate() {
//    LogUtil.log(
//        TAG: this.runtimeType, message: "ItemContainerState deactivate");
    super.deactivate();
  }

  @override
  void dispose() {
//    LogUtil.log(TAG: this.runtimeType, message: "ItemContainerState dispose");
    super.dispose();
  }

  @override
  void didUpdateWidget(MonthItemContainer oldWidget) {
//    LogUtil.log(
//        TAG: this.runtimeType, message: "ItemContainerState didUpdateWidget");
    super.didUpdateWidget(oldWidget);
  }
}
