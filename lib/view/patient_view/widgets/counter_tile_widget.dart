import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class CounterTileWidget extends StatelessWidget {
  String title;
  int value;
  VoidCallback onIncrement;
  VoidCallback onDecrement;
  CounterTileWidget({super.key,
    required this.title,
    required this.value,
    required this.onIncrement,
    required this.onDecrement
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title,style:  Theme.of(context).textTheme.bodyMedium,),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(onPressed: onDecrement, icon: Icon(Icons.remove)),
          SizedBox(
            width: 32.w,
              child: Text('$value', textAlign: TextAlign.center,style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),)),
          IconButton(onPressed: onIncrement, icon: Icon(Icons.add))
        ],
      ),
    );
  }
}
