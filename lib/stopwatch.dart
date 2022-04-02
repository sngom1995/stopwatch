import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stopwatch/platform_alert.dart';

class StopWatch extends StatefulWidget {
  const StopWatch({Key? key, this.name, this.email}) : super(key: key);
  final String? name;
  final String? email;
  static const stopwatchRoute = '/stopwatch';

  @override
  _StopWatchState createState() => _StopWatchState();
}

class _StopWatchState extends State<StopWatch> {
  final laps = <int>[];
  late int milliseconds;
  late Timer timer;
  bool isTicking = true;
  final itemHeight = 60.0;
  final scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    milliseconds = 0;
    timer = Timer.periodic(Duration(microseconds: 100), _onTick);
  }

  void _onTick(Timer time) {
    setState(() {
      milliseconds += 100;
    });
  }

  void _lap() {
    setState(() {
      laps.add(milliseconds);
      milliseconds = 0;
      scrollController.animateTo(
        itemHeight * laps.length,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    String? name = ModalRoute.of(context)?.settings.arguments as String?;
    return Scaffold(
      appBar: AppBar(
        title: Text(name!),
      ),
      body: Column(
        children: [
          Expanded(child: _buildCounter(context)),
          Expanded(child: _buildLapDisplay()),
        ],
      ),
    );
  }

  void _startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), _onTick);
    setState(() {
      isTicking = true;
      laps.clear();
    });
  }

  void _stopTimer(BuildContext context) {
    timer.cancel();
    setState(() {
      isTicking = false;
    });
    /*final totalRuntime =
        laps.fold(milliseconds, (total, lap) => (total as int) + lap);
    final alert = PlatformAlert(
      title: 'Run Completed!',
      message: 'Total Run Time is ${_secondsText(totalRuntime)}.',
    );
    alert.show(context);*/
    final controller =
        showBottomSheet(context: context, builder: _buildRunCompleteSheet);
    Future.delayed(Duration(seconds: 5)).then((_) => controller.close());
  }

  Widget _buildRunCompleteSheet(BuildContext context) {
    final totalRuntime =
        laps.fold(milliseconds, (total, lap) => (total as int) + lap);
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
        child: Container(
      color: Theme.of(context).cardColor,
      width: double.infinity,
      child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Run Finished!', style: textTheme.headline6),
            Text('Total Run Time is ${_secondsText(totalRuntime)}.')
          ])),
    ));
  }

  String _secondsText(int milliseconds) {
    final seconds = milliseconds / 1000;
    return '$seconds seconds';
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Widget _buildLapDisplay() {
    return Scrollbar(
        controller: scrollController,
        child: ListView.builder(
          controller: scrollController,
          //primary: true,
          itemExtent: itemHeight,
          itemCount: laps.length,
          itemBuilder: (context, index) {
            return ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 50),
              title: Text('Lap ${index + 1}'),
              trailing: Text(_secondsText(laps[index])),
            );
          },
        ));
  }

  Widget _buildCounter(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Lap ${laps.length + 1}',
            style: Theme.of(context)
                .textTheme
                .subtitle1
                ?.copyWith(color: Colors.white),
          ),
          Text(
            _secondsText(milliseconds),
            style: Theme.of(context)
                .textTheme
                .headline4
                ?.copyWith(color: Colors.white),
          ),
          SizedBox(
            height: 20,
          ),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.green),
              foregroundColor: MaterialStateProperty.all(Colors.white)),
          child: Text('Start'),
          onPressed: isTicking ? null : _startTimer,
        ),
        SizedBox(
          width: 20,
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.yellow),
          ),
          child: Text('Lap'),
          onPressed: isTicking ? _lap : null,
        ),
        SizedBox(width: 20),
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => isTicking ? _stopTimer(context) : null,
            child: Text('Stop'),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red),
                foregroundColor: MaterialStateProperty.all(Colors.white)),
          ),
        ),
      ],
    );
  }
}
