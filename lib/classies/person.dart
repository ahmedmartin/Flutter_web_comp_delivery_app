
/*
['القاهره','الجيزه','القليوبيه','الإسكندريه','البحيره','مطروح','الدقهليه','كفر الشيخ','الغربيه','المنوفيه','دمياط',
  'بورسعيد','الإسماعيليه','السويس','الشرقيه','بني سويف','المنيا','الفيوم','أسيوط' ,'سوهاج' ,'قنا','الأقصر','أسوان','الوادي الجديد','شمال سيناء','جنوب سيناء','البحر الأحمر'];
 */
class person{

  String name;
  String phone;
  String uid;
  Map<String,dynamic> delivery_fee = {};



  person.seller(this.name, this.phone,this.uid,this.delivery_fee);

  person.delivery(this.name, this.phone,this.uid);


}