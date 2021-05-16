import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

import 'classies/order.dart';
import 'home.dart';





class Orders_history extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _Orders_history();
  }

}

class _Orders_history extends State<Orders_history>{

  String comp_id = 'comp_id';
  String selected_city;
  String selected_date;
  List<order> all_order_list =[];
  List<order> search_order_list =[];
  TextEditingController controller_cust_phone = TextEditingController();
  List<String> city_list = ['القاهره','الجيزه','القليوبيه','الاسكندريه','البحيره','مطروح','الدقهليه','كفر الشيخ','الغربيه','المنوفيه','دمياط',
  'بورسعيد','الإسماعيليه','السويس','الشرقيه','بني سويف','المنيا','الفيوم','أسيوط' ,'سوهاج' ,'قنا','الأقصر','أسوان','الوادي الجديد','شمال سيناء','جنوب سيناء','البحر الأحمر'];
 List<String> date_list = [];

  CollectionReference order_ref ;

  get_data(){
    order_ref.doc(selected_date).collection('all').where('cust_city',isEqualTo: selected_city ).get().then((snapshot){
      snapshot.docs.forEach((element) {
        order Order = order(element['cust_name'], element['cust_phone'], element['cust_city'], element['cust_address'],
            element['cust_price'], element['cust_note'], element['seller_id'], element['delivery_fee_plus'],element.id,element['statuse']);
        setState(() {
          if(element['delivery_id']!= null) Order.delivery_id = element['delivery_id'];
          if(element['cust_delivery_price']!= null) Order.cust_delivery_price = element['cust_delivery_price'];
          all_order_list.add(Order);
          search_order_list.add(Order);
        });
      });
    });
  }
  
  get_date(){
   order_ref = FirebaseFirestore.instance.collection('companies').doc(comp_id).collection('orders');
   order_ref.get().then((snapshot){
     snapshot.docs.forEach((element) { 
       setState(() {
         date_list.add(element.id);
       });
     });
   });
  }
  
  @override
  void initState() {
    get_date();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: ()async=>Navigator.push(context, MaterialPageRoute(builder: (c)=> Home())),
        child: Scaffold(
          body: Column(
            children: [
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  DropdownButton(
                      hint: Text('اختار المحافظه',style: TextStyle(fontSize: 20,color: Colors.black),),
                      items: city_list.map((statuse) => DropdownMenuItem <String>(child: Text(statuse,style: TextStyle(fontSize: 20,color: Colors.black)
                        ,textAlign: TextAlign.center,), value: statuse,)).toList(),
                      value: selected_city ,
                      onChanged: (value){
                        setState(() {
                          selected_city = value;
                          if(selected_date != null) {
                            search_order_list.clear();
                            all_order_list.clear();
                            get_data();
                          }
                        });
                      }),
                  
                  DropdownButton(
                      hint: Text('اختار التاريخ',style: TextStyle(fontSize: 20,color: Colors.black),),
                      items: date_list.map((statuse) => DropdownMenuItem <String>(child: Text(statuse,style: TextStyle(fontSize: 20,color: Colors.black)
                        ,textAlign: TextAlign.center,), value: statuse,)).toList(),
                      value: selected_date ,
                      onChanged: (value){
                        setState(() {
                          selected_date = value;
                          if(selected_city!=null) {
                            search_order_list.clear();
                            all_order_list.clear();
                            get_data();
                          }
                        });
                      }),
                ],
              ),
              TextFormField(
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(hintText: 'تليفون العميل',
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      suffixIcon: Icon(Icons.search,size: 30,color: Colors.black,)
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black,fontSize: 20),
                  controller: controller_cust_phone,
                  onChanged: (value){

                    setState(() {
                      search_order_list.clear();
                      // search for cust phone number
                      search_order_list.addAll(all_order_list.where((element) => element.cust_phone.contains(value)));
                    });

                  }),
              SizedBox(height: 20,),
              Flexible(
                  child: ListView.builder(
                      itemCount: search_order_list.length,
                      itemBuilder: (context,index){
                        return GestureDetector(
                          child: Row_style(index,search_order_list[index].cust_name,search_order_list[index].cust_phone, search_order_list[index].cust_address,
                              search_order_list[index].cust_note, search_order_list[index].cust_price, search_order_list[index].cust_city,
                              search_order_list[index].delivery_fee_plus,search_order_list[index].statuse,search_order_list[index].cust_delivery_price),

                          onTap: (){
                            show_seller_info(index);
                          },
                        );
                      }

                  )),
            ],
          ),
        )
    );
  }


  Widget Row_style(index,cust_name,cust_phone,cust_address,cust_note,cust_price,String cust_city,delivery_fee_plus,statuse,delivery_price){

    return Card(
      color:Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 8,
      shadowColor: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(statuse,style: TextStyle(fontSize: 20,color: Colors.black),),
                    SizedBox(width: 10,),
                    Icon(Icons.assignment,color: Colors.black,size: 30,)
                  ],
                ),
                Row(
                  children: [
                    FlatButton(
                      color: Colors.black.withOpacity(0),
                      child: Text("عرض بيانات التاجر",style: TextStyle(fontSize: 20,color: Colors.black),),
                      onPressed: (){
                        show_seller_info(index);
                      },),
                    Icon(Icons.remove_red_eye,color: Colors.black,size: 30,)
                  ],
                ),
              ],
            ),
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(cust_note,style: TextStyle(fontSize: 20,color: Colors.black),),
                    SizedBox(width: 10,),
                    Icon(Icons.message,color: Colors.black,size: 30,)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(cust_name , style: TextStyle(fontSize: 20,color: Colors.black),),
                    Icon(Icons.person,color: Colors.black,size: 30,)
                  ],
                )

              ],
            ),

            //--------------------------------------------------------------------------------

            Container(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(cust_phone , style: TextStyle(fontSize: 20,color: Colors.black),),
                    Icon(Icons.phone,color: Colors.black,size: 30,)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(cust_city, style: TextStyle(fontSize: 20,color: Colors.black),textAlign: TextAlign.center,),
                    Icon(Icons.map,color: Colors.black,size: 30,)
                  ],
                )

              ],
            ),

            //---------------------------------------------------------------------------------

            Container(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(cust_address,style: TextStyle(fontSize: 20,color: Colors.black),),
                Icon(Icons.person_pin_circle,color: Colors.black,size: 30,)
              ],
            ),

            Container(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(delivery_fee_plus,style: TextStyle(fontSize: 20,color: Colors.red),),
                    SizedBox(width: 10,),
                    Icon(Icons.add_shopping_cart,color: Colors.red,size: 30,)
                  ],
                ),
                Row(
                  children: [
                    FlatButton(
                      color: Colors.black.withOpacity(0),
                      child: Text(delivery_price,style: TextStyle(fontSize: 20,color: Colors.green),),
                      onPressed: (){
                        show_update_delivery_price(index);
                      },),
                    Icon(Icons.monetization_on,color: Colors.green,size: 30,)
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(cust_price,style: TextStyle(fontSize: 20,color: Colors.black),),
                    SizedBox(width: 10,),
                    Icon(Icons.attach_money,color: Colors.black,size: 30,)
                  ],
                ),

              ],
            ),

          ],
        ),
      ),
    );
  }

  show_seller_info(int index){

    showDialog(
        context: context,
        builder: (context) {
          String selectedseller="";
          String seller_phone="";
          String seller_name = '';
          bool update = false;
          List<order> seller_name_list = [];
          return StatefulBuilder(
              builder: (context, setState) {
                FirebaseFirestore.instance.collection('sellers').doc(search_order_list[index].seller_id).get().then((snapshot){
                  setState((){
                    seller_name = snapshot.data()['name'];
                    seller_phone= snapshot.data()['phone'];
                  });
                });
                return AlertDialog(
                  title: Text('بيانات التاجر'),
                  content: Center(
                    child: Column(
                      children: [
                        update ? SearchableDropdown.single(
                          items: seller_name_list.map((val){
                            return DropdownMenuItem(child: Text(val.seller_name),value: val.seller_name,);
                          }).toList(),
                          value: selectedseller,
                          hint: "اختار التاجر",
                          searchHint: "اختار التاجر",
                          onChanged: (value) {
                            setState(() {
                              selectedseller = value;
                            });
                          },
                          isExpanded: true,
                        ):
                        FlatButton(
                          onPressed:(){
                            FirebaseFirestore.instance.collection('companies').doc(comp_id)
                                .collection('sellers').get().then((snapshot){
                              snapshot.docs.forEach((element) {
                                setState((){
                                  seller_name_list.add(order.info(element['name'], element.id));
                                  update = true;
                                });
                              });
                            });
                          },
                          child: Row(
                            children: [
                              Icon(Icons.person),
                              Text(seller_name, style: TextStyle(fontSize: 30,color: Colors.black),textAlign: TextAlign.center,),
                            ],
                          ),
                        ),
                        SizedBox(height: 20,),
                        Row(
                          children: [
                            Icon(Icons.phone),
                            Text(seller_phone, style: TextStyle(fontSize: 30,color: Colors.black),textAlign: TextAlign.center,),
                          ],
                        ),
                      ],
                    ),
                  ),

                  actions: [
                    FlatButton(
                        child: Text('تعديل التاجر',
                          style: TextStyle(fontSize: 30, color: Colors.white),
                          textAlign: TextAlign.center,),
                        color: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(color: Colors.black)
                        ),
                        onPressed: () {
                          if(selectedseller.isNotEmpty ) {
                            search_order_list[index].seller_id = seller_name_list[seller_name_list.indexWhere((item) => item.seller_name == selectedseller)].seller_id;
                            order_ref.doc(selected_date).collection('all').doc(search_order_list[index].order_id)
                                .update(search_order_list[index].to_map()).whenComplete(() => Navigator.pop(context));
                          }
                        })
                  ],
                );
              });
        });

  }

  show_update_delivery_price(int index){

    showDialog(context: context,
    builder: (context){
      TextEditingController controller_delivery_price = TextEditingController();
      controller_delivery_price.text = search_order_list[index].cust_delivery_price;
      return AlertDialog(
        title:Text('سعر المستلم'),
        content: Center(
          child:TextFormField(
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(hintText: 'سعر الاستلام',
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  suffixIcon: Icon(Icons.search,size: 30,color: Colors.black,)
              ),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black,fontSize: 20),
              controller: controller_delivery_price,
          ) ,
        ),
        actions: [
          FlatButton(
              child: Text('تعديل سعر الاستلام',
                style: TextStyle(fontSize: 30, color: Colors.white),
                textAlign: TextAlign.center,),
              color: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(color: Colors.black)
              ),
              onPressed: () {
                  search_order_list[index].cust_delivery_price = controller_delivery_price.text;
                  order_ref.doc(selected_date).collection('all').doc(search_order_list[index].order_id)
                      .update(search_order_list[index].to_map()).whenComplete((){ setState(() {
                          Navigator.pop(context);
                          search_order_list = search_order_list;
                      });});
              })
        ],
      );
    });
  }



}