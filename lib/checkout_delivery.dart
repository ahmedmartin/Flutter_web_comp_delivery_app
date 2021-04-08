
import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_db_web_unofficial/DatabaseSnapshot.dart';
import 'package:firebase_db_web_unofficial/firebasedbwebunofficial.dart';
import 'package:flutter/material.dart';

import 'classies/money.dart';
import 'home.dart';

class Checkout extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _Checkout();
  }


}

class _Checkout extends State<Checkout>{




    StreamSubscription <DatabaseSnapshot> adds;
    StreamSubscription <DatabaseSnapshot> updates;
    List<money> money_list = [];
    String comp_id = 'comp_id';
    DatabaseRef ref ;
    get_data()async{
      /* await FirebaseFirestore.instance.collection('companies').doc('comp_id').collection('money').
         .get().then((QuerySnapshot value){
          value.docs.forEach((element) {print(element['name']);});
     });*/
      // .get().then((snapshot) {print(snapshot.exists);});
      ref= FirebaseDatabaseWeb.instance.reference().child('companies').child(comp_id).child('delivery_money');
      adds = ref.onChildAdded.listen((data) {
        if(data.value!=null) {
          Map map = data.value;
          map.forEach((key, value) {
            setState(() {
              money_list.insert(0, money.delivery(key, data.key, value['orders_price'], value['name'], value['phone'],
                  value['delivered_count'], value['delivering_on_seller_count']));
            });
          });
        }
      });

      updates = ref.onChildChanged.listen((data) {
        Map map = data.value;
        map.forEach((key, value) {
          money temp =  money.delivery(key, data.key, value['orders_price'], value['name'], value['phone']
              ,value['delivered_count'],value['delivering_on_seller_count']);
          // check if he find the same object in list don't add to list
          if(!money_list.any((element) => (element.date==temp.date&&element.phone==temp.phone&&element.name==temp.name))) {
            setState(() {
              money_list.insert(0, temp);
            });
          }
        });
      });

    }

    @override
    void initState() {
      super.initState();
      get_data();

    }

  @override
  Widget build(BuildContext context) {

      return WillPopScope(
        onWillPop: () async => Navigator.push(context, MaterialPageRoute(builder: (context) => Home())),
        child: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(10),
            child:money_list.length==0?
            Center(child: Image(image: NetworkImage("https://thumbs.gfycat.com/UnselfishDiligentAlligatorgar-max-1mb.gif"),height: 300,width: 300,))
                : ListView.builder(
                itemCount: money_list.length,
                itemBuilder: (context,index){
                  return GestureDetector(
                    child: card_Style(money_list[index].phone,money_list[index].name,money_list[index].date),
                    onTap: (){
                      show_detailes(index);
                    },
                  );
                }),


          ),

        ),
      );
  }

    Widget card_Style(String phone, String name, String date) {

      return Padding(
          padding: EdgeInsets.all(20),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 10,
            child: Column(
              children: [
                SizedBox(height: 20,),
                Center(child: Text(date,style: TextStyle(fontSize: 20,color: Colors.black),),),

                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Text(phone ,style: TextStyle(fontSize: 20,color: Colors.black),),
                        Icon(Icons.phone,color: Colors.black,)
                      ],
                    ),
                    Row(
                      children: [
                        Text(name ,style: TextStyle(fontSize: 20,color: Colors.black),),
                        Icon(Icons.person,color: Colors.black,),
                      ],
                    )
                  ],
                ),

                SizedBox(height: 20,),


              ],
            ),

          )
      );

    }


    show_detailes(index){

      showDialog(
          context: context,
          builder: (BuildContext context) {
            TextEditingController delivering_price_controller= TextEditingController();
            TextEditingController delivering_on_seller_price_controller = TextEditingController();
            double pricee = double.parse(money_list[index].price);
            double deliver_count = double.parse(money_list[index].delivered_count);
            double deliver_on_seller_count = double.parse(money_list[index].delivering_on_seller_count);
            double deliver =0;
            double deliver_on_seller =0;
            String msg = "";
            bool waiting = false;
            return StatefulBuilder(
                builder: (context, setState){
                  return BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child:  AlertDialog(
                        title:  Text('التقفيل'),
                        content:SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              TextFormField(
                                keyboardType:TextInputType.number,
                                decoration: InputDecoration(hintText: 'سعر الشحن',
                                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                                      borderRadius: BorderRadius.all(Radius.circular(30))),
                                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                                      borderRadius: BorderRadius.all(Radius.circular(30))),

                                ),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black,fontSize: 20),
                                controller: delivering_price_controller,
                                onChanged: (String value){
                                  setState(() {
                                    deliver = double.parse(value)*deliver_count;
                                  });
                                },
                              ),
                              SizedBox(height: 20,),
                              TextFormField(
                                keyboardType:TextInputType.number,
                                decoration: InputDecoration(hintText: 'سعر الشحن على الراسل',
                                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                                      borderRadius: BorderRadius.all(Radius.circular(30))),
                                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                                      borderRadius: BorderRadius.all(Radius.circular(30))),

                                ),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black,fontSize: 20),
                                controller: delivering_on_seller_price_controller,
                                onChanged: (String value){
                                  setState(() {
                                    deliver_on_seller = double.parse(value)*deliver_on_seller_count;
                                  });
                                },
                              ),

                              waiting?CircularProgressIndicator():Text(msg,style: TextStyle(color: Colors.red),),
                              SizedBox(height: 20,),

                              Row(
                                children: [
                                  Icon(Icons.person,color: Colors.black,),
                                  Text(money_list[index].name ,style: TextStyle(fontSize: 25,color: Colors.black),),
                                ],
                              ),

                              SizedBox(height: 20,),
                              Row(
                                children: [
                                  Icon(Icons.attach_money,color: Colors.black,),
                                  Text(pricee.toString() ,style: TextStyle(fontSize: 25,color: Colors.black),),

                                ],
                              ),

                              SizedBox(height: 20,),
                              Row(
                                children: [
                                  Icon(Icons.shopping_cart,color: Colors.black,),
                                  Text(deliver.toString() ,style: TextStyle(fontSize: 25,color: Colors.black),),

                                ],
                              ),

                              SizedBox(height: 20,),
                              Row(
                                children: [
                                  Icon(Icons.remove_shopping_cart,color: Colors.black,),
                                  Text(deliver_on_seller.toString() ,style: TextStyle(fontSize: 25,color: Colors.black),),

                                ],
                              ),

                              SizedBox(height: 20,),
                              Row(
                                children: [
                                  Icon(Icons.account_balance_wallet,color: Colors.black,),
                                  Text((pricee-deliver-deliver_on_seller).toString() ,style: TextStyle(fontSize: 25,color: Colors.black),),

                                ],
                              )
                            ],
                          ),
                        ),
                        actions: [

                          FlatButton(
                            padding: EdgeInsets.all(20),
                            child: Text('تقفيل الحساب',style: TextStyle(fontSize: 20,color: Colors.white),),
                            onPressed: (){
                              if(delivering_on_seller_price_controller.text.isNotEmpty) {
                                if(delivering_price_controller.text.isNotEmpty) {
                                  setState(() {
                                    waiting=true;
                                  });
                                  DocumentReference r = FirebaseFirestore.instance.collection('companies').doc(comp_id).collection('delivery_money').doc(money_list[index].date);
                                  r.set({" ":" "}).whenComplete((){
                                    r.collection('all').doc(money_list[index].uid).set({
                                      'name':money_list[index].name,
                                      'phone':money_list[index].phone,
                                      'price':money_list[index].price,
                                      'delivery':(deliver+deliver_on_seller).toString()
                                    }).whenComplete((){
                                      ref.child(money_list[index].date).child(money_list[index].uid).remove().whenComplete(() {
                                        remove_from_array(index);
                                      });

                                    });

                                  });

                                }else{
                                  setState(() {
                                    msg = 'يجب ادخال سعر الشحن';
                                  });
                                }
                              }else{
                                setState(() {
                                  msg = 'يجب ادخال سعر الشحن على الراسل';
                                });
                              }
                            },
                            color: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(color: Colors.black)
                            ),

                          )
                        ],

                      ));
                });
          });
    }

  void remove_from_array(index) {
    setState(() {
      money_list.removeAt(index);
      Navigator.pop(context);
    });
  }

   @override
  void deactivate() {
     updates.cancel();
     adds.cancel();
    super.deactivate();
  }


}