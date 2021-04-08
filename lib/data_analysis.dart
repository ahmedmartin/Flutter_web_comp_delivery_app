import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'home.dart';

class Data_analysis extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _Data_analysis();
  }


}

class _Data_analysis extends State<Data_analysis>{

  CollectionReference coll_ref;
  List<String> date_list=[];
  List<String> city_list = ['القاهره','الجيزه','القليوبيه','الإسكندريه','البحيره','مطروح','الدقهليه','كفر الشيخ','الغربيه','المنوفيه','دمياط',
  'بورسعيد','الإسماعيليه','السويس','الشرقيه','بني سويف','المنيا','الفيوم','أسيوط' ,'سوهاج' ,'قنا','الأقصر','أسوان','الوادي الجديد','شمال سيناء','جنوب سيناء','البحر الأحمر'];
  String comp_id = 'comp_id';
  String selected_date;
  String selected_city;
  bool show_data = false;
  int all_orders_count = 0;
  double orders_price = 0;
  double delivery_fee = 0;
  int orders_delivered=0;
  int orders_canceled = 0;
  int orders_sha7n_rasel =0;
  int orders_mortg3_goz2 = 0;

  get_dates(){
    coll_ref = FirebaseFirestore.instance.collection('companies').doc(comp_id).collection('orders');
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

    return WillPopScope(onWillPop: ()async=>Navigator.push(context, MaterialPageRoute(builder: (c)=> Home())),
    child: Scaffold(
     backgroundColor: Colors.white60,
      body:SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(

            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                            if(selected_city!=null)
                              get_data();
                            else
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("اختار المحافظه",style: TextStyle(fontSize: 40),textAlign: TextAlign.center,),
                                backgroundColor: Colors.black,
                              ));
                          });
                        }),
                  ),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15.0,vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      border: Border.all(
                          color:  Colors.black, style: BorderStyle.solid, width: 2),
                    ),
                    child: DropdownButton(
                        hint: Text('اختار المحافظه',style: TextStyle(fontSize: 20,color: Colors.black),),
                        items: city_list.map((statuse) => DropdownMenuItem <String>(child: Text(statuse,style: TextStyle(fontSize: 20,color: Colors.black)
                          ,textAlign: TextAlign.center,), value: statuse,)).toList(),
                        value: selected_city ,
                        onChanged: (value){
                          setState(() {
                            selected_city = value;
                            if(selected_date!=null)
                              get_data();
                            else
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("اختار التاريخ",style: TextStyle(fontSize: 40),textAlign: TextAlign.center,),
                                backgroundColor: Colors.black,
                              ));
                          });
                        }),
                  ),
                ],
              ),

              show_data?
                   Draw_analysis()
                  : Center(child: Image(image:NetworkImage('https://www.jonmgomes.com/wp-content/uploads/2020/03/Magnifying-Glass-Research-Icon.gif'))),

            ],

          ),
        ),
      ) ,

    ),

    );
  }

  get_data(){
      coll_ref.doc(selected_date).collection('all').where('cust_city',isEqualTo:selected_city).get().then((snapshot){

            if(snapshot.docs.isNotEmpty) {

               all_orders_count = snapshot.docs.length;
               orders_price = 0;
               delivery_fee = 0;
               orders_delivered = 0;
               orders_canceled = 0;
               orders_sha7n_rasel = 0;
               orders_mortg3_goz2 = 0;
               snapshot.docs.forEach((element) {
                 switch (element.data()['cust_status']) {
                   case 'استلم' :
                     {
                       orders_delivered += 1;
                       orders_price += double.parse(element.data()['cust_delivery_price']);
                       delivery_fee += double.parse(element.data()['cust_delivery_fee']) +
                               double.parse(element.data()['cust_delivery_fee_plus']);
                       break;
                     }
                   case 'مرتجع جزئى' :
                     {
                       orders_mortg3_goz2 += 1;
                       orders_price += double.parse(element.data()['cust_delivery_price']);
                       delivery_fee +=
                           double.parse(element.data()['cust_delivery_fee']) +
                               double.parse(element.data()['cust_delivery_fee_plus']);
                       break;
                     }
                   case 'لاغى':
                     {
                       orders_canceled += 1;
                       break;
                     }
                   case 'شحن على الراسل':
                     {
                       orders_sha7n_rasel += 1;
                       delivery_fee +=
                           double.parse(element.data()['cust_delivery_fee']);
                       break;
                     }
                 }
               });
               setState(() {
                 show_data = true;
               });
             }
      });

  }

 Widget Draw_analysis(){
    return
       Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Container(height: 30,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CircularPercentIndicator(
                  radius: 130.0,
                  animation: true,
                  animationDuration: 2000,
                  lineWidth: 15.0,
                  percent: orders_delivered/all_orders_count,
                  center: new Text(orders_delivered.toString()+'/'+all_orders_count.toString(), style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                  circularStrokeCap: CircularStrokeCap.butt,
                  backgroundColor: Colors.grey.shade100,
                  progressColor: Colors.black,
                  footer: Text('استلم',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.black),),
                ),

                CircularPercentIndicator(
                  radius: 130.0,
                  animation: true,
                  animationDuration: 2000,
                  lineWidth: 15.0,
                  percent: orders_canceled/all_orders_count,
                  center: new Text(orders_canceled.toString()+'/'+all_orders_count.toString(), style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                  circularStrokeCap: CircularStrokeCap.butt,
                  backgroundColor: Colors.grey.shade100,
                  progressColor: Colors.black,
                  footer: Text('لاغى',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.black),),
                ),
              ],
            ),

            Container(height: 30,),

           /* Container(height: 30,),
            Center(
              child: CircularPercentIndicator(
                radius: 130.0,
                animation: true,
                animationDuration: 2000,
                lineWidth: 15.0,
                percent: orders_wait/all_orders.length,
                center: new Text(orders_wait.toString(), style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                ),
                circularStrokeCap: CircularStrokeCap.butt,
                backgroundColor: Colors.white,
                progressColor: Colors.black,
                footer: Text('مؤجل',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.black),),
              ),
            ),*/

            Row(
               mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CircularPercentIndicator(
                  radius: 130.0,
                  animation: true,
                  animationDuration: 2000,
                  lineWidth: 15.0,
                  percent: orders_sha7n_rasel/all_orders_count,
                  center: new Text(orders_sha7n_rasel.toString()+'/'+all_orders_count.toString(), style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                  circularStrokeCap: CircularStrokeCap.butt,
                  backgroundColor: Colors.grey.shade100,
                  progressColor: Colors.black,
                  footer: Text('شحن على الراسل',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.black),),
                ),

                CircularPercentIndicator(
                  radius: 130.0,
                  animation: true,
                  animationDuration: 2000,
                  lineWidth: 15.0,
                  percent: orders_mortg3_goz2/all_orders_count,
                  center: new Text(orders_mortg3_goz2.toString()+'/'+all_orders_count.toString(), style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                  circularStrokeCap: CircularStrokeCap.butt,
                  backgroundColor: Colors.grey.shade100,
                  progressColor: Colors.black,
                  footer: Text('مرتجع جزئى',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.black),),
                ),
              ],
            ),

           /* Container(height: 30,),
            Center(
              child: CircularPercentIndicator(
                radius: 130.0,
                animation: true,
                animationDuration: 3000,
                lineWidth: 20.0,
                percent: orders_ked_tanfez/all_orders.length,
                center: new Text(orders_ked_tanfez.toString(), style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                ),
                circularStrokeCap: CircularStrokeCap.butt,
                backgroundColor: Colors.white,
                progressColor: Colors.black,
                footer: Text('قيد التنفيذ',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.black),),
              ),
            ),*/

            Container(height: 30,),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(orders_price.toString(),style: TextStyle(fontSize: 20,color: Colors.black),),
                  Text(" : اجمالى التحصيل",style: TextStyle(fontSize: 25,color: Colors.black,fontWeight: FontWeight.bold),)
                ],
              ),
            ),

            Container(height: 30,),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(delivery_fee.toString(),style: TextStyle(fontSize: 20,color: Colors.black),),
                  Text(" : اجمالى الشحن",style: TextStyle(fontSize: 25,color: Colors.black,fontWeight: FontWeight.bold),)
                ],
              ),
            ),

            Container(height: 30,),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text((orders_price-delivery_fee).toString(),style: TextStyle(fontSize: 20,color: Colors.black),),
                  Text(" : الاجمالى",style: TextStyle(fontSize: 25,color: Colors.black,fontWeight: FontWeight.bold),)
                ],
              ),
            ),

            Container(height: 30,),

          ],
        ),
    );
 }

}