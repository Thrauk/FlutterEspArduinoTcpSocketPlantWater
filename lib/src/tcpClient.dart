import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

// Create a variable that changes
// Use that variable to build your UI (build method)
// Change that variable in setState

class _HomePageState extends State<HomePage> {
  bool serverConnected = false;
  String text = '';
  String serverIp;
  String serverPort;
  String statusText = 'disconnected';
  String connectionButtonText = 'Connect';
  Color statusColor = Colors.red;
  Color connectionButtonColor = Colors.green;
  String subscribeText = 'unsubscribed';
  Color subscribeColor = Colors.red;
  Icon doorIcon = Icon(CupertinoIcons.lock_fill);
  String doorText = 'Locked';


  String temperature='-';
  String humidity='-';
  String tempLv1='-';
  String tempLv2='-';
  String tempLv3='-';
  String humidityThresh='-';

  String tempLv1Set = '';
  String tempLv2Set = '';
  String tempLv3Set = '';
  String humidityThreshSet = '';

  bool autoMode = false;


  Socket client;

  void initState() {
    super.initState();
  }

  void disposeClient() {
    client.close();
    setState(() {
      serverConnected = false;
      statusText = 'disconnected';
      connectionButtonText = 'Connect';
      statusColor = Colors.red;
      connectionButtonColor = Colors.green;
    });
  }

  String dataToString(String data)
  {
    double value = double.parse(data);
    value /= 100.0;
    return value.toString();
  }

  Future<void> connectToServer(String ip, String port) async {
    int portInt = int.parse(port);
    try {
      client = await Socket.connect(ip, portInt);
      setState(() {
        serverConnected = true;
        statusText = 'connected';
        connectionButtonText = 'Disconnect';
        statusColor = Colors.green;
        connectionButtonColor = Colors.red;
      });
      client.listen((value) {
        //String valueString = utf8.decode(value);
        String valueString = ascii.decode(value);
        try{
          List<String> extractedValues = valueString.split('n');
          print(extractedValues);
          setState(() {
            temperature = dataToString(extractedValues[0]);
            humidity = dataToString(extractedValues[1]);
            tempLv1 = dataToString(extractedValues[2]);
            tempLv2 = dataToString(extractedValues[3]);
            tempLv3 = dataToString(extractedValues[4]);
            humidityThresh = dataToString(extractedValues[5]);
          });

        } catch(e) {
          print("Error " + e);
        }

        print(valueString);
      });
    } catch (e) {
      statusText = 'error connecting';
    }
  }

  bool isInt(String s) {
    if (s == null) {
      return false;
    }
    return int.tryParse(s) != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: AlignmentDirectional.center,
                        height: 30,
                        decoration: BoxDecoration(
                          border: Border.all(),
                        ),
                        child: Text(
                          "Server ip",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(0.0),
                          isDense: true,
                        ),
                        onChanged: (String value) {
                          setState(() {
                            serverIp = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: AlignmentDirectional.center,
                        height: 30,
                        decoration: BoxDecoration(
                          border: Border.all(),
                        ),
                        child: Text(
                          "Port",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(0.0),
                          isDense: true,
                        ),
                        onChanged: (String value) {
                          setState(() {
                            serverPort = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (!serverConnected)
                      connectToServer(serverIp, serverPort);
                    else {
                      disposeClient();
                      temperature='-';
                      humidity='-';
                      tempLv1='-';
                      tempLv2='-';
                      tempLv3='-';
                      humidityThresh='-';
                      tempLv1Set = '';
                      tempLv2Set = '';
                      tempLv3Set = '';
                      humidityThreshSet = '';

                    }
                  },
                  child: Text(connectionButtonText),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(connectionButtonColor),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Server Status',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      statusText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Auto'),
                    Switch(
                      onChanged: (value){
                        if(value == false) {
                          client.write('mode=' + '0' + '\r'); // auto mode
                          sleep(Duration(milliseconds: 10));
                        }
                        else {
                          client.write('mode=' + '1' + '\r'); // manual mode
                          sleep(Duration(milliseconds: 10));
                        }
                        setState(
                                () {
                              autoMode = value;
                            }); },
                      value: autoMode,
                    ),
                    Text('Manual'),
                  ],
                ),
                (serverConnected && !autoMode)
                    ? Column(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Temperature: ',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 10),
                            Text(temperature + " °C"),
                            const SizedBox(width: 5),
                            Icon(CupertinoIcons.thermometer),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Humidity: ',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 10),
                            Text(humidity + '%'),
                            const SizedBox(width: 5),
                            Icon(CupertinoIcons.drop_fill),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Temp level 1: ',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 10),
                            Text(tempLv1 + ' °C'),
                            const SizedBox(width: 5),
                            Icon(Icons.wb_sunny_outlined),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Temp level 2: ',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 10),
                            Text(tempLv2 + ' °C'),
                            const SizedBox(width: 5),
                            Icon(Icons.wb_sunny),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Temp level 3: ',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 10),
                            Text(tempLv3 + ' °C'),
                            const SizedBox(width: 5),
                            Icon(CupertinoIcons.flame_fill),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Humidity thresh: ',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 10),
                            Text(humidityThresh + '%'),
                            const SizedBox(width: 5),
                            Icon(CupertinoIcons.drop),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    Column(
                      children: <Widget>[
                        Text(
                          'Settings control',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Temp level 1: ',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 50,
                              child: TextField(
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(0.0),
                                  isDense: true,
                                ),
                                onChanged: (String value) {
                                  setState(() {
                                    //serverIp = value;
                                    tempLv1Set = value;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 10,),
                            ElevatedButton(
                              onPressed: () {
                                try {
                                  if(tempLv1Set != '') {
                                    client.write('temp1=' + tempLv1Set + '\r');
                                    sleep(Duration(milliseconds: 10));
                                  }
                                  //client.flush();
                                  setState(() {

                                  });
                                } catch(e) {
                                  print('Error' + e);
                                }

                              },
                              child: Text('Apply'),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(Colors.blueGrey),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Temp level 2: ',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 50,
                              child: TextField(
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(0.0),
                                  isDense: true,
                                ),
                                onChanged: (String value) {
                                  setState(() {
                                    //serverIp = value;
                                    tempLv2Set = value;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 10,),
                            ElevatedButton(
                              onPressed: () {
                                try {
                                  if(tempLv2Set != '') {
                                    client.write('temp2=' + tempLv2Set + '\r');
                                    sleep(Duration(milliseconds: 10));
                                  }
                                  //client.flush();
                                  setState(() {

                                  });
                                } catch(e) {
                                  print('Error' + e);
                                }

                              },
                              child: Text('Apply'),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(Colors.blueGrey),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Temp level 3: ',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 50,
                              child: TextField(
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(0.0),
                                  isDense: true,
                                ),
                                onChanged: (String value) {
                                  setState(() {
                                    tempLv3Set = value;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 10,),
                            ElevatedButton(
                              onPressed: () {
                                try {
                                  if(tempLv3Set != '') {
                                    client.write('temp3=' + tempLv3Set + '\r');
                                    sleep(Duration(milliseconds: 10));
                                  }
                                  //client.flush();
                                  setState(() {

                                  });
                                } catch(e) {
                                  print('Error' + e);
                                }

                              },
                              child: Text('Apply'),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(Colors.blueGrey),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Humidity thresh: ',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 50,
                              child: TextField(
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(0.0),
                                  isDense: true,
                                ),
                                onChanged: (String value) {
                                  setState(() {
                                    humidityThreshSet = value;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 10,),
                            ElevatedButton(
                              onPressed: () {
                                try {
                                  if(humidityThreshSet != '') {
                                    client.write('humi=' + humidityThreshSet + '\r');
                                    sleep(Duration(milliseconds: 10));
                                  }
                                  //client.flush();
                                  setState(() {

                                  });
                                } catch(e) {
                                  print('Error' + e);
                                }

                              },
                              child: Text('Apply'),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(Colors.blueGrey),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                      ],
                    ),
                  ],
                )
                    : SizedBox(height: 0),
                (serverConnected && autoMode) ? Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Pump time: ',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 50,
                          child: TextField(
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(0.0),
                              isDense: true,
                            ),
                            onChanged: (String value) {
                              setState(() {
                                tempLv3Set = value;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 10,),
                        ElevatedButton(
                          onPressed: () {
                            try {
                              if(tempLv3Set != '') {
                                client.write('pump=' + tempLv3Set + '\r');
                                sleep(Duration(milliseconds: 10));
                              }
                              //client.flush();
                              setState(() {

                              });
                            } catch(e) {
                              print('Error' + e);
                            }

                          },
                          child: Text('Apply'),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.blueGrey),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Fan time: ',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 50,
                          child: TextField(
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(0.0),
                              isDense: true,
                            ),
                            onChanged: (String value) {
                              setState(() {
                                humidityThreshSet = value;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 10,),
                        ElevatedButton(
                          onPressed: () {
                            try {
                              if(humidityThreshSet != '') {
                                client.write('fan=' + humidityThreshSet + '\r');
                                sleep(Duration(milliseconds: 10));
                              }
                              //client.flush();
                              setState(() {

                              });
                            } catch(e) {
                              print('Error' + e);
                            }

                          },
                          child: Text('Apply'),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.blueGrey),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                  ],
                ): SizedBox(height: 0),
                /*Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Subscribe status',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      subscribeText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: subscribeColor,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Door',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      Text(doorText),
                      const SizedBox(width: 10),
                      doorIcon,
                    ],
                  ),
                ),*/
              ],
            ),
          ),
        ),
      ),
    );
  }
}
