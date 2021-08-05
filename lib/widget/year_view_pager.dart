import 'package:flutter/material.dart';
import 'package:flutter_custom_calendar/widget/Year_view.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_custom_calendar/configuration.dart';
import 'package:flutter_custom_calendar/flutter_custom_calendar.dart';
import 'package:flutter_custom_calendar/utils/LogUtil.dart';

class YearViewPager extends StatefulWidget {
  const YearViewPager({Key key}) : super(key: key);

  @override
  _YearViewPagerState createState() => _YearViewPagerState();
}

class _YearViewPagerState extends State<YearViewPager> with AutomaticKeepAliveClientMixin {
  int lastMonth; //保存上一个月份，不然不知道月份发生了变化
  CalendarProvider calendarProvider;

//  PageController newPageController;

  @override
  void initState() {
    super.initState();
    LogUtil.log(TAG: this.runtimeType, message: "YearViewPager initState");

    calendarProvider = Provider.of<CalendarProvider>(context, listen: false);

    lastMonth = calendarProvider.lastClickDateModel.month;
  }

  @override
  void dispose() {
    LogUtil.log(TAG: this.runtimeType, message: "YearViewPager dispose");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    LogUtil.log(TAG: this.runtimeType, message: "YearViewPager build");

    //    获取到当前的CalendarProvider对象,设置listen为false，不需要刷新
    CalendarProvider calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
    CalendarConfiguration configuration = calendarProvider.calendarConfiguration;
    return Container(
      height: configuration.itemSize ?? MediaQuery.of(context).size.width / 7,
      child: PageView.builder(
        onPageChanged: (position) {
          if (calendarProvider.expandStatus.value == true) {
            return;
          }

          LogUtil.log(TAG: this.runtimeType, message: "YearViewPager PageView onPageChanged,position:$position");
          DateModel firstDayOfYear = configuration.yearList[position];
          int currentMonth = firstDayOfYear.month;
//          周视图的变化
          configuration.yearChangeListeners.forEach((listener) {
            listener(firstDayOfYear.year, firstDayOfYear.month);
          });
          if (lastMonth != currentMonth) {
            LogUtil.log(TAG: this.runtimeType, message: "YearViewPager PageView monthChange:currentMonth:$currentMonth");
            configuration.monthChangeListeners.forEach((listener) {
              listener(firstDayOfYear.year, firstDayOfYear.month);
            });
            lastMonth = currentMonth;
            if (calendarProvider.lastClickDateModel == null || calendarProvider.lastClickDateModel.month != currentMonth) {
              DateModel temp = new DateModel();
              temp.year = firstDayOfYear.year;
              temp.month = firstDayOfYear.month;
              temp.day = firstDayOfYear.day + 14;
              print('83 周视图的变化: $temp');
              calendarProvider.lastClickDateModel = temp;
            }
          }
//          calendarProvider.lastClickDateModel = configuration.YearList[position]
//            ..day += 4;
        },
        controller: calendarProvider.calendarConfiguration.yearController,
        itemBuilder: (context, index) {
          DateModel dateModel = configuration.yearList[index];
          print('dateModel: $dateModel');
          return new YearView(
            year: dateModel.year,
            month: dateModel.month,
            firstDayOfYear: dateModel,
            configuration: calendarProvider.calendarConfiguration,
          );
        },
        itemCount: configuration.yearList.length,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
