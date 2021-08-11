import 'package:flutter/material.dart';
import 'package:flutter_custom_calendar/flutter_custom_calendar.dart';
import 'package:flutter_custom_calendar/style/style.dart';
import 'package:provider/provider.dart';

import 'base_day_view.dart';

/**
 * 默认的利用组合widget的方式构造item
 */
//class DefaultCombineDayWidget extends StatelessWidget {
//  DateModel dateModel;
//
//  DefaultCombineDayWidget(this.dateModel);
//
//  @override
//  Widget build(BuildContext context) {
//    return Container(
//      margin: EdgeInsets.only(top: 5, bottom: 5),
//      decoration: dateModel.isSelected
//          ? new BoxDecoration(color: Colors.red, shape: BoxShape.circle)
//          : null,
//      child: new Stack(
//        alignment: Alignment.center,
//        children: <Widget>[
//          new Column(
//            mainAxisSize: MainAxisSize.max,
//            crossAxisAlignment: CrossAxisAlignment.center,
//            children: <Widget>[
//              //公历
//              new Expanded(
//                child: Center(
//                  child: new Text(
//                    dateModel.day.toString(),
//                    style: currentMonthTextStyle,
//                  ),
//                ),
//              ),
//
//              //农历
//              new Expanded(
//                child: Center(
//                  child: new Text(
//                    "${dateModel.lunarString}",
//                    style: lunarTextStyle,
//                  ),
//                ),
//              ),
//            ],
//          )
//        ],
//      ),
//    );
//  }
//}

class DefaultCombineMonthWidget extends BaseCombineDayWidget {
  DefaultCombineMonthWidget(DateModel dateModel) : super(dateModel);

  @override
  Widget getNormalWidget(DateModel dateModel) {
    return Builder(builder: (BuildContext context) {
      return Container(
        height: Provider.of<CalendarProvider>(context, listen: false).calendarConfiguration.itemSize,
        // color: Colors.red,
        child: new Stack(
          alignment: Alignment.center,
          children: <Widget>[
            new Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                //公历
                new Expanded(
                  child: Center(
                    child: new Text(
                      dateModel.month.toString(),
                      style: dateModel.isCurrentMonth ? currentDayTextStyle : currentMonthTextStyle,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      );
    });
  }

  @override
  Widget getSelectedWidget(DateModel dateModel) {
    return Builder(builder: (BuildContext context) {
      return Container(
        foregroundDecoration: new BoxDecoration(border: Border.all(width: 2, color: Colors.blue)),
        height: Provider.of<CalendarProvider>(context, listen: false).calendarConfiguration.itemSize,
        child: new Stack(
          alignment: Alignment.center,
          children: <Widget>[
            new Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                //公历
                new Expanded(
                  child: Center(
                    child: new Text(
                      dateModel.day.toString(),
                      style: currentMonthTextStyle,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      );
    });
  }
}
