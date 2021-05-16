import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'classies/order.dart';
import 'home.dart';


class Current_orders extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _Current_orders();
  }

}

class _Current_orders extends State<Current_orders>{

  String comp_id = 'comp_id';
  String selected_city;
  List<order> all_order_list =[];
  List<order> search_order_list =[];
  TextEditingController controller_cust_phone = TextEditingController();
  List<String> city_list = ['القاهره','الجيزه','القليوبيه','الاسكندريه','البحيره','مطروح','الدقهليه','كفر الشيخ','الغربيه','المنوفيه','دمياط',
  'بورسعيد','الإسماعيليه','السويس','الشرقيه','بني سويف','المنيا','الفيوم','أسيوط' ,'سوهاج' ,'قنا','الأقصر','أسوان','الوادي الجديد','شمال سيناء','جنوب سيناء','البحر الأحمر'];


  get_data(){
    FirebaseFirestore.instance.collection('companies').doc(comp_id).collection('waiting_orders')
        .where('cust_city',isEqualTo: selected_city ).get().then((snapshot){
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: ()async=>Navigator.push(context, MaterialPageRoute(builder: (c)=> Home())),
        child: Scaffold(
          body: Column(
            children: [
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton(
                      hint: Text('اختار المحافظه',style: TextStyle(fontSize: 20,color: Colors.black),),
                      items: city_list.map((statuse) => DropdownMenuItem <String>(child: Text(statuse,style: TextStyle(fontSize: 20,color: Colors.black)
                        ,textAlign: TextAlign.center,), value: statuse,)).toList(),
                      value: selected_city ,
                      onChanged: (value){
                        setState(() {
                          selected_city = value;
                          search_order_list.clear();
                          all_order_list.clear();
                          get_data();
                        });
                      }),

                  Flexible(
                    child: TextFormField(
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
                  ),
                ],
              ),
              SizedBox(height: 20,),
              Flexible(
                  child: ListView.builder(
                      itemCount: search_order_list.length,
                      itemBuilder: (context,index){
                        return GestureDetector(
                          child: Row_style(index,search_order_list[index].cust_name,search_order_list[index].cust_phone, search_order_list[index].cust_address,
                              search_order_list[index].cust_note, search_order_list[index].cust_price, search_order_list[index].cust_city,
                              search_order_list[index].delivery_fee_plus,search_order_list[index].statuse),

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


  Widget Row_style(index,cust_name,cust_phone,cust_address,cust_note,cust_price,String cust_city,delivery_fee_plus,statuse){

    return Card(
      color:Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 8,
      shadowColor: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(cust_price,style: TextStyle(fontSize: 20,color: Colors.green),),
                    SizedBox(width: 10,),
                    Icon(Icons.attach_money,color: Colors.green,size: 30,)
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(cust_note,style: TextStyle(fontSize: 20,color: Colors.black),),
                    SizedBox(width: 10,),
                    Icon(Icons.message,color: Colors.black,size: 30,)
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
                              FirebaseFirestore.instance.collection('companies').doc(comp_id).collection('waiting_orders')
                                  .doc(search_order_list[index].order_id).update(search_order_list[index].to_map())
                                  .whenComplete(() => Navigator.pop(context));
                            }
                          })
                    ],
                );
              });
        });

  }


}