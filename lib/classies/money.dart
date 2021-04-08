class money {


  String uid;// كود من يريد تقفيل الحساب
  String date;// تاريخ تقفيل الحساب
  String price;//اجمالى مبلغ الاوردارات المسلمه
  String delivery;// اجمالى مبلغ الشحن
  String phone;//رقم تليفون من يريد تقفيل الحساب
  String name;//اسم من يريد تقفيل الحساب
  String delivering_on_seller_count;//عدد الاوردارات شحن على الراسل
  String delivered_count;//عدد الاوردارات المسلمه

  money(this.uid, this.date, this.price, this.delivery,this.name,this.phone);
  money.delivery(this.uid, this.date, this.price,this.name,this.phone,this.delivered_count,this.delivering_on_seller_count);

}