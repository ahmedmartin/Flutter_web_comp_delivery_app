import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'checkout_delivery.dart';
import 'classies/money.dart';
import 'home.dart';


class Seller_history extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _Seller_history();
  }


}

class _Seller_history extends State<Seller_history>{

  String comp_id='comp_id';
  List<String> date_list =[];
  List<money> search_list = [];
  CollectionReference coll_ref;
  get_dates(){
    coll_ref = FirebaseFirestore.instance.collection('companies').doc(comp_id).collection('money');
    coll_ref.get().then((QuerySnapshot snapshot){
      snapshot.docs.forEach((element) {
        setState(() {
          date_list.add(element.id);
        });
        print(date_list.toString());
        });
    });
  }

  @override
  void initState() {
    super.initState();
    get_dates();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => Navigator.push(context, MaterialPageRoute(builder: (context) => Home())),
      child: Scaffold(
       body:
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                 search_row(),
                Expanded(
                  child: ListView.builder(
                      itemCount: search_list.length,
                      itemBuilder: (context,index){
                        return card_Style(search_list[index].phone, search_list[index].name, search_list[index].date,index );
                      }
                  ),
                ),
              ],
            ),
          )
      ),

    );
  }

  Widget card_Style(String phone, String name, String date ,int index) {

    double price = double.parse(search_list[index].price);
    double delivery = double.parse(search_list[index].delivery);

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 30,),
                  Row(
                    children: [
                      Text((price-delivery).toString() ,style: TextStyle(fontSize: 20,color: Colors.black),),
                      Icon(Icons.account_balance_wallet,color: Colors.black,),
                    ],
                  ),
                  //SizedBox(width: 20,),
                  Row(
                    children: [
                      Text(delivery.toString() ,style: TextStyle(fontSize: 20,color: Colors.red),),
                      Icon(Icons.shopping_cart,color: Colors.red,),
                    ],
                  ),
                  //SizedBox(width: 20,),
                  Row(
                    children: [
                      Text(price.toString() ,style: TextStyle(fontSize: 20,color: Colors.green),),
                      Icon(Icons.attach_money,color: Colors.green,),
                    ],
                  ),
                  SizedBox(width: 20,),
                ],
              ),
              SizedBox(height: 20,),

            ],
          ),

        )
    );

  }

  String selected_date;
  TextEditingController search_controller = TextEditingController();
  Widget search_row(){
      return
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
                  hint: Text('اختار التاريخ',style: TextStyle(fontSize: 20,color: Colors.black),),
                  items: date_list.map((statuse) => DropdownMenuItem <String>(child: Text(statuse,style: TextStyle(fontSize: 20,color: Colors.black)
                    ,textAlign: TextAlign.center,), value: statuse,)).toList(),
                  value: selected_date ,
                  onChanged: (value){
                    setState(() {
                      selected_date = value;
                      if(search_controller.text.isNotEmpty)
                        get_data();
                      else
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("اختار اسم العميل",style: TextStyle(fontSize: 40),textAlign: TextAlign.center,),
                          backgroundColor: Colors.black,
                        ));
                    });
                  }),
            ),

            SizedBox(width: 10,),

            Flexible(
              child: TextFormField(
                controller: search_controller,
                decoration: InputDecoration(hintText: ' الاسم',
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  suffixIcon: Icon(Icons.search,color: Colors.black,size: 30,),
                ),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20,color: Colors.black),
                onChanged: (value){
                    if(search_controller.text.isNotEmpty)
                      get_data();
                    else
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("اختار اسم العميل",style: TextStyle(fontSize: 40),textAlign: TextAlign.center,),
                        backgroundColor: Colors.black,
                      ));
                },
              ),
            ),

          ],
        );

  }


  get_data(){
    coll_ref.doc(selected_date).collection('all').orderBy('name').startAt([search_controller.text.toUpperCase()]).endAt([search_controller.text.toUpperCase()+ '\uf8ff']).startAt([search_controller.text]).endAt([search_controller.text+ '\uf8ff'])//.where('name', isGreaterThanOrEqualTo: search_controller.text)
        .get().then((snap_shot){
          if(snap_shot.docs.isNotEmpty){
            search_list.clear();
            snap_shot.docs.forEach((element) {
              setState(() {
                search_list.add(money(element.id,selected_date,element.data()['price'],element.data()['delivery']
                    ,element.data()['name'], element.data()['phone']));
              });

            });
          }
        });

  }

}
