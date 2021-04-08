import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'classies/person.dart';
import 'home.dart';



class Person_info extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _Person_info();
  }


}

class _Person_info extends State<Person_info>{

  String comp_name="";
  String comp_id='comp_id';
  String comp_phone =""  ;
  String comp_city ="";
  String comp_address ="";
  DocumentReference doc_ref ;
  bool show_ui =false; // show seller or delivery search
  String msg = '';
  TextEditingController search_controller = TextEditingController();
  List<person> search_list = [];

  get_data(){

    doc_ref = FirebaseFirestore.instance.collection('companies').doc(comp_id);
    doc_ref.get().then((snapshot){
      setState(() {

        comp_name =  snapshot.data()['name'];
        comp_phone = snapshot.data()['phone'];
        comp_city = snapshot.data()['city'];
        comp_address = snapshot.data()['address'];
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(comp_name,style: TextStyle(fontSize: 20,color: Colors.black),),
                  SizedBox(width: 20,),
                  Icon(Icons.person,color: Colors.black,size: 20,)
                ],
              ),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(comp_phone,style: TextStyle(fontSize: 20,color: Colors.black),),
                  SizedBox(width: 20,),
                  Icon(Icons.phone,color: Colors.black,size: 20,)
                ],
              ),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(comp_city,style: TextStyle(fontSize: 20,color: Colors.black),),
                  SizedBox(width: 20,),
                  Icon(Icons.person_pin_circle,color: Colors.black,size: 20,)
                ],
              ),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(comp_address,style: TextStyle(fontSize: 20,color: Colors.black),),
                  SizedBox(width: 20,),
                  Icon(Icons.map,color: Colors.black,size: 20,)
                ],
              ),
              SizedBox(height: 20,),
              RaisedButton(
                color:  Colors.black ,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.black)
                ),
                child: Text("تعديل البيانات",style: TextStyle(fontSize: 25,color: Colors.white,fontWeight: FontWeight.bold),),
                onPressed: (){
                  update_info();
                },
              ),
              SizedBox(height: 40,),
              FlatButton(
                color:  Colors.black.withOpacity(0) ,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("مشاهدة العملاء",style: TextStyle(fontSize: 25,color: Colors.black,fontWeight: FontWeight.bold),),
                    Icon(Icons.remove_red_eye,color: Colors.black,size: 30,)
                  ],
                ),
                onPressed: (){
                  setState(() {
                    search_list..clear();
                    search_controller.text='';
                    show_ui=true;
                    msg = 'العميل';
                  });
                },
              ),
              SizedBox(height: 20,),
              FlatButton(
                color:  Colors.black.withOpacity(0) ,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("مشاهدة المناديب",style: TextStyle(fontSize: 25,color: Colors.black,fontWeight: FontWeight.bold),),
                    Icon(Icons.remove_red_eye,color: Colors.black,size: 30,)
                  ],
                ),
                onPressed: (){
                  setState(() {
                    search_list.clear();
                    search_controller.text='';
                    show_ui=true;
                    msg = 'المندوب';
                  });
                },
              ),
              SizedBox(height: 15,),

              show_ui? show_ui_detailes() : Container(),
            ],
          ),
        ) ,
      ),
    );
  }

  /*----------------show seller or delivery search ui ------------*/
  Widget show_ui_detailes(){
    return Column(
      children: [

        Padding(
          padding: const EdgeInsets.all(40),
          child: TextFormField(
            controller: search_controller,
            decoration: InputDecoration(hintText: ' اسم '+msg,
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              suffixIcon: Icon(Icons.search,color: Colors.black,size: 30,),
            ),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20,color: Colors.black),
            onChanged: (value){
              if(value.isNotEmpty) {
                CollectionReference coll_ref;
                if (msg == 'العميل')
                  coll_ref = doc_ref.collection('sellers');
                else
                  coll_ref = doc_ref.collection('deliveries');

                coll_ref.orderBy('name').startAt(
                    [search_controller.text.toUpperCase()]).endAt(
                    [search_controller.text.toUpperCase() + '\uf8ff'])
                    .startAt([search_controller.text]).endAt(
                    [search_controller.text + '\uf8ff']).get().then((snap_shot) {
                  if (snap_shot.docs.isNotEmpty) {
                    search_list.clear();
                    snap_shot.docs.forEach((element) {
                      setState(() {
                        if (msg == 'العميل')
                          search_list.add(person.seller(
                              element.data()['name'], element.data()['phone'],
                              element.id, element.data()['delivery_fee']));
                        else
                          search_list.add(person.delivery(
                              element.data()['name'], element.data()['phone'],element.id ));
                      });
                    });
                  }
                });
              }
            },
          ),
        ),

        SizedBox(height: 20,),
        Container(
          height: 400,
          child: ListView.builder(
              itemCount: search_list.length,
              itemBuilder: (context,index){
                return GestureDetector(
                    child: card_Style(search_list[index].phone, search_list[index].name,search_list[index].uid , index),
                    onTap: (){
                      if(msg == 'العميل')
                        show_city_delivery_price_dialog(index);
                    },
                );
              }),
        )
      ],
    );
  }

  Widget card_Style(String phone, String name , String uid , index) {

    return Padding(
        padding: EdgeInsets.all(20),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 10,
          child: Column(
            children: [
              
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
                  ),
                  RaisedButton(
                      color:  Colors.black ,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(color: Colors.black)
                      ),
                      child: Text('حذف',style: TextStyle(fontSize: 20,color: Colors.red),textAlign: TextAlign.center,),
                      onPressed: (){
                        show_delete_dialog(name,uid ,index);
                      })
                ],
              ),

              SizedBox(height: 20,),
            ],
          ),

        )
    );

  }
  
  show_delete_dialog(String name , String uid , index){

    showDialog(
        context: context,
        builder: (context) {
      bool waiting = false;
      return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
                title: Text('حذف'),
                content: Center(
                  child: Column(
                      children: [
                        Text('هل تريد حقا حذف',style: TextStyle(fontSize: 20,color: Colors.red),textAlign: TextAlign.center,),
                        Text(name,style: TextStyle(fontSize: 20,color: Colors.red),textAlign: TextAlign.center,),
                        SizedBox(height: 20,),
                        waiting?CircularProgressIndicator():Container(),
                      ]),
                ),
            actions: [
              FlatButton(
                color:  Colors.black ,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.black)
                ),
                child:Text('حذف',style: TextStyle(fontSize: 20,color: Colors.red),textAlign: TextAlign.center,),
                onPressed: (){

                  if(msg == 'العميل') {
                    setState((){
                      waiting = true;
                      doc_ref.collection('sellers').doc(uid).delete().whenComplete((){
                        FirebaseFirestore.instance.collection('sellers').doc(uid).collection('companies')
                            .doc(comp_id).delete().whenComplete((){  delete_ui(index); });
                      });

                    });
                  }else{
                    setState((){
                      waiting = true;
                      doc_ref.collection('deliveries').doc(uid).delete().whenComplete((){
                        FirebaseFirestore.instance.collection('deliveries').doc(uid).collection('companies')
                            .doc(comp_id).delete().whenComplete((){ delete_ui(index); });
                      });

                    });
                  }
                },
              )
             ],
            );
          });
    });

  }

  delete_ui(index){
    setState(() {
      show_ui = true;
      search_list.removeAt(index);
      Navigator.pop(context);
    });
  }

  /*------------- update function---------------*/
   update_info(){

     showDialog(
        context: context,
        builder: (context) {
       TextEditingController phone_controller = TextEditingController();
       TextEditingController city_controller = TextEditingController();
       TextEditingController address_controller = TextEditingController();
       String msg = "";
       bool waiting = false;
       phone_controller.text = comp_phone;
       address_controller.text = comp_address;
       city_controller.text = comp_city;
       return StatefulBuilder(
           builder: (context, setState) {
             return AlertDialog(
               title: Text('تعديل بيانات'),
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

                   TextFormField(
                     decoration: InputDecoration(hintText: 'المحافظه',
                       focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                           borderRadius: BorderRadius.all(Radius.circular(30))),
                       enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                           borderRadius: BorderRadius.all(Radius.circular(30))),

                     ),
                     textAlign: TextAlign.center,
                     style: TextStyle(color: Colors.black,fontSize: 20),
                     controller: city_controller,

                   ),

                   TextFormField(
                     decoration: InputDecoration(hintText: 'العنوان',
                       focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                           borderRadius: BorderRadius.all(Radius.circular(30))),
                       enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                           borderRadius: BorderRadius.all(Radius.circular(30))),

                     ),
                     textAlign: TextAlign.center,
                     style: TextStyle(color: Colors.black,fontSize: 20),
                     controller: address_controller,

                   ),

                   waiting? CircularProgressIndicator():Text(msg,style: TextStyle(fontSize: 20,color: Colors.black),),

                ],
               )),
                actions: [
                  FlatButton(
                    color:  Colors.black ,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(color: Colors.black)
                    ),
                      child: Text("تعديل البيانات",style: TextStyle(fontSize: 25,color: Colors.white,fontWeight: FontWeight.bold),),
                      onPressed: (){
                        if(phone_controller.text.isNotEmpty){
                          if(city_controller.text.isNotEmpty){
                            if(address_controller.text.isNotEmpty){
                              setState((){
                                waiting=true;
                              });
                              doc_ref.update({
                                'phone':phone_controller.text,
                                'city':city_controller.text,
                                'address':address_controller.text,
                              }).whenComplete((){
                                comp_phone = phone_controller.text;
                                comp_address = address_controller.text;
                                comp_city = city_controller.text;
                                update_ui();
                                Navigator.pop(context);
                              });
                            }else{
                              setState((){
                                msg = 'يجب كتابة العنوان الخاص بالشركه';
                              });
                            }
                          }else{
                            setState((){
                              msg = 'يجب كتابة المحافظه الخاصه بالشركه';
                            });
                          }
                        }else{
                          setState((){
                            msg = 'يجب كتابة التليفون الخاص بالشركه';
                          });
                        }
                      },
                  )
                ],
             );
           });
     });

  }

  update_ui(){
    setState(() {
       comp_phone =comp_phone;
       comp_city = comp_city;
       comp_address = comp_address;
    });
  }

  //-------------show dialog contain all city delivery price for seller and update it--------\\
  show_city_delivery_price_dialog(int index){

    showDialog(
        context: context,
        builder: (context) {
      String msg = "";
      bool waiting = false;
      List<String> city = ['شحن على الراسل','القاهره','الجيزه','القليوبيه','الاسكندريه','البحيره','مطروح','الدقهليه','كفر الشيخ','الغربيه','المنوفيه','دمياط',
      'بورسعيد','الإسماعيليه','السويس','الشرقيه','بني سويف','المنيا','الفيوم','أسيوط' ,'سوهاج' ,'قنا','الأقصر','أسوان','الوادي الجديد','شمال سيناء','جنوب سيناء','البحر الأحمر'];
      String selected_city ;
      TextEditingController delivery = TextEditingController();
      Map<String,dynamic> city_delivery_map ={};

      if(search_list[index].delivery_fee !=null)
        city_delivery_map.addAll(search_list[index].delivery_fee);

      List<String> keys =city_delivery_map.keys.toList();
      for(int i=0 ; i<keys.length;i++){
        city.remove(keys[i]);
      }
      return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
                title: Text('تحديد سعر الشحن '),
                content:  Column(
                  children: [
                  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0,vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        border: Border.all(
                            color:  Colors.black, style: BorderStyle.solid, width: 2),
                      ),
                      child: DropdownButton(
                          hint: Text('اختار المحافظه',style: TextStyle(fontSize: 20,color: Colors.black),),
                          items: city.map((statuse) => DropdownMenuItem <String>(child: Text(statuse,style: TextStyle(fontSize: 20,color: Colors.black)
                            ,textAlign: TextAlign.center,), value: statuse,)).toList(),
                          value: selected_city ,
                          onChanged: (value){
                            setState(() {
                              selected_city = value;
                            });
                          }),
                    ),

                    SizedBox(width: 10,),

                    Flexible(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: delivery,
                        decoration: InputDecoration(hintText: ' سعر الشحن',
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                              borderRadius: BorderRadius.all(Radius.circular(30))),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                              borderRadius: BorderRadius.all(Radius.circular(30))),
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20,color: Colors.black),
                      ),
                    ),

                  ],
                ),

                  waiting?CircularProgressIndicator():Text(msg,style: TextStyle(fontSize: 20,color: Colors.black),),
                  SizedBox(height: 20,),
                  FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(color: Colors.black)
                      ),
                      child: Text("اضافة المحافظه",style: TextStyle(fontSize: 20,color: Colors.white),),
                      color: Colors.black,
                      onPressed: (){
                        if(delivery.text.isNotEmpty)
                          setState((){
                            city_delivery_map[selected_city]= delivery.text;
                            keys.add(selected_city);
                            String temp = selected_city;
                            if(city.length-1 != 0){
                              if(city.indexOf(selected_city)==city.length-1)
                                selected_city = city[0];
                              else if(city.indexOf(selected_city)== 0)
                                selected_city = city[1];
                              else
                                selected_city = city[0];
                            }else{  // if i select last element in city list , add ' ' and remove item from list
                              city.insert(0,' ');
                              selected_city = city[0];
                            }
                            city.remove(temp);
                            delivery.text='';
                          });
                        else
                          setState((){
                            msg = 'يجب ادخال سعر الشحن للمحافظه';
                          });
                      },
                      ),

                  SizedBox(height: 30,),
                  Container(
                    width: 400,
                    height: 220,
                    child: ListView.builder(
                        itemCount:keys.length,
                        itemBuilder: (context,i){
                          return GestureDetector(
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Card(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 10,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(keys[i],style: TextStyle(fontSize: 20,color: Colors.black),),
                                    Text(city_delivery_map[keys[i]],style: TextStyle(fontSize: 20,color: Colors.black),)
                                  ],
                                ),
                              ),
                            ),
                            onTap: (){
                               setState((){
                                 city.add(keys[i]);
                                 selected_city = keys[i];
                                 city_delivery_map.remove(keys[i]);
                                 delivery.text = '';
                               });
                            },
                          );
                        }),
                  ),

                  ],),
              actions: [
                FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.black)
                  ),
                  child: Text("اضافة المحافظات للعميل",style: TextStyle(fontSize: 20,color: Colors.white),textAlign: TextAlign.center,),
                  color: Colors.black,
                  onPressed: (){

                      setState(() {
                        waiting = true;
                      });
                      doc_ref.collection('sellers').doc(search_list[index].uid).set({
                        'delivery_fee':city_delivery_map,
                        'name':search_list[index].name,
                        'phone':search_list[index].phone
                      }).whenComplete(() {
                         print('hhhhh');
                        if(search_list[index].delivery_fee !=null)
                            search_list[index].delivery_fee.clear();

                        search_list[index].delivery_fee.addAll(city_delivery_map);
                        Navigator.pop(context);
                      });

                  },
                )
              ],
            );
          });
    });

  }

 }
