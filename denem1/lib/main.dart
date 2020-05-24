import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_html/flutter_html.dart';

void main() {
  runApp(new MaterialApp(
    home:new Basla(),
  ));
}
class Basla extends StatefulWidget {
  @override
  _BaslaState createState() => _BaslaState();
}

class _BaslaState extends State<Basla> {
  List data;
  String origin="";
  String destination="";
  bool vis=false;
  List<double>points=[0.0,0.0,0.0,0.0,41.015137, 28.979530];
  String end="";
  String start="";
  String distance="";
  TextEditingController corgin=new TextEditingController();
  TextEditingController cdestination=new TextEditingController();
  MapController conMap=new MapController();
  double zoom=10.0;
  @override
  void initState() {
    super.initState();
  }
  Future<String> getJsonData() async{
    print(origin);
    String url="https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=AIzaSyDtwCm5qw7S7ruArmqyZxE-pyIs4b9bNcs";
    destination="";
    origin="";
    var response= await http.get(url);
    setState(() {
      var condata=jsonDecode(response.body);
      if(condata['routes'].length==0){
        data=condata['routes'];
        return"Fail";
      }

      print("burdaya da ugradıkkkkk");
      data=condata['routes'][0]['legs'][0]['steps'];
      String z=data[1]['html_instructions'];
      points[0]=condata['routes'][0]['legs'][0]['start_location']['lat'];
      points[1]=condata['routes'][0]['legs'][0]['start_location']['lng'];
      points[2]=condata['routes'][0]['legs'][0]['end_location']['lat'];
      points[3]=condata['routes'][0]['legs'][0]['end_location']['lng'];
      points[4]=(points[0]+points[2])/2;
      points[5]=(points[1]+points[3])/2;
      vis=true;
      print("PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP");
      print(points[0]);
      print(points[2]);

      double zoomval=findzoomvalue();
      end=condata['routes'][0]['legs'][0]['start_address'];
      start=condata['routes'][0]['legs'][0]['end_address'];
      distance=condata['routes'][0]['legs'][0]['distance']['text'];
      distance+=" "+condata['routes'][0]['legs'][0]['duration']['text'];
      data.insert(0, {distance: "distance value"});
      conMap.move(new LatLng(points[4],points[5]),zoomval);
    });
    return "Success";
  }
  findzoomvalue(){
    setState(() {
      double temp=points[1]-points[3];
      temp=temp.abs();
      if((points[0]-points[2]).abs()>temp)temp=(points[0]-points[2]).abs();
      zoom=3.3633*pow(temp,4)-23.5786*pow(temp,3)+33.3932*pow(temp,2)-20.3420*temp+13.8023;
      print(zoom);
      if(zoom<7)zoom=5;
      if(zoom>15)zoom=5;
    }
    );
    return zoom;
  }
  zoomin(){
    setState(() {
      zoom+=0.5;
      conMap.move(new LatLng(points[4],points[5]),zoom);
    });
  }
  zoomout(){
    setState(() {
      zoom-=0.5;
      conMap.move(new LatLng(points[4],points[5]),zoom);
    });
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: new AppBar(
        title: new Text("Take Home Project"),
      ),
      body: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Center(


            child:new TextField(
              controller: corgin,
              decoration: new InputDecoration(
                hintText: "Enter Origin"
              ),
              onChanged:(String str){
                origin=str;
              },
            ),
          ),
          new Center(
            child: new TextField(
              controller: cdestination,
              decoration: new InputDecoration(
                  hintText: "Enter Destination"
              ),
              onChanged: (String str){
                setState(() {
                  destination = str;
                });
              },
            ),
          ),
          new RaisedButton(
            onPressed: (){
              cdestination.text="";
              corgin.text="";
              if(origin!=""&& destination!="")this.getJsonData();
            },
            child: new Text("Get Destination"),
          ),

          new Stack(
            children: <Widget>[


              new Center(child:
                new Container(
                  width: 300.0,
                  height:230.0,
                  child: new FlutterMap(
                    mapController: conMap,
                    options: new MapOptions(
                      center: new LatLng(points[4], points[5]), zoom: 10,
                    ),
                    layers: [
                      new TileLayerOptions(
                          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c']
                      ),
                      new MarkerLayerOptions(
                        markers: [
                          new Marker(
                            width: 80.0,
                            height: 80.0,
                            point: new LatLng(points[0], points[1]),
                            builder: (ctx) =>
                            new Container(
                              child: new Icon(Icons.location_on,color: Colors.black,),
                            ),
                          ),
                          new Marker(
                            width: 80.0,
                            height: 80.0,
                            point: new LatLng(points[2], points[3]),
                            builder: (ctx) =>
                            new Container(
                              child: new Icon(Icons.location_on,color:Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: vis,
                child: Positioned(
                  top: 185,
                  left: 45,
                  child:new IconButton(
                    tooltip: "Zoom in",
                    icon: Icon(Icons.zoom_in),
                    onPressed: (){zoomin();},
                  ),),

              ),
              Visibility(
                visible: vis,
                child: Positioned(
                  top: 185,
                  left: 70,
                  child:new IconButton(
                    tooltip: "Zoom in",
                    icon: Icon(Icons.zoom_out),
                    onPressed: (){zoomout();},
                  ),),

              ),

            ],
          ),

          new Visibility(
            visible: vis,
            child: new Expanded(
              child: new ListView.builder(
                itemCount: data==null ? 0 : data.length,
                itemBuilder:(BuildContext context,int index){
                  if(index ==0){return new Card(
                    child: new Container(
                      padding: EdgeInsets.all(8.0),
                      child:
                      new Text("Orgin: $end \nDestination: $start  Duration: $distance"),),);
                  }
                  else{
                  return new Container(
                    child:new Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        new Card(
                          child: new Column(
                            children: <Widget>[
                              new Text(data[index]['distance']['text']+" / "+data[index]['duration']['text']),
                              new Html(data: data[index]['html_instructions']),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                  }
                },
              ),
          ),
          ),
        ],
      ),

    );
  }
}
