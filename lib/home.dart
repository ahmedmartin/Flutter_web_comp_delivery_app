import 'dart:async';
import 'dart:html';
import 'dart:ui';
import 'package:Ra7al_Company/profile_info.dart';
import 'package:Ra7al_Company/seller_history.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_db_web_unofficial/DatabaseSnapshot.dart';
import 'package:flutter/material.dart';
import 'checkout_delivery.dart';
import 'classies/money.dart';
import 'package:firebase_db_web_unofficial/firebasedbwebunofficial.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'current_orders.dart';
import 'data_analysis.dart';
import 'delivery_history.dart';
import 'login.dart';
import 'orders_history.dart';


class Home extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _Home();
  }


}

class _Home extends State<Home>{

  StreamSubscription <DatabaseSnapshot> adds;
  StreamSubscription <DatabaseSnapshot> updates;
  List<money> money_list = [];
  String comp_id = 'comp_id';
  DatabaseRef ref ;
  CollectionReference coll_ref ;
  get_data()async{

    ref= FirebaseDatabaseWeb.instance.reference().child('companies').child(comp_id).child('money');
    adds = ref.onChildAdded.listen((data) {
      Map map = data.value;
      map.forEach((key, value) {
        setState(() {
          money_list.insert(0, money(key, data.key, value['orders_price'], value['orders_delivery'], value['name'], value['phone']));

        });
      });
    });

    updates = ref.onChildChanged.listen((data) {
      Map map = data.value;
      map.forEach((key, value) {
        money temp =  money(key, data.key, value['orders_price'], value['orders_delivery'], value['name'], value['phone']);
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

    return
       Scaffold(
           drawer: Drawer(
             child: ListView(
               padding: EdgeInsets.all(10),
               children: [
                 Draw_header(),
                 SizedBox(height: 20,),
                 FlatButton(
                     color: Colors.white.withOpacity(0),
                     child: Text('تقفيل المناديب',style: TextStyle(fontSize: 20,color: Colors.black,fontWeight: FontWeight.bold),),
                     onPressed: (){
                       Navigator.of(context).push(MaterialPageRoute(builder: (c)=> Checkout()));
                     }),
                 SizedBox(height: 20,),
                 FlatButton(
                   color: Colors.white.withOpacity(0),
                   child: Text('سجل تحصيل العملاء',style: TextStyle(fontSize: 20,color: Colors.black,fontWeight: FontWeight.bold),),
                     onPressed: (){
                       Navigator.push(context, MaterialPageRoute(builder: (context) => Seller_history()));
                     }),
                 SizedBox(height: 20,),
                 FlatButton(
                     color: Colors.white.withOpacity(0),
                     child: Text('سجل تحصيل المناديب',style: TextStyle(fontSize: 20,color: Colors.black,fontWeight: FontWeight.bold),),
                     onPressed: (){
                       Navigator.push(context, MaterialPageRoute(builder: (context) => Delivery_history()));
                     }),

                 SizedBox(height: 20,),
                 FlatButton(
                     color: Colors.white.withOpacity(0),
                     child: Text('تحليل النتائج',style: TextStyle(fontSize: 20,color: Colors.black,fontWeight: FontWeight.bold),),
                     onPressed: (){
                         Navigator.push(context, MaterialPageRoute(builder: (c)=> Data_analysis()));
                     }),
                 SizedBox(height: 20,),
                 FlatButton(
                     color: Colors.white.withOpacity(0),
                     child: Text('اضافة عميل جديد',style: TextStyle(fontSize: 20,color: Colors.black,fontWeight: FontWeight.bold),),
                     onPressed: (){
                         add_seller();
                     }),
                 SizedBox(height: 20,),
                 FlatButton(
                     color: Colors.white.withOpacity(0),
                     child: Text('اضافة مندوب جديد',style: TextStyle(fontSize: 20,color: Colors.black,fontWeight: FontWeight.bold),),
                     onPressed: (){
                         add_delivery();
                     }),
                 SizedBox(height: 20,),
                 FlatButton(
                     color: Colors.white.withOpacity(0),
                     child: Text('انشاء رحله جديده',style: TextStyle(fontSize: 20,color: Colors.black,fontWeight: FontWeight.bold),),
                     onPressed: (){
                       coll_ref = FirebaseFirestore.instance.collection('companies').doc(comp_id).collection('orders');
                       coll_ref.where('last_date',isEqualTo: 'yes').get().then((snapshot){
                           snapshot.docs.forEach((element) {
                             create_new_travel(element.id);
                           });
                       });
                     }),
                 SizedBox(height: 20,),
                 FlatButton(
                     color: Colors.white.withOpacity(0),
                     child: Text('متابعه الاوردارات',style: TextStyle(fontSize: 20,color: Colors.black,fontWeight: FontWeight.bold),),
                     onPressed: (){
                       Navigator.push(context, MaterialPageRoute(builder: (c)=> Current_orders()));
                     }),
                 SizedBox(height: 20,),
                 FlatButton(
                     color: Colors.white.withOpacity(0),
                     child: Text('سجل الاوردارات',style: TextStyle(fontSize: 20,color: Colors.black,fontWeight: FontWeight.bold),),
                     onPressed: (){
                       Navigator.push(context, MaterialPageRoute(builder: (c)=> Orders_history()));
                     }),
                 SizedBox(height: 20,),
                 FlatButton(
                     color: Colors.white.withOpacity(0),
                     child: Text('الملف الشخصى',style: TextStyle(fontSize: 20,color: Colors.black,fontWeight: FontWeight.bold),),
                     onPressed: (){
                       Navigator.push(context, MaterialPageRoute(builder: (c)=> Person_info()));
                     }),
                 SizedBox(height: 40,),
                 FlatButton(
                     color: Colors.white.withOpacity(0),
                     child: Text('تسجيل الخروج',style: TextStyle(fontSize: 20,color: Colors.black,fontWeight: FontWeight.bold),),
                     onPressed: () async {
                       await FirebaseAuth.instance.signOut().whenComplete((){
                         Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (c)=>Login()), (route) => false);
                       });
                     }),
               ],
             ),
           ),
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text('Ra7al',style: TextStyle(fontSize: 35,color: Colors.white),textAlign: TextAlign.center,),

          ),

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

      );

  }

  Widget Draw_header(){
    return DrawerHeader(
      decoration: BoxDecoration(color: Colors.black),
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        //mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(height: 100,
            width: 110,
            child:CircleAvatar(backgroundImage: NetworkImage("https://images.squarespace-cdn.com/content/v1/5c528d9e96d455e9608d4c63/1586379635937-DUGHB6LHU59QIVDH2QHZ/ke17ZwdGBToddI8pDm48kHTW22EZ3GgW4oVLBBkxXg1Zw-zPPgdn4jUwVcJE1ZvWQUxwkmyExglNqGp0IvTJZUJFbgE-7XRK3dMEBRBhUpwEg94W6zd8FBNj5MCw-Ij7INTc0XdOQR2FYhNzGmPXJN9--qDehzI3YAaYB5CQ-LA/Hiker.gif?format=500w"),),
          ),

          SizedBox(width: 20,),

          Expanded(
            child: Text('Ra7al',style: TextStyle(fontSize: 30,color: Colors.white,fontWeight: FontWeight.bold),),
          ),

        ],
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


              SizedBox(height: 20,)

            ],
          ),

       )
    );
    
  }


  show_detailes(index){

    double pricee = double.parse(money_list[index].price);
    double deliver = double.parse(money_list[index].delivery);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          bool wait = false;
          return StatefulBuilder(builder: (context,setState){
            return BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child:  AlertDialog(
                  title:  Text('التقفيل'),
                  content:Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 10,),
                      wait?CircularProgressIndicator():Container(),
                      Row(
                        children: [
                          Icon(Icons.person,color: Colors.black,),
                          Text(money_list[index].name ,style: TextStyle(fontSize: 25,color: Colors.black),),
                        ],
                      ),

                      SizedBox(height: 20,),
                      Row(
                        children: [
                          Icon(Icons.attach_money,color: Colors.green,),
                          Text(pricee.toString() ,style: TextStyle(fontSize: 25,color: Colors.green),),

                        ],
                      ),

                      SizedBox(height: 20,),
                      Row(
                        children: [
                          Icon(Icons.shopping_cart,color: Colors.red,),
                          Text(deliver.toString() ,style: TextStyle(fontSize: 25,color: Colors.red),),

                        ],
                      ),

                      SizedBox(height: 20,),
                      Row(
                        children: [
                          Icon(Icons.account_balance_wallet,color: Colors.black,),
                          Text((pricee-deliver).toString() ,style: TextStyle(fontSize: 25,color: Colors.black),),

                        ],
                      )
                    ],
                  ),
                  actions: [

                    FlatButton(
                      padding: EdgeInsets.all(20),
                      child: Text('تقفيل الحساب',style: TextStyle(fontSize: 20,color: Colors.white),),
                      onPressed: (){
                        setState(() {
                          wait = true;
                        });
                        DocumentReference r= FirebaseFirestore.instance.collection('companies').doc(comp_id).collection('money').doc(money_list[index].date);
                        r.set({" ":" "}).whenComplete((){
                          r.collection('all').doc(money_list[index].uid).set({
                            'name':money_list[index].name,
                            'phone':money_list[index].phone,
                            'price':money_list[index].price,
                            'delivery':money_list[index].delivery
                          }).whenComplete((){
                            FirebaseFirestore.instance.collection('sellers').doc(money_list[index].uid).collection('money')
                                .doc('all').collection(comp_id).doc(money_list[index].date).set({
                              'statuse':'تم تقفيل الحساب'
                            }).whenComplete((){
                              ref.child(money_list[index].date).child(money_list[index].uid).remove().whenComplete((){
                                update_ui(index);

                              });

                            });

                          });

                        });

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

  update_ui(int index){
    setState(() {
      money_list.removeAt(index);
      Navigator.pop(context);
    });
  }

// add delivery alart dialog (have set state to rebuild dialog every time)
 void add_delivery(){

   showDialog(
     context: context,
     builder: (context) {
       TextEditingController phone_controller =  TextEditingController() ;
       String msg= "";
       bool waiting = false;
       return StatefulBuilder(
         builder: (context, setState) {
           return AlertDialog(
             title: Text('اضافة مندوب جديد'),
             content: Center(
             child: Column(
             children: [
             TextFormField(
             keyboardType:TextInputType.number,
             decoration: InputDecoration(hintText: 'التليفون',
               focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                   borderRadius: BorderRadius.all(Radius.circular(30))),
               enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                   borderRadius: BorderRadius.all(Radius.circular(30))),

             ),
             textAlign: TextAlign.center,
             style: TextStyle(color: Colors.black,fontSize: 20),
             controller: phone_controller,
           ),

           waiting?CircularProgressIndicator():Text(msg),

           SizedBox(height: 30,),
           FlatButton(
           color:  Colors.black ,
           shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(10.0),
           side: BorderSide(color: Colors.black)
           ),
           onPressed: (){
           if(phone_controller.text.isNotEmpty) {

             if (phone_controller.text.length == 11) {
               setState(() {
                 waiting = true;
               });
               FirebaseDatabaseWeb.instance.reference().child('waiting_list').child('delivery')
                   .child(phone_controller.text).set('comp_id,comp_name').whenComplete(() {
                 setState(() {
                   waiting = false;
                   phone_controller.text = "";
                   msg = 'تم اضافة المندوب بنجاح يجب على المندوب تسجيل الدخول الان';
                 });
               });
             } else {
               setState(() {
                 msg = 'يجب ان يكون التليفون مكون من 11 رقم ';
               });
             }
           }else {
             setState(() {
               msg = 'يجب اضافة رقم تليفون المندوب';
             });
           }
           },
           child: Text('اضافه مندوب',style: TextStyle(fontSize: 20,color: Colors.white),),
           )
           ],
           )));
         },
       );
     },
   );

 }

 add_seller(){
   showDialog(
     context: context,
     builder: (context) {
       TextEditingController phone_controller =  TextEditingController() ;
       String msg= "";
       bool waiting = false;
       return StatefulBuilder(
         builder: (context, setState) {
           return AlertDialog(
               title: Text('اضافة عميل جديد'),
               content: Center(
                   child: Column(
                     children: [
                       TextFormField(
                         keyboardType:TextInputType.number,
                         decoration: InputDecoration(hintText: 'التليفون',
                           focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                               borderRadius: BorderRadius.all(Radius.circular(30))),
                           enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                               borderRadius: BorderRadius.all(Radius.circular(30))),

                         ),
                         textAlign: TextAlign.center,
                         style: TextStyle(color: Colors.black,fontSize: 20),
                         controller: phone_controller,
                       ),

                       waiting?CircularProgressIndicator():Text(msg),

                       SizedBox(height: 30,),
                       FlatButton(
                         color:  Colors.black ,
                         shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(10.0),
                             side: BorderSide(color: Colors.black)
                         ),
                         onPressed: (){
                           if(phone_controller.text.isNotEmpty) {

                             if (phone_controller.text.length == 11) {
                               setState(() {
                                 waiting = true;
                               });
                               FirebaseDatabaseWeb.instance.reference().child('waiting_list').child('seller')
                                   .child(phone_controller.text).set('comp_id,comp_name').whenComplete(() {
                                 setState(() {
                                   waiting = false;
                                   phone_controller.text = "";
                                   msg = 'تم اضافة العميل بنجاح يجب على العميل تسجيل الدخول و اضافة الشركه';
                                 });
                               });
                             } else {
                               setState(() {
                                 msg = 'يجب ان يكون التليفون مكون من 11 رقم ';
                               });
                             }
                           }else {
                             setState(() {
                               msg = 'يجب اضافة رقم تليفون العميل';
                             });
                           }
                         },
                         child: Text('اضافه عميل',style: TextStyle(fontSize: 20,color: Colors.white),),
                       )
                     ],
                   )));
         },
       );
     },
   );
 }


  create_new_travel(String date){
    showDialog(context: context, builder: (context) {
      String date_selected ;
      return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
                title: Text('انشاء رحله جديده'),
                content: Center(
                  child: Column(
                    children: [
                      Text('هل تريد غلق الرحله القديمه ',style: TextStyle(fontSize: 20),),
                      Text(date,style: TextStyle(fontSize: 20),),
                      Text('و انشاء رحله جديده ؟',style: TextStyle(fontSize: 20),),
                      SizedBox(height: 20,),
                      RaisedButton(
                        color:  Colors.black ,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(color: Colors.black)
                        ),
                        onPressed: () async {
                          DateTime picked = await showDatePicker(
                              context: context,
                              initialDate: new DateTime.now(),
                              firstDate: new DateTime(2016),
                              lastDate: new DateTime.now()
                          );
                          if(picked != null) setState(() => date_selected = picked.toString().split(' ')[0]);
                        },
                        child: Text(date_selected!=null?date_selected:'اختار تاريخ الرحله الجديده',style: TextStyle(color: Colors.white,fontSize: 25),),
                      ),
                    ],
                  ),
                ),
              actions: [
                FlatButton(
                  color:  Colors.black ,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.black)
                  ),
                  child: Text('انشاء',style: TextStyle(color: Colors.white,fontSize: 25),),
                  onPressed: (){
                    if(date_selected != null) {
                      coll_ref.doc(date_selected).set({'last_date': 'yes'});
                      coll_ref.doc(date).update({'last_date': 'no'}).whenComplete(() {
                        Navigator.pop(context);
                      });
                    }
                  },
                )
              ],
            );
          });
    });
  }


}
